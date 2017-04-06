//
//  BaseViewModelSpec.swift
//  LetGo
//
//  Created by Eli Kohen on 06/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import Quick
import Nimble

class BaseViewModelSpec: QuickSpec, BaseViewModelDelegate, TabNavigator {
    var delegateReceivedShowAutoFadingMessage = false
    var delegateReceivedShowLoading = false
    var delegateReceivedHideLoading = false
    var delegateReceivedShowAlert = false
    var delegateReceivedShowActionSheet = false
    var lastLoadingMessageShown: String?
    var lastAutofadingMessageShown: String?
    var lastAlertTextShown: String?

    func resetViewModelSpec() {
        delegateReceivedShowAutoFadingMessage = false
        delegateReceivedShowLoading = false
        delegateReceivedHideLoading = false
        delegateReceivedShowAlert = false
        delegateReceivedShowActionSheet = false
        lastLoadingMessageShown = nil
        lastAutofadingMessageShown = nil
        lastAlertTextShown = nil
    }

    func vmShowAutoFadingMessage(_ message: String, completion: (() -> ())?) {
        delegateReceivedShowAutoFadingMessage = true
        lastAutofadingMessageShown = message
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
            completion?()
        }
    }

    func vmShowLoading(_ loadingMessage: String?) {
        delegateReceivedShowLoading = true
        lastLoadingMessageShown = loadingMessage
    }

    func vmHideLoading(_ finishedMessage: String?, afterMessageCompletion: (() -> ())?) {
        delegateReceivedHideLoading = true
        lastLoadingMessageShown = finishedMessage
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
            afterMessageCompletion?()
        }
    }

    func vmShowAlertWithTitle(_ title: String?, text: String, alertType: AlertType, actions: [UIAction]?) {
        delegateReceivedShowAlert = true
        lastAlertTextShown = text
    }

    func vmShowAlertWithTitle(_ title: String?, text: String, alertType: AlertType, buttonsLayout: AlertButtonsLayout, actions: [UIAction]?) {
        delegateReceivedShowAlert = true
        lastAlertTextShown = text
    }

    func vmShowAlert(_ title: String?, message: String?, actions: [UIAction]) {
        delegateReceivedShowAlert = true
        lastAlertTextShown = message
    }

    func vmShowAlert(_ title: String?, message: String?, cancelLabel: String, actions: [UIAction]) {
        delegateReceivedShowAlert = true
        lastAlertTextShown = message
    }
    
    func vmShowAlertWithTitle(_ title: String?, text: String, alertType: AlertType, actions: [UIAction]?, dismissAction: (() -> ())?) {
        delegateReceivedShowAlert = true
    }
    
    func vmShowAlertWithTitle(_ title: String?, text: String, alertType: AlertType, buttonsLayout: AlertButtonsLayout, actions: [UIAction]?, dismissAction: (() -> ())?) {
        delegateReceivedShowAlert = true
    }

    func vmShowActionSheet(_ cancelAction: UIAction, actions: [UIAction]) {
        delegateReceivedShowActionSheet = true
    }

    func vmShowActionSheet(_ cancelLabel: String, actions: [UIAction]) {
        delegateReceivedShowActionSheet = true
    }

    func ifLoggedInThen(_ source: EventParameterLoginSourceValue, loggedInAction: () -> Void,
                        elsePresentSignUpWithSuccessAction afterLogInAction: @escaping () -> Void) {}
    func ifLoggedInThen(_ source: EventParameterLoginSourceValue, loginStyle: LoginStyle, loggedInAction: () -> Void,
                        elsePresentSignUpWithSuccessAction afterLogInAction: @escaping () -> Void) {}
    func vmPop() {}
    func vmDismiss(_ completion: (() -> Void)?) {}
    func vmOpenInternalURL(_ url: URL) {}


    // Tab navigator
    func openHome() {}
    func openSell(_ source: PostingSource) {}
    func openAppRating(_ source: EventParameterRatingSource) {}
    func openUserRating(_ source: RateUserSource, data: RateUserData) {}
    func openUser(_ data: UserDetailData) {}
    func openListing(_ data: ListingDetailData, source: EventParameterProductVisitSource,
                     showKeyboardOnFirstAppearIfNeeded: Bool) {}
    func openChat(_ data: ChatDetailData, source: EventParameterTypePage) {}
    func openVerifyAccounts(_ types: [VerificationType], source: VerifyAccountsSource, completionBlock: (() -> Void)?) {}
    func openAppInvite() {}
    func canOpenAppInvite() -> Bool { return false }
    func openRatingList(_ userId: String) {}
}
