//
//  PostProductViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 11/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

protocol PostProductViewModelDelegate: BaseViewModelDelegate {}

enum PostingSource {
    case tabBar
    case sellButton
    case deepLink
    case onboardingButton
    case onboardingCamera
    case notifications
    case deleteProduct
}


class PostProductViewModel: BaseViewModel {
    
    static let carDetailsNumber: Int = 3
    
    weak var delegate: PostProductViewModelDelegate?
    weak var navigator: PostProductNavigator?

    var usePhotoButtonText: String {
        if sessionManager.loggedIn {
            return LGLocalizedString.productPostUsePhoto
        } else {
            return LGLocalizedString.productPostUsePhotoNotLogged
        }
    }
    var confirmationOkText: String {
        if sessionManager.loggedIn {
            return LGLocalizedString.productPostProductPosted
        } else {
            return LGLocalizedString.productPostProductPostedNotLogged
        }
    }

    let state: Variable<PostListingState>
    let category: Variable<PostCategory?>

    let postDetailViewModel: PostProductDetailViewModel
    let postProductCameraViewModel: PostProductCameraViewModel
    let postingSource: PostingSource
    
    fileprivate let listingRepository: ListingRepository
    fileprivate let fileRepository: FileRepository
    fileprivate let carsInfoRepository: CarsInfoRepository
    fileprivate let currencyHelper: CurrencyHelper
    fileprivate let tracker: Tracker
    fileprivate let sessionManager: SessionManager
    fileprivate let featureFlags: FeatureFlaggeable
    fileprivate let locationManager: LocationManager
    
    private var imagesSelected: [UIImage]?
    fileprivate var uploadedImageSource: EventParameterPictureSource?
    
    let selectedDetail = Variable<CategoryDetailSelectedInfo?>(nil)
    var selectedCarAttributes: CarAttributes = CarAttributes.emptyCarAttributes()
    
    fileprivate let disposeBag: DisposeBag

    
    // MARK: - Lifecycle

    convenience init(source: PostingSource) {
        self.init(source: source,
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
         listingRepository: ListingRepository,
         fileRepository: FileRepository,
         carsInfoRepository: CarsInfoRepository,
         tracker: Tracker,
         sessionManager: SessionManager,
         featureFlags: FeatureFlaggeable,
         locationManager: LocationManager,
         currencyHelper: CurrencyHelper) {
        self.state = Variable<PostListingState>(PostListingState(featureFlags: featureFlags))
        self.category = Variable<PostCategory?>(nil)
        
        self.postingSource = source
        self.listingRepository = listingRepository
        self.fileRepository = fileRepository
        self.carsInfoRepository = carsInfoRepository
        self.postDetailViewModel = PostProductDetailViewModel()
        self.postProductCameraViewModel = PostProductCameraViewModel(postingSource: source)
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
    }

    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        guard firstTime else { return }
        trackVisit()
    }

    // MARK: - Public methods
    
    func revertToPreviousStep() {
        state.value = state.value.revertToPreviousStep()
    }
   
    func retryButtonPressed() {
        guard let images = imagesSelected, let source = uploadedImageSource else { return }
        imagesSelected(images, source: source)
    }

    func imagesSelected(_ images: [UIImage], source: EventParameterPictureSource) {
        uploadedImageSource = source
        imagesSelected = images
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
                navigator?.cancelPostProduct()
                return
            }
            
            var listingParams: ListingCreationParams?
            if let category = category.value, category == .car {
                if let carParams = makeCarCreationParams(images: images) {
                    listingParams = ListingCreationParams.car(carParams)
                } else {
                    navigator?.cancelPostProduct()
                }
            }
            else if let productParams = makeProductCreationParams(images: images) {
                listingParams = ListingCreationParams.product(productParams)
            } else {
                navigator?.cancelPostProduct()
            }
            
            guard let params = listingParams else { return }
            let trackingInfo = PostProductTrackingInfo(buttonName: .close,
                                                       sellButtonPosition: postingSource.sellButtonPosition,
                                                       imageSource: uploadedImageSource,
                                                       price: postDetailViewModel.price.value)
            navigator?.closePostProductAndPostInBackground(params: params,
                                                           trackingInfo: trackingInfo)
        }
    }
}

// MARK: - Cars vertical

extension PostProductViewModel {
    
    func shouldShowBackButtonInCarDetails() -> Bool {
        return featureFlags.carsCategoryAfterPicture
    }
    
    func shouldAddPriceRowInCarDetails() -> Bool {
        return !featureFlags.carsCategoryAfterPicture
    }
    
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
        let details = PostProductViewModel.carDetailsNumber
        var detailsFilled = 0
        detailsFilled += selectedCarAttributes.isMakeEmpty ? 0 : 1
        detailsFilled += selectedCarAttributes.isModelEmpty ? 0 : 1
        detailsFilled += selectedCarAttributes.isYearEmpty ? 0 : 1
        guard details > 0 else { return 1 }
        return Float(detailsFilled) / Float(details)
    }
    
    func postCarDetailDone() {
        if !featureFlags.carsCategoryAfterPicture {
            state.value = state.value.updating(price: postDetailViewModel.productPrice, carInfo: selectedCarAttributes)
        } else {
            state.value = state.value.updating(carInfo: selectedCarAttributes)
        }
        
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
        }.addDisposableTo(disposeBag)
    }
}

// MARK: - PostProductDetailViewModelDelegate

extension PostProductViewModel: PostProductDetailViewModelDelegate {
    func postProductDetailDone(_ viewModel: PostProductDetailViewModel) {
        state.value = state.value.updating(price: viewModel.productPrice)
    }
}


// MARK: - Private methods

fileprivate extension PostProductViewModel {
    func setupRx() {
        category.asObservable().subscribeNext { [weak self] category in
            guard let strongSelf = self, let category = category else { return }
            strongSelf.state.value = strongSelf.state.value.updating(category: category)
        }.addDisposableTo(disposeBag)
        
        state.asObservable().filter { $0.step == .finished }.bindNext { [weak self] _ in
            self?.postListing()
        }.addDisposableTo(disposeBag)
        
        state.asObservable().filter { $0.step == .uploadSuccess }.bindNext { [weak self] _ in
            // Keep one second delay in order to give time to read the product posted message.
            delay(1) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.state.value = strongSelf.state.value.updatingAfterUploadingSuccess()
            }
        }.addDisposableTo(disposeBag)
    }
    
    func openPostAbandonAlertNotLoggedIn() {
        let title = LGLocalizedString.productPostCloseAlertTitle
        let message = LGLocalizedString.productPostCloseAlertDescription
        let cancelAction = UIAction(interface: .text(LGLocalizedString.productPostCloseAlertCloseButton), action: { [weak self] in
            self?.navigator?.cancelPostProduct()
        })
        let postAction = UIAction(interface: .text(LGLocalizedString.productPostCloseAlertOkButton), action: { [weak self] in
            self?.postListing()
        })
        delegate?.vmShowAlert(title, message: message, actions: [cancelAction, postAction])
    }

    func postProduct() {
        let trackingInfo = PostProductTrackingInfo(buttonName: .done, sellButtonPosition: postingSource.sellButtonPosition,
                                                   imageSource: uploadedImageSource, price: postDetailViewModel.price.value)
        if sessionManager.loggedIn {
            guard let images = state.value.lastImagesUploadResult?.value,
                let productParams = makeProductCreationParams(images: images) else { return }
            navigator?.closePostProductAndPostInBackground(params: ListingCreationParams.product(productParams),
                                                           trackingInfo: trackingInfo)
        } else if let images = state.value.pendingToUploadImages {
            let loggedInAction = { [weak self] in
                guard let productParams = self?.makeProductCreationParams(images: []) else { return }
                self?.navigator?.closePostProductAndPostLater(params: ListingCreationParams.product(productParams),
                                                              images: images,
                                                              trackingInfo: trackingInfo)
            }
            let cancelAction = { [weak self] in
                guard let state = self?.state.value else { return }
                self?.revertToPreviousStep()
            }
            navigator?.openLoginIfNeededFromProductPosted(from: .sell, loggedInAction: loggedInAction, cancelAction: cancelAction)
        } else {
            navigator?.cancelPostProduct()
        }
    }
    
    func postCar() {
        let trackingInfo = PostProductTrackingInfo(buttonName: .done, sellButtonPosition: postingSource.sellButtonPosition,
                                                   imageSource: uploadedImageSource, price: postDetailViewModel.price.value)
        if sessionManager.loggedIn {
            guard let images = state.value.lastImagesUploadResult?.value,
                let carParams = makeCarCreationParams(images: images) else { return }
            navigator?.closePostProductAndPostInBackground(params: ListingCreationParams.car(carParams),
                                                           trackingInfo: trackingInfo)
        } else if let images = state.value.pendingToUploadImages {
            let loggedInAction = { [weak self] in
                guard let carParams = self?.makeCarCreationParams(images: []) else { return }
                self?.navigator?.closePostProductAndPostLater(params: ListingCreationParams.car(carParams),
                                                              images: images,
                                                              trackingInfo: trackingInfo)
            }
            let cancelAction = { [weak self] in
                guard let _ = self?.state.value else { return }
                self?.navigator?.cancelPostProduct()
            }
            navigator?.openLoginIfNeededFromProductPosted(from: .sell, loggedInAction: loggedInAction, cancelAction: cancelAction)
        } else {
            navigator?.cancelPostProduct()
        }
    }
    
    func postListing() {
        if let postCategory = category.value, postCategory == .car {
            postCar()
        } else {
            postProduct()
        }
    }

    func makeProductCreationParams(images: [File]) -> ProductCreationParams? {
        guard let location = locationManager.currentLocation?.location else { return nil }
        let price = postDetailViewModel.productPrice
        let title = postDetailViewModel.productTitle
        let description = postDetailViewModel.productDescription
        let postalAddress = locationManager.currentLocation?.postalAddress ?? PostalAddress.emptyAddress()
        let currency = currencyHelper.currencyWithCountryCode(postalAddress.countryCode ?? "US")
        return ProductCreationParams(name: title,
                                     description: description,
                                     price: price,
                                     category: .unassigned,
                                     currency: currency,
                                     location: location,
                                     postalAddress: postalAddress,
                                     images: images)
    }
    
    func makeCarCreationParams(images: [File]) -> CarCreationParams? {
        guard let location = locationManager.currentLocation?.location else { return nil }
        let price = postDetailViewModel.productPrice
        var title = postDetailViewModel.productTitle
        title = title ?? selectedCarAttributes.generatedCarName()

        let description = postDetailViewModel.productDescription
        let postalAddress = locationManager.currentLocation?.postalAddress ?? PostalAddress.emptyAddress()
        let currency = currencyHelper.currencyWithCountryCode(postalAddress.countryCode ?? "US")
        return CarCreationParams(name: title,
                                 description: description,
                                 price: price,
                                 category: .cars,
                                 currency: currency,
                                 location: location,
                                 postalAddress: postalAddress,
                                 images: images,
                                 carAttributes: selectedCarAttributes)
    }
}


// MARK: - Tracking

fileprivate extension PostProductViewModel {
    func trackVisit() {
        let event = TrackerEvent.productSellStart(postingSource.typePage,buttonName: postingSource.buttonName,
                                                  sellButtonPosition: postingSource.sellButtonPosition)
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
        case .onboardingButton, .onboardingCamera:
            return .onboarding
        case .notifications:
            return .notifications
        case .deleteProduct:
            return .productDelete
        }
    }

    var buttonName: EventParameterButtonNameType? {
        switch self {
        case .tabBar, .sellButton, .deepLink, .notifications, .deleteProduct:
            return nil
        case .onboardingButton:
            return .sellYourStuff
        case .onboardingCamera:
            return .startMakingCash
        }
    }
    var sellButtonPosition: EventParameterSellButtonPosition {
        switch self {
        case .tabBar:
            return .tabBar
        case .sellButton:
            return .floatingButton
        case .onboardingButton, .onboardingCamera, .deepLink, .notifications, .deleteProduct:
            return .none
        }
    }
}
