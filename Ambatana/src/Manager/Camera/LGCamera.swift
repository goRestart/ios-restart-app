//
//  LGCamera.swift
//  LetGo
//
//  Created by Álvaro Murillo del Puerto on 7/3/18.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import UIKit
import AVFoundation

class LGCamera: Camera {

    var flashMode: AVCaptureDevice.FlashMode {
        get {
            if #available(iOS 10.2, *) {
                return photoSettings.flashMode
            } else  {
                return videoInputDevice?.flashMode ?? .off
            }
        }
        set {
            updateFlashMode(flashMode: newValue)
        }
    }

    var cameraPosition: CameraSource = .rear // TODO: Pending implementation

    var isReady: Bool = false // TODO: Pending implementation

    var hasFlash: Bool {
        return videoInputDevice?.hasFlash ?? false
    }

    var hasFrontCamera: Bool {

        return AVCaptureDevice.defaultVideoDevice(position: .front) != nil
    }

    var isAttached: Bool = false

    var shouldForwardPixelBuffersToDelegate: Bool = false

    var pixelsBuffersToForwardPerSecond: CMTime = CMTimeMake(0, 0)

    var videoOutputDelegate: VideoOutputDelegate?

    private let session: AVCaptureSession
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    private let previewLayer: AVCaptureVideoPreviewLayer
    private var videoInputDevice: AVCaptureDevice?

    @available(iOS 10.0, *)
    fileprivate var photoSettings: AVCapturePhotoSettings {
        return AVCapturePhotoSettings()
    }

    init() {
        session = AVCaptureSession()
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        sessionQueue.async {
            self.configureSession()
        }
    }

    func addPreviewLayerTo(view: UIView) -> Bool {

        previewLayer.frame = view.layer.bounds
        view.clipsToBounds = true
//        view.layer.addSublayer(previewLayer)
        view.layer.insertSublayer(previewLayer, at: 0)
        previewLayer.videoGravity = .resizeAspectFill

        let statusBarOrientation = UIApplication.shared.statusBarOrientation
        var initialVideoOrientation: AVCaptureVideoOrientation = .portrait
        if statusBarOrientation != .unknown {
            if let videoOrientation = AVCaptureVideoOrientation(interfaceOrientation: statusBarOrientation) {
                initialVideoOrientation = videoOrientation
            }
        }
        previewLayer.connection?.videoOrientation = initialVideoOrientation

        return true
    }

    private func configureSession() {

        session.beginConfiguration()
        session.sessionPreset = .photo

        do {

            // Add video device to session as input
            if let defaultVideoDevice = defaultVideoDevice() {
                videoInputDevice = defaultVideoDevice
                let videoInput = try AVCaptureDeviceInput(device: defaultVideoDevice)
                session.addInput(videoInput)
            }

        } catch {

        }

        session.commitConfiguration()
    }

    private func updateFlashMode(flashMode: AVCaptureDevice.FlashMode) {

        if #available(iOS 10.2, *) {
            photoSettings.flashMode = flashMode
        } else {

            if let videoInputDevice = videoInputDevice, videoInputDevice.isFlashModeSupported(flashMode) {

                do {
                    try videoInputDevice.lockForConfiguration()
                    videoInputDevice.flashMode = flashMode
                    videoInputDevice.unlockForConfiguration()
                } catch {

                }
            }
        }
    }

    private func defaultVideoDevice() -> AVCaptureDevice? {

        if let backVideoCamera = AVCaptureDevice.defaultVideoDevice(position: .back) {
            return backVideoCamera
        } else if let frontCamera = AVCaptureDevice.defaultVideoDevice(position: .front) {
            return frontCamera
        }

        return nil
    }

    func capturePhoto(completion: @escaping CameraPhotoCompletion) {
        // TODO: Pending implementation
    }

    func startRecordingVideo() {
        // TODO: Pending implementation
    }

    func stopRecordingVideo(completion: @escaping CameraRecordingVideoCompletion) {
        // TODO: Pending implementation
    }

    func pause() {
        // TODO: Pending implementation
        sessionQueue.async {
            self.session.stopRunning()
        }
    }

    func resume() {
        // TODO: Pending implementation
        sessionQueue.async {
            self.session.startRunning()
        }
    }

}

fileprivate extension AVCaptureDevice {

    fileprivate static var videoDevices: [AVCaptureDevice] {
        return AVCaptureDevice.devices(for: AVMediaType.video)
    }

    fileprivate static func defaultVideoDevice(position: AVCaptureDevice.Position) -> AVCaptureDevice? {

        if #available(iOS 10.2, *) {

            if position == .back {

                if let dualCameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
                    return dualCameraDevice
                } else if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                    return backCameraDevice
                }

            } else if position == .front {

                if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
                    return frontCameraDevice
                }
            }

            return nil

        } else {

            let videoDevices: [AVCaptureDevice] = AVCaptureDevice.devices(for: AVMediaType.video)

            return videoDevices.filter { $0.position == position }.first
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

extension CameraFlashState {
    init(deviceFlashMode: AVCaptureDevice.FlashMode) {
        switch deviceFlashMode {
        case .auto: self = .auto
        case .on: self = .on
        case .off: self = .off
        }
    }

    func deviceFlashMode() -> AVCaptureDevice.FlashMode {
        switch self {
        case .auto: return .auto
        case .on: return .on
        case .off: return .off
        }
    }
}
