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
    fileprivate let currencyHelper: CurrencyHelper
    fileprivate let tracker: Tracker
    fileprivate let sessionManager: SessionManager
    fileprivate let featureFlags: FeatureFlaggeable
    fileprivate let locationManager: LocationManager
    
    private var imagesSelected: [UIImage]?
    fileprivate var uploadedImageSource: EventParameterPictureSource?
    
    fileprivate let disposeBag: DisposeBag

    
    // MARK: - Lifecycle

    convenience init(source: PostingSource) {
        self.init(source: source,
                  listingRepository: Core.listingRepository,
                  fileRepository: Core.fileRepository,
                  tracker: TrackerProxy.sharedInstance,
                  sessionManager: Core.sessionManager,
                  featureFlags: FeatureFlags.sharedInstance,
                  locationManager: Core.locationManager,
                  currencyHelper: Core.currencyHelper)
    }

    init(source: PostingSource,
         listingRepository: ListingRepository,
         fileRepository: FileRepository,
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
                strongSelf.state.value = strongSelf.state.value.updating(uploadedImages: images)
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
            self?.postProduct()
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

    func postProduct() {
        let trackingInfo = PostProductTrackingInfo(buttonName: .done, sellButtonPosition: postingSource.sellButtonPosition,
                                                   imageSource: uploadedImageSource, price: postDetailViewModel.price.value)
        if sessionManager.loggedIn {
            guard let images = state.value.lastImagesUploadResult?.value, let params = makeProductCreationParams(images: images) else { return }
            navigator?.closePostProductAndPostInBackground(params: params, showConfirmation: true, trackingInfo: trackingInfo)
            } else if let images = state.value.pendingToUploadImages {
            navigator?.openLoginIfNeededFromProductPosted(from: .sell, loggedInAction: { [weak self] in
                guard let params = self?.makeProductCreationParams(images: []) else { return }
                self?.navigator?.closePostProductAndPostLater(params: params, images: images, trackingInfo: trackingInfo)
            })
        } else {
            navigator?.cancelPostProduct()
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
