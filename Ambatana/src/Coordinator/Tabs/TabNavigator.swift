import LGCoreKit
import LGComponents

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
    case sectionedRelatedListing(listing: Listing, thumbnailImage: UIImage?, originFrame: CGRect?, index: Int, sectionIdentifier: String?, sectionIndex: UInt?)
    case sectionedNonRelatedListing(listing: Listing, feedListingDatas: [FeedListingData], thumbnailImage: UIImage?, originFrame: CGRect?, index: Int, sectionIdentifier: String, sectionIndex: UInt?)
}

enum ChatDetailData {
    case dataIds(conversationId: String)
    case conversation(conversation: ChatConversation)
    case inactiveConversations
    case inactiveConversation(coversation: ChatInactiveConversation)
    case listingAPI(listing: Listing)
}

enum ProductCarouselActionOnFirstAppear {
    case nonexistent
    case showKeyboard
    case showShareSheet
    case triggerBumpUp(bumpUpProductData: BumpUpProductData?,
        maxCountdown: TimeInterval,
        bumpUpType: BumpUpType?,
        triggerBumpUpSource: BumpUpSource,
        typePage: EventParameterTypePage?)
    case triggerMarkAsSold
    case edit

    var actionIsTriggerBumpUp: Bool {
        if case .triggerBumpUp = self {
            return true
        }
        return false
    }
}

protocol TabNavigator: class {
    func openHome()
    func openSell(source: PostingSource, postCategory: PostCategory?)
    func openUserRating(_ source: RateUserSource, data: RateUserData)
    func openUser(_ data: UserDetailData)
    func openUser(user: User, source: UserSource)
    func openListing(_ data: ListingDetailData, source: EventParameterListingVisitSource, actionOnFirstAppear: ProductCarouselActionOnFirstAppear)
    func openChat(_ data: ChatDetailData, source: EventParameterTypePage, predefinedMessage: String?)
    func openAppInvite(myUserId: String?, myUserName: String?)
    func canOpenAppInvite() -> Bool
    func openRatingList(_ userId: String)
    func openUserReport(source: EventParameterTypePage, userReportedId: String)
    func showUndoBubble(withMessage message: String,
                        duration: TimeInterval,
                        withAction action: @escaping () -> ())
    func showFailBubble(withMessage message: String, duration: TimeInterval)
    func openUserVerificationView()
    func openCommunityTab()
    func openUserVerificationAwarenessView()
}

protocol ListingDetailNavigator: class {
    func openAppRating(_ source: EventParameterRatingSource)
    func openUser(_ data: UserDetailData)
    func openUserVerificationView()
    func closeProductDetail()
    func editListing(_ listing: Listing,
                     bumpUpProductData: BumpUpProductData?,
                     listingCanBeBoosted: Bool,
                     timeSinceLastBump: TimeInterval?,
                     maxCountdown: TimeInterval)
    func openListingChat(_ listing: Listing, source: EventParameterTypePage, interlocutor: User?)
    func closeListingAfterDelete(_ listing: Listing)
    func openFreeBumpUp(forListing listing: Listing,
                        bumpUpProductData: BumpUpProductData,
                        typePage: EventParameterTypePage?,
                        maxCountdown: TimeInterval)
    func openPayBumpUp(forListing listing: Listing,
                       bumpUpProductData: BumpUpProductData,
                       typePage: EventParameterTypePage?,
                       maxCountdown: TimeInterval)
    func openBumpUpBoost(forListing listing: Listing,
                         bumpUpProductData: BumpUpProductData,
                         typePage: EventParameterTypePage?,
                         timeSinceLastBump: TimeInterval,
                         maxCountdown: TimeInterval)
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
    func showBumpUpBoostSucceededAlert()
    func openContactUs(forListing listing: Listing, contactUstype: ContactUsType)
    func openFeaturedInfo()

    func openAskPhoneFor(listing: Listing, interlocutor: User?)
    
    func openListingAttributeTable(withViewModel viewModel: ListingAttributeTableViewModel)
    func closeListingAttributeTable()
}

protocol SimpleProductsNavigator: class {
    func closeSimpleProducts()
    func openListing(_ data: ListingDetailData, source: EventParameterListingVisitSource, actionOnFirstAppear: ProductCarouselActionOnFirstAppear)
}
