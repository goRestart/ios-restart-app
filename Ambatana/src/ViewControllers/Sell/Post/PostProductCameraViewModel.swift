//
//  PostProductCameraViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 10/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import RxSwift
import Photos

enum CameraState {
    case MissingPermissions(String), Capture, Preview

    var captureMode: Bool {
        switch self {
        case .MissingPermissions, .Preview:
            return false
        case .Capture:
            return true
        }
    }

    var previewMode: Bool {
        switch self {
        case .MissingPermissions, .Capture:
            return false
        case .Preview:
            return true
        }
    }
}

enum CameraFlashMode {
    case Auto, On, Off
}

enum CameraSourceMode {
    case Front, Rear
}

class PostProductCameraViewModel: BaseViewModel {

    weak var cameraDelegate: PostProductCameraViewDelegate?

    let cameraState = Variable<CameraState>(.MissingPermissions(LGLocalizedString.productPostCameraPermissionsSubtitle))
    let cameraFlashMode = Variable<CameraFlashMode>(.Auto)
    let cameraSourceMode = Variable<CameraSourceMode>(.Rear)
    let imageSelected = Variable<UIImage?>(nil)

    let infoShown = Variable<Bool>(false)
    let infoTitle = Variable<String>("")
    let infoSubtitle = Variable<String>("")
    let infoButton = Variable<String>("")

    private let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    override init() {
        super.init()
        setupRX()
    }

    override func didBecomeActive() {
        switch cameraState.value {
        case .MissingPermissions:
            checkCameraState()
        case .Preview, .Capture:
            break
        }
    }

    // MARK: - Public methods

    func flashButtonPressed() {
        cameraFlashMode.value = cameraFlashMode.value.next
    }

    func cameraButtonPressed() {
        cameraSourceMode.value = cameraSourceMode.value.toggle
    }

    func takePhotoButtonPressed(photo: UIImage) {
        imageSelected.value = photo
        cameraState.value = .Preview
    }

    func retryPhotoButtonPressed() {
        imageSelected.value = nil
        cameraState.value = .Capture
    }

    func usePhotoButtonPressed() {
        guard let image = imageSelected.value else { return }
        cameraDelegate?.productCameraDidTakeImage(image)
    }

    func infoButtonPressed() {
        switch cameraState.value {
        case .MissingPermissions:
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
        case .Capture, .Preview:
            break
        }
    }

    // MARK: - Private methods

    private func setupRX() {
        cameraState.asObservable().subscribeNext{ [weak self] state in
            switch state {
            case .MissingPermissions(let msg):
                self?.infoTitle.value = LGLocalizedString.productPostCameraPermissionsTitle
                self?.infoSubtitle.value = msg
                self?.infoButton.value = LGLocalizedString.productPostCameraPermissionsButton
                self?.infoShown.value = true
            case .Capture, .Preview:
                self?.infoShown.value = false
            }
        }.addDisposableTo(disposeBag)

        cameraState.asObservable().map{ $0.previewMode }.subscribeNext{ [weak self] previewMode in
            self?.cameraDelegate?.productCameraRequestHideTabs(previewMode)
        }.addDisposableTo(disposeBag)
    }

    private func checkCameraState() {
        guard UIImagePickerController.isSourceTypeAvailable(.Camera) else {
            cameraState.value = .MissingPermissions(LGLocalizedString.productSellCameraRestrictedError)
            return
        }
        let status = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        switch (status) {
        case .Authorized:
            cameraState.value = .Capture
        case .Denied:
            cameraState.value = .MissingPermissions(LGLocalizedString.productPostCameraPermissionsSubtitle)
        case .NotDetermined:
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo) { granted in
                if granted {
                    dispatch_async(dispatch_get_main_queue()) { [weak self] in
                        self?.cameraState.value = .Capture
                    }
                }
            }
        case .Restricted:
            // this will never be called, this status is not visible for the user
            // https://developer.apple.com/library/ios/documentation/AVFoundation/Reference/AVCaptureDevice_Class/#//apple_ref/swift/enum/c:@E@AVAuthorizationStatus
            break
        }
    }
}


// MARK: - Camera Enum extensions

private extension CameraFlashMode {
    var next: CameraFlashMode {
        switch self {
        case .Auto:
            return .On
        case .On:
            return .Off
        case .Off:
            return .Auto
        }
    }
}

private extension CameraSourceMode {
    var toggle: CameraSourceMode {
        switch self {
        case .Front:
            return .Rear
        case .Rear:
            return .Front
        }
    }
}
