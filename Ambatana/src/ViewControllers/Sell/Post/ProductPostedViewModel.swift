//
//  ProductPostedViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 14/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit


// MARK: - ProductPostedViewModelDelegate

protocol ProductPostedViewModelDelegate: class {
    func productPostedViewModelSetupLoadingState(viewModel: ProductPostedViewModel)
    func productPostedViewModel(viewModel: ProductPostedViewModel, finishedLoadingState correct: Bool)
    func productPostedViewModel(viewModel: ProductPostedViewModel, setupStaticState correct: Bool)
    func productPostedViewModelShareNative()
}


// MARK: - ProductPostedViewModel

class ProductPostedViewModel: BaseViewModel {
    weak var navigator: ProductPostedNavigator?
    weak var delegate: ProductPostedViewModelDelegate?

    private var status: ProductPostedStatus
    private var productRepository: ProductRepository?
    private var trackingInfo: PostProductTrackingInfo
    private var featureFlags: FeatureFlaggeable

    var wasFreePosting: Bool {
        switch self.status {
        case let .Posting(_, product):
            return product.price.free
        case let .Success(product):
            return product.price.free
        case .Error:
            return false
        }
    }

    
    // MARK: - Lifecycle

    init(postResult: ProductResult, trackingInfo: PostProductTrackingInfo) {
        self.trackingInfo = trackingInfo
        self.featureFlags = FeatureFlags.sharedInstance
        self.status = ProductPostedStatus(result: postResult)
        super.init()
    }

    convenience init(productToPost: Product, productImages: [UIImage], trackingInfo: PostProductTrackingInfo) {
        let productRepository = Core.productRepository
        let featureFlags = FeatureFlags.sharedInstance
        self.init(productRepository: productRepository, productToPost: productToPost,
                  productImages: productImages, trackingInfo: trackingInfo, featureFlags: featureFlags)
    }

    init(productRepository: ProductRepository, productToPost: Product,
         productImages: [UIImage], trackingInfo: PostProductTrackingInfo, featureFlags: FeatureFlaggeable) {
            self.productRepository = productRepository
            self.trackingInfo = trackingInfo
            self.featureFlags = featureFlags
            self.status = ProductPostedStatus(images: productImages, product: productToPost)
            super.init()
    }

    override func didBecomeActive(firstTime: Bool) {
        if firstTime {
            switch status {
            case let .Posting(images, product):
                postProduct(images, product: product)
            case .Success:
                delegate?.productPostedViewModel(self, setupStaticState: true)
                trackProductUploadResultScreen()
            case .Error:
                delegate?.productPostedViewModel(self, setupStaticState: false)
                trackProductUploadResultScreen()
            }
        }
    }


    // MARK: - Public

    var mainButtonText: String? {
        switch status {
        case .Posting:
            return nil
        case .Success:
            return wasFreePosting ? LGLocalizedString.productPostFreeConfirmationAnotherButton : LGLocalizedString.productPostConfirmationAnotherButton
        case .Error:
            return LGLocalizedString.productPostRetryButton
        }
    }

    var mainText: String? {
        switch status {
        case .Posting:
            return nil
        case .Success:
            return LGLocalizedString.productPostIncentiveTitle
        case .Error:
            return LGLocalizedString.commonErrorTitle.capitalizedString
        }
    }

    var secondaryText: String? {
        switch status {
        case .Posting:
            return nil
        case .Success:
            return wasFreePosting ? LGLocalizedString.productPostIncentiveSubtitleFree : LGLocalizedString.productPostIncentiveSubtitle
        case let .Error(error):
            switch error {
            case .Network:
                return LGLocalizedString.productPostNetworkError
            default:
                return LGLocalizedString.productPostGenericError
            }
        }
    }

    var socialMessage: SocialMessage? {
        switch status {
        case .Posting, .Error:
            return nil
        case let .Success(product):
            return ProductSocialMessage(product: product)
        }
    }

    var promoteProductViewModel: PromoteProductViewModel? {
        switch status {
        case .Posting, .Error:
            return nil
        case let .Success(product):
            guard let countryCode = product.postalAddress.countryCode, let productId = product.objectId else { return nil }
            let themes = Core.commercializerRepository.templatesForCountryCode(countryCode)
            guard !themes.isEmpty else { return nil }
            return PromoteProductViewModel(productId: productId, themes: themes, commercializers: [],
                promotionSource: .ProductSell)
        }
    }

    // MARK: > Actions

    func closeActionPressed() {
        var product: Product? = nil
        switch status {
        case let .Success(productPosted):
            trackEvent(TrackerEvent.productSellConfirmationClose(productPosted))
            product = productPosted
        case .Posting:
            break
        case let .Error(error):
            trackEvent(TrackerEvent.productSellErrorClose(error))
        }
        
        guard let productValue = product else {
            navigator?.cancelProductPosted()
            return
        }
        
        if featureFlags.shareAfterPosting {
            if let socialMessage = socialMessage {
                navigator?.closeProductPostedAndOpenShare(productValue, socialMessage: socialMessage)
            } else {
                navigator?.cancelProductPosted()
            }
        } else {
            navigator?.closeProductPosted(productValue)
        }
    }
    
    func shareActionPressed() {
        if featureFlags.shareAfterPosting {
            closeActionPressed()
        } else {
            delegate?.productPostedViewModelShareNative()
        }
    }

    func editActionPressed() {
        guard let product = status.product else { return }

        trackEvent(TrackerEvent.productSellConfirmationEdit(product))
        navigator?.closeProductPostedAndOpenEdit(product)
    }

    func mainActionPressed() {
        switch status {
        case .Posting:
            break
        case let .Success(product):
            trackEvent(TrackerEvent.productSellConfirmationPost(product))
        case let .Error(error):
            trackEvent(TrackerEvent.productSellErrorPost(error))
        }

        navigator?.closeProductPostedAndOpenPost()
    }

    func shareStartedIn(shareType: ShareType) {
        guard let product = status.product else { return }
        trackEvent(TrackerEvent.productSellConfirmationShare(product, network: shareType.trackingShareNetwork))
    }

    func shareFinishedIn(shareType: ShareType, withState state: SocialShareState) {
        guard let product = status.product else { return }

        switch state {
        case .Completed:
            trackEvent(TrackerEvent.productSellConfirmationShareComplete(product, network: shareType.trackingShareNetwork))
        case .Cancelled:
            trackEvent(TrackerEvent.productSellConfirmationShareCancel(product, network: shareType.trackingShareNetwork))
        case .Failed:
            break;
        }
    }
    

    // MARK: - Private methods

    private func postProduct(images: [UIImage], product: Product) {
        guard let productRepository = productRepository else { return }

        delegate?.productPostedViewModelSetupLoadingState(self)

        productRepository.create(product, images: images, progress: nil) { [weak self] result in
            guard let strongSelf = self else { return }

            // Tracking
            if let postedProduct = result.value {
                let buttonName = strongSelf.trackingInfo.buttonName
                let negotiable = strongSelf.trackingInfo.negotiablePrice
                let pictureSource = strongSelf.trackingInfo.imageSource
                let event = TrackerEvent.productSellComplete(postedProduct, buttonName: buttonName,
                                                             sellButtonPosition: strongSelf.trackingInfo.sellButtonPosition,
                                                             negotiable: negotiable, pictureSource: pictureSource,
                                                             freePostingModeAllowed: strongSelf.featureFlags.freePostingModeAllowed)
                strongSelf.trackEvent(event)

                // Track product was sold in the first 24h (and not tracked before)
                if let firstOpenDate = KeyValueStorage.sharedInstance[.firstRunDate]
                    where NSDate().timeIntervalSinceDate(firstOpenDate) <= 86400 &&
                        !KeyValueStorage.sharedInstance.userTrackingProductSellComplete24hTracked {
                    KeyValueStorage.sharedInstance.userTrackingProductSellComplete24hTracked = true
                    let event = TrackerEvent.productSellComplete24h(postedProduct)
                    strongSelf.trackEvent(event)
                }
            } else if let error = result.error {
                let sellError: EventParameterPostProductError
                switch error {
                case .Network:
                    sellError = .Network
                case .ServerError, .NotFound, .Forbidden, .Unauthorized, .TooManyRequests, .UserNotVerified:
                    sellError = .ServerError(code: error.errorCode)
                case .Internal:
                    sellError = .Internal
                }
                let sellErrorDataEvent = TrackerEvent.productSellErrorData(sellError)
                strongSelf.trackEvent(sellErrorDataEvent)
            }

            let status = ProductPostedStatus(result: result)
            strongSelf.status = status
            strongSelf.trackProductUploadResultScreen()
            strongSelf.delegate?.productPostedViewModel(strongSelf, finishedLoadingState: status.success)
        }
    }

    private func trackProductUploadResultScreen() {
        switch status {
        case .Posting:
            break
        case let .Success(product):
            trackEvent(TrackerEvent.productSellConfirmation(product))
        case let .Error(error):
            trackEvent(TrackerEvent.productSellError(error))
        }
    }

    private func trackEvent(event: TrackerEvent) {
        TrackerProxy.sharedInstance.trackEvent(event)
    }
}


// MARK: - ProductPostedStatus

private enum ProductPostedStatus {
    case Posting(images: [UIImage], product: Product)
    case Success(product: Product)
    case Error(error: EventParameterPostProductError)

    var product: Product? {
        switch self {
        case .Posting, .Error:
            return nil
        case let .Success(product):
            return product
        }
    }

    var success: Bool {
        switch self {
        case .Success:
            return true
        case .Posting, .Error:
            return false
        }
    }

    init(images: [UIImage], product: Product) {
        self = .Posting(images: images, product: product)
    }

    init(result: ProductResult) {
        if let product = result.value {
            self = .Success(product: product)
        } else if let error = result.error {
            switch error {
            case .Network:
                self = .Error(error: .Network)
            default:
                self = .Error(error: .Internal)
            }
        } else {
            self = .Error(error: .Internal)
        }
    }
}
