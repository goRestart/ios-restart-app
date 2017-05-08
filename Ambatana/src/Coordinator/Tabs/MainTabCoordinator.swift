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
        let listingRepository = Core.listingRepository
        let userRepository = Core.userRepository
        let chatRepository = Core.chatRepository
        let oldChatRepository = Core.oldChatRepository
        let myUserRepository = Core.myUserRepository
        let bubbleNotificationManager =  LGBubbleNotificationManager.sharedInstance
        let keyValueStorage = KeyValueStorage.sharedInstance
        let tracker = TrackerProxy.sharedInstance
        let featureFlags = FeatureFlags.sharedInstance
        let sessionManager = Core.sessionManager
        let viewModel = MainProductsViewModel(searchType: nil, tabNavigator: nil)
        let rootViewController = MainProductsViewController(viewModel: viewModel)
        self.init(listingRepository: listingRepository, userRepository: userRepository,
                  chatRepository: chatRepository, oldChatRepository: oldChatRepository,
                  myUserRepository: myUserRepository,
                  bubbleNotificationManager: bubbleNotificationManager,
                  keyValueStorage: keyValueStorage, tracker: tracker, rootViewController: rootViewController,
                  featureFlags: featureFlags, sessionManager: sessionManager)

        viewModel.navigator = self
    }

    func openSearch(_ query: String, categoriesString: String?) {
        var filters = ProductFilters()
        if let categoriesString = categoriesString {
            filters.selectedCategories = ListingCategory.categoriesFromString(categoriesString)
        }
        let viewModel = MainProductsViewModel(searchType: .user(query: query), filters: filters)
        viewModel.navigator = self
        let vc = MainProductsViewController(viewModel: viewModel)

        navigationController.pushViewController(vc, animated: true)
    }

    // Note: override in subclasses
    override func shouldHideSellButtonAtViewController(_ viewController: UIViewController) -> Bool {
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
        let vm = FiltersViewModel(currentFilters: productFilters)
        vm.dataDelegate = filtersVMDataDelegate
        let vc = FiltersViewController(viewModel: vm)
        let navVC = UINavigationController(rootViewController: vc)
        navigationController.present(navVC, animated: true, completion: nil)
    }
}
