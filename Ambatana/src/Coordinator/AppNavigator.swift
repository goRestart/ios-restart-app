import LGComponents

protocol AppNavigatorDelegate: class {
    func appNavigatorDidOpenApp()
}

protocol AppNavigator: class {
    var delegate: AppNavigatorDelegate? { get }
    
    func open()
    func openForceUpdateAlertIfNeeded()
    func openHome()
    func openSell(source: PostingSource, postCategory: PostCategory?, listingTitle: String?)
    func openAppRating(_ source: EventParameterRatingSource)
    func openUserRating(_ source: RateUserSource, data: RateUserData)
    func openAppInvite(myUserId: String?, myUserName: String?)
    func canOpenAppInvite() -> Bool
    func openDeepLink(deepLink: DeepLink)
    func openAppStore()
    func openPromoteBumpForListingId(listingId: String,
                                     purchases: [BumpUpProductData],
                                     maxCountdown: TimeInterval,
                                     typePage: EventParameterTypePage?)
    func openConfirmUsername(token: String)
    func canOpenModalView() -> Bool
    func openOffensiveReportAlert()
    func showBottomBubbleNotification(data: BubbleNotificationData,
                                      duration: TimeInterval,
                                      alignment: BubbleNotificationView.Alignment,
                                      style: BubbleNotificationView.Style)
    func openCommunityTab()
    func shouldShowVerificationAwareness() -> Bool
    func openVerificationAwarenessView()
    func openP2PPaymentOfferStatus(offerId: String)
}
