//
//  TabNavigator.swift
//  LetGo
//
//  Created by Albert Hernández López on 01/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

enum UserDetailData {
    case Id(userId: String, source: UserSource)
    case UserAPI(user: User, source: UserSource)
    case UserChat(user: ChatInterlocutor)
}

enum ProductDetailData {
    case Id(productId: String)
    case ProductAPI(product: Product, thumbnailImage: UIImage?, originFrame: CGRect?)
    case ProductList(product: Product, cellModels: [ProductCellModel], requester: ProductListRequester,
                     thumbnailImage: UIImage?, originFrame: CGRect?, showRelated: Bool)
    case ProductChat(chatProduct: ChatProduct, user: ChatInterlocutor,
                     thumbnailImage: UIImage?, originFrame: CGRect?)
}

enum BackAction {
    case ExpressChat(products: [Product])
}

protocol TabNavigator: class {
    func openUser(data: UserDetailData)
    func openProduct(data: ProductDetailData, source: EventParameterProductVisitSource, index: Int)
    func openExpressChat(products: [Product], sourceProductId: String)
    func openVerifyAccounts(types: [VerificationType], source: VerifyAccountsSource)
    func openAppInvite()
}

protocol ProductDetailNavigator: TabNavigator {
    func closeProductDetail()
    func editProduct(product: Product, closeCompletion: ((Product) -> Void)?)
    func openProductChat(product: Product)
}
