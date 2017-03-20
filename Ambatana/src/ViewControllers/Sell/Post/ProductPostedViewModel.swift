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
    func productPostedViewModelSetupLoadingState(_ viewModel: ProductPostedViewModel)
    func productPostedViewModel(_ viewModel: ProductPostedViewModel, finishedLoadingState correct: Bool)
    func productPostedViewModel(_ viewModel: ProductPostedViewModel, setupStaticState correct: Bool)
    func productPostedViewModelShareNative()
}


// MARK: - ProductPostedViewModel

class ProductPostedViewModel: BaseViewModel {
    weak var navigator: ProductPostedNavigator?
    weak var delegate: ProductPostedViewModelDelegate?

    private var status: ProductPostedStatus
    private var listingRepository: ListingRepository?
    private var trackingInfo: PostProductTrackingInfo
    private var featureFlags: FeatureFlaggeable

    var wasFreePosting: Bool {
        switch self.status {
        case let .posting(_, product):
            return product.price.free
        case let .success(product):
            return product.price.free
        case .error:
            return false
        }
    }

    
    // MARK: - Lifecycle

    init(postResult: ListingResult, trackingInfo: PostProductTrackingInfo) {
        self.trackingInfo = trackingInfo
        self.featureFlags = FeatureFlags.sharedInstance
        self.status = ProductPostedStatus(result: postResult)
        super.init()
    }

    convenience init(productToPost: Product, productImages: [UIImage], trackingInfo: PostProductTrackingInfo) {
        let listingRepository = Core.listingRepository
        let featureFlags = FeatureFlags.sharedInstance
        self.init(listingRepository: listingRepository, productToPost: productToPost,
                  productImages: productImages, trackingInfo: trackingInfo, featureFlags: featureFlags)
    }

    init(listingRepository: ListingRepository, productToPost: Product,
         productImages: [UIImage], trackingInfo: PostProductTrackingInfo, featureFlags: FeatureFlaggeable) {
            self.listingRepository = listingRepository
            self.trackingInfo = trackingInfo
            self.featureFlags = featureFlags
            self.status = ProductPostedStatus(images: productImages, product: productToPost)
            super.init()
    }

    override func didBecomeActive(_ firstTime: Bool) {
        if firstTime {
            switch status {
            case let .posting(images, product):
                postProduct(images, product: product)
            case .success:
                delegate?.productPostedViewModel(self, setupStaticState: true)
                trackProductUploadResultScreen()
            case .error:
                delegate?.productPostedViewModel(self, setupStaticState: false)
                trackProductUploadResultScreen()
            }
        }
    }


    // MARK: - Public

    var mainButtonText: String? {
        switch status {
        case .posting:
            return nil
        case .success:
            return wasFreePosting ? LGLocalizedString.productPostFreeConfirmationAnotherButton : LGLocalizedString.productPostConfirmationAnotherButton
        case .error:
            return LGLocalizedString.productPostRetryButton
        }
    }

    var mainText: String? {
        switch status {
        case .posting:
            return nil
        case .success:
            return LGLocalizedString.productPostIncentiveTitle
        case .error:
            return LGLocalizedString.commonErrorTitle.capitalized
        }
    }

    var secondaryText: String? {
        switch status {
        case .posting:
            return nil
        case .success:
            return wasFreePosting ? LGLocalizedString.productPostIncentiveSubtitleFree : LGLocalizedString.productPostIncentiveSubtitle
        case let .error(error):
            switch error {
            case .network:
                return LGLocalizedString.productPostNetworkError
            default:
                return LGLocalizedString.productPostGenericError
            }
        }
    }

    var socialMessage: SocialMessage? {
        switch status {
        case .posting, .error:
            return nil
        case let .success(product):
            return ProductSocialMessage(product: product, fallbackToStore: false)
        }
    }
    

    // MARK: > Actions

    func closeActionPressed() {
        var product: Product? = nil
        switch status {
        case let .success(productPosted):
            trackEvent(TrackerEvent.productSellConfirmationClose(productPosted))
            product = productPosted
        case .posting:
            break
        case let .error(error):
            trackEvent(TrackerEvent.productSellErrorClose(error))
        }
        
        guard let productValue = product else {
            navigator?.cancelProductPosted()
            return
        }
        
        navigator?.closeProductPosted(productValue)
    }
    
    func shareActionPressed() {
        delegate?.productPostedViewModelShareNative()
    }

    func editActionPressed() {
        guard let product = status.product else { return }

        trackEvent(TrackerEvent.productSellConfirmationEdit(product))
        navigator?.closeProductPostedAndOpenEdit(product)
    }

    func mainActionPressed() {
        switch status {
        case .posting:
            break
        case let .success(product):
            trackEvent(TrackerEvent.productSellConfirmationPost(product, buttonType: .button))
        case let .error(error):
            trackEvent(TrackerEvent.productSellErrorPost(error))
        }

        navigator?.closeProductPostedAndOpenPost()
    }

    func incentivateSectionPressed() {
        guard let product = status.product else { return }
        trackEvent(TrackerEvent.productSellConfirmationPost(product, buttonType: .itemPicture))
        navigator?.closeProductPostedAndOpenPost()
    }

    func shareStartedIn(_ shareType: ShareType) {
        guard let product = status.product else { return }
        trackEvent(TrackerEvent.productSellConfirmationShare(product, network: shareType.trackingShareNetwork))
    }

    func shareFinishedIn(_ shareType: ShareType, withState state: SocialShareState) {
        guard let product = status.product else { return }

        switch state {
        case .completed:
            trackEvent(TrackerEvent.productSellConfirmationShareComplete(product, network: shareType.trackingShareNetwork))
        case .cancelled:
            trackEvent(TrackerEvent.productSellConfirmationShareCancel(product, network: shareType.trackingShareNetwork))
        case .failed:
            break;
        }
    }
    

    // MARK: - Private methods

    private func postProduct(_ images: [UIImage], product: Product) {
        guard let listingRepository = listingRepository else { return }

        delegate?.productPostedViewModelSetupLoadingState(self)

        listingRepository.create(product, images: images, progress: nil) { [weak self] result in
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
                if let firstOpenDate = KeyValueStorage.sharedInstance[.firstRunDate], NSDate().timeIntervalSince(firstOpenDate as Date) <= 86400 &&
                        !KeyValueStorage.sharedInstance.userTrackingProductSellComplete24hTracked {
                    KeyValueStorage.sharedInstance.userTrackingProductSellComplete24hTracked = true
                    let event = TrackerEvent.productSellComplete24h(postedProduct)
                    strongSelf.trackEvent(event)
                }
            } else if let error = result.error {
                let sellError: EventParameterPostProductError
                switch error {
                case .network:
                    sellError = .network
                case .serverError, .notFound, .forbidden, .unauthorized, .tooManyRequests, .userNotVerified:
                    sellError = .serverError(code: error.errorCode)
                case .internalError:
                    sellError = .internalError
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
        case .posting:
            break
        case let .success(product):
            trackEvent(TrackerEvent.productSellConfirmation(product))
        case let .error(error):
            trackEvent(TrackerEvent.productSellError(error))
        }
    }

    private func trackEvent(_ event: TrackerEvent) {
        TrackerProxy.sharedInstance.trackEvent(event)
    }
}


// MARK: - ProductPostedStatus

private enum ProductPostedStatus {
    case posting(images: [UIImage], product: Product)
    case success(product: Product)
    case error(error: EventParameterPostProductError)

    var product: Product? {
        switch self {
        case .posting, .error:
            return nil
        case let .success(product):
            return product
        }
    }

    var success: Bool {
        switch self {
        case .success:
            return true
        case .posting, .error:
            return false
        }
    }

    init(images: [UIImage], product: Product) {
        self = .posting(images: images, product: product)
    }

    init(result: ListingResult) {
        if let product = result.value {
            self = .success(product: product)
        } else if let error = result.error {
            switch error {
            case .network:
                self = .error(error: .network)
            default:
                self = .error(error: .internalError)
            }
        } else {
            self = .error(error: .internalError)
        }
    }
}
