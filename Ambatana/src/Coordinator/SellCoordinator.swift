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
    var viewController: UIViewController// { return postProductViewController }
    var presentedAlertController: UIAlertController?

    private let keyValueStorage: KeyValueStorage

//    private let postProductViewController: PostProductViewController

    weak var delegate: SellCoordinatorDelegate?
//    weak var delegate: SellNavigatorDelegate?

    private let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    convenience init(source: PostingSource) {
        let keyValueStorage = KeyValueStorage.sharedInstance
        self.init(source: source, keyValueStorage: keyValueStorage)
    }

    init(source: PostingSource, keyValueStorage: KeyValueStorage) {
        self.keyValueStorage = keyValueStorage
        
        let postProductVM = PostProductViewModel(source: source)
        let postProductVC = PostProductViewController(viewModel: postProductVM, forceCamera: source.forceCamera)
        self.viewController = postProductVC

        super.init()
        postProductVM.navigator = self
        postProductVC.delegate = self
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
//    weak var delegate: SellNavigatorDelegate?
}


// MARK: - SellProductViewControllerDelegate

extension SellCoordinator: SellProductViewControllerDelegate {
    func sellProductViewController(sellVC: SellProductViewController?, didCompleteSell successfully: Bool,
                                   withPromoteProductViewModel promoteProductVM: PromoteProductViewModel?) {
        guard successfully else { return }
//        delegate?.sellNavigator(self, didCompleteSellWithViewModel: promoteProductVM)
    }

    func sellProductViewController(sellVC: SellProductViewController?,
                                   didFinishPostingProduct postedViewModel: ProductPostedViewModel) {
//        delegate?.sellNavigator(self, productPostedWithViewModel: postedViewModel)
    }

    func sellProductViewController(sellVC: SellProductViewController?,
                                   didEditProduct editVC: EditProductViewController?) {
//        guard let editVC = editVC else { return }
//        delegate?.sellNavigator(self, editProductWithViewModel: editVC) // TODO: ⚠️ it's a fucking VC (venture capital)
    }

    func sellProductViewControllerDidTapPostAgain(sellVC: SellProductViewController?) {
//        openSell()
    }
}

// MARK: - PostProductNavigator

extension SellCoordinator: PostProductNavigator {
//    weak var postProductNavigatorDelegate: PostProductNavigatorDelegate? { get }

    // Cancels post product flow.
    func cancel() {
        close(animated: true, notifyDelegate: true, completion: nil)
    }

    // Closes post product screen, posts the product and opens product posted if `showConfirmation` is `true`
    func closeAndPost(productRepository: ProductRepository, product: Product, images: [File], showConfirmation: Bool,
                      trackingInfo: PostProductTrackingInfo) {

        close(animated: true, notifyDelegate: false) {
            productRepository.create(product, images: images) { [weak self] result in

                // Tracking
                if let product = result.value {
                    let event = TrackerEvent.productSellComplete(product, buttonName: trackingInfo.buttonName,
                                                                 negotiable: trackingInfo.negotiablePrice,
                                                                 pictureSource: trackingInfo.imageSource)
                    TrackerProxy.sharedInstance.trackEvent(event)

                    // Track product was sold in the first 24h (and not tracked before)
                    if let firstOpenDate = KeyValueStorage.sharedInstance[.firstRunDate]
                        where NSDate().timeIntervalSinceDate(firstOpenDate) <= 86400 &&
                            !KeyValueStorage.sharedInstance.userTrackingProductSellComplete24hTracked {
                        KeyValueStorage.sharedInstance.userTrackingProductSellComplete24hTracked = true

                        let event = TrackerEvent.productSellComplete24h(product)
                        TrackerProxy.sharedInstance.trackEvent(event)
                    }
                }

                if showConfirmation {
                    guard let parentVC = self?.parentViewController else { return }

                    let productPostedVM = ProductPostedViewModel(postResult: result, trackingInfo: trackingInfo)
                    let productPostedVC = ProductPostedViewController(viewModel: productPostedVM)
                    productPostedVC.delegate = self
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

    // Closes post product screen and opens product posted to post the product
    func closeAndPost(priceText priceText: String?, image: UIImage, trackingInfo: PostProductTrackingInfo) {

//        delegate?.postProductviewModel(self, shouldAskLoginWithCompletion: { [weak self] in
//            guard let strongSelf = self else { return }
//            strongSelf.delegate?.postProductviewModelshouldClose(strongSelf, animated: false, completion: {
//                [weak self] in
//                guard let product = self?.buildProduct(priceText: priceText) else { return }
//                let productPostedViewModel = ProductPostedViewModel(productToPost: product, productImage: image,
//                    trackingInfo: trackInfo)
//                sellDelegate?.sellProductViewController(controller, didFinishPostingProduct: productPostedViewModel)
//                })
//            })
    }
}

//private extension SellCoordinator {
//    func dismiss() {
//        if viewController is PostProductViewController {
//            viewController.dismissViewControllerAnimated(true) {
//
//            }
//        }
//    }
//}
