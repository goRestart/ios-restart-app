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

enum PostProductState {
    case imageSelection
    case uploadingImage
    case errorUpload(message: String)
    case detailsSelection
}


class PostProductViewModel: BaseViewModel {

    weak var delegate: PostProductViewModelDelegate?
    weak var navigator: PostProductNavigator?
    fileprivate let sessionManager: SessionManager

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

    let state = Variable<PostProductState>(.imageSelection)

    let postDetailViewModel: PostProductDetailViewModel
    let postProductCameraViewModel: PostProductCameraViewModel
    let postingSource: PostingSource
    
    fileprivate let productRepository: ProductRepository
    fileprivate let fileRepository: FileRepository
    fileprivate let tracker: Tracker
    private let commercializerRepository: CommercializerRepository
    let galleryMultiSelectionEnabled: Bool
    private var imagesSelected: [UIImage]?
    fileprivate var pendingToUploadImages: [UIImage]?
    fileprivate var uploadedImages: [File]?
    fileprivate var uploadedImageSource: EventParameterPictureSource?
    

    // MARK: - Lifecycle

    convenience init(source: PostingSource) {
        let productRepository = Core.productRepository
        let fileRepository = Core.fileRepository
        let commercializerRepository = Core.commercializerRepository
        let tracker = TrackerProxy.sharedInstance
        let featureFlags = FeatureFlags.sharedInstance
        let sessionManager = Core.sessionManager
        self.init(source: source, productRepository: productRepository, fileRepository: fileRepository,
                  commercializerRepository: commercializerRepository, tracker: tracker, sessionManager: sessionManager,
                  galleryMultiSelectionEnabled: featureFlags.postingMultiPictureEnabled)
    }

    init(source: PostingSource, productRepository: ProductRepository, fileRepository: FileRepository,
         commercializerRepository: CommercializerRepository, tracker: Tracker, sessionManager: SessionManager,
         galleryMultiSelectionEnabled: Bool) {
        self.postingSource = source
        self.productRepository = productRepository
        self.fileRepository = fileRepository
        self.commercializerRepository = commercializerRepository
        self.postDetailViewModel = PostProductDetailViewModel()
        self.postProductCameraViewModel = PostProductCameraViewModel(postingSource: source)
        self.tracker = tracker
        self.sessionManager = sessionManager
        self.galleryMultiSelectionEnabled = galleryMultiSelectionEnabled
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
            pendingToUploadImages = images
            state.value = .detailsSelection
            return
        }

        state.value = .uploadingImage

        fileRepository.upload(images, progress: nil) { [weak self] result in
            guard let strongSelf = self else { return }
            guard let images = result.value else {
                guard let error = result.error else { return }
                let errorString: String
                switch (error) {
                case .internalError, .unauthorized, .notFound, .forbidden, .tooManyRequests, .userNotVerified, .serverError:
                    errorString = LGLocalizedString.productPostGenericError
                case .network:
                    errorString = LGLocalizedString.productPostNetworkError
                }
                strongSelf.state.value = .errorUpload(message: errorString)
                return
            }
            strongSelf.uploadedImages = images
            strongSelf.state.value = .detailsSelection
        }
    }

    func closeButtonPressed() {
        if pendingToUploadImages != nil {
            openPostAbandonAlertNotLoggedIn()
        } else {
            guard let product = buildProduct(isFreePosting: false), let images = uploadedImages else {
                navigator?.cancelPostProduct()
                return
            }
            let trackingInfo = PostProductTrackingInfo(buttonName: .close, sellButtonPosition: postingSource.sellButtonPosition,
                                                       imageSource: uploadedImageSource, price: nil)
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
            guard let product = buildProduct(isFreePosting: false), let images = uploadedImages else { return }
            navigator?.closePostProductAndPostInBackground(product, images: images, showConfirmation: true,
                                                           trackingInfo: trackingInfo)
        } else if let images = pendingToUploadImages {
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
