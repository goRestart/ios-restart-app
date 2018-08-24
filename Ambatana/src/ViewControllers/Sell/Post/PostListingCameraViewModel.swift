import Foundation
import RxSwift
import LGCoreKit
import LGComponents

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
    let videoRecordingErrorMessage = PublishSubject<String?>()
    
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
    let machineLearningSupported: Bool
    
    private let featureFlags: FeatureFlaggeable
    private let mediaPermissions: MediaPermissions
    private let tracker: TrackerProxy
    
    let postCategory: PostCategory?
    
    var verticalPromotionMessage: String? {
        return postCategory?.postCameraTitle(forFeatureFlags: featureFlags)
    }
    
    var learnMoreMessage: NSAttributedString {
        var titleAttributes = [NSAttributedStringKey : Any]()
        titleAttributes[NSAttributedStringKey.foregroundColor] = UIColor.white
        titleAttributes[NSAttributedStringKey.underlineStyle] = NSUnderlineStyle.styleSingle.rawValue
        titleAttributes[NSAttributedStringKey.font] = UIFont.boldSystemFont(ofSize: 23)
        let text = NSAttributedString(string: R.Strings.realEstateCameraViewRealEstateLearnMore,
                                      attributes: titleAttributes)
        return text
    }
    
    let machineLearning: MachineLearning
    let liveStats = Variable<MachineLearningStats?>(nil)
    let liveStatsText = Variable<String?>(nil)
    let machineLearningButtonHidden = Variable<Bool>(false)
    let isLiveStatsEnabled = Variable<Bool>(false)
    var isLiveStatsPaused: Bool = false
    
    
    // MARK: - Lifecycle
    
    init(postingSource: PostingSource, postCategory: PostCategory?, isBlockingPosting: Bool,
         machineLearningSupported: Bool, keyValueStorage: KeyValueStorage, filesManager: FilesManager,
         featureFlags: FeatureFlaggeable, mediaPermissions: MediaPermissions, machineLearning: MachineLearning, tracker: TrackerProxy) {
        self.keyValueStorage = keyValueStorage
        self.filesManager = filesManager
        self.sourcePosting = postingSource
        self.isBlockingPosting = isBlockingPosting
        self.machineLearningSupported = machineLearningSupported
        self.featureFlags = featureFlags
        self.mediaPermissions = mediaPermissions
        self.postCategory = postCategory
        self.machineLearning = machineLearning
        self.tracker = tracker
        machineLearning.isLiveStatsEnabled = machineLearningSupported
        self.isLiveStatsEnabled.value = machineLearning.isLiveStatsEnabled
        super.init()
        setupFirstShownLiterals()
        setupVerticalTextAlert()
        setupRX()
    }
    
    convenience init(postingSource: PostingSource, postCategory: PostCategory?, isBlockingPosting: Bool,
                     machineLearningSupported: Bool) {
        let mediaPermissions: MediaPermissions = LGMediaPermissions()
        let keyValueStorage = KeyValueStorage.sharedInstance
        let filesManager = LGFilesManager()
        let featureFlags = FeatureFlags.sharedInstance
        let machineLearning = LGMachineLearning()
        let tracker = TrackerProxy.sharedInstance
        
        self.init(postingSource: postingSource,
                  postCategory: postCategory,
                  isBlockingPosting: isBlockingPosting,
                  machineLearningSupported: machineLearningSupported,
                  keyValueStorage: keyValueStorage,
                  filesManager: filesManager,
                  featureFlags: featureFlags,
                  mediaPermissions: mediaPermissions,
                  machineLearning: machineLearning,
                  tracker: tracker)
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
    
    func trackPredictedData(predictedData: MLPredictionDetailsViewData) {
        tracker.trackEvent(TrackerEvent.predictedPosting(data: predictedData))
    }
    
    func closeButtonPressed() {
        switch cameraState.value {
        case .takingPhoto, .recordingVideo, .previewPhoto, .previewVideo:
            retryPhotoButtonPressed()
        case .missingPermissions, .pendingAskPermissions, .capture:
            cameraDelegate?.productCameraCloseButton()
        }
    }
    
    func machineLearningButtonPressed() {
        let isEnabled = !machineLearning.isLiveStatsEnabled
        enableLiveStats(enable: isEnabled)
    }
    
    func flashButtonPressed() {
        cameraFlashState.value = cameraFlashState.value.next
    }
    
    func cameraButtonPressed() {
        cameraSource.value = cameraSource.value.toggle
    }
    
    func takePhotoButtonPressed() {
        if machineLearning.isLiveStatsEnabled {
            pauseLiveStats()
        }
        cameraState.value = .takingPhoto
    }
    
    func recordVideoButtonPressed() {
        cameraState.value = .recordingVideo
    }
    
    func photoTaken(_ photo: UIImage, camera: CameraSource) {
        imageSelected.value = photo
        cameraState.value = .previewPhoto
        trackMediaCapture(source: .camera, camera: camera.eventParameter, predictiveFlow: machineLearningSupported)
    }
    
    func videoRecorded(video: RecordedVideo, camera: CameraSource) {
        if video.duration > SharedConstants.videoMinRecordingDuration {
            videoRecorded.value = video
            cameraState.value = .previewVideo
            trackMediaCapture(source: .videoCamera, camera: camera.eventParameter, predictiveFlow: machineLearningSupported)
        } else {
            backToCaptureMode()
            let message = R.Strings.productPostCameraVideoRecordingMinDurationMessage(Int(SharedConstants.videoMinRecordingDuration))
            videoRecordingErrorMessage.onNext(message)
            trackMediaCapture(source: .videoCamera, camera: camera.eventParameter, hasError: true, predictiveFlow: machineLearningSupported)
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
    
    func usePhotoButtonPressed(predictionData: MLPredictionDetailsViewData) {
        switch cameraMode.value {
        case .photo:
            guard let image = imageSelected.value else { return }
            cameraDelegate?.productCameraDidTakeImage(image, predictionData: predictionData)
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
    
    // MARK: - Private methods
    
    private func setupRX() {
        cameraState.asObservable().subscribeNext{ [weak self] state in
            guard let strongSelf = self else { return }
            switch state {
            case .missingPermissions(let msg):
                strongSelf.infoTitle.value = R.Strings.productPostCameraPermissionsTitle
                strongSelf.infoSubtitle.value = msg
                strongSelf.infoButton.value = R.Strings.productPostCameraPermissionsButton
                strongSelf.infoShown.value = true
            case .pendingAskPermissions:
                strongSelf.infoTitle.value = R.Strings.productPostCameraPermissionsTitle
                strongSelf.infoSubtitle.value = R.Strings.productPostCameraPermissionsSubtitle
                strongSelf.infoButton.value = R.Strings.productPostCameraPermissionsButton
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
        
        cameraMode.asObservable().subscribeNext { [weak self] cameraMode in
            guard let strongSelf = self else { return }
            if cameraMode == .photo {
                strongSelf.machineLearningButtonHidden.value = !strongSelf.machineLearningSupported
                if strongSelf.machineLearningSupported && strongSelf.isLiveStatsPaused {
                    strongSelf.resumeLiveStats()
                }
            } else if cameraMode == .video {
                if strongSelf.machineLearning.isLiveStatsEnabled {
                    strongSelf.pauseLiveStats()
                }
                strongSelf.machineLearningButtonHidden.value = true
            }
            }.disposed(by: disposeBag)
        
        cameraState.asObservable().map{ $0.captureMode }.subscribeNext{ [weak self] captureMode in
            guard let strongSelf = self else { return }
            let showMachineLearningButton = captureMode && strongSelf.machineLearningSupported && strongSelf.cameraMode.value == .photo
            strongSelf.machineLearningButtonHidden.value = !showMachineLearningButton
            }.disposed(by: disposeBag)
        
        cameraState.asObservable().filter{ $0 == .capture }.subscribeNext{ [weak self] _ in
            guard let strongSelf = self else { return }
            if strongSelf.machineLearningSupported &&
                strongSelf.cameraMode.value == .photo &&
                strongSelf.isLiveStatsPaused {
                strongSelf.resumeLiveStats()
            }
            }.disposed(by: disposeBag)
        
        machineLearning.liveStats.asObservable()
            .bind { [weak self] stats in
                guard let strongSelf = self,
                    let first = stats?.first,
                    let confidence = first.confidence else {
                        self?.liveStats.value = nil
                        return
                }
                guard strongSelf.liveStats.value?.keyword != first.keyword
                    || confidence <= SharedConstants.MachineLearning.minimumConfidenceToRemove else { return }
                
                if strongSelf.liveStats.value?.keyword != first.keyword, confidence > SharedConstants.MachineLearning.minimumConfidence {
                    strongSelf.liveStats.value = first
                } else {
                    strongSelf.liveStats.value = nil
                }
            }
            .disposed(by: disposeBag)
        
        liveStats.asObservable()
            .bind { [weak self] stats in
                guard let strongSelf = self,
                    let stats = stats else {
                        self?.liveStatsText.value = nil
                        return
                }
                let nameString = stats.keyword.capitalized
                var avgPriceString: String? = nil
                if stats.prices.count >= SharedConstants.MachineLearning.pricePositionDisplay {
                    avgPriceString = R.Strings.mlCameraSellsForText(Int(stats.prices[SharedConstants.MachineLearning.pricePositionDisplay]))
                }
                var medianDaysToSellString: String? = nil
                if stats.medianDaysToSell > 0 {
                    if stats.medianDaysToSell > SharedConstants.MachineLearning.maximumDaysToDisplay {
                        medianDaysToSellString = R.Strings.mlCameraInMoreThanDaysText(Int(SharedConstants.MachineLearning.maximumDaysToDisplay.rounded()))
                    } else {
                        medianDaysToSellString = R.Strings.mlCameraInAboutDaysText(Int(stats.medianDaysToSell.rounded()))
                    }
                }
                let allTexts = [nameString, avgPriceString, medianDaysToSellString]
                strongSelf.liveStatsText.value = allTexts.compactMap { $0 }.joined(separator: "\n")
            }
            .disposed(by: disposeBag)
    }
    
    func predictionDetailsData() -> MLPredictionDetailsViewData? {
        guard let stats = liveStats.value else { return nil }
        let price: Int? = stats.prices.count >= SharedConstants.MachineLearning.pricePositionDisplay ?
            Int(stats.prices[SharedConstants.MachineLearning.pricePositionDisplay]) : nil
        let doublePrice: Double?
        if let priceValue = price {
            doublePrice = Double(priceValue)
        } else {
            doublePrice = nil
        }
        return MLPredictionDetailsViewData(title: stats.keyword.capitalized,
                                           price: doublePrice,
                                           category: stats.category)
    }
    
    private func setupFirstShownLiterals() {
        firstTimeTitle = R.Strings.productPostCameraFirstTimeAlertTitle
        firstTimeSubtitle = R.Strings.productPostCameraFirstTimeAlertSubtitle
    }
    
    private func setupVerticalTextAlert() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(5)) { [weak self] in
            self?.hideVerticalTextAlert()
        }
    }
    
    private func checkCameraState() {
        guard mediaPermissions.isCameraAvailable else {
            cameraState.value = .missingPermissions(R.Strings.productSellCameraRestrictedError)
            return
        }
        let status = mediaPermissions.videoAuthorizationStatus
        switch (status) {
        case .authorized:
            cameraState.value = .capture
        case .denied:
            cameraState.value = .missingPermissions(R.Strings.productPostCameraPermissionsSubtitle)
        case .notDetermined:
            cameraState.value = .pendingAskPermissions
        case .restricted:
            cameraState.value = .missingPermissions(R.Strings.productPostCameraPermissionsSubtitle)
            break
        }
    }
    
    private func askForPermissions() {
        mediaPermissions.requestVideoAccess { granted in
            //This is required :(, callback is not on main thread so app would crash otherwise.
            DispatchQueue.main.async { [weak self] in
                if granted {
                    self?.cameraState.value = .capture
                    self?.trackPermissionsGrant()
                } else {
                    self?.cameraState.value = .missingPermissions(R.Strings.productPostCameraPermissionsSubtitle)
                }
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
    
    private func pauseLiveStats() {
        guard machineLearning.isLiveStatsEnabled else { return }
        isLiveStatsPaused = true
        machineLearning.isLiveStatsEnabled = false
        isLiveStatsEnabled.value = false
    }
    
    private func resumeLiveStats() {
        enableLiveStats(enable: true)
    }
    
    private func enableLiveStats(enable: Bool) {
        isLiveStatsPaused = false
        machineLearning.isLiveStatsEnabled = enable
        isLiveStatsEnabled.value = enable
        machineLearning.liveStats.value = nil
    }
    
    // MARK: - Trackings
    
    private func trackPermissionsGrant() {
        tracker.trackEvent(TrackerEvent.listingSellPermissionsGrant(type: .camera))
    }
    
    private func trackMediaCapture(source: EventParameterMediaSource,
                                   camera: EventParameterCameraSide,
                                   hasError: Bool = false,
                                   predictiveFlow: Bool) {
        tracker.trackEvent(TrackerEvent.listingSellMediaCapture(source: source,
                                                                cameraSide: camera,
                                                                hasError: EventParameterBoolean(bool: hasError),
                                                                predictiveFlow: EventParameterBoolean(bool: predictiveFlow)))
    }
}

extension CameraSource {
    var eventParameter: EventParameterCameraSide {
        switch self {
        case .front:
            return .front
        case .rear:
            return .back
        }
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
    
    static func ==(lhs: CameraState, rhs: CameraState) -> Bool {
        switch (lhs, rhs) {
        case (.pendingAskPermissions, .pendingAskPermissions):
            return true
        case (.missingPermissions(let lText), .missingPermissions(let rText)):
            return lText == rText
        case (.capture, .capture):
            return true
        case (.takingPhoto, .takingPhoto):
            return true
        case (.recordingVideo, .recordingVideo):
            return true
        case (.previewPhoto, .previewPhoto):
            return true
        case (.previewVideo, .previewVideo):
            return true
        default:
            return false
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


