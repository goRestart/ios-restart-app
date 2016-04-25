//
//  ProductDetailFactory.swift
//  LetGo
//
//  Created by Eli Kohen on 18/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

class ProductDetailFactory {
    static func productDetailFromProduct(product: Product, thumbnailImage: UIImage? = nil, originFrame: CGRect? = nil)
        -> UIViewController? {
            if FeatureFlags.snapchatPrductDetail {
                // TODO: Use Related product requester
                let requester = FilteredProductListRequester()
                let listViewModel = ProductListViewModel(requester: requester)
                let vm = ProductCarouselViewModel(productListVM: listViewModel, index: 0, thumbnailImage: thumbnailImage)
                var animator: ProductCarouselPushAnimator? = nil
                if let frame = originFrame {
                    animator = ProductCarouselPushAnimator(originFrame: frame, originThumbnail: thumbnailImage)
                }
                return ProductCarouselViewController(viewModel: vm, pushAnimator: animator)
            } else {
                let viewModel = ProductViewModel(product: product, thumbnailImage: thumbnailImage)
                return ProductViewController(viewModel: viewModel)
            }
    }
    
    static func productDetailFromProductList(productListVM: ProductListViewModel, index: Int, thumbnailImage: UIImage?,
                                             originFrame: CGRect? = nil) -> UIViewController? {
        if FeatureFlags.snapchatPrductDetail {
            let newListVM = ProductListViewModel(listViewModel: productListVM)
            let vm = ProductCarouselViewModel(productListVM: newListVM, index: index,
                                              thumbnailImage: thumbnailImage)
            var animator: ProductCarouselPushAnimator? = nil
            if let frame = originFrame {
                animator = ProductCarouselPushAnimator(originFrame: frame, originThumbnail: thumbnailImage)
            }
            return ProductCarouselViewController(viewModel: vm, pushAnimator: animator)
        } else {
            guard let product = productListVM.productAtIndex(index) else { return nil }
            let viewModel = ProductViewModel(product: product, thumbnailImage: thumbnailImage)
            return ProductViewController(viewModel: viewModel)
        }
    }
}
