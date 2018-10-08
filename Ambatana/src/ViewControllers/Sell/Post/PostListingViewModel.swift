import LGCoreKit
import RxSwift
import LGComponents

protocol PostListingViewModelDelegate: BaseViewModelDelegate {
    func shareOnFacebook(socialMessage: SocialMessage)
    func showCameraTab()
}

enum PostingSource: String {
    case tabBar
    case deepLink
    case onboardingButton
    case onboardingCamera
    case onboardingBlockingPosting
    case notifications
    case deleteListing
    case realEstatePromo
    case carPromo
    case servicesPromo
    case chatList
    case listingList
    case profile
    case markAsSold
    case rewardCenter
    case referralNotAvailable
}

class PostListingViewModel: BaseViewModel {
    
    static let carDetailsNumber: Int = 3
    static let maxNumberImages: Int = SharedConstants.maxImageCount
    
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
    var isService: Bool {
        return postCategory?.isService ?? false
    }

    var availablePostCategories: [PostCategory] {
        var categories: [PostCategory] = [.car, .motorsAndAccessories, .services, .otherItems(listingCategory: nil)]
        if featureFlags.realEstateEnabled.isActive {
            categories.append(.realEstate)
        }
        return categories.sorted(by: {
            $0.sortWeight(featureFlags: featureFlags) > $1.sortWeight(featureFlags: featureFlags)
        })
    }

    let state: Variable<PostListingState>
    let category: Variable<PostCategory?>

    let postDetailViewModel: PostListingBasicDetailViewModel
    let postListingCameraViewModel: PostListingCameraViewModel
    let postListingGalleryViewModel: PostListingGalleryViewModel
    let postingSource: PostingSource
    let postCategory: PostCategory?
    let isBlockingPosting: Bool
    let machineLearningSupported: Bool
    let isBulkPosting: Bool
    var bulkPostedListings: [Listing]?
    
    fileprivate let listingRepository: ListingRepository
    fileprivate let categoryRepository: CategoryRepository
    fileprivate let fileRepository: FileRepository
    fileprivate let preSignedUploadUrlRepository: PreSignedUploadUrlRepository
    fileprivate let carsInfoRepository: CarsInfoRepository
    private let myUserRepository: MyUserRepository
    fileprivate let currencyHelper: CurrencyHelper
    fileprivate let tracker: Tracker
    fileprivate let sessionManager: SessionManager
    fileprivate let featureFlags: FeatureFlaggeable
    fileprivate let locationManager: LocationManager
    fileprivate let keyValueStorage: KeyValueStorageable
    
    fileprivate var imagesSelected: [UIImage]?
    fileprivate var uploadedImageSource: EventParameterMediaSource?
    fileprivate var uploadedVideoLength: TimeInterval?
    fileprivate var recordedVideo: RecordedVideo?
    fileprivate var uploadingVideo: VideoUpload?
    fileprivate var predictionData: MLPredictionDetailsViewData?

    private var myUserId: String? {
        return myUserRepository.myUser?.objectId
    }

    private var myUserName: String? {
        return myUserRepository.myUser?.name
    }

    let videoPostingTooltipText: NSAttributedString = {
        let highlightedText = R.Strings.productPostCameraVideoRecordingTooltipHighlightedWord
        let hintText = R.Strings.productPostCameraVideoRecordingTooltip(highlightedText)
        let hintNSString = NSString(string: hintText)
        let range = hintNSString.range(of: highlightedText)
        let attributues: [NSAttributedStringKey : Any] = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 17),
                                                          NSAttributedStringKey.foregroundColor: UIColor.white]
        let hint = NSMutableAttributedString(string: hintText, attributes: attributues)
        if range.location != NSNotFound {
            hint.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.primaryColor, range: range)
        }
        return hint
    }()

    let bulkPostingTooltipText: NSAttributedString = {
        let highlightedText = R.Strings.productPostCameraBulkPostingTooltipHighlightedWord
        let hintText = R.Strings.productPostCameraBulkPostingTooltip(highlightedText)
        let hintNSString = NSString(string: hintText)
        let range = hintNSString.range(of: highlightedText)
        let attributues: [NSAttributedStringKey : Any] = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 17),
                                                          NSAttributedStringKey.foregroundColor: UIColor.white]
        let hint = NSMutableAttributedString(string: hintText, attributes: attributues)
        if range.location != NSNotFound {
            hint.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.primaryColor, range: range)
        }
        return hint
    }()
    
    let selectedDetail = Variable<CategoryDetailSelectedInfo?>(nil)
    var selectedCarAttributes: CarAttributes = CarAttributes.emptyCarAttributes()
    var selectedRealEstateAttributes: RealEstateAttributes = RealEstateAttributes.emptyRealEstateAttributes()
    
    var realEstateEnabled: Bool {
        return featureFlags.realEstateEnabled.isActive
    }

    var shouldShowVideoFooter: Bool {
        guard let category = postCategory?.listingCategory else { return false }
        return (category.isProduct && !category.isServices) && featureFlags.videoPosting.isActive
    }

    var shouldShowBulkPostingTooltip: Bool {
        return isBulkPosting && bulkPostedListings?.count ?? 0 > 0
    }
    
    fileprivate let disposeBag: DisposeBag

    var categories: [ListingCategory] = []
    var mediaSource: EventParameterMediaSource = .camera

    
    // MARK: - Lifecycle

    convenience init(source: PostingSource,
                     postCategory: PostCategory?,
                     listingTitle: String?,
                     isBlockingPosting: Bool,
                     machineLearningSupported: Bool,
                     isBulkPosting: Bool,
                     bulkPostedListings: [Listing]?) {
        self.init(source: source,
                  postCategory: postCategory,
                  listingTitle: listingTitle,
                  isBlockingPosting: isBlockingPosting,
                  machineLearningSupported: machineLearningSupported,
                  isBulkPosting: isBulkPosting,
                  bulkPostedListings: bulkPostedListings,
                  listingRepository: Core.listingRepository,
                  categoryRepository: Core.categoryRepository,
                  fileRepository: Core.fileRepository,
                  preSignedUploadUrlRepository: Core.preSignedUploadUrlRepository,
                  carsInfoRepository: Core.carsInfoRepository,
                  myUserRepository: Core.myUserRepository,
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
         isBulkPosting: Bool,
         bulkPostedListings: [Listing]?,
         listingRepository: ListingRepository,
         categoryRepository: CategoryRepository,
         fileRepository: FileRepository,
         preSignedUploadUrlRepository: PreSignedUploadUrlRepository,
         carsInfoRepository: CarsInfoRepository,
         myUserRepository: MyUserRepository,
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
        self.isBulkPosting = isBulkPosting
        self.bulkPostedListings = bulkPostedListings
        self.listingRepository = listingRepository
        self.categoryRepository = categoryRepository
        self.fileRepository = fileRepository
        self.preSignedUploadUrlRepository = preSignedUploadUrlRepository
        self.carsInfoRepository = carsInfoRepository
        self.myUserRepository = myUserRepository
        self.postDetailViewModel = PostListingBasicDetailViewModel()
        self.postListingCameraViewModel = PostListingCameraViewModel(postingSource: source,
                                                                     postCategory: postCategory,
                                                                     isBlockingPosting: isBlockingPosting,
                                                                     isBulkPosting: isBulkPosting,
                                                                     machineLearningSupported: machineLearningSupported)
        self.postListingGalleryViewModel = PostListingGalleryViewModel(postCategory: postCategory,
                                                                       isBlockingPosting: isBlockingPosting,
                                                                       maxImageSelected: PostListingViewModel.maxNumberImages)
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

    private func setupCategories() {
        categoryRepository.index { [weak self] result in
            guard let categories = result.value else { return }
            self?.categories = categories.filteringBy([.cars, .realEstate, .services, .unassigned])
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

    func imagesSelected(_ images: [UIImage], source: EventParameterMediaSource, predictionData: MLPredictionDetailsViewData?) {
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
    
    fileprivate func uploadImages(_ images: [UIImage], source: EventParameterMediaSource, predictionData: MLPredictionDetailsViewData? = nil) {
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

        trackPublish(source: source, size: nil)
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

        trackPublish(source: .videoCamera, size: uploadingVideo.fileSize)
    }

    fileprivate func createPreSignedUploadUrlForVideo(uploadingVideo: VideoUpload) {

        preSignedUploadUrlRepository.create(fileExtension: SharedConstants.videoFileExtension) { [weak self] result in
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
    
    fileprivate func openQueuedRequestsLoading(images: [UIImage], imageSource: EventParameterMediaSource) {
        guard let listingParams = makeListingParams() else { return }
        navigator?.openQueuedRequestsLoading(images: images,
                                             listingCreationParams: listingParams,
                                             imageSource: imageSource,
                                             postingSource: postingSource)
    }
    
    func closeButtonPressed() {
        
        if state.value.pendingToUploadMedia {
            openPostAbandonAlertNotLoggedIn()
        } else {
            if state.value.lastImagesUploadResult?.value == nil && state.value.uploadedVideo == nil {
                trackPostSellAbandon()
                if isBulkPosting, let listings = bulkPostedListings, listings.count > 0 {
                    navigator?.showBulkPostingPostConfirmation(listings: listings, modalStyle: true)
                } else {
                    navigator?.cancelPostListing()
                }
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
                                                           machineLearningInfo: machineLearningTrackingInfo)
                navigator?.closePostProductAndPostInBackground(params: listingParams,
                                                               trackingInfo: trackingInfo,
                                                               shareAfterPost: state.value.shareAfterPost)
            } else {
                trackPostSellAbandon()
                navigator?.cancelPostListing()
            }
        }
    }

    func mediaSourceDidChange(mediaSource: EventParameterMediaSource) {
        self.mediaSource = mediaSource
    }

    func shareFinishedIn(_ shareType: ShareType, withState state: SocialShareState) {
        continueBulkPosting()
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
        case .distance, .body, .transmission, .fuel, .drivetrain, .seat:
            return (carInfoWrappers: [], selectedIndex: nil)
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
            case .distance, .body, .transmission, .fuel, .drivetrain, .seat:
                break
            }
        }.disposed(by: disposeBag)
    }
}

// MARK: - PostListingBasicDetailViewModelDelegate

extension PostListingViewModel: PostListingBasicDetailViewModelDelegate {
    func postListingDetailDone(_ viewModel: PostListingBasicDetailViewModel) {
        state.value = state.value.updating(price: viewModel.listingPrice, shareAfterPost: viewModel.shareOnFacebook.value)
    }
}


// MARK: - Private methods

fileprivate extension PostListingViewModel {
    func setupRx() {

        category.asObservable().subscribeNext { [weak self] category in
            guard let strongSelf = self, let category = category else { return }
            strongSelf.state.value = strongSelf.state.value.updating(category: category)
            }.disposed(by: disposeBag)

        let state = self.state.asDriver()

        state.filter { $0.step == .finished }.drive(onNext: { [weak self] _ in
            self?.postListing()
        }).disposed(by: disposeBag)
        
        state.filter { $0.step == .addingDetails }.drive(onNext: { [weak self] _ in
            self?.openPostingDetails()
        }).disposed(by: disposeBag)
        
        state.filter { $0.step == .uploadSuccess }.drive(onNext: { [weak self] _ in
            // Keep one second delay in order to give time to read the product posted message.
            delay(1) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.state.value = strongSelf.state.value.updatingAfterUploadingSuccess(predictionData: strongSelf.predictionData)
            }
        }).disposed(by: disposeBag)
    }
    
    func openPostAbandonAlertNotLoggedIn() {
        let title = R.Strings.productPostCloseAlertTitle
        let message = R.Strings.productPostCloseAlertDescription
        let cancelAction = UIAction(interface: .text(R.Strings.productPostCloseAlertCloseButton), action: { [weak self] in
            self?.navigator?.cancelPostListing()
            self?.trackPostSellAbandon()
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
                                                   machineLearningInfo: machineLearningTrackingInfo)
        if sessionManager.loggedIn {
            guard state.value.lastImagesUploadResult?.value != nil || state.value.uploadedVideo != nil,
                let listingCreationParams = makeListingParams() else { return }

            if isBulkPosting {
                postBulkPosting(params: listingCreationParams, trackingInfo: trackingInfo)
            } else {
                navigator?.closePostProductAndPostInBackground(params: listingCreationParams,
                                                               trackingInfo: trackingInfo,
                                                               shareAfterPost: state.value.shareAfterPost)
            }
        } else if state.value.pendingToUploadMedia {
            let loggedInAction = { [weak self] in
                guard let listingParams = self?.makeListingParams() else { return }
                self?.navigator?.closePostProductAndPostLater(params: listingParams,
                                                              images: self?.state.value.pendingToUploadImages,
                                                              video: self?.state.value.pendingToUploadVideo,
                                                              trackingInfo: trackingInfo,
                                                              shareAfterPost: self?.state.value.shareAfterPost)
            }
            let cancelAction = { [weak self] in
                guard let _ = self?.state.value else { return }
                self?.navigator?.cancelPostListing()
            }
            
            navigator?.openLoginIfNeededFromListingPosted(
                from: .sell,
                loggedInAction: loggedInAction,
                cancelAction: cancelAction
            )
        } else {
            navigator?.cancelPostListing()
        }
    }

    private func postBulkPosting(params: ListingCreationParams,
                                 trackingInfo: PostListingTrackingInfo) {
        state.value = state.value.updatingToPosting()
        listingRepository.create(listingParams: params) { [weak self] result in
            guard let strongSelf = self else { return }
            if let listing = result.value {
                strongSelf.trackPost(withListing: listing, trackingInfo: trackingInfo)
                strongSelf.keyValueStorage.userPostProductPostedPreviously = true

                let shareAfterPost = strongSelf.state.value.shareAfterPost ?? false
                var bulkPostedListings = strongSelf.bulkPostedListings ?? []
                bulkPostedListings.append(listing)
                strongSelf.bulkPostedListings = bulkPostedListings

                if shareAfterPost,
                    let myUserId = strongSelf.myUserId,
                    let myUserName = strongSelf.myUserName {
                    let socialMessage = ListingSocialMessage(listing: listing,
                                                             fallbackToStore: false,
                                                             myUserId: myUserId,
                                                             myUserName: myUserName)
                    strongSelf.delegate?.shareOnFacebook(socialMessage: socialMessage)
                } else {
                    strongSelf.continueBulkPosting()
                }

            } else if let error = result.error {
                strongSelf.state.value = strongSelf.state.value.updatingToPostingError(error: error)
                strongSelf.trackListingPostingError(withError: error)
            }
        }
    }

    func continueBulkPosting() {
        guard let bulkPostedListings = self.bulkPostedListings else { return }
        if bulkPostedListings.count >= featureFlags.bulkPosting.productsLimit {
            navigator?.showBulkPostingPostConfirmation(listings: bulkPostedListings,
                                                                  modalStyle: true)
        } else {
            navigator?.closePostProductAndContinueBulkPosting(listings: bulkPostedListings,
                                                         source: postingSource,
                                                         listingTitle: state.value.title)
        }
    }
    
    func openPostingDetails() {
        let firstStep = createFirstStep(forCategory: state.value.category)
        
        navigator?.startDetails(firstStep: firstStep,
                                postListingState: state.value,
                                uploadedImageSource: uploadedImageSource,
                                uploadedVideoLength: uploadedVideoLength,
                                postingSource: postingSource,
                                postListingBasicInfo: postDetailViewModel)
    }
    
    private func createFirstStep(forCategory category: PostCategory?) -> PostingDetailStep {
        guard let category = category, category.isService else { return .summary }
        
        if featureFlags.jobsAndServicesEnabled.isActive {
            return .servicesListingType
        }
        return .servicesSubtypes
    }
    
    func makeListingParams() -> ListingCreationParams? {
        guard let location = locationManager.currentLocation?.location else { return nil }
        let description = postDetailViewModel.listingDescription ?? ""
        let postalAddress = locationManager.currentLocation?.postalAddress ?? PostalAddress.emptyAddress()
        let currency = currencyHelper.currencyWithCountryCode(postalAddress.countryCode ?? SharedConstants.currencyDefault)
        
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

// MARK: - Tracking

fileprivate extension PostListingViewModel {

    private func trackPostSellAbandon() {
        var step: EventParameterPostingAbandonStep
        let pictureUploaded = EventParameterBoolean(bool: state.value.lastImagesUploadResult != nil)
        switch self.state.value.step {
        case .imageSelection:
            switch mediaSource {
            case .gallery:
                switch postListingGalleryViewModel.galleryState.value {
                case .pendingAskPermissions, .missingPermissions:
                    step = .cameraPermissions
                case .normal, .empty, .loadImageError, .loading:
                    step = .capturePhoto
                }
            case .camera, .videoCamera:
                switch self.postListingCameraViewModel.cameraState.value {
                case .pendingAskPermissions, .missingPermissions:
                    step = .cameraPermissions
                case .capture, .recordingVideo, .takingPhoto:
                    step = .capturePhoto
                case .previewPhoto, .previewVideo:
                    step = .imagePreview
                }
            }
        case .addingDetails, .carDetailsSelection, .detailsSelection:
            step = .addingDetails
        case .categorySelection:
            step = .productSellTypeSelect
        case .errorUpload, .errorVideoUpload:
            step = .errorUpload
        case .uploadingImage:
            step = .uploadingImage
        case .uploadingVideo:
            step = .uploadingVideo
        case .uploadSuccess, .finished, .postingListing, .postingError:
            step = .none
        }

        let event = TrackerEvent.listingSellAbandon(abandonStep: step,
                                                    pictureUploaded: pictureUploaded,
                                                    loggedUser: EventParameterBoolean(bool: sessionManager.loggedIn),
                                                    buttonName: .close)
        tracker.trackEvent(event)
    }

    private func trackPublish(source: EventParameterMediaSource, size: Int?) {
        tracker.trackEvent(TrackerEvent.listingSellMediaPublish(source: source, size: size))
    }

    private func trackPost(withListing listing: Listing, trackingInfo: PostListingTrackingInfo) {
        let event = TrackerEvent.listingSellComplete(listing,
                                                     buttonName: trackingInfo.buttonName,
                                                     sellButtonPosition: trackingInfo.sellButtonPosition,
                                                     negotiable: trackingInfo.negotiablePrice,
                                                     pictureSource: trackingInfo.imageSource,
                                                     videoLength: trackingInfo.videoLength,
                                                     freePostingModeAllowed: featureFlags.freePostingModeAllowed,
                                                     typePage: trackingInfo.typePage,
                                                     machineLearningTrackingInfo: trackingInfo.machineLearningInfo)

        tracker.trackEvent(event)
    }

    private func trackListingPostingError(withError error: RepositoryError) {
        let sellError = EventParameterPostListingError(error: error)
        let sellErrorDataEvent = TrackerEvent.listingSellErrorData(sellError)
        TrackerProxy.sharedInstance.trackEvent(sellErrorDataEvent)
    }
}

extension PostingSource {
    var typePage: EventParameterTypePage {
        switch self {
        case .tabBar:
            return .tabBar
        case .deepLink:
            return .external
        case .onboardingButton, .onboardingCamera, .onboardingBlockingPosting:
            return .onboarding
        case .notifications:
            return .notifications
        case .deleteListing:
            return .listingDelete
        case .realEstatePromo:
            return .realEstatePromo
        case .carPromo:
            return .carPromo
        case .servicesPromo:
            return .servicesPromo
        case .chatList:
            return .chatList
        case .listingList:
            return .listingList
        case .profile:
            return .profile
        case .markAsSold:
            return .listingSold
        case .rewardCenter:
            return .rewardCenter
        case .referralNotAvailable:
            return .referralNotAvailable
        }
    }

    var buttonName: EventParameterButtonNameType? {
        switch self {
        case .tabBar, .deepLink, .notifications, .deleteListing, .onboardingBlockingPosting, .chatList, .markAsSold, .rewardCenter:
            return nil
        case .onboardingButton, .listingList, .profile, .referralNotAvailable:
            return .sellYourStuff
        case .onboardingCamera:
            return .startMakingCash
        case .realEstatePromo:
            return .realEstatePromo
        case .carPromo:
            return .carPromo
        case .servicesPromo:
            return .servicesPromo
        }
    }
    
    var sellButtonPosition: EventParameterSellButtonPosition {
        switch self {
        case .tabBar:
            return .tabBar
        case .listingList, .profile:
            return .floatingButton
        case .onboardingButton, .onboardingCamera, .onboardingBlockingPosting, .deepLink, .notifications,
             .deleteListing, .chatList, .markAsSold, .rewardCenter:
            return .none
        case .realEstatePromo:
            return .realEstatePromo
        case .carPromo:
            return .carPromo
        case .servicesPromo:
            return .servicesPromo
        case .referralNotAvailable:
            return .referralNotAvailable
        }
    }
}
