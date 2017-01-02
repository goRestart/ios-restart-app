//
//  CategoriesTabCoordinator.swift
//  LetGo
//
//  Created by Albert Hernández López on 01/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

final class CategoriesTabCoordinator: MainTabCoordinator {

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
        let viewModel = CategoriesViewModel()
        let rootViewController = CategoriesViewController(viewModel: viewModel)
        self.init(productRepository: productRepository, userRepository: userRepository,
                  chatRepository: chatRepository, oldChatRepository: oldChatRepository,
                  myUserRepository: myUserRepository,
                  bubbleNotificationManager: bubbleNotificationManager,
                  keyValueStorage: keyValueStorage, tracker: tracker, rootViewController: rootViewController,
                  featureFlags:featureFlags)
        
        viewModel.navigator = self
    }

    // Note: override in subclasses
    override func shouldHideSellButtonAtViewController(viewController: UIViewController) -> Bool {
        return super.shouldHideSellButtonAtViewController(viewController) && !(viewController is MainProductsViewController)
    }
}

extension CategoriesTabCoordinator: CategoriesTabNavigator {
    func openMainProducts(with filters: ProductFilters) {
        let vm = MainProductsViewModel(filters: filters)
        vm.navigator = self
        let vc = MainProductsViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }
}
 
