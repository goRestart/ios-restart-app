//
//  TabNavigator.swift
//  LetGo
//
//  Created by Albert Hernández López on 01/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

enum UserDetailData {
    case id(userId: String, source: UserSource)
    case userAPI(user: User, source: UserSource)
    case userChat(user: ChatInterlocutor)
}

enum ProductDetailData {
    case id(productId: String)
    case productAPI(product: Product, thumbnailImage: UIImage?, originFrame: CGRect?)
    case productList(product: Product, cellModels: [ProductCellModel], requester: ProductListRequester,
                     thumbnailImage: UIImage?, originFrame: CGRect?, showRelated: Bool, index: Int)
    case productChat(chatConversation: ChatConversation)
}

enum ChatDetailData {
    case dataIds(data: ConversationData)
    case chatAPI(chat: Chat)
    case conversation(conversation: ChatConversation)
    case productAPI(product: Product)
}

enum BackAction {
    case expressChat(products: [Product])
}

protocol TabNavigator: BaseNavigator {
    func openSell(_ source: PostingSource)
    func openUser(_ data: UserDetailData)
    func openProduct(_ data: ProductDetailData, source: EventParameterProductVisitSource,
                     showKeyboardOnFirstAppearIfNeeded: Bool)
    func openChat(_ data: ChatDetailData, source: EventParameterTypePage)
    func openVerifyAccounts(_ types: [VerificationType], source: VerifyAccountsSource, completionBlock: (() -> Void)?)
    func openAppInvite()
    func canOpenAppInvite() -> Bool
    func openRatingList(_ userId: String)
}

protocol ProductDetailNavigator: TabNavigator {
    func closeProductDetail()
    func editProduct(_ product: Product)
    func openProductChat(_ product: Product)
    func closeAfterDelete()
    func openFreeBumpUpForProduct(product: Product, socialMessage: SocialMessage, withPaymentItemId: String)
    func openPayBumpUpForProduct(product: Product, purchaseableProduct: PurchaseableProduct)
}

protocol SimpleProductsNavigator: class {
    func closeSimpleProducts()
    func openProduct(_ data: ProductDetailData, source: EventParameterProductVisitSource,
                     showKeyboardOnFirstAppearIfNeeded: Bool)
}

protocol ChatDetailNavigator: TabNavigator {
    func closeChatDetail()
    func openExpressChat(_ products: [Product], sourceProductId: String, manualOpen: Bool)
}
