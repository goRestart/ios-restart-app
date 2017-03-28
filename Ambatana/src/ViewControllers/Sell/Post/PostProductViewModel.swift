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

    let state: Variable<PostProductState>

    let postDetailViewModel: PostProductDetailViewModel
    let postProductCameraViewModel: PostProductCameraViewModel
    let postingSource: PostingSource
    
    fileprivate let productRepository: ProductRepository
    fileprivate let fileRepository: FileRepository
    fileprivate let tracker: Tracker
    fileprivate let sessionManager: SessionManager
    fileprivate let featureFlags: FeatureFlaggeable
    
    private var imagesSelected: [UIImage]?
    fileprivate var uploadedImageSource: EventParameterPictureSource?
    

    // MARK: - Lifecycle

    convenience init(source: PostingSource) {
        self.init(source: source,
                  productRepository: Core.productRepository,
                  fileRepository: Core.fileRepository,
                  tracker: TrackerProxy.sharedInstance,
                  sessionManager: Core.sessionManager,
                  featureFlags: FeatureFlags.sharedInstance)
    }

    init(source: PostingSource,
         productRepository: ProductRepository,
         fileRepository: FileRepository,
         tracker: Tracker,
         sessionManager: SessionManager,
         featureFlags: FeatureFlaggeable) {
        self.state = Variable<PostProductState>(PostProductState(featureFlags: featureFlags))
        self.postingSource = source
        self.productRepository = productRepository
        self.fileRepository = fileRepository
        self.postDetailViewModel = PostProductDetailViewModel()
        self.postProductCameraViewModel = PostProductCameraViewModel(postingSource: source)
        self.tracker = tracker
        self.sessionManager = sessionManager
        self.featureFlags = featureFlags
        super.init()
        self.postDetailViewModel.delegate = self
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
            guard let product = buildProduct(isFreePosting: false), let images = state.value.lastImagesUploadResult?.value else {
                navigator?.cancelPostProduct()
                return
            }
            let trackingInfo = PostProductTrackingInfo(buttonName: .close, sellButtonPosition: postingSource.sellButtonPosition,
                                                       imageSource: uploadedImageSource, price: nil) // TODO: 🚔 that nil..?
            navigator?.closePostProductAndPostInBackground(product, images: images, showConfirmation: false,
                                                           trackingInfo: trackingInfo)
        }
    }
}


// MARK: - PostProductDetailViewModelDelegate

extension PostProductViewModel: PostProductDetailViewModelDelegate {
    func postProductDetailDone(_ viewModel: PostProductDetailViewModel) {
        postProduct()
    }
}


// MARK: - Private methods

fileprivate extension PostProductViewModel {
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
            guard let product = buildProduct(isFreePosting: false), let images = state.value.lastImagesUploadResult?.value else { return }
            navigator?.closePostProductAndPostInBackground(product, images: images, showConfirmation: true,
                                                           trackingInfo: trackingInfo)
        } else if let images = state.value.pendingToUploadImages {
            navigator?.openLoginIfNeededFromProductPosted(from: .sell, loggedInAction: { [weak self] in
                guard let product = self?.buildProduct(isFreePosting: false) else { return }
                self?.navigator?.closePostProductAndPostLater(product, images: images, trackingInfo: trackingInfo)
            })
        } else {
            navigator?.cancelPostProduct()
        }
    }

    func buildProduct(isFreePosting: Bool) -> Product? {
        let price = isFreePosting ? ProductPrice.free : postDetailViewModel.productPrice
        let title = postDetailViewModel.productTitle
        let description = postDetailViewModel.productDescription
        return productRepository.buildNewProduct(title, description: description, price: price, category: .unassigned)
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
