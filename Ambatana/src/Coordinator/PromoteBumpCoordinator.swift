//
//  PromoteBumpCoordinator.swift
//  LetGo
//
//  Created by Dídac on 16/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

protocol PromoteBumpCoordinatorDelegate: class {
    func openSellFaster(listingId: String,
                        bumpUpProductData: BumpUpProductData,
                        typePage: EventParameterTypePage?)
}

final class PromoteBumpCoordinator: Coordinator {
    var child: Coordinator?
    weak var coordinatorDelegate: CoordinatorDelegate?
    var viewController: UIViewController
    weak var presentedAlertController: UIAlertController?
    let bubbleNotificationManager: BubbleNotificationManager
    let sessionManager: SessionManager

    weak var delegate: PromoteBumpCoordinatorDelegate?


    convenience init(listingId: String,
                     bumpUpProductData: BumpUpProductData,
                     typePage: EventParameterTypePage?) {
        self.init(listingId: listingId,
                  bumpUpProductData: bumpUpProductData,
                  typePage: typePage,
                  bubbleNotificationManager: LGBubbleNotificationManager.sharedInstance,
                  sessionManager: Core.sessionManager)
    }

    init(listingId: String,
         bumpUpProductData: BumpUpProductData,
         typePage: EventParameterTypePage?,
         bubbleNotificationManager: BubbleNotificationManager,
         sessionManager: SessionManager) {

        let promoteBumpVM = PromoteBumpViewModel(listingId: listingId,
                                                 bumpUpProductData: bumpUpProductData,
                                                 typePage: typePage)
        let promoteBumpVC = PromoteBumpViewController(viewModel: promoteBumpVM)
        self.viewController = promoteBumpVC
        self.bubbleNotificationManager = bubbleNotificationManager
        self.sessionManager = sessionManager
        promoteBumpVM.navigator = self
    }

    func presentViewController(parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard viewController.parent == nil else { return }
        parent.present(viewController, animated: animated, completion: completion)
    }

    func dismissViewController(animated: Bool, completion: (() -> Void)?) {
        viewController.dismissWithPresented(animated: animated, completion: completion)
    }
}

extension PromoteBumpCoordinator : PromoteBumpNavigator {
    func promoteBumpDidCancel() {
        closeCoordinator(animated: true, completion: nil)
    }

    func openSellFaster(listingId: String,
                        bumpUpProductData: BumpUpProductData,
                        typePage: EventParameterTypePage?) {
        closeCoordinator(animated: true) { [weak self] in
            self?.delegate?.openSellFaster(listingId: listingId,
                                           bumpUpProductData: bumpUpProductData,
                                           typePage: typePage)
        }
    }
}
