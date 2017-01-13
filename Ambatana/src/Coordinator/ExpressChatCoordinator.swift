//
//  ExpressChatCoordinator.swift
//  LetGo
//
//  Created by Dídac on 11/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

protocol ExpressChatCoordinatorDelegate: CoordinatorDelegate {
    func expressChatCoordinatorDidSentMessages(_ coordinator: ExpressChatCoordinator, count: Int)
}

class ExpressChatCoordinator: Coordinator {
    
    var child: Coordinator?

    var viewController: UIViewController
    var presentedAlertController: UIAlertController?
    weak var delegate: ExpressChatCoordinatorDelegate?

    var keyValueStorage: KeyValueStorage

    // MARK: - Lifecycle

    convenience init?(products: [Product], sourceProductId: String, manualOpen: Bool) {
        self.init(products: products, sourceProductId: sourceProductId, keyValueStorage: KeyValueStorage.sharedInstance, manualOpen: manualOpen)
    }

    init?(products: [Product], sourceProductId: String, keyValueStorage: KeyValueStorage, manualOpen: Bool) {
        let vm = ExpressChatViewModel(productList: products, sourceProductId: sourceProductId, manualOpen: manualOpen)
        let vc = ExpressChatViewController(viewModel: vm)
        self.viewController = vc
        self.keyValueStorage = keyValueStorage

        vm.navigator = self

        if !manualOpen {
            // user didn't pressed "Don't show again"
            guard keyValueStorage.userShouldShowExpressChat else { return nil }
            // express chat hasn't been shown for this product
            guard !expressChatAlreadyShownForProduct(sourceProductId) else { return nil }
        }
    }

    func open(parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard viewController.parent == nil else { return }
        parent.present(viewController, animated: animated, completion: completion)
    }

    func close(animated: Bool, completion: (() -> Void)?) {
        close(0, animated: animated, completion: completion)
    }

    func close(_ countMessagesSent: Int, animated: Bool, completion: (() -> Void)?) {
        viewController.dismiss(animated: animated, completion: completion)
        delegate?.coordinatorDidClose(self)
        if countMessagesSent > 0 { delegate?.expressChatCoordinatorDidSentMessages(self, count: countMessagesSent) }
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
