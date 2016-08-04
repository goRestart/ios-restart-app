//
//  TabNavigator.swift
//  LetGo
//
//  Created by Albert Hernández López on 01/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

protocol TabNavigator: class {
    func openUser(userId userId: String, source: UserSource)
    func openUser(user user: User, source: UserSource)
    func openUser(interlocutor: ChatInterlocutor)

    func openProduct(productId productId: String)
    func openProduct(product product: Product)
    func openProduct(product: Product, productListVM: ProductListViewModel, index: Int,
                     thumbnailImage: UIImage?, originFrame: CGRect?)
    func openProduct(productListVM productListVM: ProductListViewModel, index: Int,
                     thumbnailImage: UIImage?, originFrame: CGRect?)
    func openProduct(chatProduct chatProduct: ChatProduct, user: ChatInterlocutor,
                                 thumbnailImage: UIImage?, originFrame: CGRect?)
}
