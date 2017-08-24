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
    case listingList(listing: Listing, cellModels: [ListingCellModel], requester: ListingListRequester,
                     thumbnailImage: UIImage?, originFrame: CGRect?, showRelated: Bool, index: Int)
    case listingChat(chatConversation: ChatConversation)
}

enum ChatDetailData {
    case dataIds(data: ConversationData)
    case chatAPI(chat: Chat)
    case conversation(conversation: ChatConversation)
    case listingAPI(listing: Listing)
}

enum ProductCarouselActionOnFirstAppear {
    case nonexistent
    case showKeyboard
    case showShareSheet
    case triggerBumpUp
    case triggerMarkAsSold
}

protocol TabNavigator: class {
    func openHome()
    func openSell(source: PostingSource)
    func openAppRating(_ source: EventParameterRatingSource)
    func openUserRating(_ source: RateUserSource, data: RateUserData)
    func openUser(_ data: UserDetailData)
    func openListing(_ data: ListingDetailData, source: EventParameterListingVisitSource, actionOnFirstAppear: ProductCarouselActionOnFirstAppear)
    func openChat(_ data: ChatDetailData, source: EventParameterTypePage, predefinedMessage: String?)
    func openVerifyAccounts(_ types: [VerificationType], source: VerifyAccountsSource, completionBlock: (() -> Void)?)
    func openAppInvite()
    func canOpenAppInvite() -> Bool
    func openRatingList(_ userId: String)
}

protocol ProductDetailNavigator: TabNavigator {
    func closeProductDetail()
    func editListing(_ listing: Listing)
    func openListingChat(_ listing: Listing)
    func closeAfterDelete()
    func openFreeBumpUp(forListing listing: Listing, socialMessage: SocialMessage, paymentItemId: String)
    func openPayBumpUp(forListing listing: Listing,
                       purchaseableProduct: PurchaseableProduct,
                       paymentItemId: String)
    func selectBuyerToRate(source: RateUserSource,
                           buyers: [UserListing],
                           listingId: String,
                           sourceRateBuyers: SourceRateBuyers?,
                           trackingInfo: MarkAsSoldTrackingInfo)
    func showProductFavoriteBubble(with data: BubbleNotificationData)
    func openLoginIfNeededFromProductDetail(from: EventParameterLoginSourceValue, infoMessage: String,
                                            loggedInAction: @escaping (() -> Void))
    func showBumpUpNotAvailableAlertWithTitle(title: String,
                                              text: String,
                                              alertType: AlertType,
                                              buttonsLayout: AlertButtonsLayout,
                                              actions: [UIAction])
    func openContactUs(forListing listing: Listing, contactUstype: ContactUsType)
}

protocol SimpleProductsNavigator: class {
    func closeSimpleProducts()
    func openListing(_ data: ListingDetailData, source: EventParameterListingVisitSource, actionOnFirstAppear: ProductCarouselActionOnFirstAppear)
}

protocol ChatDetailNavigator: TabNavigator {
    func closeChatDetail()
    func openExpressChat(_ listings: [Listing], sourceListingId: String, manualOpen: Bool)
    func selectBuyerToRate(source: RateUserSource,
                           buyers: [UserListing],
                           listingId: String,
                           sourceRateBuyers: SourceRateBuyers?,
                           trackingInfo: MarkAsSoldTrackingInfo)
    func openLoginIfNeededFromChatDetail(from: EventParameterLoginSourceValue, loggedInAction: @escaping (() -> Void))
}
