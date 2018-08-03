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
    func openVerifyAccounts(_ types: [VerificationType], source: VerifyAccountsSource, completionBlock: (() -> Void)?)
    func openSurveyIfNeeded()
    func openAppInvite(myUserId: String?, myUserName: String?)
    func canOpenAppInvite() -> Bool
    func openDeepLink(deepLink: DeepLink)
    func openAppStore()
    func openPromoteBumpForListingId(listingId: String,
                                     bumpUpProductData: BumpUpProductData,
                                     typePage: EventParameterTypePage?)
    func openConfirmUsername(token: String)
    func canOpenOffensiveReportAlert() -> Bool
    func openOffensiveReportAlert()
    func showBottomBubbleNotification(data: BubbleNotificationData,
                                      duration: TimeInterval,
                                      alignment: BubbleNotificationView.Alignment,
                                      style: BubbleNotificationView.Style)
    func openCommunityTab()
}
