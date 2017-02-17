//
//  CameraWrapper.swift
//  LetGo
//
//  Created by Eli Kohen on 16/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import CameraManager
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
        let motionOrientation = motionDeviceOrientation.orientation
        let viewBounds = cameraContainer?.bounds
        cameraManager.capturePictureWithCompletion { (image, error) in
            if var image = image {
                image = image.imageByRotatingBasedOn(deviceOrientation: motionOrientation).imageByNormalizingOrientation
                if let bounds = viewBounds {
                    image = image.imageByCroppingTo(aspectRatio: bounds.width/bounds.height)
                }
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
    var cameraDevice: CameraDevice {
        switch self {
        case .front:
            return .front
        case .rear:
            return .back
        }
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
