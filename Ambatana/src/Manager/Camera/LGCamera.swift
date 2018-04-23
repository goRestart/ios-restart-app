//
//  LGCamera.swift
//  LetGo
//
//  Created by Álvaro Murillo del Puerto on 7/3/18.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import UIKit
import AVFoundation

private typealias CapturePhotoOutput = AVCaptureOutput & CapturePhotoOutputProtocol

final class LGCamera: Camera {

    private let session: AVCaptureSession = AVCaptureSession()
    private let sessionQueue: DispatchQueue = DispatchQueue(label: "camera.manager.session.queue")
    private var isSetup: Bool = false
    private let previewView: CameraPreviewView = CameraPreviewView()
    private var currentInputVideoDevice: AVCaptureDeviceInput?
    private let frontCamera: AVCaptureDevice? = AVCaptureDevice.defaultFrontCameraDevice()
    private let backCamera: AVCaptureDevice? = AVCaptureDevice.defaultBackCameraDevice()
    private let motionDeviceOrientation: MotionDeviceOrientation = MotionDeviceOrientation()
    private let capturePhotoOutput: CapturePhotoOutput
    private let videoRecorder: VideoRecorder = VideoRecorder()
    private var pixelsBufferForwarder: PixelsBufferForwarder?

    var flashMode: CameraFlashState? {
        set { if let flashMode = newValue { updateFlashMode(flashMode.asFlashMode()) }}
        get { return currentInputVideoDevice?.device.flashMode.asCameraFlashState() }
    }

    var cameraPosition: CameraSource? {
        get { return currentInputVideoDevice?.device.position.cameraSource() }
        set { if let source = newValue { changeToCamera(source: source) } }
    }

    var cameraMode: CameraMode = .photo {
        didSet {
            sessionQueue.async {
                self.session.beginConfiguration()
                self.configureOutputs()
                self.session.commitConfiguration()
            }
        }
    }

    var isReady: Bool {
        return isSetup && session.isRunning
    }

    var hasFlash: Bool {
        return currentInputVideoDevice?.device.hasFlash ?? false
    }

    var hasFrontCamera: Bool {
        return frontCamera != nil
    }

    var hasBackCamera: Bool {
        return backCamera != nil
    }

    private(set) var isAttached: Bool = false

    var isRecording: Bool {
        return videoRecorder.isRecording
    }

    var recordingDuration: TimeInterval {
        return videoRecorder.recordingDuration
    }

    convenience init() {
        let capturePhotoOutput: CapturePhotoOutput
        if #available(iOS 10.0, *) {
            capturePhotoOutput = LGCapturePhotoOutput()
        } else {
            capturePhotoOutput = LGCaptureStillImageOutput()
        }
        self.init(capturePhotoOutput: capturePhotoOutput)
    }

    private init(capturePhotoOutput: CapturePhotoOutput) {
        self.capturePhotoOutput = capturePhotoOutput
    }

    func pause() {
        session.stopRunning()
    }

    func resume() {
        if !isSetup {
            setup()
        } else if !session.isRunning {
            session.startRunning()
        }
    }

    func addPreviewLayerTo(view: UIView) {
        guard !view.subviews.contains(previewView) else { return }

        view.addSubviewForAutoLayout(previewView)

        previewView.videoPreviewLayer.videoGravity = .resizeAspectFill
        previewView.session = session

        previewView.layout(with: view).fill()

        let statusBarOrientation = UIApplication.shared.statusBarOrientation

        if let videoOrientation = AVCaptureVideoOrientation(interfaceOrientation: statusBarOrientation) {
            previewView.videoPreviewLayer.connection?.videoOrientation = videoOrientation
        }

        isAttached = true
    }

    func toggleCamera() {
        guard let currentCamera = currentInputVideoDevice?.device else { return }
        if currentCamera == self.frontCamera {
            changeToCamera(source: .rear)
        } else if currentCamera == self.backCamera {
            changeToCamera(source: .front)
        }
    }

    func capturePhoto(completion: @escaping CameraPhotoCompletion) {
        guard session.outputs.contains(capturePhotoOutput) else {
            completion(CameraPhotoResult(error: .internalError(message: "")))
            return
        }

        let settings = PhotoSettings(flashMode: flashMode?.asFlashMode() ?? .auto)
        let deviceOrientation = motionDeviceOrientation.orientation
        capturePhotoOutput.capturePhoto(settings: settings, captureAnimation: { [weak self] in

            UIView.animate(withDuration: 0.3, animations: {
                self?.previewView.alpha = 0.0
            }, completion: { (finished) in
                self?.previewView.alpha = 1.0
            })

        }) { [weak self] result in
            guard let strongSelf = self else {
                completion(CameraPhotoResult(error: .internalError(message: "")))
                return
            }

            if var image = result.value {
                image = strongSelf.processPhotoImage(image: image,
                                               deviceOrientation: deviceOrientation,
                                               aspectRatio: strongSelf.previewView.aspectRatio)
                completion(CameraPhotoResult(image))
            } else {
                completion(result)
            }
        }
    }

    public func startRecordingVideo(completion: @escaping CameraRecordingVideoCompletion) {

        let outputFileName = NSUUID().uuidString
        let outputFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((outputFileName as NSString).appendingPathExtension("mp4")!)
        let fileUrl = URL(fileURLWithPath: outputFilePath)

        let videoOrientation = AVCaptureVideoOrientation(deviceOrientation: motionDeviceOrientation.orientation) ?? .portrait

        sessionQueue.async {
            self.videoRecorder.startRecording(fileUrl: fileUrl, orientation: videoOrientation, completion: completion)
        }
    }

    func stopRecordingVideo() {
        if videoRecorder.isRecording {
            videoRecorder.stopRecording()
        }
    }

    func startForwardingPixelBuffers(to delegate: VideoOutputDelegate, pixelsBuffersToForwardPerSecond: Int) {
        if self.pixelsBufferForwarder != nil {
            stopForwardingPixelBuffers()
        }
        let pixelsBufferForwarder = PixelsBufferForwarder(delegate: delegate, pixelsBuffersToForwardPerSecond: pixelsBuffersToForwardPerSecond)
        self.pixelsBufferForwarder = pixelsBufferForwarder
        addPixelBuffersForwarderOutput(output: pixelsBufferForwarder.videoOutput)
        pixelsBufferForwarder.start()
    }

    func stopForwardingPixelBuffers() {
        if let pixelsBufferForwarder = self.pixelsBufferForwarder {
            pixelsBufferForwarder.stop()
            removePixelBuffersForwarderOutput(output: pixelsBufferForwarder.videoOutput)
            self.pixelsBufferForwarder = nil
        }
    }
}

// MARK - Private Methods
extension LGCamera {

    private func setup() {
        sessionQueue.async {
            do {
                self.session.beginConfiguration()
                if let backCamera = self.backCamera {
                    try self.configureInputVideoDevice(device: backCamera)
                } else if let frontCamera = self.frontCamera {
                    try self.configureInputVideoDevice(device: frontCamera)
                }
                self.configureOutputs()
                self.session.commitConfiguration()
                self.session.startRunning()
                self.isSetup = true
            } catch let error {
                self.session.commitConfiguration()
                logMessage(.error, type: .camera, message: "Error trying to configure camera input: \(error)")
            }
        }
    }

    private func changeToCamera(source: CameraSource) {
        sessionQueue.async {
            self.session.beginConfiguration()
            do {
                if source == .rear, let backCamera = self.backCamera  {
                    try self.configureInputVideoDevice(device: backCamera)
                } else if source == .front, let frontCamera = self.frontCamera {
                    try self.configureInputVideoDevice(device: frontCamera)
                }
                self.session.commitConfiguration()
            } catch let error {
                self.session.commitConfiguration()
                logMessage(.error, type: .camera, message: "Error trying to configure camera input: \(error)")
            }
        }

        DispatchQueue.main.async {
            self.previewView.flipAnimation()
        }
    }

    private func configureInputVideoDevice(device: AVCaptureDevice) throws {
        let videoDeviceInput = try AVCaptureDeviceInput(device: device)

        if let currentInputVideoDevice = currentInputVideoDevice, session.inputs.contains(currentInputVideoDevice) {
            session.removeInput(currentInputVideoDevice)
            self.currentInputVideoDevice = nil
        }

        if session.canAddInput(videoDeviceInput) {
            session.addInput(videoDeviceInput)
            currentInputVideoDevice = videoDeviceInput
        }
    }

    private func updateFlashMode(_ flashMode: AVCaptureDevice.FlashMode) {

        guard let currentInputVideoDevice = currentInputVideoDevice,
            currentInputVideoDevice.device.isFlashModeSupported(flashMode) else { return }
        
        do {
            try currentInputVideoDevice.device.lockForConfiguration()
            currentInputVideoDevice.device.flashMode = flashMode
            currentInputVideoDevice.device.unlockForConfiguration()
        } catch let error {
            logMessage(.error, type: .camera, message: "Error trying to configure device: \(error)")
        }
    }

    private func configureOutputs() {
        switch cameraMode {
        case .photo:
            configurePhotoOutput()
        case .video:
            configureVideoRecordingOutput()
        }
    }

    private func configurePhotoOutput() {
        if session.outputs.contains(videoRecorder.videoOutput) {
            session.removeOutput(videoRecorder.videoOutput)
        }
        if session.sessionPreset != .photo {
            session.sessionPreset = .photo
        }
        if !session.outputs.contains(capturePhotoOutput), session.canAddOutput(capturePhotoOutput) {
            session.addOutput(capturePhotoOutput)
        }
    }

    private func configureVideoRecordingOutput() {
        if session.outputs.contains(capturePhotoOutput){
            session.removeOutput(capturePhotoOutput)
        }
        if session.sessionPreset != .high {
            session.sessionPreset = .high
        }
        if !session.outputs.contains(videoRecorder.videoOutput), session.canAddOutput(videoRecorder.videoOutput) {
            session.addOutput(videoRecorder.videoOutput)
        }
    }

    private func addPixelBuffersForwarderOutput(output: AVCaptureOutput) {
        sessionQueue.async {
            if !self.session.outputs.contains(output), self.session.canAddOutput(output) {
                self.session.beginConfiguration()
                self.session.addOutput(output)
                self.session.commitConfiguration()
            }
        }
    }

    private func removePixelBuffersForwarderOutput(output: AVCaptureOutput) {
        sessionQueue.async {
            if self.session.outputs.contains(output) {
                self.session.beginConfiguration()
                self.session.removeOutput(output)
                self.session.commitConfiguration()
            }
        }
    }

    private func processPhotoImage(image: UIImage, deviceOrientation: UIDeviceOrientation, aspectRatio: CGFloat) -> UIImage {
        return image.imageByRotatingBasedOn(deviceOrientation: deviceOrientation)
            .imageByNormalizingOrientation
            .imageByCroppingTo(aspectRatio: previewView.aspectRatio)
    }
}

fileprivate struct PhotoSettings {
    let flashMode: AVCaptureDevice.FlashMode
}

private protocol CapturePhotoOutputProtocol {
    func capturePhoto(settings: PhotoSettings, captureAnimation: @escaping () -> Void, completion: @escaping CameraPhotoCompletion)
}

@available(iOS 10.0, *)
private final class LGCapturePhotoOutput: AVCapturePhotoOutput, CapturePhotoOutputProtocol {

    private var inProgressPhotoCaptureDelegates: [Int64: PhotoCaptureProcessor] = [Int64: PhotoCaptureProcessor]()

    func capturePhoto(settings: PhotoSettings, captureAnimation: @escaping () -> Void, completion: @escaping CameraPhotoCompletion) {
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.flashMode = settings.flashMode

        let processor = PhotoCaptureProcessor(with: photoSettings, willCapturePhotoAnimation: captureAnimation) { [weak self] result in
            self?.inProgressPhotoCaptureDelegates[photoSettings.uniqueID] = nil
            completion(result)
        }

        inProgressPhotoCaptureDelegates[photoSettings.uniqueID] = processor
        capturePhoto(with: photoSettings, delegate: processor)
    }
}

private final class LGCaptureStillImageOutput: AVCaptureStillImageOutput, CapturePhotoOutputProtocol {

    func capturePhoto(settings: PhotoSettings,
                      captureAnimation: @escaping () -> Void,
                      completion: @escaping CameraPhotoCompletion) {
        guard let connection = connection(with: .video) else {
            completion(CameraPhotoResult(error: .internalError(message: "")))
            return
        }
        captureStillImageAsynchronously(from: connection, completionHandler: { (sample, error) in
            let result: CameraPhotoResult
            if let sample = sample,
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sample) {
                if let image = UIImage(data: imageData) {
                    result = CameraPhotoResult(value: image)
                } else {
                    result = CameraPhotoResult(error: .internalError(message: ""))
                }
            } else if let error = error {
                result = CameraPhotoResult(error: .frameworkError(error: error))
            } else {
                result = CameraPhotoResult(error: .internalError(message: ""))
            }
            DispatchQueue.main.async {
                captureAnimation()
                completion(result)
            }
        })
    }
}

@available(iOS 10.0, *)
class PhotoCaptureProcessor: NSObject, AVCapturePhotoCaptureDelegate {

    private(set) var requestedPhotoSettings: AVCapturePhotoSettings
    private let willCapturePhotoAnimation: () -> Void
    private var completionHandler: CameraPhotoCompletion
    private var photo: UIImage?

    init(with requestedPhotoSettings: AVCapturePhotoSettings,
         willCapturePhotoAnimation: @escaping () -> Void,
         completionHandler: @escaping CameraPhotoCompletion) {
        self.requestedPhotoSettings = requestedPhotoSettings
        self.willCapturePhotoAnimation = willCapturePhotoAnimation
        self.completionHandler = completionHandler
    }

    // MARK - AVCapturePhotoCaptureDelegate
    func photoOutput(_ output: AVCapturePhotoOutput,
                     willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        willCapturePhotoAnimation()
    }

    @available(iOS 11.0, *)
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto capturePhoto: AVCapturePhoto, error: Error?) {

        if let error = error {
            logMessage(.error, type: .camera, message: "Error processing photo: \(error)")
        } else {
            if let photoData = capturePhoto.fileDataRepresentation() {
                photo = UIImage(data: photoData)
            }
        }
    }

    @available(iOS, introduced: 10.0, deprecated: 11.0)
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?,
                     previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?,
                     resolvedSettings: AVCaptureResolvedPhotoSettings,
                     bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {

        if let error = error {
            logMessage(.error, type: .camera, message: "Error processing photo: \(error)")
        }

        if let sampleBuffer = photoSampleBuffer,
            let previewBuffer = previewPhotoSampleBuffer,
            let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer,
                                                                             previewPhotoSampleBuffer: previewBuffer) {
            photo = UIImage(data: dataImage)
        }
    }

    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings,
                     error: Error?) {

        DispatchQueue.main.async {
            if let error = error {
                self.completionHandler(CameraPhotoResult(error: .frameworkError(error: error)))
            } else if let photo = self.photo {
                self.completionHandler(CameraPhotoResult(value: photo))
            } else {
                self.completionHandler(CameraPhotoResult(error: .internalError(message: "")))
            }
        }
    }
}

// MARK: - Video Recorder
class VideoRecorder : NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {

    static let videoSettings: [String: Any] = [
        AVVideoCodecKey: AVVideoCodecH264,
        AVVideoWidthKey: 480,
        AVVideoHeightKey: 640,
        AVVideoScalingModeKey: AVVideoScalingModeResizeAspectFill
    ];

    private(set) var videoOutput: AVCaptureVideoDataOutput = {
        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = false
        return output
    }()
    private(set) var recordingDuration: TimeInterval = 0
    private(set) var snapshot: UIImage?
    private let videoOutputQueue: DispatchQueue = DispatchQueue(label: "camera.video.recording.output.queue")
    private var fileWriter: AVAssetWriter?
    private var videoInput: AVAssetWriterInput?
    private var completion: CameraRecordingVideoCompletion?
    private var startRecordingTime: CMTime?
    private let maxRecordingDuration: TimeInterval = 15 //TODO: Should be a startRecording param
    private(set) var isRecording: Bool = false

    public func startRecording(fileUrl: URL, orientation: AVCaptureVideoOrientation, completion: @escaping CameraRecordingVideoCompletion) {
        guard let connection = videoOutput.connection(with: .video), connection.isActive else {
            completion(CameraRecordingVideoResult(error: .internalError(message: "")))
            return
        }
        isRecording = true

        connection.videoOrientation = orientation

        if FileManager.default.fileExists(atPath: fileUrl.path) {
            try? FileManager.default.removeItem(at: fileUrl)
        }

        do {
            let fileWriter = try AVAssetWriter(url: fileUrl, fileType: AVFileType.mp4)
            self.fileWriter = fileWriter
            self.completion = completion

            let videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: VideoRecorder.videoSettings)
            self.videoInput = videoInput
            videoInput.expectsMediaDataInRealTime = true
            fileWriter.add(videoInput)

            videoOutput.setSampleBufferDelegate(self, queue: videoOutputQueue)

        } catch let error {
            isRecording = false
            DispatchQueue.main.async {
                completion(CameraRecordingVideoResult(error: .frameworkError(error: error)))
            }
        }
    }

    public func stopRecording() {
        isRecording = false
        videoInput?.markAsFinished()
        videoOutput.setSampleBufferDelegate(nil, queue: nil)
        let duration = recordingDuration
        recordingDuration = 0

        guard let completion = completion, let fileWriter = fileWriter else { return }

        if fileWriter.status == .failed {
            DispatchQueue.main.async {
                completion(CameraRecordingVideoResult(error: .internalError(message: "")))
            }
        } else {
            fileWriter.finishWriting {
                let result: CameraRecordingVideoResult
                do {
                    let snapshot = try AVURLAsset(url: fileWriter.outputURL).videoSnapshot()
                    let videoRecorded = RecordedVideo(url: fileWriter.outputURL, snapshot: snapshot, duration: duration)
                    result = CameraRecordingVideoResult(value: videoRecorded)
                } catch let error {
                    result = CameraRecordingVideoResult(error: .frameworkError(error: error))
                }
                DispatchQueue.main.async { completion(result) }
            }
        }
    }

    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let fileWriter = fileWriter, let videoInput = videoInput else { return }

        if CMSampleBufferDataIsReady(sampleBuffer) {
            let bufferTimeStamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)

            if fileWriter.status == .unknown {
                fileWriter.startWriting()
                fileWriter.startSession(atSourceTime: bufferTimeStamp)
                startRecordingTime = bufferTimeStamp
            }

            if fileWriter.status == .failed {
                completion?(CameraRecordingVideoResult(error: .frameworkError(error: fileWriter.error!)))
            }

            if videoInput.isReadyForMoreMediaData {
                videoInput.append(sampleBuffer)
            }

            if let startRecordingTime = startRecordingTime {
                recordingDuration = CMTimeSubtract(bufferTimeStamp, startRecordingTime).seconds
                if recordingDuration >= maxRecordingDuration {
                    stopRecording()
                }
            }
        }
    }
}

class PixelsBufferForwarder: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {

    private(set) var videoOutput: AVCaptureVideoDataOutput
    private let videoOutputQueue = DispatchQueue(label: "camera.manager.video.output.queue")
    private let delegate: VideoOutputDelegate

    private var pixelsBuffersToForwardPerSecond: Int = 15
    private var videoOutputLastTimestamp = CMTime()

    init(delegate: VideoOutputDelegate, pixelsBuffersToForwardPerSecond: Int) {
        self.delegate = delegate
        self.pixelsBuffersToForwardPerSecond = pixelsBuffersToForwardPerSecond
        self.videoOutput = AVCaptureVideoDataOutput()
        self.videoOutput.alwaysDiscardsLateVideoFrames = true

        let settings: [String: Any] = [kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32BGRA)]
        self.videoOutput.videoSettings = settings
    }

    public func start() {
        videoOutput.setSampleBufferDelegate(self, queue: videoOutputQueue)
    }

    public func stop() {
        videoOutput.setSampleBufferDelegate(nil, queue: nil)
    }

    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {

        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        let deltaTime = timestamp - videoOutputLastTimestamp
        if deltaTime >= CMTimeMake(1, Int32(pixelsBuffersToForwardPerSecond)) {
            videoOutputLastTimestamp = timestamp
            let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
            delegate.didCaptureVideoFrame(pixelBuffer: imageBuffer, timestamp: timestamp)
        }
    }
}

final class CameraPreviewView: UIView {

    private let focusMode: AVCaptureDevice.FocusMode = .continuousAutoFocus
    private let exposureMode: AVCaptureDevice.ExposureMode = .continuousAutoExposure
    private var focusGesture: UITapGestureRecognizer?
    private var lastFocusRectangle: CAShapeLayer? = nil
    private let focusRectSize = CGSize(width: 75, height: 75)

    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }

    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        guard let layer = layer as? AVCaptureVideoPreviewLayer else {
            fatalError("Expected `AVCaptureVideoPreviewLayer` type for layer. Check CameraPreviewView.layerClass implementation.")
        }
        return layer
    }

    var session: AVCaptureSession? {
        get { return videoPreviewLayer.session }
        set {
            videoPreviewLayer.session = newValue
            if newValue == nil {
                removeFocusGestureRecognizer()
            } else {
                addFocusGestureRecognizer()
            }
        }
    }

    private func addFocusGestureRecognizer() {
        if let focusGesture = focusGesture {
            if !(gestureRecognizers?.contains(focusGesture) ?? false) {
                addGestureRecognizer(focusGesture)
            }
        } else {
            let focusGesture = UITapGestureRecognizer()
            focusGesture.addTarget(self, action: #selector(CameraPreviewView.focusTapReceived(recognizer:)))
            addGestureRecognizer(focusGesture)
            self.focusGesture = focusGesture
        }
    }

    private func removeFocusGestureRecognizer() {
        guard let focusGesture = focusGesture,
            let gestureRecognizers = gestureRecognizers,
            gestureRecognizers.contains(focusGesture) else {
                return
        }
        removeGestureRecognizer(focusGesture)
    }

    @objc private func focusTapReceived(recognizer: UITapGestureRecognizer) {
        let pointInPreviewLayer = layer.convert(recognizer.location(in: self), to: videoPreviewLayer)
        let pointOfInterest = videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: pointInPreviewLayer)

        if let input = videoPreviewLayer.session?.inputs.first as? AVCaptureDeviceInput {

            let device = input.device

            do {
                try device.lockForConfiguration()

                displayFocusRectangleAtPoint(pointInPreviewLayer, inLayer: videoPreviewLayer)

                if device.isFocusPointOfInterestSupported {
                    device.focusPointOfInterest = pointOfInterest
                }

                if device.isExposurePointOfInterestSupported {
                    device.exposurePointOfInterest = pointOfInterest
                }

                if device.isFocusModeSupported(focusMode) {
                    device.focusMode = focusMode
                }

                if device.isExposureModeSupported(exposureMode) {
                    device.exposureMode = exposureMode
                }

                device.unlockForConfiguration()

            } catch let error {
                logMessage(.error, type: .camera, message: "Error locking camera for configuration: \(error)")
            }
        }
    }

    private func displayFocusRectangleAtPoint(_ focusPoint: CGPoint, inLayer layer: CALayer) {
        if let lastFocusRectangle = lastFocusRectangle {
            lastFocusRectangle.removeFromSuperlayer()
            self.lastFocusRectangle = nil
        }

        let endPath = UIBezierPath.cameraFocusPath(with: focusRectSize, at: focusPoint)
        let startPath = UIBezierPath(cgPath: endPath.cgPath)
        let scaleAroundCenterTransform = CGAffineTransform(translationX: -focusPoint.x, y: -focusPoint.y)
            .concatenating(CGAffineTransform(scaleX: 2.0, y: 2.0)
                .concatenating(CGAffineTransform(translationX: focusPoint.x, y: focusPoint.y)))
        startPath.apply(scaleAroundCenterTransform)

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = endPath.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor(red:1, green:0.83, blue:0, alpha:0.95).cgColor
        shapeLayer.lineWidth = 1.0

        layer.addSublayer(shapeLayer)
        lastFocusRectangle = shapeLayer

        CATransaction.begin()

        CATransaction.setAnimationDuration(0.2)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut))

        CATransaction.setCompletionBlock() {
            if shapeLayer.superlayer != nil {
                shapeLayer.removeFromSuperlayer()
                self.lastFocusRectangle = nil
            }
        }

        let appearPathAnimation = CABasicAnimation(keyPath: "path")
        appearPathAnimation.fromValue = startPath.cgPath
        appearPathAnimation.toValue = endPath.cgPath
        shapeLayer.add(appearPathAnimation, forKey: "path")

        let appearOpacityAnimation = CABasicAnimation(keyPath: "opacity")
        appearOpacityAnimation.fromValue = 0.0
        appearOpacityAnimation.toValue = 1.0
        shapeLayer.add(appearOpacityAnimation, forKey: "appearOpacityAnimation")

        let disappearOpacityAnimation = CABasicAnimation(keyPath: "opacity")
        disappearOpacityAnimation.fromValue = 1.0
        disappearOpacityAnimation.toValue = 0.0
        disappearOpacityAnimation.beginTime = CACurrentMediaTime() + 0.8
        disappearOpacityAnimation.fillMode = kCAFillModeForwards
        disappearOpacityAnimation.isRemovedOnCompletion = false
        shapeLayer.add(disappearOpacityAnimation, forKey: "disappearOpacityAnimation")

        CATransaction.commit()
    }

    private var transitionAnimating: Bool = false

    fileprivate func flipAnimation() {
        guard transitionAnimating == false else { return }

        let blurEffect = UIBlurEffect(style: .light)
        let blurredView = UIVisualEffectView(effect: blurEffect)
        blurredView.frame = bounds
        addSubview(blurredView)

        if let cameraTransitionView = snapshotView(afterScreenUpdates: true) {
            addSubview(cameraTransitionView)
            blurredView.removeFromSuperview()
            transitionAnimating = true

            UIView.transition(with: self, duration: 0.5, options: .transitionFlipFromLeft , animations: { () -> Void in

            }, completion: { (finished) in

                UIView.animate(withDuration: 0.5, animations: { () -> Void in
                    cameraTransitionView.alpha = 0.0
                }, completion: { (finished) -> Void in
                    cameraTransitionView.removeFromSuperview()
                    self.transitionAnimating = false
                })
            })
        } else {
            blurredView.removeFromSuperview()
        }
    }
}

extension AVCaptureDevice {
    static func defaultBackCameraDevice() -> AVCaptureDevice? {
        if #available(iOS 10.0, *) {
            return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        } else {
            return AVCaptureDevice.devices(for: AVMediaType.video).filter { $0.position == .back }.first
        }
    }

    static func defaultFrontCameraDevice() -> AVCaptureDevice? {
        if #available(iOS 10.0, *) {
            return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        } else {
            return AVCaptureDevice.devices(for: AVMediaType.video).filter { $0.position == .front }.first
        }
    }
}

extension AVCaptureVideoOrientation {
    init?(deviceOrientation: UIDeviceOrientation) {
        switch deviceOrientation {
        case .portrait: self = .portrait
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeRight
        case .landscapeRight: self = .landscapeLeft
        default: return nil
        }
    }

    init?(interfaceOrientation: UIInterfaceOrientation) {
        switch interfaceOrientation {
        case .portrait: self = .portrait
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeLeft
        case .landscapeRight: self = .landscapeRight
        default: return nil
        }
    }
}

extension AVCaptureDevice.FlashMode {
    func asCameraFlashState() -> CameraFlashState {
        switch self {
        case .on: return .on
        case .off: return .off
        case .auto: return .auto
        }
    }
}

extension CameraFlashState {
    func asFlashMode() -> AVCaptureDevice.FlashMode {
        switch self {
        case .on: return .on
        case .off: return .off
        case .auto: return .auto
        }
    }
}

extension AVCaptureDevice.Position {
    func cameraSource() -> CameraSource? {
        switch self {
        case .front: return .front
        case .back: return .rear
        case .unspecified: return nil
        }
    }
}

private extension UIBezierPath {
    static func cameraFocusPath(with size: CGSize, at point: CGPoint) -> UIBezierPath {
        let lineWidth: CGFloat = 5.0
        let rect = CGRect(origin: CGPoint(x: point.x - size.width / 2.0, y: point.y - size.height / 2.0), size: size)
        let path = UIBezierPath(rect: rect)
        path.move(to: CGPoint(x: rect.minX + size.width / 2.0, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX + size.width / 2.0, y: rect.minY + lineWidth))
        path.move(to: CGPoint(x: rect.maxX, y: rect.minY + size.height / 2.0))
        path.addLine(to: CGPoint(x: rect.maxX - lineWidth, y: rect.minY + size.height / 2.0))
        path.move(to: CGPoint(x: rect.minX + size.width / 2.0, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + size.width / 2.0, y: rect.maxY - lineWidth))
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + size.height / 2.0))
        path.addLine(to: CGPoint(x: rect.minX + lineWidth, y: rect.minY + size.height / 2.0))

        return path
    }
}

extension UIView {
    var aspectRatio: CGFloat {
        return bounds.width/bounds.height
    }
}

private extension UIImage {

    func imageByRotatingBasedOn(deviceOrientation: UIDeviceOrientation) -> UIImage {
        let orientation: UIImageOrientation
        let mirrored = isMirrored
        switch deviceOrientation {
        case .landscapeLeft:
            orientation = mirrored ? .upMirrored : .up
        case .landscapeRight:
            orientation = mirrored ? .downMirrored : .down
        case .portraitUpsideDown:
            orientation = mirrored ? .rightMirrored : .left
        default:
            orientation = mirrored ? .leftMirrored : .right
        }

        guard let cgImage = cgImage, imageOrientation != orientation else { return self }

        return UIImage(cgImage: cgImage, scale: scale, orientation: orientation)
    }

    func imageByCroppingTo(aspectRatio: CGFloat) -> UIImage {
        guard let cgImage = cgImage else { return self }

        let imageRatio: CGFloat = size.width / size.height
        let destWidth: CGFloat
        let destHeight: CGFloat
        let ratioVertical = aspectRatio < 1
        let imageVertical = imageRatio < 1
        let adaptedRatio = ratioVertical == imageVertical ? aspectRatio : 1 / aspectRatio

        if adaptedRatio > imageRatio {
            //We must crop height
            destWidth = size.width
            destHeight = size.width / adaptedRatio
        } else {
            //We must crop width
            destHeight = size.height
            destWidth = size.height * adaptedRatio
        }

        let posX: CGFloat = (size.width - destWidth) / 2
        let posY: CGFloat = (size.height - destHeight) / 2

        let rect = CGRect(x: posX, y: posY, width: destWidth, height: destHeight)
        guard let imageRef: CGImage = cgImage.cropping(to: rect) else { return self }
        let image: UIImage = UIImage(cgImage: imageRef, scale: scale, orientation: imageOrientation)
        return image
    }

    var imageByNormalizingOrientation: UIImage {
        guard imageOrientation != .up else { return self }
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, true, scale)
        draw(in: rect)
        let normalized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalized ?? self
    }

    var isMirrored: Bool {
        switch imageOrientation {
        case .rightMirrored, .leftMirrored, .upMirrored, .downMirrored:
            return true
        case .right, .left, .up, .down:
            return false
        }
    }
}

private extension AVURLAsset {

    func videoSnapshot() throws -> UIImage {
        let generator = AVAssetImageGenerator(asset: self)
        generator.appliesPreferredTrackTransform = true
        let timestamp = kCMTimeZero
        let imageRef = try generator.copyCGImage(at: timestamp, actualTime: nil)
        return UIImage(cgImage: imageRef)
    }
}
