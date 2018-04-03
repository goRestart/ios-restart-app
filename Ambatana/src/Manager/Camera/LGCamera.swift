//
//  LGCamera.swift
//  LetGo
//
//  Created by Álvaro Murillo del Puerto on 7/3/18.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import UIKit
import AVFoundation

class LGCamera: NSObject {

    var flashMode: CameraFlashState? {
        set { if let flashMode = newValue { updateFlashMode(flashMode.asFlashMode()) }}
        get { return currentInputVideoDevice?.device.flashMode.asCameraFlashState() }
    }

    var cameraPosition: CameraSource? {
        get { return currentInputVideoDevice?.device.position.cameraSource() }
        set { if let source = newValue { changeToCamera(source: source) } }
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

    public func pause() {
        session.stopRunning()
    }

    public func resume() {
        if !isSetup {
            setup()
        } else if !session.isRunning {
            session.startRunning()
        }
    }

    public func addPreviewLayerTo(view: UIView) {
        guard !view.subviews.contains(previewView) else {
            return
        }

        previewView.translatesAutoresizingMaskIntoConstraints = true
        previewView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        previewView.frame = view.bounds
        previewView.videoPreviewLayer.videoGravity = .resizeAspectFill
        previewView.session = session
        view.addSubview(previewView)

        let statusBarOrientation = UIApplication.shared.statusBarOrientation

        if let videoOrientation = AVCaptureVideoOrientation(interfaceOrientation: statusBarOrientation) {
            previewView.videoPreviewLayer.connection?.videoOrientation = videoOrientation
        }

        isAttached = true
    }

    func toggleCamera() {
        if let currentCamera = currentInputVideoDevice?.device {
            if currentCamera == self.frontCamera {
                changeToCamera(source: .rear)
            } else if currentCamera == self.backCamera {
                changeToCamera(source: .front)
            }
        }
    }

    public func capturePhoto(completion: @escaping CameraPhotoCompletion) {
        guard session.outputs.contains(capturePhotoOutput) else { return }

        let settings = PhotoSettings(flashMode: flashMode?.asFlashMode() ?? .auto)
        let deviceOrientation = motionDeviceOrientation.orientation
        capturePhotoOutput.capturePhoto(settings: settings, captureAnimation: {

            UIView.animate(withDuration: 0.1, animations: {
                self.previewView.alpha = 0.0
            }, completion: { (finished) in
                self.previewView.alpha = 1.0
            })

        }) { (image, error) in

            if var image = image {
                image = self.processPhotoImage(image: image,
                                               deviceOrientation: deviceOrientation,
                                               aspectRatio: self.previewView.aspectRatio)
                let result = CameraPhotoResult(image)
                completion(result)
            } else if let error = error {
                let result = CameraPhotoResult(error: error as NSError)
                completion(result)
            } else {
                let result = CameraPhotoResult(error: NSError())
                completion(result)
            }
        }
    }

    // MARK - Private
    private let session: AVCaptureSession = AVCaptureSession()
    private let sessionQueue: DispatchQueue = DispatchQueue(label: "camera.manager.session.queue")
    private var isSetup: Bool = false
    private let previewView: CameraPreviewView = CameraPreviewView()
    private var currentInputVideoDevice: AVCaptureDeviceInput?
    private let frontCamera: AVCaptureDevice? = AVCaptureDevice.defaultFrontCameraDevice()
    private let backCamera: AVCaptureDevice? = AVCaptureDevice.defaultBackCameraDevice()
    private let motionDeviceOrientation: MotionDeviceOrientation = MotionDeviceOrientation()
    private let capturePhotoOutput: AVCaptureOutput & CapturePhotoOutput = {
        if #available(iOS 10.0, *) {
            return LGCapturePhotoOutput()
        } else {
            return LGCaptureStillImageOutput()
        }
    }()
}

// MARK - Private Methods
extension LGCamera {

    private func setup() {
        sessionQueue.async {
            do {
                self.session.beginConfiguration()
                if self.hasBackCamera {
                    try self.configureBackCamera()
                } else if self.hasFrontCamera {
                    try self.configureFrontCamera()
                }
                self.configureOutputs()
                self.session.commitConfiguration()
                self.session.startRunning()
                self.isSetup = true
            } catch {
                self.session.commitConfiguration()
            }
        }
    }

    private func changeToCamera(source: CameraSource) {
        sessionQueue.async {
            self.session.beginConfiguration()
            do {
                if source == .rear {
                    try self.configureBackCamera()
                } else if source == .front {
                    try self.configureFrontCamera()
                }
                self.session.commitConfiguration()
            } catch {
                self.session.commitConfiguration()
            }
        }

        DispatchQueue.main.async {
            self.previewView.flipAnimation()
        }
    }

    private func configureFrontCamera() throws {
        guard let frontCamera = frontCamera else { return }
        try configureInputVideoDevice(device: frontCamera)
    }

    private func configureBackCamera() throws {
        guard let backCamera = backCamera else { return }
        try configureInputVideoDevice(device: backCamera)
    }

    private func configureInputVideoDevice(device: AVCaptureDevice) throws {
        let videoDeviceInput = try AVCaptureDeviceInput(device: device)

        if let currentInputVideoDevice = currentInputVideoDevice, self.session.inputs.contains(currentInputVideoDevice) {
            self.session.removeInput(currentInputVideoDevice)
            self.currentInputVideoDevice = nil
        }

        if self.session.canAddInput(videoDeviceInput) {
            self.session.addInput(videoDeviceInput)
            currentInputVideoDevice = videoDeviceInput
        }
    }

    private func updateFlashMode(_ flashMode: AVCaptureDevice.FlashMode) {
        if currentInputVideoDevice?.device.isFlashModeSupported(flashMode) == true {
            do {
                try currentInputVideoDevice?.device.lockForConfiguration()
                currentInputVideoDevice?.device.flashMode = flashMode
                currentInputVideoDevice?.device.unlockForConfiguration()
            } catch { }
        }
    }

    private func configureOutputs() {
        self.session.sessionPreset = .photo
        if self.session.canAddOutput(self.capturePhotoOutput) {
            self.session.addOutput(self.capturePhotoOutput)
        }
    }

    private func processPhotoImage(image: UIImage, deviceOrientation: UIDeviceOrientation, aspectRatio: CGFloat) -> UIImage {
        return image.imageByRotatingBasedOn(deviceOrientation: deviceOrientation)
            .imageByNormalizingOrientation
            .imageByCroppingTo(aspectRatio: self.previewView.aspectRatio)
    }
}

struct PhotoSettings {
    let flashMode: AVCaptureDevice.FlashMode
}

protocol CapturePhotoOutput {
    func capturePhoto(settings: PhotoSettings, captureAnimation: @escaping () -> Void, completion: @escaping (UIImage?, Error?) -> Void)
}

@available(iOS 10.0, *)
class LGCapturePhotoOutput: AVCapturePhotoOutput, CapturePhotoOutput {

    private var inProgressPhotoCaptureDelegates: [Int64: PhotoCaptureProcessor] = [Int64: PhotoCaptureProcessor]()

    func capturePhoto(settings: PhotoSettings, captureAnimation: @escaping () -> Void, completion: @escaping (UIImage?, Error?) -> Void) {
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.flashMode = settings.flashMode

        let processor = PhotoCaptureProcessor(with: photoSettings,
                                              willCapturePhotoAnimation: captureAnimation,
                                              completionHandler: completion)

        inProgressPhotoCaptureDelegates[photoSettings.uniqueID] = processor
        capturePhoto(with: photoSettings, delegate: processor)
    }
}

class LGCaptureStillImageOutput: AVCaptureStillImageOutput, CapturePhotoOutput {

    func capturePhoto(settings: PhotoSettings, captureAnimation: @escaping () -> Void, completion: @escaping (UIImage?, Error?) -> Void) {

        if let connection = connection(with: .video) {
            captureStillImageAsynchronously(from: connection, completionHandler: { (sample, error) in

                DispatchQueue.main.async {
                    captureAnimation()
                    if let sample = sample,
                        let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sample),
                        let image = UIImage(data: imageData) {
                        completion(image, nil)
                    } else if let error = error {
                        completion(nil, error)
                    } else {
                        completion(nil, NSError())
                    }
                }
            })
        }
    }
}

@available(iOS 10.0, *)
class PhotoCaptureProcessor: NSObject, AVCapturePhotoCaptureDelegate {

    private(set) var requestedPhotoSettings: AVCapturePhotoSettings
    private let willCapturePhotoAnimation: () -> Void
    private var completionHandler: (UIImage?, Error?) -> Void
    var photo: UIImage?

    init(with requestedPhotoSettings: AVCapturePhotoSettings,
         willCapturePhotoAnimation: @escaping () -> Void,
         completionHandler: @escaping (UIImage?, Error?) -> Void) {
        self.requestedPhotoSettings = requestedPhotoSettings
        self.willCapturePhotoAnimation = willCapturePhotoAnimation
        self.completionHandler = completionHandler
    }

    //MARK: AVCapturePhotoCaptureDelegate
    func photoOutput(_ output: AVCapturePhotoOutput,
                     willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        willCapturePhotoAnimation()
    }

    @available(iOS 11.0, *)
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {

        if let error = error {
            print("Error capturing photo: \(error)")
        } else {
            if let photoData = photo.fileDataRepresentation() {
                self.photo = UIImage(data: photoData)
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
            print(error.localizedDescription)
        }

        if let sampleBuffer = photoSampleBuffer,
            let previewBuffer = previewPhotoSampleBuffer,
            let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer,
                                                                             previewPhotoSampleBuffer: previewBuffer) {
            self.photo = UIImage(data: dataImage)
        }
    }

    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings,
                     error: Error?) {

        completionHandler(photo, error)
    }
}

class CameraPreviewView: UIView {

    private let focusMode: AVCaptureDevice.FocusMode = .continuousAutoFocus
    private let exposureMode: AVCaptureDevice.ExposureMode = .continuousAutoExposure
    private weak var focusGesture: UITapGestureRecognizer?
    private var lastFocusRectangle: CAShapeLayer? = nil

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
        if let focusGesture = focusGesture, gestureRecognizers?.contains(focusGesture) ?? false {
            removeGestureRecognizer(focusGesture)
        }
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

            } catch {}
        }
    }

    private func displayFocusRectangleAtPoint(_ focusPoint: CGPoint, inLayer layer: CALayer) {
        if let lastFocusRectangle = lastFocusRectangle {
            lastFocusRectangle.removeFromSuperlayer()
            self.lastFocusRectangle = nil
        }

        let size = CGSize(width: 75, height: 75)
        let rect = CGRect(origin: CGPoint(x: focusPoint.x - size.width / 2.0, y: focusPoint.y - size.height / 2.0), size: size)

        let endPath = UIBezierPath(rect: rect)
        endPath.move(to: CGPoint(x: rect.minX + size.width / 2.0, y: rect.minY))
        endPath.addLine(to: CGPoint(x: rect.minX + size.width / 2.0, y: rect.minY + 5.0))
        endPath.move(to: CGPoint(x: rect.maxX, y: rect.minY + size.height / 2.0))
        endPath.addLine(to: CGPoint(x: rect.maxX - 5.0, y: rect.minY + size.height / 2.0))
        endPath.move(to: CGPoint(x: rect.minX + size.width / 2.0, y: rect.maxY))
        endPath.addLine(to: CGPoint(x: rect.minX + size.width / 2.0, y: rect.maxY - 5.0))
        endPath.move(to: CGPoint(x: rect.minX, y: rect.minY + size.height / 2.0))
        endPath.addLine(to: CGPoint(x: rect.minX + 5.0, y: rect.minY + size.height / 2.0))

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
        shapeLayer.add(appearOpacityAnimation, forKey: "opacity")

        let disappearOpacityAnimation = CABasicAnimation(keyPath: "opacity")
        disappearOpacityAnimation.fromValue = 1.0
        disappearOpacityAnimation.toValue = 0.0
        disappearOpacityAnimation.beginTime = CACurrentMediaTime() + 0.8
        disappearOpacityAnimation.fillMode = kCAFillModeForwards
        disappearOpacityAnimation.isRemovedOnCompletion = false
        shapeLayer.add(disappearOpacityAnimation, forKey: "opacity")

        CATransaction.commit()
    }

    private var transitionAnimating: Bool = false

    fileprivate func flipAnimation() {
        guard transitionAnimating == false else { return }

        let blurEffect = UIBlurEffect(style: .light)
        let blurredView = UIVisualEffectView(effect: blurEffect)
        blurredView.frame = bounds

        addSubview(blurredView)

        guard let cameraTransitionView = snapshotView(afterScreenUpdates: true) else {
            blurredView.removeFromSuperview()
            return
        }

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
    }
}

extension AVCaptureDevice {
    class func defaultBackCameraDevice() -> AVCaptureDevice? {
        if #available(iOS 10.0, *) {
            return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        } else {
            return AVCaptureDevice.devices(for: AVMediaType.video).filter { $0.position == .back }.first
        }
    }

    class func defaultFrontCameraDevice() -> AVCaptureDevice? {
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

extension UIView {
    var aspectRatio: CGFloat {
        return bounds.width/bounds.height
    }
}

fileprivate extension UIImage {

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
