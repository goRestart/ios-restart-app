//
//  MainTabNavigator.swift
//  LetGo
//
//  Created by Albert Hernández López on 01/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

protocol MainTabNavigator: TabNavigator {

}

protocol MainProductsNavigator: class {
    func openProduct(product: Product, productListVM: ProductListViewModel, index: Int,
                     thumbnailImage: UIImage?, originFrame: CGRect?)
}
