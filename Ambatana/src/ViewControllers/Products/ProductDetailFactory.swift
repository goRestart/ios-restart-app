//
//  ProductDetailFactory.swift
//  LetGo
//
//  Created by Eli Kohen on 18/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

class ProductDetailFactory {
    static func productDetailFromProduct(product: Product, thumbnailImage: UIImage? = nil) -> UIViewController? {
        if FeatureFlags.snapchatPrductDetail {
            let vm = ProductCarouselViewModel(product: product, thumbnailImage: thumbnailImage)
            return ProductCarouselViewController(viewModel: vm)
        } else {
            let viewModel = ProductViewModel(product: product, thumbnailImage: thumbnailImage)
            return ProductViewController(viewModel: viewModel)
        }
    }

    static func productDetailFromProductList(productListVM: ProductListViewModel, index: Int, thumbnailImage: UIImage?)
        -> UIViewController? {
            if FeatureFlags.snapchatPrductDetail {
                let vm = ProductCarouselViewModel(productListVM: productListVM, index: index,
                                                  thumbnailImage: thumbnailImage)
                return ProductCarouselViewController(viewModel: vm)
            } else {
                guard let product = productListVM.productAtIndex(index) else { return nil }
                let viewModel = ProductViewModel(product: product, thumbnailImage: thumbnailImage)
                return ProductViewController(viewModel: viewModel)
            }
    }
}
