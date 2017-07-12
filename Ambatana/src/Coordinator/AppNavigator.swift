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
    func openSell(_ source: PostingSource)
    func openAppRating(_ source: EventParameterRatingSource)
    func openUserRating(_ source: RateUserSource, data: RateUserData)
    func openVerifyAccounts(_ types: [VerificationType], source: VerifyAccountsSource, completionBlock: (() -> Void)?)
    func openSurveyIfNeeded()
    func openAppInvite()
    func canOpenAppInvite() -> Bool
    func openDeepLink(deepLink: DeepLink)
    func openAppStore()
}
