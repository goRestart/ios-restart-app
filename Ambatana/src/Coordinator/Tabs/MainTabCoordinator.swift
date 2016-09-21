//
//  MainTabCoordinator.swift
//  LetGo
//
//  Created by Albert Hernández López on 01/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

final class MainTabCoordinator: TabCoordinator {

    convenience init(canInvite: Bool) {
        let productRepository = Core.productRepository
        let userRepository = Core.userRepository
        let chatRepository = Core.chatRepository
        let oldChatRepository = Core.oldChatRepository
        let myUserRepository = Core.myUserRepository
        let keyValueStorage = KeyValueStorage.sharedInstance
        let tracker = TrackerProxy.sharedInstance
        let viewModel = MainProductsViewModel(searchType: nil, tabNavigator: nil, canInvite: canInvite)
        let rootViewController = MainProductsViewController(viewModel: viewModel)
        self.init(productRepository: productRepository, userRepository: userRepository,
                  chatRepository: chatRepository, oldChatRepository: oldChatRepository,
                  myUserRepository: myUserRepository, keyValueStorage: keyValueStorage,
                  tracker: tracker, rootViewController: rootViewController)

        viewModel.tabNavigator = self
    }

    func openSearch(query: String, categoriesString: String?, canInvite: Bool) {
        var filters = ProductFilters()
        if let categoriesString = categoriesString {
            filters.selectedCategories = ProductCategory.categoriesFromString(categoriesString)
        }
        let viewModel = MainProductsViewModel(searchType: .User(query: query), filters: filters, tabNavigator: self,
                                              canInvite: canInvite)
        let vc = MainProductsViewController(viewModel: viewModel)

        navigationController.pushViewController(vc, animated: true)
    }

    // Note: override in subclasses
    override func shouldHideSellButtonAtViewController(viewController: UIViewController) -> Bool {
        return super.shouldHideSellButtonAtViewController(viewController) && !(viewController is MainProductsViewController)
    }
}

extension MainTabCoordinator: MainTabNavigator {
    
}
