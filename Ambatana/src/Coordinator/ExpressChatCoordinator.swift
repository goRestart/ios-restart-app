//
//  ExpressChatCoordinator.swift
//  LetGo
//
//  Created by Dídac on 11/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

protocol ExpressChatCoordinatorDelegate: class {
    func expressChatCoordinatorDidSentMessages(_ coordinator: ExpressChatCoordinator, count: Int)
}

final class ExpressChatCoordinator: Coordinator {
    var child: Coordinator?
    let viewController: UIViewController
    weak var coordinatorDelegate: CoordinatorDelegate?
    weak var presentedAlertController: UIAlertController?
    let bubbleNotificationManager: BubbleNotificationManager
    let sessionManager: SessionManager

    weak var delegate: ExpressChatCoordinatorDelegate?

    fileprivate let keyValueStorage: KeyValueStorage

    
    // MARK: - Lifecycle

    convenience init?(listings: [Listing], sourceProductId: String, manualOpen: Bool) {
        self.init(listings: listings,
                  sourceProductId: sourceProductId,
                  keyValueStorage: KeyValueStorage.sharedInstance,
                  bubbleNotificationManager: LGBubbleNotificationManager.sharedInstance,
                  manualOpen: manualOpen,
                  sessionManager: Core.sessionManager)
    }

    init?(listings: [Listing],
          sourceProductId: String,
          keyValueStorage: KeyValueStorage,
          bubbleNotificationManager: BubbleNotificationManager,
          manualOpen: Bool,
          sessionManager: SessionManager) {
        let vm = ExpressChatViewModel(listings: listings, sourceProductId: sourceProductId, manualOpen: manualOpen)
        let vc = ExpressChatViewController(viewModel: vm)
        self.viewController = vc
        self.bubbleNotificationManager = bubbleNotificationManager
        self.keyValueStorage = keyValueStorage
        self.sessionManager = sessionManager
        vm.navigator = self

        if !manualOpen {
            // user didn't pressed "Don't show again"
            guard keyValueStorage.userShouldShowExpressChat else { return nil }
            // express chat hasn't been shown for this product
            guard !expressChatAlreadyShownForProduct(sourceProductId) else { return nil }
        }
    }

    func presentViewController(parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard viewController.parent == nil else { return }
        parent.present(viewController, animated: animated, completion: completion)
    }

    func dismissViewController(animated: Bool, completion: (() -> Void)?) {
        viewController.dismissWithPresented(animated: animated, completion: completion)
    }

    fileprivate func close(_ countMessagesSent: Int, animated: Bool, completion: (() -> Void)?) {
        closeCoordinator(animated: animated) { [weak self] in
            guard let strongSelf = self else { return }
            if countMessagesSent > 0 {
                strongSelf.delegate?.expressChatCoordinatorDidSentMessages(strongSelf, count: countMessagesSent)
            }
        }
    }
}

extension ExpressChatCoordinator: ExpressChatNavigator {
    func closeExpressChat(_ showAgain: Bool, forProduct: String) {
        keyValueStorage.userShouldShowExpressChat = showAgain
        saveProductAsExpressChatShown(forProduct)
        close(0, animated: true, completion: nil)
    }

    func sentMessage(_ forProduct: String, count: Int) {
        saveProductAsExpressChatMessageSent(forProduct)
        saveProductAsExpressChatShown(forProduct)
        close(count, animated: true, completion: nil)
    }

    // save products which already have shown the express chat
    fileprivate func saveProductAsExpressChatShown(_ productId: String) {
        var productsExpressShown = keyValueStorage.userProductsWithExpressChatAlreadyShown

        for productShownId in productsExpressShown {
            if productShownId == productId { return }
        }
        productsExpressShown.append(productId)
        keyValueStorage.userProductsWithExpressChatAlreadyShown = productsExpressShown
    }

    fileprivate func expressChatAlreadyShownForProduct(_ productId: String) -> Bool {
        for productShownId in keyValueStorage.userProductsWithExpressChatAlreadyShown {
            if productShownId == productId { return true }
        }
        return false
    }

    // save products which sent messages
    fileprivate func saveProductAsExpressChatMessageSent(_ productId: String) {
        var productsExpressSent = keyValueStorage.userProductsWithExpressChatMessageSent

        for productSentId in productsExpressSent {
            if productSentId == productId { return }
        }
        productsExpressSent.append(productId)
        keyValueStorage.userProductsWithExpressChatMessageSent = productsExpressSent
    }

    fileprivate func expressChatMessageSentForProduct(_ productId: String) -> Bool {
        for productSentId in keyValueStorage.userProductsWithExpressChatMessageSent {
            if productSentId == productId { return true }
        }
        return false
    }
}
