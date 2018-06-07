import LGCoreKit
import RxSwift
import LGComponents

class MLPostListingViewModel: BaseViewModel {
    
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
    var confirmationOkText: String {
        if sessionManager.loggedIn {
            return R.Strings.productPostProductPosted
        } else {
            return R.Strings.productPostProductPostedNotLogged
        }
    }
    
    var isRealEstate: Bool {
        guard let category = postCategory, category == .realEstate else { return false }
        return true
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

    let state: Variable<MLPostListingState>
    let category: Variable<PostCategory?>

    let postDetailViewModel: PostListingBasicDetailViewModel
    let postListingCameraViewModel: MLPostListingCameraViewModel
    let postingSource: PostingSource
    let postCategory: PostCategory?
    
    fileprivate let listingRepository: ListingRepository
    fileprivate let fileRepository: FileRepository
    fileprivate let carsInfoRepository: CarsInfoRepository
    fileprivate let currencyHelper: CurrencyHelper
    fileprivate let tracker: Tracker
    fileprivate let sessionManager: SessionManager
    fileprivate let featureFlags: FeatureFlaggeable
    fileprivate let locationManager: LocationManager
    
    fileprivate var imagesSelected: [UIImage]?
    fileprivate var uploadedImageSource: EventParameterPictureSource?
    fileprivate var uploadedVideoLength: TimeInterval?
    fileprivate var predictionData: MLPredictionDetailsViewData?
    
    let selectedDetail = Variable<CategoryDetailSelectedInfo?>(nil)
    var selectedCarAttributes: CarAttributes = CarAttributes.emptyCarAttributes()
    var selectedRealEstateAttributes: RealEstateAttributes = RealEstateAttributes.emptyRealEstateAttributes()
    
    var realEstateEnabled: Bool {
        return featureFlags.realEstateEnabled.isActive
    }
    
    fileprivate let disposeBag: DisposeBag
    
    var categories: [ListingCategory] = []

    
    // MARK: - Lifecycle

    convenience init(source: PostingSource,
                     postCategory: PostCategory?,
                     listingTitle: String?) {
        self.init(source: source,
                  postCategory: postCategory,
                  listingTitle: listingTitle,
                  listingRepository: Core.listingRepository,
                  fileRepository: Core.fileRepository,
                  carsInfoRepository: Core.carsInfoRepository,
                  tracker: TrackerProxy.sharedInstance,
                  sessionManager: Core.sessionManager,
                  featureFlags: FeatureFlags.sharedInstance,
                  locationManager: Core.locationManager,
                  currencyHelper: Core.currencyHelper)
    }

    init(source: PostingSource,
         postCategory: PostCategory?,
         listingTitle: String?,
         listingRepository: ListingRepository,
         fileRepository: FileRepository,
         carsInfoRepository: CarsInfoRepository,
         tracker: Tracker,
         sessionManager: SessionManager,
         featureFlags: FeatureFlaggeable,
         locationManager: LocationManager,
         currencyHelper: CurrencyHelper) {
        self.state = Variable<MLPostListingState>(MLPostListingState(postCategory: postCategory, title: listingTitle))
        self.category = Variable<PostCategory?>(postCategory)
        
        self.postingSource = source
        self.postCategory = postCategory
        self.listingRepository = listingRepository
        self.fileRepository = fileRepository
        self.carsInfoRepository = carsInfoRepository
        self.postDetailViewModel = PostListingBasicDetailViewModel()
        self.postListingCameraViewModel = MLPostListingCameraViewModel(postingSource: source, postCategory: postCategory)
        self.tracker = tracker
        self.sessionManager = sessionManager
        self.featureFlags = featureFlags
        self.locationManager = locationManager
        self.currencyHelper = currencyHelper
        self.disposeBag = DisposeBag()
        super.init()
        self.postDetailViewModel.delegate = self
        
        setupRx()
        setupCarsRx()
        setupCategories()
    }

    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        guard firstTime else { return }
        trackVisit()
    }
    
    private func setupCategories() {
        Core.categoryRepository.index(servicesIncluded: false, carsIncluded: false, realEstateIncluded: false) { [weak self] result in
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
        guard let images = imagesSelected, let source = uploadedImageSource, let predictionData = predictionData else { return }
        imagesSelected(images, source: source, predictionData: predictionData)
    }

    func imagesSelected(_ images: [UIImage], source: EventParameterPictureSource, predictionData: MLPredictionDetailsViewData? = nil) {
        uploadedImageSource = source
        imagesSelected = images
        self.predictionData = predictionData
        state.value.predictionData = predictionData
        
        guard sessionManager.loggedIn else {
            state.value = state.value.updating(pendingToUploadImages: images)
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
    
    func closeButtonPressed() {
        if state.value.pendingToUploadImages != nil {
            openPostAbandonAlertNotLoggedIn()
        } else {
            guard let images = state.value.lastImagesUploadResult?.value else {
                navigator?.cancelPostListing()
                return
            }
            
            if let listingParams = makeListingParams(images: images) {
                let machineLearningTrackingInfo = MachineLearningTrackingInfo(data: state.value.predictionData,
                                                                              predictiveFlow: true,
                                                                              predictionActive: postListingCameraViewModel.isLiveStatsEnabledBackup)
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

extension MLPostListingViewModel {
    
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
        let details = MLPostListingViewModel.carDetailsNumber
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

extension MLPostListingViewModel: PostListingBasicDetailViewModelDelegate {
    func postListingDetailDone(_ viewModel: PostListingBasicDetailViewModel) {
        state.value = state.value.updating(price: viewModel.listingPrice)
    }
}


// MARK: - Private methods

fileprivate extension MLPostListingViewModel {
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
                strongSelf.state.value = strongSelf.state.value.updatingAfterUploadingSuccess()
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
                                                                      predictiveFlow: true,
                                                                      predictionActive: postListingCameraViewModel.isLiveStatsEnabledBackup)
        let trackingInfo = PostListingTrackingInfo(buttonName: .done,
                                                   sellButtonPosition: postingSource.sellButtonPosition,
                                                   imageSource: uploadedImageSource,
                                                   videoLength: uploadedVideoLength,
                                                   price: postDetailViewModel.price.value,
                                                   typePage: postingSource.typePage,
                                                   mostSearchedButton: postingSource.mostSearchedButton,
                                                   machineLearningInfo: machineLearningTrackingInfo)
        if sessionManager.loggedIn {
            guard let images = state.value.lastImagesUploadResult?.value,
                let listingCreationParams = makeListingParams(images: images) else { return }
            navigator?.closePostProductAndPostInBackground(params: listingCreationParams,
                                                           trackingInfo: trackingInfo)
        } else if let images = state.value.pendingToUploadImages {
            let loggedInAction = { [weak self] in
                guard let listingParams = self?.makeListingParams(images: []) else { return }
                self?.navigator?.closePostProductAndPostLater(params: listingParams,
                                                              images: images,
                                                              video: nil,
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
        let firstStep: PostingDetailStep = featureFlags.summaryAsFirstStep.isActive ? .summary : .price
        navigator?.startDetails(firstStep: firstStep,
                                postListingState: state.value,
                                uploadedImageSource: uploadedImageSource,
                                uploadedVideoLength: uploadedVideoLength,
                                postingSource: postingSource,
                                postListingBasicInfo: postDetailViewModel)
    }
    
    func makeListingParams(images:[File]) -> ListingCreationParams? {
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


// MARK: - Tracking

fileprivate extension MLPostListingViewModel {
    func trackVisit() {
        let event = TrackerEvent.listingSellStart(postingSource.typePage,
                                                  buttonName: postingSource.buttonName,
                                                  sellButtonPosition: postingSource.sellButtonPosition,
                                                  category: postCategory?.listingCategory,
                                                  mostSearchedButton: postingSource.mostSearchedButton,
                                                  predictiveFlow: true)
        tracker.trackEvent(event)
    }
}
