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
        let imageOrientation: UIImageOrientation
        let mirrored = self.isMirrored
        switch deviceOrientation {
        case .landscapeLeft:
            imageOrientation = mirrored ? .upMirrored : .up
        case .landscapeRight:
            imageOrientation = mirrored ? .downMirrored : .down
        case .portraitUpsideDown:
            imageOrientation = mirrored ? .rightMirrored : .left
        default:
            imageOrientation = mirrored ? .leftMirrored : .right
        }

        guard let cgImage = self.cgImage, self.imageOrientation != imageOrientation else { return self }

        return UIImage(cgImage: cgImage, scale: 1, orientation: imageOrientation)
    }


    func imageByCroppingTo(aspectRatio: CGFloat) -> UIImage {

        guard let cgImage = self.cgImage else { return self }

        let imageRatio: CGFloat = self.size.width / self.size.height
        let destWidth: CGFloat
        let destHeight: CGFloat
        let ratioVertical = aspectRatio < 1
        let imageVertical = imageRatio < 1
        let adaptedRatio = ratioVertical == imageVertical ? aspectRatio : 1 / aspectRatio

        if adaptedRatio > imageRatio {
            //We must crop height
            destWidth = self.size.width
            destHeight = self.size.width / adaptedRatio
        } else {
            //We must crop width
            destHeight = self.size.height
            destWidth = self.size.height * adaptedRatio
        }

        let posX: CGFloat = (self.size.width - destWidth) / 2
        let posY: CGFloat = (self.size.height - destHeight) / 2

        let rect = CGRect(x: posX, y: posY, width: destWidth, height: destHeight)
        guard let imageRef: CGImage = cgImage.cropping(to: rect) else { return self }
        let image: UIImage = UIImage(cgImage: imageRef, scale: scale, orientation: imageOrientation)
        return image
    }

    var imageByNormalizingOrientation: UIImage {
        guard self.imageOrientation != .up else { return self }
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, true, self.scale)
        draw(in: rect)
        let normalized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalized ?? self
    }

    var isMirrored: Bool {
        switch self.imageOrientation {
        case .rightMirrored, .leftMirrored, .upMirrored, .downMirrored:
            return true
        case .right, .left, .up, .down:
            return false
        }
    }
}
