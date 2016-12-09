//
//  SellCoordinator.swift
//  LetGo
//
//  Created by Albert Hernández López on 20/06/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

protocol SellCoordinatorDelegate: CoordinatorDelegate {
    func sellCoordinatorDidCancel(coordinator: SellCoordinator)
    func sellCoordinator(coordinator: SellCoordinator, didFinishWithProduct product: Product)
}

final class SellCoordinator: Coordinator {
    var child: Coordinator?

    private var parentViewController: UIViewController?
    var viewController: UIViewController
    var presentedAlertController: UIAlertController?

    private let productRepository: ProductRepository
    private let keyValueStorage: KeyValueStorage
    private let tracker: Tracker
    private let featureFlags: FeatureFlaggeable
    private let postingSource: PostingSource
    weak var delegate: SellCoordinatorDelegate?

    private let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    convenience init(source: PostingSource) {
        let productRepository = Core.productRepository
        let keyValueStorage = KeyValueStorage.sharedInstance
        let tracker = TrackerProxy.sharedInstance
        let featureFlags = FeatureFlags.sharedInstance
        self.init(source: source, productRepository: productRepository,
                  keyValueStorage: keyValueStorage, tracker: tracker, featureFlags: featureFlags)
    }

    init(source: PostingSource, productRepository: ProductRepository,
         keyValueStorage: KeyValueStorage, tracker: Tracker, featureFlags: FeatureFlags) {
        self.productRepository = productRepository
        self.keyValueStorage = keyValueStorage
        self.tracker = tracker
        self.postingSource = source
        self.featureFlags = featureFlags
        let postProductVM = PostProductViewModel(source: source)
        let postProductVC = PostProductViewController(viewModel: postProductVM, forceCamera: false)
        self.viewController = postProductVC

        postProductVM.navigator = self
    }

    func open(parent parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard let postProductVC = viewController as? PostProductViewController else { return }
        guard postProductVC.parentViewController == nil else { return }

        parentViewController = parent
        parent.presentViewController(postProductVC, animated: animated, completion: completion)
    }

    func close(animated animated: Bool, completion: (() -> Void)?) {
        close(UIViewController.self, animated: animated, completion: completion)
    }
}

private extension SellCoordinator {
    func close<T: UIViewController>(type: T.Type, animated: Bool, completion: (() -> Void)?) {
        let dismiss: () -> Void = { [weak self] in
            guard let viewController = self?.viewController as? T else { return }
            viewController.dismissViewControllerAnimated(animated, completion: completion)
        }

        if let child = child {
            child.close(animated: animated, completion: dismiss)
        } else {
            dismiss()
        }
    }
}


// MARK: - PostProductNavigator

extension SellCoordinator: PostProductNavigator {
    func cancelPostProduct() {
        close(PostProductViewController.self, animated: true) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.sellCoordinatorDidCancel(strongSelf)
            strongSelf.delegate?.coordinatorDidClose(strongSelf)
        }
    }

    func closePostProductAndPostInBackground(product: Product, images: [File], showConfirmation: Bool,
                                             trackingInfo: PostProductTrackingInfo) {
        close(PostProductViewController.self, animated: true) { [weak self] in
            self?.productRepository.create(product, images: images) { result in
                self?.trackPost(result, trackingInfo: trackingInfo)

                if let _ = result.value {
                    self?.keyValueStorage.userPostProductPostedPreviously = true
                } else if let error = result.error {
                    let sellError: EventParameterPostProductError
                    switch error {
                    case .Network, .NetworkFailedOnBackground:
                        sellError = .Network
                    case .ServerError, .NotFound, .Forbidden, .Unauthorized, .TooManyRequests, .UserNotVerified:
                        sellError = .ServerError(code: error.errorCode)
                    case .Internal:
                        sellError = .Internal
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
                    parentVC.presentViewController(productPostedVC, animated: true, completion: nil)
                } else {
                    guard let strongSelf = self else { return }
                    guard let delegate = strongSelf.delegate else { return }

                    if let product = result.value {
                        delegate.sellCoordinator(strongSelf, didFinishWithProduct: product)
                    } else {
                        delegate.sellCoordinatorDidCancel(strongSelf)
                    }
                    delegate.coordinatorDidClose(strongSelf)
                }
            }
        }
    }

    func closePostProductAndPostLater(product: Product, image: UIImage, trackingInfo: PostProductTrackingInfo) {
        guard let parentVC = parentViewController else { return }

        close(PostProductViewController.self, animated: true) { [weak self] in
            let productPostedVM = ProductPostedViewModel(productToPost: product, productImage: image,
                                                         trackingInfo: trackingInfo)
            productPostedVM.navigator = self
            let productPostedVC = ProductPostedViewController(viewModel: productPostedVM)
            self?.viewController = productPostedVC
            parentVC.presentViewController(productPostedVC, animated: true, completion: nil)
        }
    }
}


// MARK: - ProductPostedNavigator

extension SellCoordinator: ProductPostedNavigator {
    func cancelProductPosted() {
        close(ProductPostedViewController.self, animated: true) { [weak self] in
            guard let strongSelf = self, delegate = strongSelf.delegate else { return }

            delegate.sellCoordinatorDidCancel(strongSelf)
            delegate.coordinatorDidClose(strongSelf)
        }
    }

    func closeProductPosted(product: Product) {
        close(ProductPostedViewController.self, animated: true) { [weak self] in
            guard let strongSelf = self, delegate = strongSelf.delegate else { return }

            delegate.sellCoordinator(strongSelf, didFinishWithProduct: product)
            delegate.coordinatorDidClose(strongSelf)
        }
    }

    func closeProductPostedAndOpenEdit(product: Product) {
        close(ProductPostedViewController.self, animated: true) { [weak self] in
            guard let strongSelf = self, parentVC = strongSelf.parentViewController,
                delegate = strongSelf.delegate else { return }

            // TODO: Open EditProductCoordinator, refactor this completion with a EditProductCoordinatorDelegate func
            let editVM = EditProductViewModel(product: product)
            editVM.closeCompletion = { editedProduct in
                delegate.sellCoordinator(strongSelf, didFinishWithProduct: editedProduct ?? product)
                delegate.coordinatorDidClose(strongSelf)
            }
            let editVC = EditProductViewController(viewModel: editVM)
            let navCtl = UINavigationController(rootViewController: editVC)
            parentVC.presentViewController(navCtl, animated: true, completion: nil)
        }
    }

    func closeProductPostedAndOpenPost() {
        close(ProductPostedViewController.self, animated: true) { [weak self] in
            guard let strongSelf = self, parentVC = strongSelf.parentViewController else { return }
            let postProductVM = PostProductViewModel(source: strongSelf.postingSource)
            let postProductVC = PostProductViewController(viewModel: postProductVM, forceCamera: false)
            strongSelf.viewController = postProductVC
            postProductVM.navigator = self

            strongSelf.open(parent: parentVC, animated: true, completion: nil)
        }
    }
}


// MARK: - Tracking

private extension SellCoordinator {
    func trackPost(result: ProductResult, trackingInfo: PostProductTrackingInfo) {
        guard let product = result.value else { return }
        let event = TrackerEvent.productSellComplete(product, buttonName: trackingInfo.buttonName, sellButtonPosition: trackingInfo.sellButtonPosition,
                                                     negotiable: trackingInfo.negotiablePrice, pictureSource: trackingInfo.imageSource,
                                                     freePostingModeAllowed: featureFlags.freePostingModeAllowed)

        tracker.trackEvent(event)

        // Track product was sold in the first 24h (and not tracked before)
        if let firstOpenDate = keyValueStorage[.firstRunDate]
            where NSDate().timeIntervalSinceDate(firstOpenDate) <= 86400 &&
                !keyValueStorage.userTrackingProductSellComplete24hTracked {
            keyValueStorage.userTrackingProductSellComplete24hTracked = true

            let event = TrackerEvent.productSellComplete24h(product)
            tracker.trackEvent(event)
        }
    }
}
