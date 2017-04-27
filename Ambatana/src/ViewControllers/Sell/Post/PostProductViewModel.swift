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
            guard let images = state.value.lastImagesUploadResult?.value, let params = makeProductCreationParams(images: images) else {
                navigator?.cancelPostProduct()
                return
            }
            let trackingInfo = PostProductTrackingInfo(buttonName: .close, sellButtonPosition: postingSource.sellButtonPosition,
                                                       imageSource: uploadedImageSource, price: nil) // TODO: 🚔 that nil..?
            navigator?.closePostProductAndPostInBackground(params: params, showConfirmation: false, trackingInfo: trackingInfo)
        }
    }
}

// MARK: - Cars vertical

extension PostProductViewModel {
    
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
        // TODO: take from corekit
        return Array(1900...2017).reversed()
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
        let details: [Any?] = [selectedCarAttributes.make, selectedCarAttributes.model, selectedCarAttributes.year]
        let detailsFilled: [Any] = details.flatMap { data in
            if let data = data as? String, !data.isEmpty {
                return data
            } else if let data = data as? Int, data != 0 {
                return data
            }
            return nil
        }
        
        guard details.count > 0 else { return 1 }
        return Float(detailsFilled.count) / Float(details.count)
    }
    
    func postCarDetailDone() {
        state.value = state.value.updating(carInfo: selectedCarAttributes)
    }
    
//    func postCar?
    
    // MARK: - Setup rx
    
    func setupCarsRx() {
        selectedDetail.asObservable().subscribeNext { [weak self] (categoryDetailSelectedInfo) in
            guard let categoryDetail = categoryDetailSelectedInfo else { return }
            guard let strongSelf = self else { return}
            switch categoryDetail.type {
            case .make:
                strongSelf.selectedCarAttributes = strongSelf.selectedCarAttributes.updating(make: categoryDetail.name,
                                                                                             makeId: categoryDetail.id,
                                                                                             model: "",
                                                                                             modelId: "")
            case .model:
                strongSelf.selectedCarAttributes = strongSelf.selectedCarAttributes.updating(model: categoryDetail.name,
                                                                                             modelId: categoryDetail.id)
            case .year:
                strongSelf.selectedCarAttributes = strongSelf.selectedCarAttributes.updating(year: Int(categoryDetail.id))
            }
        }.addDisposableTo(disposeBag)
    }
}

extension CarAttributes {
    // use "" to remove data
    func updating(make: String? = nil, //LGCoreKit.carMakeEmptyValue
                  makeId: String? = nil,
                  model: String? = nil,
                  modelId: String? = nil,
                  year: Int? = nil) -> CarAttributes {
        
        return CarAttributes(make: make ?? self.make,
                             makeId: makeId ?? self.makeId,
                             model: model ?? self.model,
                             modelId: modelId ?? self.modelId,
                             year: year ?? self.year)
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
//            guard let strongSelf = self, let category = category else { return }
//            strongSelf.state.value = strongSelf.state.value.updating(category: category)
            guard let strongSelf = self else { return }
            strongSelf.state.value = strongSelf.state.value.updatingAfterUploadingSuccess()
        }.addDisposableTo(disposeBag)
        
        state.asObservable().filter { $0.step == .finished }.bindNext { [weak self] _ in
            self?.postProduct()
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
            self?.postProduct()
        })
        delegate?.vmShowAlert(title, message: message, actions: [cancelAction, postAction])
    }

    fileprivate func postProduct() {
        let trackingInfo = PostProductTrackingInfo(buttonName: .done, sellButtonPosition: postingSource.sellButtonPosition,
                                                   imageSource: uploadedImageSource, price: postDetailViewModel.price.value)
        if sessionManager.loggedIn {
            guard let images = state.value.lastImagesUploadResult?.value, let params = makeProductCreationParams(images: images) else { return }
            navigator?.closePostProductAndPostInBackground(params: params, showConfirmation: true, trackingInfo: trackingInfo)
        } else if let images = state.value.pendingToUploadImages {
            let loggedInAction = { [weak self] in
                guard let params = self?.makeProductCreationParams(images: []) else { return }
                self?.navigator?.closePostProductAndPostLater(params: params, images: images, trackingInfo: trackingInfo)
            }
            let cancelAction = { [weak self] in
                guard let state = self?.state.value else { return }
                self?.state.value = state.revertToPreviousStep()
            }
            navigator?.openLoginIfNeededFromProductPosted(from: .sell, loggedInAction: loggedInAction, cancelAction: cancelAction)
        } else {
            navigator?.cancelPostProduct()
        }
    }
    
    fileprivate func postCar() {
        let trackingInfo = PostProductTrackingInfo(buttonName: .done, sellButtonPosition: postingSource.sellButtonPosition,
                                                   imageSource: uploadedImageSource, price: postDetailViewModel.price.value)
        if sessionManager.loggedIn {
            guard let images = state.value.lastImagesUploadResult?.value, let params = makeCarCreationParams(images: images) else { return }
            navigator?.closePostProductAndPostInBackground(params: params, showConfirmation: true, trackingInfo: trackingInfo)
        } else if let images = state.value.pendingToUploadImages {
            let loggedInAction = { [weak self] in
                guard let params = self?.makeProductCreationParams(images: []) else { return }
                self?.navigator?.closePostProductAndPostLater(params: params, images: images, trackingInfo: trackingInfo)
            }
            let cancelAction = { [weak self] in
                guard let state = self?.state.value else { return }
                self?.state.value = state.revertToPreviousStep()
            }
            navigator?.openLoginIfNeededFromProductPosted(from: .sell, loggedInAction: loggedInAction, cancelAction: cancelAction)
        } else {
            navigator?.cancelPostProduct()
        }
    }
    
    func postListing() {
        if let postCategory = category.value, postCategory == .car {
            psotCar()
        } else {
            postProduct()
        }
    }

    fileprivate func makeProductCreationParams(images: [File]) -> ProductCreationParams? {
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
    
    fileprivate func makeCarCreationParams(images: [File]) -> CarCreationParams? {
        guard let location = locationManager.currentLocation?.location else { return nil }
        let price = postDetailViewModel.productPrice
        let title = postDetailViewModel.productTitle
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
