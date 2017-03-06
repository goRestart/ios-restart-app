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
    var delegateReceivedShowLoading = false
    var delegateReceivedHideLoading = false
    var delegateReceivedShowAlert = false
    var delegateReceivedShowActionSheet = false

    func resetViewModelSpec() {
        delegateReceivedShowLoading = false
        delegateReceivedHideLoading = false
        delegateReceivedShowAlert = false
        delegateReceivedShowActionSheet = false
    }

    func vmShowAutoFadingMessage(_ message: String, completion: (() -> ())?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
            completion?()
        }
    }

    func vmShowLoading(_ loadingMessage: String?) {
        delegateReceivedShowLoading = true
    }

    func vmHideLoading(_ finishedMessage: String?, afterMessageCompletion: (() -> ())?) {
        delegateReceivedHideLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
            afterMessageCompletion?()
        }
    }

    func vmShowAlertWithTitle(_ title: String?, text: String, alertType: AlertType, actions: [UIAction]?) {
        delegateReceivedShowAlert = true
    }

    func vmShowAlertWithTitle(_ title: String?, text: String, alertType: AlertType, buttonsLayout: AlertButtonsLayout, actions: [UIAction]?) {
        delegateReceivedShowAlert = true
    }

    func vmShowAlert(_ title: String?, message: String?, actions: [UIAction]) {
        delegateReceivedShowAlert = true
    }

    func vmShowAlert(_ title: String?, message: String?, cancelLabel: String, actions: [UIAction]) {
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
    func openSell(_ source: PostingSource) {}
    func openUser(_ data: UserDetailData) {}
    func openProduct(_ data: ProductDetailData, source: EventParameterProductVisitSource,
                     showKeyboardOnFirstAppearIfNeeded: Bool) {}
    func openChat(_ data: ChatDetailData, source: EventParameterTypePage) {}
    func openVerifyAccounts(_ types: [VerificationType], source: VerifyAccountsSource, completionBlock: (() -> Void)?) {}
    func openAppInvite() {}
    func canOpenAppInvite() -> Bool { return false }
    func openRatingList(_ userId: String) {}
}
