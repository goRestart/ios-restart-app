//
//  BumpUpCoordinator.swift
//  LetGo
//
//  Created by Dídac on 30/01/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

enum BumpUpPurchaseableData {
    case socialMessage(message: SocialMessage)
    case purchaseableProduct(product: PurchaseableProduct)
}

struct BumpUpProductData {
    let bumpUpPurchaseableData: BumpUpPurchaseableData
    let paymentItemId: String?
    let storeProductId: String?

    var hasPaymentId: Bool {
        return paymentItemId != nil
    }
}

class BumpUpCoordinator: Coordinator {
    var child: Coordinator?
    weak var coordinatorDelegate: CoordinatorDelegate?
    var viewController: UIViewController
    weak var presentedAlertController: UIAlertController?
    let bubbleNotificationManager: BubbleNotificationManager
    let sessionManager: SessionManager


    convenience init(listing: Listing,
                     bumpUpProductData: BumpUpProductData,
                     typePage: EventParameterTypePage?,
                     timeSinceLastBump: TimeInterval? = 0,
                     maxCountdoWn: TimeInterval? = 0) {
        switch bumpUpProductData.bumpUpPurchaseableData {
        case .socialMessage(let socialMessage):
            self.init(listing: listing,
                      socialMessage: socialMessage,
                      paymentItemId: bumpUpProductData.paymentItemId,
                      storeProductId: bumpUpProductData.storeProductId,
                      typePage: typePage,
                      bubbleNotificationManager: LGBubbleNotificationManager.sharedInstance,
                      sessionManager: Core.sessionManager)
        case .purchaseableProduct(let purchaseableProduct):
            let featureFlags = FeatureFlags.sharedInstance
            self.init(listing: listing,
                      purchaseableProduct: purchaseableProduct,
                      paymentItemId: bumpUpProductData.paymentItemId,
                      storeProductId: bumpUpProductData.storeProductId,
                      typePage: typePage,
                      bubbleNotificationManager: LGBubbleNotificationManager.sharedInstance,
                      sessionManager: Core.sessionManager,
                      featureFlags: featureFlags,
                      timeSinceLastBump: timeSinceLastBump,
                      maxCountdoWn: maxCountdoWn)
        }
    }

    init(listing: Listing,
         socialMessage: SocialMessage,
         paymentItemId: String?,
         storeProductId: String?,
         typePage: EventParameterTypePage?,
         bubbleNotificationManager: BubbleNotificationManager,
         sessionManager: SessionManager) {

        let bumpUpVM = BumpUpFreeViewModel(listing: listing,
                                           socialMessage: socialMessage,
                                           paymentItemId: paymentItemId,
                                           storeProductId: storeProductId,
                                           typePage: typePage)
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
         storeProductId: String?,
         typePage: EventParameterTypePage?,
         bubbleNotificationManager: BubbleNotificationManager,
         sessionManager: SessionManager,
         featureFlags: FeatureFlaggeable,
         timeSinceLastBump: TimeInterval? = 0,
         maxCountdoWn: TimeInterval? = 0) {

        let bumpUpVM = BumpUpPayViewModel(listing: listing,
                                          purchaseableProduct: purchaseableProduct,
                                          paymentItemId: paymentItemId,
                                          storeProductId: storeProductId,
                                          typePage: typePage)
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
