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

    // MARK - Private
    private let session: AVCaptureSession = AVCaptureSession()
    private let sessionQueue: DispatchQueue = DispatchQueue(label: "camera.manager.session.queue")
    private var isSetup: Bool = false
    private let previewView: CameraPreviewView = CameraPreviewView()
    private var currentInputVideoDevice: AVCaptureDeviceInput?
    private let frontCamera: AVCaptureDevice? = AVCaptureDevice.defaultFrontCameraDevice()
    private let backCamera: AVCaptureDevice? = AVCaptureDevice.defaultBackCameraDevice()
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
}

class CameraPreviewView: UIView {

    private let focusMode: AVCaptureDevice.FocusMode = .continuousAutoFocus
    private let exposureMode: AVCaptureDevice.ExposureMode = .continuousAutoExposure
    private var focusGesture: UITapGestureRecognizer?
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
