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
                                         originFrame: CGRect? = nil, tabNavigator: TabNavigator?) -> UIViewController? {
        guard let productId = product.objectId else { return nil }
        let requester = RelatedProductListRequester(productId: productId)
        let listViewModel = ProductListViewModel(requester: requester, products: [product])
        let product = listViewModel.productAtIndex(0)
        let vm = ProductCarouselViewModel(productListVM: listViewModel, initialProduct: product,
                                          thumbnailImage: thumbnailImage, singleProductList: true,
                                          productListRequester: requester, tabNavigator: tabNavigator)
        let color = UIColor.placeholderBackgroundColor(product?.objectId)
        let animator = ProductCarouselPushAnimator(originFrame: originFrame, originThumbnail: thumbnailImage,
                                                   backgroundColor: color)
        return ProductCarouselViewController(viewModel: vm, pushAnimator: animator)
    }
    
    static func productDetailFromChatProduct(product: ChatProduct, user: ChatInterlocutor,
                                             thumbnailImage: UIImage? = nil, originFrame: CGRect? = nil,
                                             tabNavigator: TabNavigator?) -> UIViewController? {
        
        guard let productId = product.objectId else { return nil }
        let requester = RelatedProductListRequester(productId: productId)
        let vm = ProductCarouselViewModel(chatProduct: product, chatInterlocutor: user,
                                          thumbnailImage: thumbnailImage, singleProductList: true,
                                          productListRequester: requester, tabNavigator: tabNavigator)
        let animator = ProductCarouselPushAnimator(originFrame: originFrame, originThumbnail: thumbnailImage)
        return ProductCarouselViewController(viewModel: vm, pushAnimator: animator)
    }
    
    static func productDetailFromProductList(productListVM: ProductListViewModel, index: Int,
                                             thumbnailImage: UIImage?, originFrame: CGRect? = nil,
                                             tabNavigator: TabNavigator?) -> UIViewController? {
        let newListVM = ProductListViewModel(listViewModel: productListVM)
        guard let product = productListVM.productAtIndex(index) else { return nil }
        let vm = ProductCarouselViewModel(productListVM: newListVM, initialProduct: product,
                                          thumbnailImage: thumbnailImage, singleProductList: false,
                                          productListRequester: newListVM.productListRequester?.duplicate(),
                                          tabNavigator: tabNavigator)
        let color = UIColor.placeholderBackgroundColor(product.objectId)
        let animator = ProductCarouselPushAnimator(originFrame: originFrame, originThumbnail: thumbnailImage,
                                                   backgroundColor: color)
        return ProductCarouselViewController(viewModel: vm, pushAnimator: animator)
    }
}
