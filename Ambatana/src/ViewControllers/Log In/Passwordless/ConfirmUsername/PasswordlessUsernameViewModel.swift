//
//  PasswordlessUsernameViewModel.swift
//  LetGo
//
//  Created by Isaac Roldan on 30/4/18.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
import LGComponents

final class PasswordlessUsernameViewModel: BaseViewModel {

    private let sessionManager: SessionManager
    private let tracker: Tracker
    private let token: String
    weak var delegate: BaseViewModelDelegate?
    weak var navigator: PasswordlessUsernameNavigator?

    init(sessionManager: SessionManager, tracker: Tracker, token: String) {
        self.sessionManager = sessionManager
        self.tracker = tracker
        self.token = token
    }

    convenience init(token: String) {
        self.init(sessionManager: Core.sessionManager,
                  tracker: TrackerProxy.sharedInstance,
                  token: token)
    }

    func didTapDoneWith(name: String) {
        sessionManager.signUpPasswordlessWith(token: token, username: name) { [weak self] result in
            if let _ = result.value {
                self?.trackSignupComplete()
                self?.navigator?.closePasswordlessConfirmUsername()
            } else {
                self?.delegate?.vmShowAlert(R.Strings.commonErrorTitle,
                                      message: R.Strings.commonError,
                                      cancelLabel: R.Strings.commonOk,
                                      actions: [])
            }
        }
    }

    func didTapHelp() {
        navigator?.openHelp()
    }

    func didTapClose() {
        navigator?.closePasswordlessConfirmUsername()
    }

    func trackSignupComplete() {
        let event = TrackerEvent.signupEmail(.passwordless, newsletter: .falseParameter)
        tracker.trackEvent(event)
    }
}
