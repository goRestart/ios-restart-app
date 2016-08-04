//
//  ProductDetailFactory.swift
//  LetGo
//
//  Created by Eli Kohen on 18/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

class ProductDetailFactory {
    static func productDetailFromProduct(product: Product, thumbnailImage: UIImage? = nil,
                                         originFrame: CGRect? = nil) -> UIViewController? {
        guard let productId = product.objectId else { return nil }
        let requester = RelatedProductListRequester(productId: productId)
        let vm = ProductCarouselViewModel(product: product, thumbnailImage: thumbnailImage,
                                          productListRequester: requester)
        let color = UIColor.placeholderBackgroundColor(product.objectId)
        let animator = ProductCarouselPushAnimator(originFrame: originFrame, originThumbnail: thumbnailImage,
                                                   backgroundColor: color)
        return ProductCarouselViewController(viewModel: vm, pushAnimator: animator)
    }
    
    static func productDetailFromChatProduct(product: ChatProduct, user: ChatInterlocutor,
                                             thumbnailImage: UIImage? = nil, originFrame: CGRect? = nil) -> UIViewController? {
        
        guard let productId = product.objectId else { return nil }
        let requester = RelatedProductListRequester(productId: productId)
        let vm = ProductCarouselViewModel(chatProduct: product, chatInterlocutor: user, thumbnailImage: thumbnailImage,
                                          productListRequester: requester)
        let animator = ProductCarouselPushAnimator(originFrame: originFrame, originThumbnail: thumbnailImage)
        return ProductCarouselViewController(viewModel: vm, pushAnimator: animator)
    }
    
    static func productDetailFromProductList(productListVM: ProductListViewModel, index: Int,
                                             thumbnailImage: UIImage?, originFrame: CGRect? = nil) -> UIViewController? {
        guard let product = productListVM.productAtIndex(index) else { return nil }
        let vm = ProductCarouselViewModel(productListModels: productListVM.objects, initialProduct: product,
                                          thumbnailImage: thumbnailImage, singleProductList: false,
                                          productListRequester: productListVM.productListRequester?.duplicate())
        let color = UIColor.placeholderBackgroundColor(product.objectId)
        let animator = ProductCarouselPushAnimator(originFrame: originFrame, originThumbnail: thumbnailImage,
                                                   backgroundColor: color)
        return ProductCarouselViewController(viewModel: vm, pushAnimator: animator)
    }

    static func productDetailFromProductListModels(productListModels: [ProductCellModel], requester: ProductListRequester,
                                                   product: Product, thumbnailImage: UIImage?, originFrame: CGRect? = nil)
        -> UIViewController? {
            let vm = ProductCarouselViewModel(productListModels: productListModels, initialProduct: product,
                                              thumbnailImage: thumbnailImage, singleProductList: false,
                                              productListRequester: requester.duplicate())
            let color = UIColor.placeholderBackgroundColor(product.objectId)
            let animator = ProductCarouselPushAnimator(originFrame: originFrame, originThumbnail: thumbnailImage,
                                                       backgroundColor: color)
            return ProductCarouselViewController(viewModel: vm, pushAnimator: animator)
    }
}
