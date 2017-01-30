//
//  RememberPasswordViewModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 15/06/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import Result

protocol RememberPasswordViewModelDelegate: class {
    func viewModel(_ viewModel: RememberPasswordViewModel, updateSendButtonEnabledState enabled: Bool)
    func viewModelDidStartResettingPassword(_ viewModel: RememberPasswordViewModel)
    func viewModelDidFinishResetPassword(_ viewModel: RememberPasswordViewModel)
    func viewModel(_ viewModel: RememberPasswordViewModel, didFailResetPassword error: String)
}


class RememberPasswordViewModel: BaseViewModel {
    let sessionManager: SessionManager
    let tracker: Tracker
    let loginSource: EventParameterLoginSourceValue

    weak var delegate: RememberPasswordViewModelDelegate?
    
    // Input
    var email: String {
        didSet {
            email = email.trim
            delegate?.viewModel(self, updateSendButtonEnabledState: sendButtonShouldBeEnabled())
        }
    }
    
    // MARK: - Lifecycle
    
    init(sessionManager: SessionManager, tracker: Tracker, source: EventParameterLoginSourceValue, email: String) {
        self.sessionManager = sessionManager
        self.tracker = tracker
        self.email = email
        self.loginSource = source
        super.init()
    }
    
    convenience init(source: EventParameterLoginSourceValue, email: String) {
        let sessionManager = Core.sessionManager
        let tracker = TrackerProxy.sharedInstance
        self.init(sessionManager: sessionManager, tracker: tracker, source: source, email: email)
    }

    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        let event = TrackerEvent.passwordResetVisit()
        tracker.trackEvent(event)
    }

    
    // MARK: - Public methods

    func resetPassword() {
        if !email.isEmail() {
            delegate?.viewModel(self, didFailResetPassword: LGLocalizedString.resetPasswordSendErrorInvalidEmail)
        }
        else {
            delegate?.viewModelDidStartResettingPassword(self)
            sessionManager.recoverPassword(email) { [weak self] recoverPwdResult in
                guard let strongSelf = self else { return }

                switch (recoverPwdResult) {
                case .success:
                    strongSelf.delegate?.viewModelDidFinishResetPassword(strongSelf)
                case .failure(let error):
                    var errorMessage: String?
                    var errorDescription: EventParameterLoginError?
                    switch (error) {
                    case .network:
                        errorMessage = LGLocalizedString.commonErrorConnectionFailed
                        errorDescription = .network
                    case .badRequest(let cause):
                        switch cause {
                        case .nonAcceptableParams:
                            errorDescription = .blacklistedDomain
                        case .notSpecified, .other:
                            errorDescription = .internalError(description: "BadRequest")
                        }
                        errorMessage = LGLocalizedString.resetPasswordSendErrorGeneric
                    case .notFound:
                        errorMessage = LGLocalizedString.resetPasswordSendErrorUserNotFoundOrWrongPassword(
                            strongSelf.email)
                        errorDescription = .notFound
                    case .conflict, .tooManyRequests:
                        errorMessage = LGLocalizedString.resetPasswordSendTooManyRequests
                        errorDescription = .tooManyRequests
                    case .scammer:
                        errorMessage = LGLocalizedString.resetPasswordSendErrorGeneric
                        errorDescription = .scammer
                    case let .internalError(description):
                        errorMessage = LGLocalizedString.resetPasswordSendErrorGeneric
                        errorDescription = .internalError(description: description)
                    case .userNotVerified:
                        errorMessage = LGLocalizedString.resetPasswordSendErrorGeneric
                        errorDescription = .internalError(description: "UserNotVerified")
                    case .forbidden:
                        errorMessage = LGLocalizedString.resetPasswordSendErrorGeneric
                        errorDescription = .forbidden
                    case .unauthorized:
                        errorMessage = LGLocalizedString.resetPasswordSendErrorGeneric
                        errorDescription = .unauthorized
                    case .nonExistingEmail:
                        errorMessage = LGLocalizedString.resetPasswordSendErrorGeneric
                        errorDescription = .nonExistingEmail
                    }
                    if let errorDescription = errorDescription {
                        let event = TrackerEvent.passwordResetError(errorDescription)
                        strongSelf.tracker.trackEvent(event)
                    }

                    if let errorMessage = errorMessage {
                        strongSelf.delegate?.viewModel(strongSelf, didFailResetPassword: errorMessage)
                    }
                }
            }
        }
    }

    // MARK: - Private methods
    
    private func sendButtonShouldBeEnabled() -> Bool {
        return email.characters.count > 0
    }
}
