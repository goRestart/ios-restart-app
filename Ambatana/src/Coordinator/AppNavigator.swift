//
//  AppNavigator.swift
//  LetGo
//
//  Created by Albert Hernández López on 29/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//


protocol AppNavigatorDelegate: class {
    func appNavigatorDidOpenApp()
}

protocol AppNavigator: class {
    weak var delegate: AppNavigatorDelegate? { get }
    
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
    func openMostSearchedItems(source: PostingSource, enableSearch: Bool)
    func showBottomBubbleNotification(data: BubbleNotificationData,
                                      duration: TimeInterval,
                                      alignment: BubbleNotification.Alignment,
                                      style: BubbleNotification.Style)
}
