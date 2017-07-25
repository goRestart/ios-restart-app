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
    weak var coordinatorDelegate: CoordinatorDelegate?
    var viewController: UIViewController
    weak var presentedAlertController: UIAlertController?
    let bubbleNotificationManager: BubbleNotificationManager
    let sessionManager: SessionManager


    convenience init(listing: Listing,
                     socialMessage: SocialMessage,
                     paymentItemId: String?) {
        self.init(listing: listing,
                  socialMessage: socialMessage,
                  paymentItemId: paymentItemId,
                  bubbleNotificationManager: LGBubbleNotificationManager.sharedInstance,
                  sessionManager: Core.sessionManager)
    }

    convenience init(listing: Listing,
                     purchaseableProduct: PurchaseableProduct,
                     paymentItemId: String?) {
        self.init(listing: listing,
                  purchaseableProduct: purchaseableProduct,
                  paymentItemId: paymentItemId,
                  bubbleNotificationManager: LGBubbleNotificationManager.sharedInstance,
                  sessionManager: Core.sessionManager)
    }

    init(listing: Listing,
         socialMessage: SocialMessage,
         paymentItemId: String?,
         bubbleNotificationManager: BubbleNotificationManager,
         sessionManager: SessionManager) {

        let bumpUpVM = BumpUpFreeViewModel(listing: listing, socialMessage: socialMessage, paymentItemId: paymentItemId)
        let bumpUpVC = BumpUpFreeViewController(viewModel: bumpUpVM)
        bumpUpVC.modalPresentationStyle = .overCurrentContext
        self.viewController = bumpUpVC
        self.bubbleNotificationManager = bubbleNotificationManager
        self.sessionManager = sessionManager
        bumpUpVM.navigator = self
    }


    init(listing: Listing,
         purchaseableProduct: PurchaseableProduct,
         paymentItemId: String?,
         bubbleNotificationManager: BubbleNotificationManager,
         sessionManager: SessionManager) {

        let bumpUpVM = BumpUpPayViewModel(listing: listing, purchaseableProduct: purchaseableProduct,
                                          paymentItemId: paymentItemId)
        let bumpUpVC = BumpUpPayViewController(viewModel: bumpUpVM)
        bumpUpVC.modalPresentationStyle = .overCurrentContext
        self.viewController = bumpUpVC
        self.bubbleNotificationManager = bubbleNotificationManager
        self.sessionManager = sessionManager
        bumpUpVM.navigator = self
    }

    func presentViewController(parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard viewController.parent == nil else { return }
        parent.present(viewController, animated: animated, completion: completion)
    }

    func dismissViewController(animated: Bool, completion: (() -> Void)?) {
        viewController.dismissWithPresented(animated: animated, completion: completion)
    }
}

extension BumpUpCoordinator : BumpUpNavigator {
    func bumpUpDidCancel() {
        closeCoordinator(animated: true, completion: nil)
    }

    func bumpUpDidFinish(completion: (() -> Void)?) {
        closeCoordinator(animated: true, completion: completion)
    }
}
