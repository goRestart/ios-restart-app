//
//  BumpUpCoordinator.swift
//  LetGo
//
//  Created by Dídac on 30/01/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit


class BumpUpCoordinator: Coordinator {

    var child: Coordinator?

    private var parentViewController: UIViewController?
    var viewController: UIViewController
    var presentedAlertController: UIAlertController?

    weak var delegate: CoordinatorDelegate?

    init(product: Product, socialMessage: SocialMessage, paymentItemId: String?) {

        let bumpUpVM = BumpUpFreeViewModel(product: product, socialMessage: socialMessage, paymentItemId: paymentItemId)
        let bumpUpVC = BumpUpFreeViewController(viewModel: bumpUpVM)
        bumpUpVC.modalPresentationStyle = .overCurrentContext
        self.viewController = bumpUpVC

        bumpUpVM.navigator = self
    }

    init(product: Product, purchaseableProduct: PurchaseableProduct, paymentItemId: String?) {

        let bumpUpVM = BumpUpPayViewModel(product: product, purchaseableProduct: purchaseableProduct,
                                          paymentItemId: paymentItemId)
        let bumpUpVC = BumpUpPayViewController(viewModel: bumpUpVM)
        bumpUpVC.modalPresentationStyle = .overCurrentContext
        self.viewController = bumpUpVC

        bumpUpVM.navigator = self
    }

    func open(parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard viewController.parent == nil else { return }

        parentViewController = parent
        parent.present(viewController, animated: animated, completion: completion)
    }

    func close(animated: Bool, completion: (() -> Void)?) {
        closeBumpUp(animated: animated, completion: completion)
    }

    fileprivate func closeBumpUp(animated: Bool, completion: (() -> Void)?) {
        let dismiss: () -> Void = { [weak self] in
            self?.viewController.dismiss(animated: animated) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.delegate?.coordinatorDidClose(strongSelf)
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

extension BumpUpCoordinator : BumpUpNavigator {
    func bumpUpDidCancel() {
        closeBumpUp(animated: true, completion: nil)
    }

    func bumpUpDidFinish(completion: (() -> Void)?) {
        closeBumpUp(animated: true, completion: completion)
    }
}
