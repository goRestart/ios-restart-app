//
//  MainTabCoordinator.swift
//  LetGo
//
//  Created by Albert Hernández López on 01/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

class MainTabCoordinator: TabCoordinator {

    convenience init() {
        let productRepository = Core.productRepository
        let userRepository = Core.userRepository
        let chatRepository = Core.chatRepository
        let oldChatRepository = Core.oldChatRepository
        let myUserRepository = Core.myUserRepository
        let bubbleNotificationManager =  BubbleNotificationManager.sharedInstance
        let keyValueStorage = KeyValueStorage.sharedInstance
        let tracker = TrackerProxy.sharedInstance
        let featureFlags = FeatureFlags.sharedInstance
        let viewModel = MainProductsViewModel(searchType: nil, tabNavigator: nil)
        let rootViewController = MainProductsViewController(viewModel: viewModel)
        self.init(productRepository: productRepository, userRepository: userRepository,
                  chatRepository: chatRepository, oldChatRepository: oldChatRepository,
                  myUserRepository: myUserRepository, bubbleNotificationManager: bubbleNotificationManager,
                  keyValueStorage: keyValueStorage, tracker: tracker, rootViewController: rootViewController,
                  featureFlags: featureFlags)

        viewModel.navigator = self
    }

    func openSearch(query: String, categoriesString: String?) {
        var filters = ProductFilters()
        if let categoriesString = categoriesString {
            filters.selectedCategories = ProductCategory.categoriesFromString(categoriesString)
        }
        let viewModel = MainProductsViewModel(searchType: .User(query: query), filters: filters)
        viewModel.navigator = self
        let vc = MainProductsViewController(viewModel: viewModel)

        navigationController.pushViewController(vc, animated: true)
    }

    // Note: override in subclasses
    override func shouldHideSellButtonAtViewController(viewController: UIViewController) -> Bool {
        return super.shouldHideSellButtonAtViewController(viewController) && !(viewController is MainProductsViewController)
    }
}

extension MainTabCoordinator: MainTabNavigator {
    func openMainProduct(withSearchType searchType: SearchType, productFilters: ProductFilters) {
        let vm = MainProductsViewModel(searchType: searchType, filters: productFilters)
        vm.navigator = self
        let vc = MainProductsViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showFilters(with productFilters: ProductFilters, filtersVMDataDelegate: FiltersViewModelDataDelegate?) {
        let vm = FiltersViewModel(currentFilters: productFilters ?? ProductFilters())
        vm.dataDelegate = filtersVMDataDelegate
        let vc = FiltersViewController(viewModel: vm)
        let navVC = UINavigationController(rootViewController: vc)
        navigationController.presentViewController(navVC, animated: true, completion: nil)
    }
}
