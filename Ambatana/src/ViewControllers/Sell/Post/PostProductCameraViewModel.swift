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
    case pendingAskPermissions, missingPermissions(String), capture, takingPhoto, preview
}



class PostProductCameraViewModel: BaseViewModel {

    weak var cameraDelegate: PostProductCameraViewDelegate?

    let visible = Variable<Bool>(false)

    let cameraState = Variable<CameraState>(.pendingAskPermissions)
    let cameraFlashState = Variable<CameraFlashState>(.auto)
    let cameraSource = Variable<CameraSource>(.rear)
    let imageSelected = Variable<UIImage?>(nil)

    let infoShown = Variable<Bool>(false)
    let infoTitle = Variable<String>("")
    let infoSubtitle = Variable<String>("")
    let infoButton = Variable<String>("")
    let shouldShowFirstTimeAlert = Variable<Bool>(false)

    var firstTimeTitle: String?
    var firstTimeSubtitle: String?
    
    private let disposeBag = DisposeBag()
    private let keyValueStorage: KeyValueStorage   //cameraAlreadyShown
    let sourcePosting: PostingSource
    private var firstTimeAlertTimer: Timer?

    private let featureFlags: FeatureFlaggeable
    
    private var skipCustomPermissions: Bool {
        return sourcePosting == .onboardingCamera || sourcePosting == .onboardingButton
    }

    // MARK: - Lifecycle


    init(postingSource: PostingSource, keyValueStorage: KeyValueStorage, featureFlags: FeatureFlaggeable) {
        self.keyValueStorage = keyValueStorage
        self.sourcePosting = postingSource
        self.featureFlags = featureFlags
        super.init()
        setupFirstShownLiterals()
        setupRX()
    }

    convenience init(postingSource: PostingSource) {
        let keyValueStorage = KeyValueStorage.sharedInstance
        let featureFlags = FeatureFlags.sharedInstance
        self.init(postingSource: postingSource, keyValueStorage: keyValueStorage, featureFlags: featureFlags)
    }

    override func didBecomeActive(_ firstTime: Bool) {
        switch cameraState.value {
        case .pendingAskPermissions, .missingPermissions:
            checkCameraState()
        case .takingPhoto, .preview, .capture:
            break
        }
    }


    // MARK: - Public methods

    func closeButtonPressed() {
        switch cameraState.value {
        case .takingPhoto, .preview:
            retryPhotoButtonPressed()
        case .missingPermissions, .pendingAskPermissions, .capture:
            cameraDelegate?.productCameraCloseButton()
        }
    }

    func flashButtonPressed() {
        cameraFlashState.value = cameraFlashState.value.next
    }

    func cameraButtonPressed() {
        cameraSource.value = cameraSource.value.toggle
    }

    func takePhotoButtonPressed() {
        cameraState.value = .takingPhoto
    }

    func photoTaken(_ photo: UIImage) {
        imageSelected.value = photo
        cameraState.value = .preview
    }

    func retryPhotoButtonPressed() {
        imageSelected.value = nil
        cameraState.value = .capture
    }

    func usePhotoButtonPressed() {
        guard let image = imageSelected.value else { return }
        cameraDelegate?.productCameraDidTakeImage(image)
    }

    func infoButtonPressed() {
        switch cameraState.value {
        case .missingPermissions:
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else { return }
            UIApplication.shared.openURL(settingsUrl)
        case .pendingAskPermissions:
            askForPermissions()
        case .takingPhoto, .capture, .preview:
            break
        }
    }

    func hideFirstTimeAlert() {
        firstTimeAlertTimer?.invalidate()
        shouldShowFirstTimeAlert.value = false
    }


    // MARK: - Private methods

    private func setupRX() {
        cameraState.asObservable().subscribeNext{ [weak self] state in
            guard let strongSelf = self else { return }
            switch state {
            case .missingPermissions(let msg):
                guard !strongSelf.skipCustomPermissions else {
                    strongSelf.shouldShowFirstTimeAlert.value = true
                    return
                }
                strongSelf.infoTitle.value = LGLocalizedString.productPostCameraPermissionsTitle
                strongSelf.infoSubtitle.value = msg
                strongSelf.infoButton.value = LGLocalizedString.productPostCameraPermissionsButton
                strongSelf.infoShown.value = true
            case .pendingAskPermissions:
                guard !strongSelf.skipCustomPermissions else {
                    strongSelf.shouldShowFirstTimeAlert.value = true
                    return
                }
                strongSelf.infoTitle.value = LGLocalizedString.productPostCameraPermissionsTitle
                strongSelf.infoSubtitle.value = LGLocalizedString.productPostCameraPermissionsSubtitle
                strongSelf.infoButton.value = LGLocalizedString.productPostCameraPermissionsButton
                strongSelf.infoShown.value = true
            case .takingPhoto, .capture, .preview:
                strongSelf.infoShown.value = false
            }
        }.addDisposableTo(disposeBag)
        
        cameraState.asObservable().map{ $0.previewMode }.subscribeNext{ [weak self] previewMode in
            self?.cameraDelegate?.productCameraRequestHideTabs(previewMode)
        }.addDisposableTo(disposeBag)

        cameraState.asObservable().map{ $0.cameraLock }.subscribeNext{ [weak self] cameraLock in
            self?.cameraDelegate?.productCameraRequestsScrollLock(cameraLock)
        }.addDisposableTo(disposeBag)

        visible.asObservable().distinctUntilChanged().filter{ $0 }
            .subscribeNext{ [weak self] _ in self?.didBecomeVisible() }
            .addDisposableTo(disposeBag)
        
        shouldShowFirstTimeAlert.asObservable().filter {$0}.bindNext { [weak self] _ in
            self?.showFirstTimeAlert()
            }.addDisposableTo(disposeBag)
    }
    
    private func setupFirstShownLiterals() {
        firstTimeTitle = LGLocalizedString.productPostCameraFirstTimeAlertTitle
        firstTimeSubtitle = LGLocalizedString.productPostCameraFirstTimeAlertSubtitle
    }

    private func checkCameraState() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            cameraState.value = .missingPermissions(LGLocalizedString.productSellCameraRestrictedError)
            return
        }
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        switch (status) {
        case .authorized:
            cameraState.value = .capture
        case .denied:
            cameraState.value = .missingPermissions(LGLocalizedString.productPostCameraPermissionsSubtitle)
        case .notDetermined:
            cameraState.value = .pendingAskPermissions
        case .restricted:
            // this will never be called, this status is not visible for the user
            // https://developer.apple.com/library/ios/documentation/AVFoundation/Reference/AVCaptureDevice_Class/#//apple_ref/swift/enum/c:@E@AVAuthorizationStatus
            break
        }
    }

    private func askForPermissions() {
        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { granted in
            //This is required :(, callback is not on main thread so app would crash otherwise.
            DispatchQueue.main.async { [weak self] in
                self?.cameraState.value = granted ?
                    .capture : .missingPermissions(LGLocalizedString.productPostCameraPermissionsSubtitle)
            }
        }
    }

    private func didBecomeVisible() {
        switch cameraState.value {
        case .pendingAskPermissions:
            askForPermissions()
        case .capture:
            shouldShowFirstTimeAlert.value = !keyValueStorage[.cameraAlreadyShown]
        case .takingPhoto, .preview, .missingPermissions:
            break
        }
    }

    private func showFirstTimeAlert() {
        keyValueStorage[.cameraAlreadyShown] = true
        firstTimeAlertTimer = Timer.scheduledTimer(timeInterval: 5, target: self,
                                                                     selector: #selector(timerHideFirstTimeAlert),
                                                                     userInfo: nil, repeats: false)
    }

    dynamic func timerHideFirstTimeAlert() {
        hideFirstTimeAlert()
    }
}


// MARK: - Camera Enum extensions

extension CameraState {
    var captureMode: Bool {
        switch self {
        case .pendingAskPermissions, .missingPermissions, .preview:
            return false
        case .takingPhoto, .capture:
            return true
        }
    }

    var previewMode: Bool {
        switch self {
        case .pendingAskPermissions, .missingPermissions, .capture, .takingPhoto:
            return false
        case .preview:
            return true
        }
    }

    fileprivate var cameraLock: Bool {
        switch self {
        case .pendingAskPermissions, .missingPermissions, .capture:
            return false
        case .preview, .takingPhoto:
            return true
        }
    }
}

fileprivate extension CameraFlashState {
    var next: CameraFlashState {
        switch self {
        case .auto:
            return .on
        case .on:
            return .off
        case .off:
            return .auto
        }
    }
}

fileprivate extension CameraSource {
    var toggle: CameraSource {
        switch self {
        case .front:
            return .rear
        case .rear:
            return .front
        }
    }
}
