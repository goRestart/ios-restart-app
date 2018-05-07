//
//  PostListingCameraViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 10/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import RxSwift

enum CameraState {
    case pendingAskPermissions, missingPermissions(String), capture, takingPhoto, recordingVideo, previewPhoto, previewVideo
}



final class PostListingCameraViewModel: BaseViewModel {

    weak var cameraDelegate: PostListingCameraViewDelegate?

    let visible = Variable<Bool>(false)

    let cameraState = Variable<CameraState>(.pendingAskPermissions)
    let cameraFlashState = Variable<CameraFlashState>(.auto)
    let cameraSource = Variable<CameraSource>(.rear)
    let imageSelected = Variable<UIImage?>(nil)
    let videoRecorded = Variable<RecordedVideo?>(nil)
    let cameraMode = Variable<CameraMode>(.photo)

    let infoShown = Variable<Bool>(false)
    let infoTitle = Variable<String>("")
    let infoSubtitle = Variable<String>("")
    let infoButton = Variable<String>("")
    let shouldShowFirstTimeAlert = Variable<Bool>(false)
    let shouldShowVerticalText = Variable<Bool>(true)
    var firstTimeTitle: String?
    var firstTimeSubtitle: String?
    
    private let disposeBag = DisposeBag()
    private let keyValueStorage: KeyValueStorage   //cameraAlreadyShown
    private let filesManager: FilesManager
    let sourcePosting: PostingSource
    let isBlockingPosting: Bool

    private let featureFlags: FeatureFlaggeable
    private let mediaPermissions: MediaPermissions
    
    let postCategory: PostCategory?
    
    var verticalPromotionMessage: String? {
        if let category = postCategory, category == .realEstate {
            return LGLocalizedString.realEstateCameraViewRealEstateMessage
        }
        return nil
    }
    
    var learnMoreMessage: NSAttributedString {
            var titleAttributes = [NSAttributedStringKey : Any]()
            titleAttributes[NSAttributedStringKey.foregroundColor] = UIColor.white
            titleAttributes[NSAttributedStringKey.underlineStyle] = NSUnderlineStyle.styleSingle.rawValue
            titleAttributes[NSAttributedStringKey.font] = UIFont.boldSystemFont(ofSize: 23)
            let text = NSAttributedString(string: LGLocalizedString.realEstateCameraViewRealEstateLearnMore,
                                          attributes: titleAttributes)
            return text
    }
    
    var learnMoreIsHidden: Bool {
        guard let category = postCategory else { return true }
        return !(category == .realEstate && featureFlags.realEstateTutorial.shouldShowLearnMoreButton)
    }

    
    // MARK: - Lifecycle

    init(postingSource: PostingSource, postCategory: PostCategory?, isBlockingPosting: Bool,
         keyValueStorage: KeyValueStorage, filesManager: FilesManager, featureFlags: FeatureFlaggeable, mediaPermissions: MediaPermissions) {
        self.keyValueStorage = keyValueStorage
        self.filesManager = filesManager
        self.sourcePosting = postingSource
        self.isBlockingPosting = isBlockingPosting
        self.featureFlags = featureFlags
        self.mediaPermissions = mediaPermissions
        self.postCategory = postCategory
        super.init()
        setupFirstShownLiterals()
        setupVerticalTextAlert()
        setupRX()
    }

    convenience init(postingSource: PostingSource, postCategory: PostCategory?, isBlockingPosting: Bool) {
        let mediaPermissions: MediaPermissions = LGMediaPermissions()
        let keyValueStorage = KeyValueStorage.sharedInstance
        let filesManager = LGFilesManager()
        let featureFlags = FeatureFlags.sharedInstance
        self.init(postingSource: postingSource,
                  postCategory: postCategory,
                  isBlockingPosting: isBlockingPosting,
                  keyValueStorage: keyValueStorage,
                  filesManager: filesManager,
                  featureFlags: featureFlags,
                  mediaPermissions: mediaPermissions)
    }

    override func didBecomeActive(_ firstTime: Bool) {
        switch cameraState.value {
        case .pendingAskPermissions, .missingPermissions:
            checkCameraState()
        case .takingPhoto, .recordingVideo, .previewPhoto, .previewVideo, .capture:
            break
        }
    }


    // MARK: - Public methods

    func closeButtonPressed() {
        switch cameraState.value {
        case .takingPhoto, .recordingVideo, .previewPhoto, .previewVideo:
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

    func photoModeButtonPressed() {
        cameraMode.value = .photo
    }

    func videoModeButtonPressed() {
        cameraMode.value = .video
    }

    func takePhotoButtonPressed() {
        cameraState.value = .takingPhoto
    }

    func recordVideoButtonPressed() {
        cameraState.value = .recordingVideo
    }

    func photoTaken(_ photo: UIImage) {
        imageSelected.value = photo
        cameraState.value = .previewPhoto
    }

    func videoRecorded(video: RecordedVideo) {
        if video.duration > Constants.videoMinRecordingDuration {
            videoRecorded.value = video
            cameraState.value = .previewVideo
        } else {
            backToCaptureMode()
        }
    }

    func videoRecordingFailed() {
        if let url = videoRecorded.value?.url {
            filesManager.removeFile(at: url)
        }
        backToCaptureMode()
    }

    func retryPhotoButtonPressed() {
        backToCaptureMode()
    }

    func usePhotoButtonPressed() {
        switch cameraMode.value {
        case .photo:
            guard let image = imageSelected.value else { return }
            cameraDelegate?.productCameraDidTakeImage(image)
        case .video:
            guard let video = videoRecorded.value else { return }
            cameraDelegate?.productCameraDidRecordVideo(video: video)
        }
    }

    func infoButtonPressed() {
        switch cameraState.value {
        case .missingPermissions:
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else { return }
            UIApplication.shared.openURL(settingsUrl)
        case .pendingAskPermissions:
            askForPermissions()
        case .takingPhoto, .recordingVideo, .capture, .previewPhoto, .previewVideo:
            break
        }
    }

    func hideFirstTimeAlert() {
        shouldShowFirstTimeAlert.value = false
    }

    func hideVerticalTextAlert() {
        shouldShowVerticalText.value = false
    }
    
    func learnMorePressed() {
        cameraDelegate?.productCameraLearnMoreButton()
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
            case .takingPhoto, .recordingVideo, .previewPhoto, .previewVideo:
                strongSelf.infoShown.value = false
            case .capture:
                strongSelf.infoShown.value = false
                strongSelf.showFirstTimeAlertIfNeeded()
            }
        }.disposed(by: disposeBag)
        
        cameraState.asObservable().map{ $0.previewMode }.subscribeNext{ [weak self] previewMode in
            self?.cameraDelegate?.productCameraRequestHideTabs(previewMode)
        }.disposed(by: disposeBag)

        cameraState.asObservable().map{ $0.cameraLock }.subscribeNext{ [weak self] cameraLock in
            self?.cameraDelegate?.productCameraRequestsScrollLock(cameraLock)
        }.disposed(by: disposeBag)

        visible.asObservable().distinctUntilChanged().filter{ $0 }
            .subscribeNext{ [weak self] _ in self?.didBecomeVisible() }
            .disposed(by: disposeBag)
        
        shouldShowFirstTimeAlert.asObservable().filter {$0}.bind { [weak self] _ in
            self?.firstTimeAlertDidShow()
        }.disposed(by: disposeBag)
    }
    
    private func setupFirstShownLiterals() {
        firstTimeTitle = LGLocalizedString.productPostCameraFirstTimeAlertTitle
        firstTimeSubtitle = LGLocalizedString.productPostCameraFirstTimeAlertSubtitle
    }
    
    private func setupVerticalTextAlert() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(5)) { [weak self] in
            self?.hideVerticalTextAlert()
        }
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
            cameraState.value = .missingPermissions(LGLocalizedString.productPostCameraPermissionsSubtitle)
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
        case .takingPhoto, .recordingVideo, .previewPhoto, .previewVideo, .missingPermissions:
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

    private func backToCaptureMode() {
        videoRecorded.value = nil
        imageSelected.value = nil
        cameraState.value = .capture
    }
}


fileprivate extension RealEstateTutorial {
    var shouldShowLearnMoreButton: Bool {
        return self == .oneScreen || self == .twoScreens || self == .threeScreens
    }
}


// MARK: - Camera Enum extensions

extension CameraState {
    var captureMode: Bool {
        switch self {
        case .pendingAskPermissions, .missingPermissions, .previewPhoto, .previewVideo:
            return false
        case .takingPhoto, .recordingVideo, .capture:
            return true
        }
    }

    var previewMode: Bool {
        switch self {
        case .pendingAskPermissions, .missingPermissions, .capture, .takingPhoto, .recordingVideo:
            return false
        case .previewPhoto, .previewVideo:
            return true
        }
    }

    var previewPhotoMode: Bool {
        switch self {
        case .pendingAskPermissions, .missingPermissions, .capture, .takingPhoto, .recordingVideo, .previewVideo:
            return false
        case .previewPhoto:
            return true
        }
    }

    var previewVideoMode: Bool {
        switch self {
        case .pendingAskPermissions, .missingPermissions, .capture, .takingPhoto, .recordingVideo, .previewPhoto:
            return false
        case .previewVideo:
            return true
        }
    }
    
    var headerStep: BlockingPostingHeaderStep? {
        switch self {
        case .capture:
            return .takePicture
        case .previewPhoto, .previewVideo:
            return .confirmPicture
        case .pendingAskPermissions, .missingPermissions, .takingPhoto, .recordingVideo:
            return nil
        }
    }
    
    var shouldShowCloseButtonBlockingPosting: Bool {
        switch self {
        case .capture, .takingPhoto, .recordingVideo, .previewPhoto, .previewVideo:
            return false
        case .pendingAskPermissions, .missingPermissions:
            return true
        }
    }

    fileprivate var cameraLock: Bool {
        switch self {
        case .pendingAskPermissions, .missingPermissions, .capture:
            return false
        case .previewPhoto, .previewVideo, .takingPhoto, .recordingVideo:
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


