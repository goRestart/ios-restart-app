//
//  PostProductCameraViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 10/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import RxSwift

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

    private let featureFlags: FeatureFlaggeable
    private let mediaPermissions: MediaPermissions
    

    // MARK: - Lifecycle


    init(postingSource: PostingSource, keyValueStorage: KeyValueStorage, featureFlags: FeatureFlaggeable, mediaPermissions: MediaPermissions) {
        self.keyValueStorage = keyValueStorage
        self.sourcePosting = postingSource
        self.featureFlags = featureFlags
        self.mediaPermissions = mediaPermissions
        super.init()
        setupFirstShownLiterals()
        setupRX()
    }

    convenience init(postingSource: PostingSource) {
        let mediaPermissions: MediaPermissions = LGMediaPermissions()
        let keyValueStorage = KeyValueStorage.sharedInstance
        let featureFlags = FeatureFlags.sharedInstance
        self.init(postingSource: postingSource,
                  keyValueStorage: keyValueStorage,
                  featureFlags: featureFlags,
                  mediaPermissions: mediaPermissions)
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
        shouldShowFirstTimeAlert.value = false
    }


    // MARK: - Private methods

    private func setupRX() {
        cameraState.asObservable().subscribeNext{ [weak self] state in
            guard let strongSelf = self else { return }
            switch state {
            case .missingPermissions(let msg):
                strongSelf.infoTitle.value = LGLocalizedString.productPostCameraPermissionsTitle
                strongSelf.infoSubtitle.value = msg
                strongSelf.infoButton.value = LGLocalizedString.productPostCameraPermissionsButton
                strongSelf.infoShown.value = true
            case .pendingAskPermissions:
                strongSelf.infoTitle.value = LGLocalizedString.productPostCameraPermissionsTitle
                strongSelf.infoSubtitle.value = LGLocalizedString.productPostCameraPermissionsSubtitle
                strongSelf.infoButton.value = LGLocalizedString.productPostCameraPermissionsButton
                strongSelf.infoShown.value = true
            case .takingPhoto, .preview:
                strongSelf.infoShown.value = false
            case .capture:
                strongSelf.infoShown.value = false
                strongSelf.showFirstTimeAlertIfNeeded()
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
            self?.firstTimeAlertDidShow()
        }.addDisposableTo(disposeBag)
    }
    
    private func setupFirstShownLiterals() {
        firstTimeTitle = LGLocalizedString.productPostCameraFirstTimeAlertTitle
        firstTimeSubtitle = LGLocalizedString.productPostCameraFirstTimeAlertSubtitle
    }

    private func checkCameraState() {
        guard mediaPermissions.isCameraAvailable else {
            cameraState.value = .missingPermissions(LGLocalizedString.productSellCameraRestrictedError)
            return
        }
        let status = mediaPermissions.videoAuthorizationStatus
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
        mediaPermissions.requestVideoAccess { granted in
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
            showFirstTimeAlertIfNeeded()
        case .takingPhoto, .preview, .missingPermissions:
            break
        }
    }
    
    fileprivate func showFirstTimeAlertIfNeeded() {
        shouldShowFirstTimeAlert.value = !keyValueStorage[.cameraAlreadyShown]
    }

    
    fileprivate func firstTimeAlertDidShow() {
        keyValueStorage[.cameraAlreadyShown] = true
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(5)) { [weak self] in
            self?.hideFirstTimeAlert()
        }
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


