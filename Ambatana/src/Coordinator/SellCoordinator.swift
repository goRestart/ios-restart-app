//
//  SellCoordinator.swift
//  LetGo
//
//  Created by Albert Hernández López on 20/06/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

protocol SellCoordinatorDelegate: class {
    func sellCoordinatorDidCancel(_ coordinator: SellCoordinator)
    func sellCoordinator(_ coordinator: SellCoordinator, didFinishWithListing listing: Listing)
}

final class SellCoordinator: Coordinator {
    var child: Coordinator?
    weak var coordinatorDelegate: CoordinatorDelegate?
    var viewController: UIViewController
    weak var presentedAlertController: UIAlertController?
    let bubbleNotificationManager: BubbleNotificationManager
    let sessionManager: SessionManager
    
    fileprivate var parentViewController: UIViewController?

    fileprivate let listingRepository: ListingRepository
    fileprivate let keyValueStorage: KeyValueStorage
    fileprivate let tracker: Tracker
    fileprivate let featureFlags: FeatureFlaggeable
    fileprivate let postingSource: PostingSource
    weak var delegate: SellCoordinatorDelegate?

    fileprivate let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    convenience init(source: PostingSource) {
        self.init(source: source,
                  listingRepository: Core.listingRepository,
                  bubbleNotificationManager: LGBubbleNotificationManager.sharedInstance,
                  keyValueStorage: KeyValueStorage.sharedInstance,
                  tracker: TrackerProxy.sharedInstance,
                  featureFlags: FeatureFlags.sharedInstance,
                  sessionManager: Core.sessionManager)
    }

    init(source: PostingSource,
         listingRepository: ListingRepository,
         bubbleNotificationManager: BubbleNotificationManager,
         keyValueStorage: KeyValueStorage,
         tracker: Tracker,
         featureFlags: FeatureFlags,
         sessionManager: SessionManager) {
        self.listingRepository = listingRepository
        self.bubbleNotificationManager = bubbleNotificationManager
        self.keyValueStorage = keyValueStorage
        self.tracker = tracker
        self.postingSource = source
        self.featureFlags = featureFlags
        self.sessionManager = sessionManager
        let postProductVM = PostProductViewModel(source: source)
        let postProductVC = PostProductViewController(viewModel: postProductVM, forceCamera: false)
        self.viewController = postProductVC

        postProductVM.navigator = self
    }

    func presentViewController(parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard let postProductVC = viewController as? PostProductViewController else { return }
        guard postProductVC.parent == nil else { return }

        parentViewController = parent
        parent.present(postProductVC, animated: animated, completion: completion)
    }

    func dismissViewController(animated: Bool, completion: (() -> Void)?) {
        viewController.dismissWithPresented(animated: animated, completion: completion)
    }
}


// MARK: - PostProductNavigator

extension SellCoordinator: PostProductNavigator {
    func cancelPostProduct() {
        closeCoordinator(animated: true) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.sellCoordinatorDidCancel(strongSelf)
        }
    }

    func closePostProductAndPostInBackground(params: ListingCreationParams,
                                             trackingInfo: PostProductTrackingInfo) {
        dismissViewController(animated: true) { [weak self] in
            switch params {
            case .product(let productParams):
                self?.listingRepository.create(productParams: productParams) { result in
                    if let value = result.value {
                        let listing = Listing.product(value)
                        self?.trackPost(withListing: listing, trackingInfo: trackingInfo)
                        self?.keyValueStorage.userPostProductPostedPreviously = true
                        self?.showConfirmation(listingResult: ListingResult(value: listing),
                                               trackingInfo: trackingInfo)
                    } else if let error = result.error {
                        self?.trackListingPostedInBackground(withError: error)
                        self?.showConfirmation(listingResult: ListingResult(error: error),
                                               trackingInfo: trackingInfo)
                    }
                }
            case .car(let carParams):
                self?.listingRepository.create(carParams: carParams) { result in
                    if let value = result.value {
                        let listing = Listing.car(value)
                        self?.trackPost(withListing: listing, trackingInfo: trackingInfo)
                        self?.keyValueStorage.userPostProductPostedPreviously = true
                        self?.showConfirmation(listingResult: ListingResult(value: listing),
                                               trackingInfo: trackingInfo)
                    } else if let error = result.error {
                        self?.trackListingPostedInBackground(withError: error)
                        self?.showConfirmation(listingResult: ListingResult(error: error),
                                               trackingInfo: trackingInfo)
                    }
                }
            }
        }
    }
    
    fileprivate func trackListingPostedInBackground(withError error: RepositoryError) {
        let sellError: EventParameterPostProductError
        switch error {
        case .network:
            sellError = .network
        case let .forbidden(cause: cause):
            sellError = .forbidden(cause: cause)
        case .serverError, .notFound, .unauthorized, .tooManyRequests, .userNotVerified:
            sellError = .serverError(code: error.errorCode)
        case .internalError:
            sellError = .internalError
        }
        let sellErrorDataEvent = TrackerEvent.productSellErrorData(sellError)
        TrackerProxy.sharedInstance.trackEvent(sellErrorDataEvent)
    }

    fileprivate func showConfirmation(listingResult: ListingResult, trackingInfo: PostProductTrackingInfo) {
        guard let parentVC = parentViewController else { return }
        
        let productPostedVM = ProductPostedViewModel(listingResult: listingResult, trackingInfo: trackingInfo)
        productPostedVM.navigator = self
        let productPostedVC = ProductPostedViewController(viewModel: productPostedVM)
        viewController = productPostedVC
        parentVC.present(productPostedVC, animated: true, completion: nil)
    }

    func closePostProductAndPostLater(params: ListingCreationParams, images: [UIImage],
                                      trackingInfo: PostProductTrackingInfo) {
        guard let parentVC = parentViewController else { return }

        dismissViewController(animated: true) { [weak self] in
            let productPostedVM = ProductPostedViewModel(postParams: params, productImages: images,
                                                         trackingInfo: trackingInfo)
            productPostedVM.navigator = self
            let productPostedVC = ProductPostedViewController(viewModel: productPostedVM)
            self?.viewController = productPostedVC
            parentVC.present(productPostedVC, animated: true, completion: nil)
        }
    }

    func openLoginIfNeededFromProductPosted(from: EventParameterLoginSourceValue, loggedInAction: @escaping (() -> Void), cancelAction: (() -> Void)?) {
        openLoginIfNeeded(from: from, style: .popup(LGLocalizedString.productPostLoginMessage), loggedInAction: loggedInAction, cancelAction: cancelAction)
    }
}


// MARK: - ProductPostedNavigator

extension SellCoordinator: ProductPostedNavigator {
    func cancelProductPosted() {
        closeCoordinator(animated: true) { [weak self] in
            guard let strongSelf = self, let delegate = strongSelf.delegate else { return }

            delegate.sellCoordinatorDidCancel(strongSelf)
        }
    }

    func closeProductPosted(_ listing: Listing) {
        closeCoordinator(animated: true) { [weak self] in
            guard let strongSelf = self, let delegate = strongSelf.delegate else { return }

            delegate.sellCoordinator(strongSelf, didFinishWithListing: listing)
        }
    }

    func closeProductPostedAndOpenEdit(_ listing: Listing) {
        dismissViewController(animated: true) { [weak self] in
            guard let parentVC = self?.parentViewController else { return }

            // Open a coordinator @ ABIOS-2719
            let editVM = EditListingViewModel(listing: listing)
            editVM.closeCompletion = { editedListing in
                self?.closeCoordinator(animated: false) {
                    guard let strongSelf = self else { return }
                    strongSelf.delegate?.sellCoordinator(strongSelf, didFinishWithListing: editedListing ?? listing)
                }
            }
            let editVC = EditListingViewController(viewModel: editVM)
            let navCtl = UINavigationController(rootViewController: editVC)
            parentVC.present(navCtl, animated: true, completion: nil)
        }
    }

    func closeProductPostedAndOpenPost() {
        dismissViewController(animated: true) { [weak self] in
            guard let strongSelf = self, let parentVC = strongSelf.parentViewController else { return }
            let postProductVM = PostProductViewModel(source: strongSelf.postingSource)
            let postProductVC = PostProductViewController(viewModel: postProductVM, forceCamera: false)
            strongSelf.viewController = postProductVC
            postProductVM.navigator = self

            strongSelf.presentViewController(parent: parentVC, animated: true, completion: nil)
        }
    }
}


// MARK: - Tracking

fileprivate extension SellCoordinator {
    func trackPost(withListing listing: Listing, trackingInfo: PostProductTrackingInfo) {
        let event = TrackerEvent.productSellComplete(listing, buttonName: trackingInfo.buttonName, sellButtonPosition: trackingInfo.sellButtonPosition,
                                                     negotiable: trackingInfo.negotiablePrice, pictureSource: trackingInfo.imageSource,
                                                     freePostingModeAllowed: featureFlags.freePostingModeAllowed)

        tracker.trackEvent(event)

        // Track product was sold in the first 24h (and not tracked before)
        if let firstOpenDate = keyValueStorage[.firstRunDate], Date().timeIntervalSince(firstOpenDate) <= 86400 &&
                !keyValueStorage.userTrackingProductSellComplete24hTracked {
            keyValueStorage.userTrackingProductSellComplete24hTracked = true

            let event = TrackerEvent.productSellComplete24h(listing)
            tracker.trackEvent(event)
        }
    }
}
