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
    func sellCoordinator(coordinator: SellCoordinator, openPromoteIfNeeded postResult: ProductResult) -> Bool
    func sellCoordinatorOpenAfterSellDialogIfNeeded(coordinator: SellCoordinator) -> Bool
}

final class SellCoordinator: NSObject, Coordinator {
    var child: Coordinator?

    private var parentViewController: UIViewController?
    var viewController: UIViewController
    var presentedAlertController: UIAlertController?

    private let productRepository: ProductRepository
    private let keyValueStorage: KeyValueStorage
    private let tracker: Tracker

    weak var delegate: SellCoordinatorDelegate?

    private let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    convenience init(source: PostingSource) {
        let productRepository = Core.productRepository
        let keyValueStorage = KeyValueStorage.sharedInstance
        let tracker = TrackerProxy.sharedInstance
        self.init(source: source, productRepository: productRepository,
                  keyValueStorage: keyValueStorage, tracker: tracker)
    }

    init(source: PostingSource, productRepository: ProductRepository,
         keyValueStorage: KeyValueStorage, tracker: Tracker) {
        self.productRepository = productRepository
        self.keyValueStorage = keyValueStorage
        self.tracker = tracker
        
        let postProductVM = PostProductViewModel(source: source)
        let postProductVC = PostProductViewController(viewModel: postProductVM, forceCamera: source.forceCamera)
        self.viewController = postProductVC

        super.init()
        postProductVM.navigator = self
    }

    func open(parent parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard let postProductVC = viewController as? PostProductViewController else { return }
        guard postProductVC.parentViewController == nil else { return }

        parentViewController = parent
        parent.presentViewController(postProductVC, animated: animated, completion: completion)
    }

    func close(animated animated: Bool, completion: (() -> Void)?) {
        close(animated: animated, notifyDelegate: true, completion: completion)
    }
}

private extension SellCoordinator {
    func close(animated animated: Bool, notifyDelegate: Bool, completion: (() -> Void)?) {
        let dismiss: () -> Void = { [weak self] in
            guard let postProductVC = self?.viewController as? PostProductViewController else { return }
            postProductVC.dismissViewControllerAnimated(animated) { [weak self] in
                if let strongSelf = self where notifyDelegate {
                    strongSelf.delegate?.coordinatorDidClose(strongSelf)
                }
                completion?()
            }
        }

        if let child = child {
            child.close(animated: animated, completion: dismiss)
        } else {
            dismiss()
        }
    }
}

// MARK: - SellNavigator

extension SellCoordinator: SellNavigator {

}


// MARK: - PostProductNavigator

extension SellCoordinator: PostProductNavigator {
    func cancel() {
        close(animated: true, notifyDelegate: true, completion: nil)
    }

    func closeAndPost(product: Product, images: [File], showConfirmation: Bool, trackingInfo: PostProductTrackingInfo) {

        close(animated: true, notifyDelegate: false) { [weak self] in
            self?.productRepository.create(product, images: images) { result in
                self?.trackPost(result, trackingInfo: trackingInfo)

                if let _ = result.value {
                    self?.keyValueStorage.userPostProductPostedPreviously = true
                }

                if showConfirmation {
                    guard let parentVC = self?.parentViewController else { return }

                    let productPostedVM = ProductPostedViewModel(postResult: result, trackingInfo: trackingInfo)
                    let productPostedVC = ProductPostedViewController(viewModel: productPostedVM)
                    self?.viewController = productPostedVC
                    parentVC.presentViewController(productPostedVC, animated: true, completion: nil)
                } else {
                    guard let strongSelf = self else { return }
                    guard let delegate = strongSelf.delegate else { return }

                    var nextActionExecuted = delegate.sellCoordinator(strongSelf, openPromoteIfNeeded: result)
                    if !nextActionExecuted {
                        nextActionExecuted = delegate.sellCoordinatorOpenAfterSellDialogIfNeeded(strongSelf)
                    }
                    if !nextActionExecuted {
                        delegate.coordinatorDidClose(strongSelf)
                    }
                }
            }
        }
    }

    func closeAndPost(product: Product, image: UIImage, trackingInfo: PostProductTrackingInfo) {
        guard let parentVC = parentViewController else { return }

        close(animated: true, notifyDelegate: false) { [weak self] in
            let productPostedVM = ProductPostedViewModel(productToPost: product, productImage: image,
                                                         trackingInfo: trackingInfo)
            let productPostedVC = ProductPostedViewController(viewModel: productPostedVM)
            self?.viewController = productPostedVC
            parentVC.presentViewController(productPostedVC, animated: true, completion: nil)
        }
    }
}


// MARK: - Tracking

private extension SellCoordinator {
    func trackPost(result: ProductResult, trackingInfo: PostProductTrackingInfo) {
        guard let product = result.value else { return }

        let event = TrackerEvent.productSellComplete(product, buttonName: trackingInfo.buttonName,
                                                     negotiable: trackingInfo.negotiablePrice,
                                                     pictureSource: trackingInfo.imageSource)
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
