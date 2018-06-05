import LGCoreKit
import RxSwift
import LGComponents

protocol PostListingViewModelDelegate: BaseViewModelDelegate {}

enum PostingSource {
    case tabBar
    case sellButton
    case deepLink
    case onboardingButton
    case onboardingCamera
    case onboardingBlockingPosting
    case notifications
    case deleteListing
    case realEstatePromo
    case mostSearchedTabBarCamera
    case mostSearchedTrendingExpandable
    case mostSearchedTagsExpandable
    case mostSearchedCategoryHeader
    case mostSearchedCard
    case mostSearchedUserProfile
}


class PostListingViewModel: BaseViewModel {
    
    static let carDetailsNumber: Int = 3
    
    weak var delegate: PostListingViewModelDelegate?
    weak var navigator: PostListingNavigator?

    var usePhotoButtonText: String {
        if sessionManager.loggedIn {
            return R.Strings.productPostUsePhoto
        } else {
            return R.Strings.productPostUsePhotoNotLogged
        }
    }
    var useVideoButtonText: String {
        if sessionManager.loggedIn {
            return R.Strings.productPostUsePhoto
        } else {
            return R.Strings.productPostUseVideoNotLogged
        }
    }
    var confirmationOkText: String {
        if sessionManager.loggedIn {
            return R.Strings.productPostProductPosted
        } else {
            if uploadingVideo != nil {
                return R.Strings.productPostProductPostedNotLoggedVideoPosting
            } else {
                return R.Strings.productPostProductPostedNotLogged
            }
        }
    }
    
    var isRealEstate: Bool {
        guard let category = postCategory, category == .realEstate else { return false }
        return true
    }
    
    var realEstateTutorialPages: [LGTutorialPage]? {
        return LGTutorialPage.makeRealEstateTutorial(typeOfOnboarding: featureFlags.realEstateTutorial)
    }

    var availablePostCategories: [PostCategory] {
        var categories: [PostCategory] = [.car, .motorsAndAccessories, .otherItems(listingCategory: nil)]
        if featureFlags.realEstateEnabled.isActive {
            categories.append(.realEstate)
        }
        if featureFlags.servicesCategoryOnSalchichasMenu.isActive {
            categories.append(.services)
        }
        return categories.sorted(by: {
            $0.sortWeight(featureFlags: featureFlags) > $1.sortWeight(featureFlags: featureFlags)
        })
    }

    let state: Variable<PostListingState>
    let category: Variable<PostCategory?>

    let postDetailViewModel: PostListingBasicDetailViewModel
    let postListingCameraViewModel: PostListingCameraViewModel
    let postingSource: PostingSource
    let postCategory: PostCategory?
    let isBlockingPosting: Bool
    let machineLearningSupported: Bool
    
    fileprivate let listingRepository: ListingRepository
    fileprivate let categoryRepository: CategoryRepository
    fileprivate let fileRepository: FileRepository
    fileprivate let preSignedUploadUrlRepository: PreSignedUploadUrlRepository
    fileprivate let carsInfoRepository: CarsInfoRepository
    fileprivate let currencyHelper: CurrencyHelper
    fileprivate let tracker: Tracker
    fileprivate let sessionManager: SessionManager
    fileprivate let featureFlags: FeatureFlaggeable
    fileprivate let locationManager: LocationManager
    fileprivate let keyValueStorage: KeyValueStorageable
    
    fileprivate var imagesSelected: [UIImage]?
    fileprivate var uploadedImageSource: EventParameterPictureSource?
    fileprivate var uploadedVideoLength: TimeInterval?
    fileprivate var recordedVideo: RecordedVideo?
    fileprivate var uploadingVideo: VideoUpload?
    fileprivate var predictionData: MLPredictionDetailsViewData?
    
    let selectedDetail = Variable<CategoryDetailSelectedInfo?>(nil)
    var selectedCarAttributes: CarAttributes = CarAttributes.emptyCarAttributes()
    var selectedRealEstateAttributes: RealEstateAttributes = RealEstateAttributes.emptyRealEstateAttributes()
    
    var realEstateEnabled: Bool {
        return featureFlags.realEstateEnabled.isActive
    }
    
    var maxNumberImages: Int {
        return Constants.maxImageCount
    }
    
    var shouldShowInfoButton: Bool {
        guard let category = postCategory?.listingCategory else { return false }
        return category.isRealEstate && featureFlags.realEstateTutorial.shouldShowInfoButton
    }

    var shouldShowVideoFooter: Bool {
        guard let category = postCategory?.listingCategory else { return false }
        return category.isProduct && featureFlags.videoPosting.isActive
    }
    
    fileprivate let disposeBag: DisposeBag

    var categories: [ListingCategory] = []

    
    // MARK: - Lifecycle

    convenience init(source: PostingSource,
                     postCategory: PostCategory?,
                     listingTitle: String?,
                     isBlockingPosting: Bool,
                     machineLearningSupported: Bool) {
        self.init(source: source,
                  postCategory: postCategory,
                  listingTitle: listingTitle,
                  isBlockingPosting: isBlockingPosting,
                  machineLearningSupported: machineLearningSupported,
                  listingRepository: Core.listingRepository,
                  categoryRepository: Core.categoryRepository,
                  fileRepository: Core.fileRepository,
                  preSignedUploadUrlRepository: Core.preSignedUploadUrlRepository,
                  carsInfoRepository: Core.carsInfoRepository,
                  tracker: TrackerProxy.sharedInstance,
                  sessionManager: Core.sessionManager,
                  featureFlags: FeatureFlags.sharedInstance,
                  locationManager: Core.locationManager,
                  currencyHelper: Core.currencyHelper,
                  keyValueStorage: KeyValueStorage.sharedInstance)
    }

    init(source: PostingSource,
         postCategory: PostCategory?,
         listingTitle: String?,
         isBlockingPosting: Bool,
         machineLearningSupported: Bool,
         listingRepository: ListingRepository,
         categoryRepository: CategoryRepository,
         fileRepository: FileRepository,
         preSignedUploadUrlRepository: PreSignedUploadUrlRepository,
         carsInfoRepository: CarsInfoRepository,
         tracker: Tracker,
         sessionManager: SessionManager,
         featureFlags: FeatureFlaggeable,
         locationManager: LocationManager,
         currencyHelper: CurrencyHelper,
         keyValueStorage: KeyValueStorageable) {
        self.state = Variable<PostListingState>(PostListingState(postCategory: postCategory, title: listingTitle))
        self.category = Variable<PostCategory?>(postCategory)
        
        self.postingSource = source
        self.postCategory = postCategory
        self.isBlockingPosting = isBlockingPosting
        self.machineLearningSupported = machineLearningSupported
        self.listingRepository = listingRepository
        self.categoryRepository = categoryRepository
        self.fileRepository = fileRepository
        self.preSignedUploadUrlRepository = preSignedUploadUrlRepository
        self.carsInfoRepository = carsInfoRepository
        self.postDetailViewModel = PostListingBasicDetailViewModel()
        self.postListingCameraViewModel = PostListingCameraViewModel(postingSource: source,
                                                                     postCategory: postCategory,
                                                                     isBlockingPosting: isBlockingPosting,
                                                                     machineLearningSupported: machineLearningSupported)
        self.tracker = tracker
        self.sessionManager = sessionManager
        self.featureFlags = featureFlags
        self.locationManager = locationManager
        self.currencyHelper = currencyHelper
        self.keyValueStorage = keyValueStorage
        self.disposeBag = DisposeBag()
        super.init()
        self.postDetailViewModel.delegate = self
        
        setupRx()
        setupCarsRx()
        setupCategories()
    }

    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        guard firstTime, !isBlockingPosting else { return }
        trackVisit()
    }

    private func setupCategories() {
        categoryRepository.index(servicesIncluded: false, carsIncluded: false, realEstateIncluded: false) { [weak self] result in
            guard let categories = result.value else { return }
            self?.categories = categories
        }
    }

    // MARK: - Public methods

    func categoryAtIndex(_ index: Int) -> ListingCategory? {
        guard 0..<categories.count ~= index else { return nil }
        return categories[index]
    }

    func categoryNameAtIndex(_ index: Int) -> String {
        guard 0..<categories.count ~= index else { return "" }
        return categories[index].name
    }
    
    func revertToPreviousStep() {
        state.value = state.value.revertToPreviousStep()
    }
   
    func retryButtonPressed() {
        guard let source = uploadedImageSource else { return }
        if let images = imagesSelected {
            imagesSelected(images, source: source, predictionData: predictionData)
        } else if let uploadingVideo = uploadingVideo {
            if uploadingVideo.snapshot == nil {
                uploadVideoSnapshot(uploadingVideo: uploadingVideo)
            } else {
                state.value = state.value.updatingStepToCreatingPreSignedUrl(uploadingVideo: uploadingVideo)
                createPreSignedUploadUrlForVideo(uploadingVideo: uploadingVideo)
            }
        }
    }

    func infoButtonPressed() {
        openOnboardingRealEstate(origin: .postingIconInfo)
    }
    
    func learnMorePressed() {
        openOnboardingRealEstate(origin: .postingLearnMore)
    }

    func imagesSelected(_ images: [UIImage], source: EventParameterPictureSource, predictionData: MLPredictionDetailsViewData?) {
        if isBlockingPosting {
            openQueuedRequestsLoading(images: images, imageSource: source)
        } else {
            uploadImages(images, source: source, predictionData: predictionData)
        }
    }

    func videoRecorded(video: RecordedVideo) {
        let uploadingVideo = VideoUpload(recordedVideo: video, snapshot: nil, videoId: nil)
        self.uploadingVideo = uploadingVideo
        uploadVideoSnapshot(uploadingVideo: uploadingVideo)
    }
    
    private func openOnboardingRealEstate(origin: EventParameterTypePage) {
        guard let pages = LGTutorialPage.makeRealEstateTutorial(typeOfOnboarding: featureFlags.realEstateTutorial) else { return }
        navigator?.openRealEstateOnboarding(pages: pages, origin: origin, tutorialType: .realEstate)
    }
    
    fileprivate func uploadImages(_ images: [UIImage], source: EventParameterPictureSource, predictionData: MLPredictionDetailsViewData? = nil) {
        uploadedImageSource = source
        imagesSelected = images
        self.predictionData = predictionData

        guard sessionManager.loggedIn else {
            state.value = state.value.updating(pendingToUploadImages: images, predictionData: predictionData)
            return
        }

        state.value = state.value.updatingStepToUploadingImages()

        fileRepository.upload(images, progress: nil) { [weak self] result in
            guard let strongSelf = self else { return }

            if let images = result.value {
                strongSelf.state.value = strongSelf.state.value.updatingToSuccessUpload(uploadedImages: images)
            } else if let error = result.error {
                strongSelf.state.value = strongSelf.state.value.updating(uploadError: error)
            }
        }
    }

    fileprivate func uploadVideoSnapshot(uploadingVideo: VideoUpload) {

        uploadedImageSource = .videoCamera
        guard sessionManager.loggedIn else {
            state.value = state.value.updating(pendingToUploadVideo: uploadingVideo.recordedVideo)
            return
        }
        state.value = state.value.updatingStepToUploadingVideoSnapshot(uploadingVideo: uploadingVideo)
        fileRepository.upload([uploadingVideo.recordedVideo.snapshot], progress: nil) { [weak self] result in
            guard let strongSelf = self else { return }

            if let image = result.value?.first {
                let newUploadingVideo = VideoUpload(recordedVideo: uploadingVideo.recordedVideo, snapshot: image, videoId: nil)
                strongSelf.uploadingVideo = newUploadingVideo
                strongSelf.state.value = strongSelf.state.value.updatingStepToCreatingPreSignedUrl(uploadingVideo: newUploadingVideo)
                strongSelf.createPreSignedUploadUrlForVideo(uploadingVideo: newUploadingVideo)
            } else if let error = result.error {
                strongSelf.state.value = strongSelf.state.value.updating(uploadError: error)
            }
        }
    }

    fileprivate func createPreSignedUploadUrlForVideo(uploadingVideo: VideoUpload) {

        preSignedUploadUrlRepository.create(fileExtension: Constants.videoFileExtension) { [weak self] result in
            guard let strongSelf = self else { return }

            if let preSignedUploadUrl = result.value {
                let uploadingVideo = VideoUpload(recordedVideo: uploadingVideo.recordedVideo,
                                                    snapshot: uploadingVideo.snapshot,
                                                    videoId: preSignedUploadUrl.form.fileKey)
                strongSelf.state.value = strongSelf.state.value.updatingStepToUploadingVideoFile(uploadingVideo: uploadingVideo)
                strongSelf.uploadVideo(uploadingVideo: uploadingVideo, preSignedUploadUrl: preSignedUploadUrl)
            } else if let error = result.error {
                strongSelf.state.value = strongSelf.state.value.updating(uploadError: error)
            }
        }
    }

    fileprivate func uploadVideo(uploadingVideo: VideoUpload, preSignedUploadUrl: PreSignedUploadUrl) {

        preSignedUploadUrlRepository.upload(url: preSignedUploadUrl.form.action,
                                            file: uploadingVideo.recordedVideo.url,
                                            inputs: preSignedUploadUrl.form.inputs,
                                            progress: nil,
                                            completion: { [weak self] result in
            guard let strongSelf = self else { return }

            if result.value != nil {
                guard let video = LGVideo(videoUpload: uploadingVideo) else {
                    strongSelf.state.value = strongSelf.state.value.updating(uploadError: .internalError(message: "Error creating LGVideo from VideoUpload "))
                    return
                }
                strongSelf.uploadedVideoLength = uploadingVideo.recordedVideo.duration
                strongSelf.state.value = strongSelf.state.value.updatingToSuccessUpload(uploadedVideo: video)
            } else if let error = result.error {
                strongSelf.state.value = strongSelf.state.value.updating(uploadError: error)
            }
        })
    }
    
    fileprivate func openQueuedRequestsLoading(images: [UIImage], imageSource: EventParameterPictureSource) {
        guard let listingParams = makeListingParams() else { return }
        navigator?.openQueuedRequestsLoading(images: images,
                                             listingCreationParams: listingParams,
                                             imageSource: imageSource,
                                             postingSource: postingSource)
    }
    
    func showRealEstateTutorial(origin: EventParameterTypePage) {
        guard postCategory == .realEstate && !keyValueStorage[.realEstateTutorialShown] else { return }
        guard let pages = realEstateTutorialPages else { return }
        keyValueStorage[.realEstateTutorialShown] = true
        navigator?.openRealEstateOnboarding(pages: pages, origin: origin, tutorialType: .realEstate)
    }
    
    func closeButtonPressed() {
        if state.value.pendingToUploadMedia {
            openPostAbandonAlertNotLoggedIn()
        } else {
            if state.value.lastImagesUploadResult?.value == nil && state.value.uploadedVideo == nil {
                if isBlockingPosting {
                    trackPostSellAbandon()
                }
                navigator?.cancelPostListing()
            } else if let listingParams = makeListingParams() {
                let machineLearningTrackingInfo = MachineLearningTrackingInfo(data: state.value.predictionData,
                                                                              predictiveFlow: machineLearningSupported,
                                                                              predictionActive: postListingCameraViewModel.isLiveStatsPaused)
                let trackingInfo = PostListingTrackingInfo(buttonName: .close,
                                                           sellButtonPosition: postingSource.sellButtonPosition,
                                                           imageSource: uploadedImageSource,
                                                           videoLength: uploadedVideoLength,
                                                           price: postDetailViewModel.price.value,
                                                           typePage: postingSource.typePage,
                                                           mostSearchedButton: postingSource.mostSearchedButton,
                                                           machineLearningInfo: machineLearningTrackingInfo)
                navigator?.closePostProductAndPostInBackground(params: listingParams,
                                                               trackingInfo: trackingInfo)
            } else {
                navigator?.cancelPostListing()
            }
        }
    }
}

// MARK: - Cars vertical

extension PostListingViewModel {
    
    fileprivate var carMakes: [CarsMake] {
        return carsInfoRepository.retrieveCarsMakes()
    }
    
    fileprivate var selectedCarMakeInfo: CarInfoWrapper? {
        guard let makeId = selectedCarAttributes.makeId,
            let makeName = selectedCarAttributes.make else {
                return nil
        }
        return CarInfoWrapper(id: makeId, name: makeName, type: .make)
    }
    
    fileprivate func carModels(forMakeId makeId: String) -> [CarsModel] {
        return carsInfoRepository.retrieveCarsModelsFormake(makeId: makeId)
    }
    
    fileprivate var selectedCarModelInfo: CarInfoWrapper? {
        guard let modelId = selectedCarAttributes.modelId,
            let modelName = selectedCarAttributes.model else {
                return nil
        }
        return CarInfoWrapper(id: modelId, name: modelName, type: .model)
    }
    
    fileprivate var carYears: [Int] {
        return carsInfoRepository.retrieveValidYears(withFirstYear: nil, ascending: false)
    }
    
    fileprivate var selectedCarYearInfo: CarInfoWrapper? {
        guard let year = selectedCarAttributes.year else {
                return nil
        }
        let stringYear = String(year)
        return CarInfoWrapper(id: stringYear, name: stringYear, type: .year)
    }
    
    func carInfo(forDetail detail: CarDetailType) -> (carInfoWrappers: [CarInfoWrapper], selectedIndex: Int?) {
        switch detail {
        case .make:
            let values: [CarInfoWrapper] = carMakes
                .map { CarInfoWrapper(id: $0.makeId, name: $0.makeName, type: .make) }
            var selectedIndex: Int? = nil
            if let selectedMakeInfo = selectedCarMakeInfo {
                selectedIndex = values.index(of: selectedMakeInfo)
            }
            return (carInfoWrappers: values, selectedIndex: selectedIndex)
        case .model:
            guard let makeId = selectedCarMakeInfo?.id else { return ([], nil) }
            let values: [CarInfoWrapper] = carModels(forMakeId: makeId)
                .map { CarInfoWrapper(id: $0.modelId, name: $0.modelName, type: .model) }
            var selectedIndex: Int? = nil
            if let selectedModelInfo = selectedCarModelInfo {
                selectedIndex = values.index(of: selectedModelInfo)
            }
            return (carInfoWrappers: values, selectedIndex: selectedIndex)
        case .year:
            let values: [CarInfoWrapper] = carYears
                .map { CarInfoWrapper(id: String($0), name: String($0), type: .year) }
            var selectedIndex: Int? = nil
            if let selectedYearInfo = selectedCarYearInfo {
                selectedIndex = values.index(of: selectedYearInfo)
            }
            return (carInfoWrappers: values, selectedIndex: selectedIndex)
        }
    }
    
    var currentCarDetailsProgress: Float {
        let details = PostListingViewModel.carDetailsNumber
        var detailsFilled = 0
        detailsFilled += selectedCarAttributes.isMakeEmpty ? 0 : 1
        detailsFilled += selectedCarAttributes.isModelEmpty ? 0 : 1
        detailsFilled += selectedCarAttributes.isYearEmpty ? 0 : 1
        guard details > 0 else { return 1 }
        return Float(detailsFilled) / Float(details)
    }
    
    func postCarDetailDone() {
        state.value = state.value.updating(carInfo: selectedCarAttributes)
    }
    
    // MARK: - Setup rx
    
    func setupCarsRx() {
        selectedDetail.asObservable().subscribeNext { [weak self] (categoryDetailSelectedInfo) in
            guard let categoryDetail = categoryDetailSelectedInfo else { return }
            guard let strongSelf = self else { return}
            switch categoryDetail.type {
            case .make:
                strongSelf.selectedCarAttributes = strongSelf.selectedCarAttributes.updating(makeId: categoryDetail.id,
                                                                                             make: categoryDetail.name,
                                                                                             modelId: CarAttributes.emptyModel,
                                                                                             model: CarAttributes.emptyModel)
            case .model:
                strongSelf.selectedCarAttributes = strongSelf.selectedCarAttributes.updating(modelId: categoryDetail.id,
                                                                                             model: categoryDetail.name)
            case .year:
                strongSelf.selectedCarAttributes = strongSelf.selectedCarAttributes.updating(year: Int(categoryDetail.id))
            }
        }.disposed(by: disposeBag)
    }
}

// MARK: - PostListingBasicDetailViewModelDelegate

extension PostListingViewModel: PostListingBasicDetailViewModelDelegate {
    func postListingDetailDone(_ viewModel: PostListingBasicDetailViewModel) {
        state.value = state.value.updating(price: viewModel.listingPrice)
    }
}


// MARK: - Private methods

fileprivate extension PostListingViewModel {
    func setupRx() {
        category.asObservable().subscribeNext { [weak self] category in
            guard let strongSelf = self, let category = category else { return }
            strongSelf.state.value = strongSelf.state.value.updating(category: category)
        }.disposed(by: disposeBag)
        
        state.asObservable().filter { $0.step == .finished }.bind { [weak self] _ in
            self?.postListing()
        }.disposed(by: disposeBag)
        
        state.asObservable().filter { $0.step == .addingDetails }.bind { [weak self] _ in
            self?.openPostingDetails()
            }.disposed(by: disposeBag)
        
        state.asObservable().filter { $0.step == .uploadSuccess }.bind { [weak self] _ in
            // Keep one second delay in order to give time to read the product posted message.
            delay(1) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.state.value = strongSelf.state.value.updatingAfterUploadingSuccess(predictionData: strongSelf.predictionData)
            }
        }.disposed(by: disposeBag)
    }
    
    func openPostAbandonAlertNotLoggedIn() {
        let title = R.Strings.productPostCloseAlertTitle
        let message = R.Strings.productPostCloseAlertDescription
        let cancelAction = UIAction(interface: .text(R.Strings.productPostCloseAlertCloseButton), action: { [weak self] in
            self?.navigator?.cancelPostListing()
        })
        let postAction = UIAction(interface: .text(R.Strings.productPostCloseAlertOkButton), action: { [weak self] in
            self?.postListing()
        })
        delegate?.vmShowAlert(title, message: message, actions: [cancelAction, postAction])
    }
    
    func postListing() {
        let machineLearningTrackingInfo = MachineLearningTrackingInfo(data: state.value.predictionData,
                                                                      predictiveFlow: machineLearningSupported,
                                                                      predictionActive: postListingCameraViewModel.isLiveStatsPaused)
        let trackingInfo = PostListingTrackingInfo(buttonName: .done,
                                                   sellButtonPosition: postingSource.sellButtonPosition,
                                                   imageSource: uploadedImageSource,
                                                   videoLength: uploadedVideoLength,
                                                   price: postDetailViewModel.price.value,
                                                   typePage: postingSource.typePage,
                                                   mostSearchedButton: postingSource.mostSearchedButton,
                                                   machineLearningInfo: machineLearningTrackingInfo)
        if sessionManager.loggedIn {
            guard state.value.lastImagesUploadResult?.value != nil || state.value.uploadedVideo != nil,
                let listingCreationParams = makeListingParams() else { return }
            navigator?.closePostProductAndPostInBackground(params: listingCreationParams,
                                                           trackingInfo: trackingInfo)
        } else if state.value.pendingToUploadMedia {
            let loggedInAction = { [weak self] in
                guard let listingParams = self?.makeListingParams() else { return }
                self?.navigator?.closePostProductAndPostLater(params: listingParams,
                                                              images: self?.state.value.pendingToUploadImages,
                                                              video: self?.state.value.pendingToUploadVideo,
                                                              trackingInfo: trackingInfo)
            }
            let cancelAction = { [weak self] in
                guard let _ = self?.state.value else { return }
                self?.navigator?.cancelPostListing()
            }
            navigator?.openLoginIfNeededFromListingPosted(from: .sell, loggedInAction: loggedInAction, cancelAction: cancelAction)

        } else {
            navigator?.cancelPostListing()
        }
    }
    
    func openPostingDetails() {
        navigator?.startDetails(postListingState: state.value,
                                uploadedImageSource: uploadedImageSource,
                                uploadedVideoLength: uploadedVideoLength,
                                postingSource: postingSource,
                                postListingBasicInfo: postDetailViewModel)
    }
    
    func makeListingParams() -> ListingCreationParams? {
        guard let location = locationManager.currentLocation?.location else { return nil }
        let description = postDetailViewModel.listingDescription ?? ""
        let postalAddress = locationManager.currentLocation?.postalAddress ?? PostalAddress.emptyAddress()
        let currency = currencyHelper.currencyWithCountryCode(postalAddress.countryCode ?? Constants.currencyDefault)
        
        var title: String?
        if let listingTitle = postDetailViewModel.listingTitle {
            title = listingTitle
        } else if let verticalGeneratedTitle = state.value.verticalAttributes?.generatedTitle(postingFlowType: featureFlags.postingFlowType) {
            title = verticalGeneratedTitle
        } else if let stateTitle = state.value.title {
            title = stateTitle
        }
        
        return ListingCreationParams.make(title: title,
                                          description: description,
                                          currency: currency,
                                          location: location,
                                          postalAddress: postalAddress,
                                          postListingState: state.value)
    }
}


fileprivate extension RealEstateTutorial {
    var shouldShowInfoButton: Bool {
        return self == .oneScreen || self == .twoScreens || self == .threeScreens
    }
}


// MARK: - Tracking

fileprivate extension PostListingViewModel {
    func trackVisit() {
        let event = TrackerEvent.listingSellStart(postingSource.typePage,
                                                  buttonName: postingSource.buttonName,
                                                  sellButtonPosition: postingSource.sellButtonPosition,
                                                  category: postCategory?.listingCategory,
                                                  mostSearchedButton: postingSource.mostSearchedButton,
                                                  predictiveFlow: false)
        tracker.trackEvent(event)
    }
    
    fileprivate func trackPostSellAbandon() {
        let event = TrackerEvent.listingSellAbandon(abandonStep: .cameraPermissions)
        tracker.trackEvent(event)
    }
}

extension PostingSource {
    var typePage: EventParameterTypePage {
        switch self {
        case .tabBar, .sellButton:
            return .sell
        case .deepLink:
            return .external
        case .onboardingButton, .onboardingCamera, .onboardingBlockingPosting:
            return .onboarding
        case .notifications:
            return .notifications
        case .deleteListing:
            return .listingDelete
        case .mostSearchedTabBarCamera, .mostSearchedTrendingExpandable, .mostSearchedTagsExpandable,
             .mostSearchedCategoryHeader, .mostSearchedCard, .mostSearchedUserProfile:
            return .mostSearched
        case .realEstatePromo:
            return .realEstatePromo
        }
    }

    var buttonName: EventParameterButtonNameType? {
        switch self {
        case .tabBar, .sellButton, .deepLink, .notifications, .deleteListing, .mostSearchedTabBarCamera,
             .mostSearchedTrendingExpandable, .mostSearchedTagsExpandable, .mostSearchedCategoryHeader,
             .mostSearchedCard, .mostSearchedUserProfile, .onboardingBlockingPosting:
            return nil
        case .onboardingButton:
            return .sellYourStuff
        case .onboardingCamera:
            return .startMakingCash
        case .realEstatePromo:
            return .realEstatePromo
        }
    }
    
    var sellButtonPosition: EventParameterSellButtonPosition {
        switch self {
        case .tabBar:
            return .tabBar
        case .sellButton:
            return .floatingButton
        case .onboardingButton, .onboardingCamera, .onboardingBlockingPosting, .deepLink, .notifications, .deleteListing, .mostSearchedTabBarCamera,
             .mostSearchedTrendingExpandable, .mostSearchedTagsExpandable, .mostSearchedCategoryHeader,
             .mostSearchedCard, .mostSearchedUserProfile:
            return .none
        case .realEstatePromo:
            return .realEstatePromo
        }
    }
    
    var mostSearchedButton: EventParameterMostSearched {
        switch self {
        case .tabBar, .sellButton, .deepLink, .onboardingButton, .onboardingCamera, .onboardingBlockingPosting,
             .notifications, .deleteListing, .realEstatePromo:
            return .notApply
        case .mostSearchedTabBarCamera:
            return .tabBarCamera
        case .mostSearchedTrendingExpandable:
            return .trendingExpandableButton
        case .mostSearchedTagsExpandable:
            return .postingTags
        case .mostSearchedCategoryHeader:
            return .feedBubble
        case .mostSearchedCard:
            return .feedCard
        case .mostSearchedUserProfile:
            return .userProfile
        }
    }
}
