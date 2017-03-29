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

enum ListingDetailData {
    case id(listingId: String)
    case listingAPI(listing: Listing, thumbnailImage: UIImage?, originFrame: CGRect?)
    case listingList(listing: Listing, cellModels: [ListingCellModel], requester: ProductListRequester,
                     thumbnailImage: UIImage?, originFrame: CGRect?, showRelated: Bool, index: Int)
    case listingChat(chatConversation: ChatConversation)
}

enum ChatDetailData {
    case dataIds(data: ConversationData)
    case chatAPI(chat: Chat)
    case conversation(conversation: ChatConversation)
    case listingAPI(listing: Listing)
}

enum BackAction {
    case expressChat(products: [Product])
}

protocol TabNavigator: class {
    func openSell(_ source: PostingSource)
    func openUser(_ data: UserDetailData)
    func openListing(_ data: ListingDetailData, source: EventParameterProductVisitSource,
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
    func openListingChat(_ listing: Listing)
    func closeAfterDelete()
    func openFreeBumpUpForProduct(product: Product, socialMessage: SocialMessage, withPaymentItemId: String)
    func openPayBumpUpForProduct(product: Product, purchaseableProduct: PurchaseableProduct, withPaymentItemId: String)
    func selectBuyerToRate(source: RateUserSource, buyers: [UserListing], completion: @escaping (String?) -> Void)
    func showProductFavoriteBubble(with data: BubbleNotificationData)
    func openLoginIfNeededFromProductDetail(from: EventParameterLoginSourceValue, infoMessage: String,
                                            loggedInAction: @escaping (() -> Void))
}

protocol SimpleProductsNavigator: class {
    func closeSimpleProducts()
    func openListing(_ data: ListingDetailData, source: EventParameterProductVisitSource,
                     showKeyboardOnFirstAppearIfNeeded: Bool)
}

protocol ChatDetailNavigator: TabNavigator {
    func closeChatDetail()
    func openExpressChat(_ products: [Product], sourceProductId: String, manualOpen: Bool)
    func selectBuyerToRate(source: RateUserSource, buyers: [UserListing], completion: @escaping (String?) -> Void)
    func openLoginIfNeededFromChatDetail(from: EventParameterLoginSourceValue, loggedInAction: @escaping (() -> Void))
}
