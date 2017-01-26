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
    func sellCoordinatorDidCancel(_ coordinator: SellCoordinator)
    func sellCoordinator(_ coordinator: SellCoordinator, didFinishWithProduct product: Product)
}

final class SellCoordinator: Coordinator {
    var child: Coordinator?

    fileprivate var parentViewController: UIViewController?
    var viewController: UIViewController
    var presentedAlertController: UIAlertController?

    fileprivate let productRepository: ProductRepository
    fileprivate let keyValueStorage: KeyValueStorage
    fileprivate let tracker: Tracker
    fileprivate let featureFlags: FeatureFlaggeable
    fileprivate let postingSource: PostingSource
    weak var delegate: SellCoordinatorDelegate?

    fileprivate let disposeBag = DisposeBag()


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

    func open(parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard let postProductVC = viewController as? PostProductViewController else { return }
        guard postProductVC.parent == nil else { return }

        parentViewController = parent
        parent.present(postProductVC, animated: animated, completion: completion)
    }

    func close(animated: Bool, completion: (() -> Void)?) {
        close(UIViewController.self, animated: animated, completion: completion)
    }
}

fileprivate extension SellCoordinator {
    func close<T: UIViewController>(_ type: T.Type, animated: Bool, completion: (() -> Void)?) {
        let dismiss: () -> Void = { [weak self] in
            guard let viewController = self?.viewController as? T else { return }
            viewController.dismiss(animated: animated, completion: completion)
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

    func closePostProductAndPostInBackground(_ product: Product, images: [File], showConfirmation: Bool,
                                             trackingInfo: PostProductTrackingInfo) {
        close(PostProductViewController.self, animated: true) { [weak self] in
            self?.productRepository.create(product, images: images) { result in
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

    func closePostProductAndPostLater(_ product: Product, images: [UIImage], trackingInfo: PostProductTrackingInfo) {
        guard let parentVC = parentViewController else { return }

        close(PostProductViewController.self, animated: true) { [weak self] in
            let productPostedVM = ProductPostedViewModel(productToPost: product, productImages: images,
                                                         trackingInfo: trackingInfo)
            productPostedVM.navigator = self
            let productPostedVC = ProductPostedViewController(viewModel: productPostedVM)
            self?.viewController = productPostedVC
            parentVC.present(productPostedVC, animated: true, completion: nil)
        }
    }
}


// MARK: - ProductPostedNavigator

extension SellCoordinator: ProductPostedNavigator {
    func cancelProductPosted() {
        close(ProductPostedViewController.self, animated: true) { [weak self] in
            guard let strongSelf = self, let delegate = strongSelf.delegate else { return }

            delegate.sellCoordinatorDidCancel(strongSelf)
            delegate.coordinatorDidClose(strongSelf)
        }
    }

    func closeProductPosted(_ product: Product) {
        close(ProductPostedViewController.self, animated: true) { [weak self] in
            guard let strongSelf = self, let delegate = strongSelf.delegate else { return }

            delegate.sellCoordinator(strongSelf, didFinishWithProduct: product)
            delegate.coordinatorDidClose(strongSelf)
        }
    }

    func closeProductPostedAndOpenEdit(_ product: Product) {
        close(ProductPostedViewController.self, animated: true) { [weak self] in
            guard let strongSelf = self, let parentVC = strongSelf.parentViewController,
                let delegate = strongSelf.delegate else { return }

            // TODO: Open EditProductCoordinator, refactor this completion with a EditProductCoordinatorDelegate func
            let editVM = EditProductViewModel(product: product)
            editVM.closeCompletion = { editedProduct in
                delegate.sellCoordinator(strongSelf, didFinishWithProduct: editedProduct ?? product)
                delegate.coordinatorDidClose(strongSelf)
            }
            let editVC = EditProductViewController(viewModel: editVM)
            let navCtl = UINavigationController(rootViewController: editVC)
            parentVC.present(navCtl, animated: true, completion: nil)
        }
    }

    func closeProductPostedAndOpenPost() {
        close(ProductPostedViewController.self, animated: true) { [weak self] in
            guard let strongSelf = self, let parentVC = strongSelf.parentViewController else { return }
            let postProductVM = PostProductViewModel(source: strongSelf.postingSource)
            let postProductVC = PostProductViewController(viewModel: postProductVM, forceCamera: false)
            strongSelf.viewController = postProductVC
            postProductVM.navigator = self

            strongSelf.open(parent: parentVC, animated: true, completion: nil)
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
