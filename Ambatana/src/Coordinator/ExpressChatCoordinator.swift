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
    func expressChatCoordinatorDidSentMessages(coordinator: ExpressChatCoordinator, count: Int)
}

class ExpressChatCoordinator: Coordinator {
    
    var child: Coordinator?

    var viewController: UIViewController
    var presentedAlertController: UIAlertController?
    weak var delegate: ExpressChatCoordinatorDelegate?

    var keyValueStorage: KeyValueStorage

    // MARK: - Lifecycle

    convenience init?(products: [Product], sourceProductId: String) {
        self.init(products: products, sourceProductId: sourceProductId, keyValueStorage: KeyValueStorage.sharedInstance)
    }

    init?(products: [Product], sourceProductId: String, keyValueStorage: KeyValueStorage) {
        let vm = ExpressChatViewModel(productList: products, sourceProductId: sourceProductId)
        let vc = ExpressChatViewController(viewModel: vm)
        self.viewController = vc
        self.keyValueStorage = keyValueStorage

        vm.navigator = self
        
        guard keyValueStorage.userShouldShowExpressChat else { return nil }
        guard !expressChatAlreadyShownForProduct(sourceProductId) else { return nil }
    }

    func open(parent parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard viewController.parentViewController == nil else { return }
        parent.presentViewController(viewController, animated: animated, completion: completion)
    }

    func close(animated animated: Bool, completion: (() -> Void)?) {
        close(0, animated: animated, completion: completion)
    }

    func close(countMessagesSent: Int, animated: Bool, completion: (() -> Void)?) {
        viewController.dismissViewControllerAnimated(animated, completion: completion)
        delegate?.coordinatorDidClose(self)
        if countMessagesSent > 0 { delegate?.expressChatCoordinatorDidSentMessages(self, count: countMessagesSent) }
    }
}

extension ExpressChatCoordinator: ExpressChatNavigator {
    func closeExpressChat(showAgain: Bool, forProduct: String) {
        keyValueStorage.userShouldShowExpressChat = showAgain
        saveProductAsExpressChatShown(forProduct)
        close(0, animated: true, completion: nil)
    }

    func sentMessage(forProduct: String, count: Int) {
        saveProductAsExpressChatShown(forProduct)
        close(count, animated: true, completion: nil)
    }

    private func saveProductAsExpressChatShown(productId: String) {
        var productsExpressShown = keyValueStorage.userProductsWithExpressChatAlreadyShown

        for productShownId in productsExpressShown {
            if productShownId == productId { return }
        }
        productsExpressShown.append(productId)
        keyValueStorage.userProductsWithExpressChatAlreadyShown = productsExpressShown
    }

    private func expressChatAlreadyShownForProduct(productId: String) -> Bool {
        for productShownId in keyValueStorage.userProductsWithExpressChatAlreadyShown {
            if productShownId == productId { return true }
        }
        return false
    }
}
