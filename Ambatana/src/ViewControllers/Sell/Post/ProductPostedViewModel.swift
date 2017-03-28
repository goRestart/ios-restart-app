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
    private let trackingInfo: PostProductTrackingInfo
    private let featureFlags: FeatureFlaggeable
    private let tracker: Tracker
    private let listingRepository: ListingRepository
    private let fileRepository: FileRepository

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

    convenience init(postResult: ProductResult, trackingInfo: PostProductTrackingInfo) {
        self.init(status: ProductPostedStatus(result: postResult),
                  trackingInfo: trackingInfo)
    }

    convenience init(productToPost: Product, productImages: [UIImage], trackingInfo: PostProductTrackingInfo) {
        self.init(status: ProductPostedStatus(images: productImages, product: productToPost),
                  trackingInfo: trackingInfo)
    }

    convenience init(status: ProductPostedStatus, trackingInfo: PostProductTrackingInfo) {
        self.init(status: status,
                  trackingInfo: trackingInfo,
                  listingRepository: Core.listingRepository,
                  fileRepository: Core.fileRepository,
                  featureFlags: FeatureFlags.sharedInstance,
                  tracker: TrackerProxy.sharedInstance)
    }

    init(status: ProductPostedStatus,
         trackingInfo: PostProductTrackingInfo,
         listingRepository: ListingRepository,
         fileRepository: FileRepository,
         featureFlags: FeatureFlaggeable,
         tracker: Tracker) {
        self.status = status
        self.trackingInfo = trackingInfo
        self.featureFlags = featureFlags
        self.tracker = tracker
        self.listingRepository = listingRepository
        self.fileRepository = fileRepository
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
            tracker.trackEvent(TrackerEvent.productSellConfirmationClose(productPosted))
            product = productPosted
        case .posting:
            break
        case let .error(error):
            tracker.trackEvent(TrackerEvent.productSellErrorClose(error))
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

        tracker.trackEvent(TrackerEvent.productSellConfirmationEdit(product))
        navigator?.closeProductPostedAndOpenEdit(product)
    }

    func mainActionPressed() {
        switch status {
        case .posting:
            break
        case let .success(product):
            tracker.trackEvent(TrackerEvent.productSellConfirmationPost(product, buttonType: .button))
        case let .error(error):
            tracker.trackEvent(TrackerEvent.productSellErrorPost(error))
        }

        navigator?.closeProductPostedAndOpenPost()
    }

    func incentivateSectionPressed() {
        guard let product = status.product else { return }
        tracker.trackEvent(TrackerEvent.productSellConfirmationPost(product, buttonType: .itemPicture))
        navigator?.closeProductPostedAndOpenPost()
    }

    func shareStartedIn(_ shareType: ShareType) {
        guard let product = status.product else { return }
        tracker.trackEvent(TrackerEvent.productSellConfirmationShare(product, network: shareType.trackingShareNetwork))
    }

    func shareFinishedIn(_ shareType: ShareType, withState state: SocialShareState) {
        guard let product = status.product else { return }

        switch state {
        case .completed:
            tracker.trackEvent(TrackerEvent.productSellConfirmationShareComplete(product, network: shareType.trackingShareNetwork))
        case .cancelled:
            tracker.trackEvent(TrackerEvent.productSellConfirmationShareCancel(product, network: shareType.trackingShareNetwork))
        case .failed:
            break;
        }
    }
    

    // MARK: - Private methods

    private func postProduct(_ images: [UIImage], product: Product) {
        delegate?.productPostedViewModelSetupLoadingState(self)

        listingRepository.create(product: product, images: images, progress: nil) { [weak self] result in
            // Tracking
            if let postedProduct = result.value {
                self?.trackPostSellComplete(postedProduct: postedProduct)
            } else if let error = result.error {
                self?.trackPostSellError(error: error)
            }
            self?.updateStatusAfterPosting(status: ProductPostedStatus(result: result))
        }
    }

    private func updateStatusAfterPosting(status: ProductPostedStatus) {
        self.status = status
        trackProductUploadResultScreen()
        delegate?.productPostedViewModel(self, finishedLoadingState: status.success)
    }

    private func trackPostSellComplete(postedProduct: Product) {
        let buttonName = trackingInfo.buttonName
        let negotiable = trackingInfo.negotiablePrice
        let pictureSource = trackingInfo.imageSource
        let event = TrackerEvent.productSellComplete(postedProduct, buttonName: buttonName,
                                                     sellButtonPosition: trackingInfo.sellButtonPosition,
                                                     negotiable: negotiable, pictureSource: pictureSource,
                                                     freePostingModeAllowed: featureFlags.freePostingModeAllowed)
        tracker.trackEvent(event)

        // Track product was sold in the first 24h (and not tracked before)
        if let firstOpenDate = KeyValueStorage.sharedInstance[.firstRunDate], NSDate().timeIntervalSince(firstOpenDate as Date) <= 86400 &&
            !KeyValueStorage.sharedInstance.userTrackingProductSellComplete24hTracked {
            KeyValueStorage.sharedInstance.userTrackingProductSellComplete24hTracked = true
            let event = TrackerEvent.productSellComplete24h(postedProduct)
            tracker.trackEvent(event)
        }
    }

    private func trackPostSellError(error: RepositoryError) {
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
        tracker.trackEvent(sellErrorDataEvent)
    }

    private func trackProductUploadResultScreen() {
        switch status {
        case .posting:
            break
        case let .success(product):
            tracker.trackEvent(TrackerEvent.productSellConfirmation(product))
        case let .error(error):
            tracker.trackEvent(TrackerEvent.productSellError(error))
        }
    }
}


// MARK: - ProductPostedStatus

enum ProductPostedStatus {
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

    init(result: ProductResult) {
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

    init(error: RepositoryError) {
        switch error {
        case .network:
            self = .error(error: .network)
        default:
            self = .error(error: .internalError)
        }
    }
}
