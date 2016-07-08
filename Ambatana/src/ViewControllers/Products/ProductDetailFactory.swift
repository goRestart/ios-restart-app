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
            
            switch FeatureFlags.productDetailVersion {
            case .Snapchat:
                guard let productId = product.objectId else { return nil }
                let requester = RelatedProductListRequester(productId: productId)
                let listViewModel = ProductListViewModel(requester: requester, products: [product])
                let product = listViewModel.productAtIndex(0)
                let vm = ProductCarouselViewModel(productListVM: listViewModel, initialProduct: product,
                                                  thumbnailImage: thumbnailImage, singleProductList: true,
                                                  productListRequester: requester)
                let animator = ProductCarouselPushAnimator(originFrame: originFrame, originThumbnail: thumbnailImage)
                return ProductCarouselViewController(viewModel: vm, pushAnimator: animator)
                
            case .Original, .OriginalWithoutOffer:
                let viewModel = ProductViewModel(product: product, thumbnailImage: thumbnailImage)
                return ProductViewController(viewModel: viewModel)
            }
    }
    
    static func productDetailFromProductList(productListVM: ProductListViewModel, index: Int,
                                             thumbnailImage: UIImage?, originFrame: CGRect? = nil) -> UIViewController? {
        
        switch FeatureFlags.productDetailVersion {
        case .Snapchat:
            let newListVM = ProductListViewModel(listViewModel: productListVM)
            guard let product = productListVM.productAtIndex(index) else { return nil }
            let vm = ProductCarouselViewModel(productListVM: newListVM, initialProduct: product,
                                              thumbnailImage: thumbnailImage, singleProductList: false,
                                              productListRequester: newListVM.productListRequester?.duplicate())
            let animator = ProductCarouselPushAnimator(originFrame: originFrame, originThumbnail: thumbnailImage)
            return ProductCarouselViewController(viewModel: vm, pushAnimator: animator)
        case .Original, .OriginalWithoutOffer:
            guard let product = productListVM.productAtIndex(index) else { return nil }
            let viewModel = ProductViewModel(product: product, thumbnailImage: thumbnailImage)
            return ProductViewController(viewModel: viewModel)
        }
    }
    
    static func productDetailFromChatProduct(product: ChatProduct, thumbnailImage: UIImage? = nil)
        -> UIViewController? {
            // TODO: 🎪 Create a Product View Controller from a ChatProduct
            return nil
    }
}
