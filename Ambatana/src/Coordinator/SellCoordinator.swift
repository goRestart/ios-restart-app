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
    func sellCoordinator(_ coordinator: SellCoordinator, didFinishWithProduct product: Product)
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

    func closePostProductAndPostInBackground(params: ProductCreationParams, showConfirmation: Bool,
                                             trackingInfo: PostProductTrackingInfo) {
        dismissViewController(animated: true) { [weak self] in

            self?.listingRepository.create(productParams: params) { result in
                self?.trackPost(result, trackingInfo: trackingInfo)

                if let _ = result.value {
                    self?.keyValueStorage.userPostProductPostedPreviously = true
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
                    TrackerProxy.sharedInstance.trackEvent(sellErrorDataEvent)
                }

                if showConfirmation {
                    guard let parentVC = self?.parentViewController else { return }

                    let productPostedVM = ProductPostedViewModel(postResult: result, trackingInfo: trackingInfo)
                    productPostedVM.navigator = self
                    let productPostedVC = ProductPostedViewController(viewModel: productPostedVM)
                    self?.viewController = productPostedVC
                    parentVC.present(productPostedVC, animated: true, completion: nil)
                } else {
                    self?.closeCoordinator(animated: false) {
                        guard let strongSelf = self else { return }
                        if let product = result.value {
                            strongSelf.delegate?.sellCoordinator(strongSelf, didFinishWithProduct: product)
                        } else {
                            strongSelf.delegate?.sellCoordinatorDidCancel(strongSelf)
                        }
                    }
                }
            }
        }
    }

    func closePostProductAndPostLater(params: ProductCreationParams, images: [UIImage],
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

    func openLoginIfNeededFromProductPosted(from: EventParameterLoginSourceValue, loggedInAction: @escaping (() -> Void)) {
        openLoginIfNeeded(from: from, style: .popup(LGLocalizedString.productPostLoginMessage), loggedInAction: loggedInAction)
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

    func closeProductPosted(_ product: Product) {
        closeCoordinator(animated: true) { [weak self] in
            guard let strongSelf = self, let delegate = strongSelf.delegate else { return }

            delegate.sellCoordinator(strongSelf, didFinishWithProduct: product)
        }
    }

    func closeProductPostedAndOpenEdit(_ product: Product) {
        dismissViewController(animated: true) { [weak self] in
            guard let parentVC = self?.parentViewController else { return }

            // TODO: Open EditProductCoordinator, refactor this completion with a EditProductCoordinatorDelegate func
            let editVM = EditProductViewModel(product: product)
            editVM.closeCompletion = { editedProduct in
                self?.closeCoordinator(animated: false) {
                    guard let strongSelf = self else { return }
                    strongSelf.delegate?.sellCoordinator(strongSelf, didFinishWithProduct: editedProduct ?? product)
                }
            }
            let editVC = EditProductViewController(viewModel: editVM)
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
    func trackPost(_ result: ProductResult, trackingInfo: PostProductTrackingInfo) {
        guard let product = result.value else { return }
        let event = TrackerEvent.productSellComplete(product, buttonName: trackingInfo.buttonName, sellButtonPosition: trackingInfo.sellButtonPosition,
                                                     negotiable: trackingInfo.negotiablePrice, pictureSource: trackingInfo.imageSource,
                                                     freePostingModeAllowed: featureFlags.freePostingModeAllowed)

        tracker.trackEvent(event)

        // Track product was sold in the first 24h (and not tracked before)
        if let firstOpenDate = keyValueStorage[.firstRunDate], Date().timeIntervalSince(firstOpenDate) <= 86400 &&
                !keyValueStorage.userTrackingProductSellComplete24hTracked {
            keyValueStorage.userTrackingProductSellComplete24hTracked = true

            let event = TrackerEvent.productSellComplete24h(product)
            tracker.trackEvent(event)
        }
    }
}
