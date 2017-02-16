//
//  CameraWrapper.swift
//  LetGo
//
//  Created by Eli Kohen on 16/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import CameraManager
import FastttCamera
import Result

typealias CameraPhotoResult = Result<UIImage, NSError>
typealias CameraPhotoCompletion = (CameraPhotoResult) -> Void

enum CameraFlashState {
    case auto, on, off
}

enum CameraSource {
    case front, rear
}

class CameraWrapper {

    var flashMode: CameraFlashState = .auto {
        didSet {
            cameraManager.flashMode = flashMode.cameraFlashMode
        }
    }
    var cameraSource: CameraSource = .front {
        didSet {
            cameraManager.cameraDevice = cameraSource.cameraDevice
        }
    }

    var isReady: Bool {
        return cameraManager.cameraIsReady
    }

    var hasFlash: Bool {
        return cameraManager.hasFlash
    }

    var hasFrontCamera: Bool {
        return cameraManager.hasFrontCamera
    }

    private(set) var cameraContainer: UIView?
    private let cameraManager: CameraManager
    private let motionDeviceOrientation: MotionDeviceOrientation
    private var addingCamera: Bool = false

    init() {
        cameraManager = CameraManager()
        motionDeviceOrientation = MotionDeviceOrientation()

        cameraManager.cameraOutputQuality = .high
        cameraManager.showAccessPermissionPopupAutomatically = false
        cameraManager.writeFilesToPhoneLibrary = false
        cameraManager.shouldKeepViewAtOrientationChanges = true

        cameraManager.flashMode = flashMode.cameraFlashMode
        cameraManager.cameraDevice = cameraSource.cameraDevice
    }


    func capturePhoto(completion: @escaping CameraPhotoCompletion) {
        let deviceOrientation = UIDevice.current.orientation
        let motionOrientation = motionDeviceOrientation.orientation
        cameraManager.capturePictureWithCompletion { (image, error) in
            if let image = image {
                print("🌈 Motion Orientation: \(motionOrientation.description), device: \(deviceOrientation.description)")
                completion(CameraPhotoResult(image))
            } else if let error = error {
                completion(CameraPhotoResult(error: error))
            }
        }
    }

    @discardableResult
    func addPreviewLayerTo(view: UIView) -> Bool {
        guard !addingCamera else { return false }
        let cameraState = cameraManager.addLayerPreviewToView(view, newCameraOutputMode: cameraManager.cameraOutputMode) { 
            [weak self] in
            self?.cameraContainer = view
            self?.addingCamera = false
        }
        if cameraState == .ready {
            addingCamera = true
            return true
        }
        return false
    }

    func pause() {
        cameraManager.stopCaptureSession()
    }

    func resume() {
        cameraManager.resumeCaptureSession()
    }
}

fileprivate extension CameraFlashState {
    var fastttCameraFlash: FastttCameraFlashMode {
        switch self {
        case .auto:
            return .auto
        case .on:
            return .on
        case .off:
            return .off
        }
    }

    var cameraFlashMode: CameraFlashMode {
        switch self {
        case .auto:
            return .auto
        case .on:
            return .on
        case .off:
            return .off
        }
    }
}

fileprivate extension CameraSource {
    var fastttCameraDevice: FastttCameraDevice {
        switch self {
        case .front:
            return .front
        case .rear:
            return .rear
        }
    }

    var cameraDevice: CameraDevice {
        switch self {
        case .front:
            return .front
        case .rear:
            return .back
        }
    }
}


extension UIImageOrientation {
    var description: String {
        switch self {
        case .up: // default
            return "up"
        case .down: // 180 deg rotation
            return "down"
        case .left: // 90 deg CCW
            return "left"
        case .right: // 90 deg CW
            return "right"
        case .upMirrored: // as above but image mirrored along other axis. horizontal flip
            return "up-mirrored"
        case .downMirrored: // horizontal flip
            return "down-mirrored"
        case .leftMirrored: // vertical flip
            return "left-mirrored"
        case .rightMirrored: // vertical flip
            return "right-mirrored"
        }
    }
}

extension UIDeviceOrientation {
    var description: String {

        switch self {
        case .unknown:
            return "unknown"
        case .portrait: // Device oriented vertically, home button on the bottom
            return "portrait"
        case .portraitUpsideDown: // Device oriented vertically, home button on the top
            return "portraitUpsideDown"
        case .landscapeLeft: // Device oriented horizontally, home button on the right
            return "landscapeLeft"
        case .landscapeRight: // Device oriented horizontally, home button on the left
            return "landscapeRight"
        case .faceUp: // Device oriented flat, face up
            return "faceUp"
        case .faceDown: // Device oriented flat, face down
            return "faceDown"
        }
    }
}

