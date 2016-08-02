//
//  MainTabCoordinator.swift
//  LetGo
//
//  Created by Albert Hernández López on 01/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

final class MainTabCoordinator: TabCoordinator {

    convenience init() {
        let productRepository = Core.productRepository
        let userRepository = Core.userRepository
        let chatRepository = Core.chatRepository
        let oldChatRepository = Core.oldChatRepository
        let keyValueStorage = KeyValueStorage.sharedInstance
        let tracker = TrackerProxy.sharedInstance
        let viewModel = MainProductsViewModel()
        let rootViewController = MainProductsViewController(viewModel: viewModel)
        self.init(productRepository: productRepository, userRepository: userRepository,
                  chatRepository: chatRepository, oldChatRepository: oldChatRepository,
                  keyValueStorage: keyValueStorage, tracker: tracker, rootViewController: rootViewController)

        viewModel.navigator = self
    }

    func openSearch(query: String, categoriesString: String?) {
        var filters = ProductFilters()
        if let categoriesString = categoriesString {
            filters.selectedCategories = ProductCategory.categoriesFromString(categoriesString)
        }
        let viewModel = MainProductsViewModel(searchString: query, filters: filters)
        viewModel.navigator = self
        let vc = MainProductsViewController(viewModel: viewModel)

        navigationController.pushViewController(vc, animated: true)
    }
}

extension MainTabCoordinator: MainTabNavigator {
    
}


// MARK: - MainProductsNavigator

extension MainTabCoordinator: MainProductsNavigator {
    func openProduct(product: Product, productListVM: ProductListViewModel, index: Int,
                     thumbnailImage: UIImage?, originFrame: CGRect?) {
        let vc: UIViewController?
        if FeatureFlags.showRelatedProducts {
            vc = ProductDetailFactory.productDetailFromProduct(product, thumbnailImage: thumbnailImage,
                                                               originFrame: originFrame)
        } else {
            vc = ProductDetailFactory.productDetailFromProductList(productListVM, index: index,
                                                                   thumbnailImage: thumbnailImage,
                                                                   originFrame: originFrame)
        }
        if let vc = vc {
            navigationController.pushViewController(vc, animated: true)
        }
    }
}
