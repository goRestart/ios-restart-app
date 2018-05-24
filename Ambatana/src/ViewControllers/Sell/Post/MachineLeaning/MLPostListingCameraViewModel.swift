import Foundation
import RxSwift
import LGCoreKit
import LGComponents

class MLPostListingCameraViewModel: BaseViewModel {

    weak var cameraDelegate: MLPostListingCameraViewDelegate?

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
    let shouldShowVerticalText = Variable<Bool>(true)
    var firstTimeTitle: String?
    var firstTimeSubtitle: String?
    
    private let disposeBag = DisposeBag()
    private let keyValueStorage: KeyValueStorage   //cameraAlreadyShown
    let sourcePosting: PostingSource

    private let featureFlags: FeatureFlaggeable
    private let mediaPermissions: MediaPermissions
    private let tracker: TrackerProxy
    
    let postCategory: PostCategory?
    
    var verticalPromotionMessage: String? {
        if let category = postCategory, category == .realEstate {
            return R.Strings.realEstateCameraViewRealEstateMessage
        }
        return nil
    }
    
    let machineLearning: MachineLearning
    var isLiveStatsEnabledBackup: Bool
    private let mlMinimumConfidence: Double = 0.3
    private let mlMinimumConfidenceToRemove: Double = 0.2
    private let mlMaximumDaysToDisplay: Double = 30
    private let mlPricePositionDisplay: Int = 2
    let liveStats = Variable<MachineLearningStats?>(nil)
    let liveStatsText = Variable<String?>(nil)
    
    // MARK: - Lifecycle

    init(postingSource: PostingSource, postCategory: PostCategory?, keyValueStorage: KeyValueStorage, featureFlags: FeatureFlaggeable, mediaPermissions: MediaPermissions, machineLearning: MachineLearning, tracker: TrackerProxy) {
        self.keyValueStorage = keyValueStorage
        self.sourcePosting = postingSource
        self.featureFlags = featureFlags
        self.mediaPermissions = mediaPermissions
        self.postCategory = postCategory
        self.machineLearning = machineLearning
        self.tracker = tracker
        isLiveStatsEnabledBackup = machineLearning.isLiveStatsEnabled
        super.init()
        setupFirstShownLiterals()
        setupVerticalTextAlert()
        setupRX()
    }

    convenience init(postingSource: PostingSource, postCategory: PostCategory?) {
        let mediaPermissions: MediaPermissions = LGMediaPermissions()
        let keyValueStorage = KeyValueStorage.sharedInstance
        let featureFlags = FeatureFlags.sharedInstance
        let machineLearning = LGMachineLearning()
        let tracker = TrackerProxy.sharedInstance

        self.init(postingSource: postingSource,
                  postCategory: postCategory,
                  keyValueStorage: keyValueStorage,
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
        machineLearning.isLiveStatsEnabled = !machineLearning.isLiveStatsEnabled
        isLiveStatsEnabledBackup = machineLearning.isLiveStatsEnabled
        machineLearning.liveStats.value = nil
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
        cameraState.value = .previewPhoto
    }

    func retryPhotoButtonPressed() {
        imageSelected.value = nil
        cameraState.value = .capture
    }

    func usePhotoButtonPressed(predictionData: MLPredictionDetailsViewData) {
        guard let image = imageSelected.value else { return }
        cameraDelegate?.productCameraDidTakeImage(image, predictionData: predictionData)
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
            case .takingPhoto, .previewPhoto, .previewVideo, .recordingVideo:
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
        
        machineLearning.liveStats.asObservable()
            .bind { [weak self] stats in
                guard let strongSelf = self,
                    let first = stats?.first,
                    let confidence = first.confidence else {
                        self?.liveStats.value = nil
                        return
                }
                if strongSelf.liveStats.value?.keyword != first.keyword,
                    confidence > strongSelf.mlMinimumConfidence {
                    // change stats if it's different and has a confidence higher than mlMinimumConfidence
                    strongSelf.liveStats.value = first
                } else if strongSelf.liveStats.value?.keyword == first.keyword,
                    confidence > strongSelf.mlMinimumConfidenceToRemove {
                    // keep the stats if it's the same and confidence has not gone bellow mlMinimumConfidence/5
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
                if stats.prices.count >= strongSelf.mlPricePositionDisplay {
                    avgPriceString = R.Strings.mlCameraSellsForText(Int(stats.prices[strongSelf.mlPricePositionDisplay]))
                }
                var medianDaysToSellString: String? = nil
                if stats.medianDaysToSell > 0 {
                    if stats.medianDaysToSell > strongSelf.mlMaximumDaysToDisplay {
                        medianDaysToSellString = String(format: R.Strings.mlCameraInMoreThanDaysText,
                                                        strongSelf.mlMaximumDaysToDisplay)
                    } else {
                        medianDaysToSellString = String(format: R.Strings.mlCameraInAboutDaysText,
                                                        stats.medianDaysToSell)
                    }
                }
                let allTexts = [nameString, avgPriceString, medianDaysToSellString]
                self?.liveStatsText.value = allTexts.flatMap { $0 }.joined(separator: "\n")
            }
            .disposed(by: disposeBag)
    }
    
    func predictionDetailsData() -> MLPredictionDetailsViewData? {
        guard let stats = liveStats.value else { return nil }
        let price: Int? = stats.prices.count >= mlPricePositionDisplay ? Int(stats.prices[mlPricePositionDisplay]) : nil
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
                    .capture : .missingPermissions(R.Strings.productPostCameraPermissionsSubtitle)
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
}

// MARK: - Camera Enum extensions

extension CameraState {
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
