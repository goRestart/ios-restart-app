//
//  BaseViewModelSpec.swift
//  LetGo
//
//  Created by Eli Kohen on 06/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGo
import Quick
import Nimble

class BaseViewModelSpec: QuickSpec, BaseViewModelDelegate, TabNavigator {

    var loading: Bool = false
    var loadingMessage: String?
    var finishedSuccessfully: Bool = false

    func resetViewModelSpec() {
        loading = false
        loadingMessage = nil
        finishedSuccessfully = false
    }

    func vmShowAutoFadingMessage(_ message: String, completion: (() -> ())?) { }

    func vmShowLoading(_ loadingMessage: String?) {
        loading = true
        self.loadingMessage = loadingMessage
    }

    func vmHideLoading(_ finishedMessage: String?, afterMessageCompletion: (() -> ())?) {
        loading = false
        loadingMessage = finishedMessage
    }

    func vmShowAlertWithTitle(_ title: String?, text: String, alertType: AlertType, actions: [UIAction]?) {}
    func vmShowAlertWithTitle(_ title: String?, text: String, alertType: AlertType, buttonsLayout: AlertButtonsLayout, actions: [UIAction]?) {}
    func vmShowAlert(_ title: String?, message: String?, actions: [UIAction]) {}
    func vmShowAlert(_ title: String?, message: String?, cancelLabel: String, actions: [UIAction]) {}
    func vmShowActionSheet(_ cancelAction: UIAction, actions: [UIAction]) {}
    func vmShowActionSheet(_ cancelLabel: String, actions: [UIAction]) {}
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

    // Base navigator
    func showBubble(with bubbleData: BubbleNotificationData, duration: TimeInterval) {}
}
