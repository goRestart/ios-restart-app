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
    func viewModel(viewModel: RememberPasswordViewModel, updateSendButtonEnabledState enabled: Bool)
    func viewModelDidStartResettingPassword(viewModel: RememberPasswordViewModel)
    func viewModelDidFinishResetPassword(viewModel: RememberPasswordViewModel)
    func viewModel(viewModel: RememberPasswordViewModel, didFailResetPassword error: String)
}


public class RememberPasswordViewModel: BaseViewModel {
   
    // Login source
    let sessionManager: SessionManager
    let loginSource: EventParameterLoginSourceValue
    
    // Delegate
    weak var delegate: RememberPasswordViewModelDelegate?
    
    // Input
    var email: String {
        didSet {
            email = email.trim
            delegate?.viewModel(self, updateSendButtonEnabledState: sendButtonShouldBeEnabled())
        }
    }
    
    // MARK: - Lifecycle
    
    init(sessionManager: SessionManager, source: EventParameterLoginSourceValue, email: String) {
        self.sessionManager = sessionManager
        self.email = email
        self.loginSource = source
        super.init()
    }
    
    convenience init(source: EventParameterLoginSourceValue, email: String) {
        let sessionManager = Core.sessionManager
        self.init(sessionManager: sessionManager, source: source, email: email)
    }
    
    // MARK: - Public methods
    
    public func resetPassword() {
        if !email.isEmail() {
            delegate?.viewModel(self, didFailResetPassword: LGLocalizedString.resetPasswordSendErrorInvalidEmail)
        }
        else {
            delegate?.viewModelDidStartResettingPassword(self)
            sessionManager.recoverPassword(email) { [weak self] recoverPwdResult in
                guard let strongSelf = self else { return }

                switch (recoverPwdResult) {
                case .Success:
                    strongSelf.delegate?.viewModelDidFinishResetPassword(strongSelf)
                case .Failure(let error):
                    var errorMessage: String?
                    var errorDescription: EventParameterLoginError?
                    switch (error) {
                    case .Network:
                        errorMessage = LGLocalizedString.commonErrorConnectionFailed
                        errorDescription = .Network
                    case .NotFound:
                        errorMessage = LGLocalizedString.resetPasswordSendErrorUserNotFoundOrWrongPassword(
                            strongSelf.email)
                        errorDescription = .NotFound
                    case .AlreadyExists, .TooManyRequests:
                        errorMessage = LGLocalizedString.resetPasswordSendTooManyRequests
                        errorDescription = .TooManyRequests
                    case .Scammer:
                        errorMessage = LGLocalizedString.resetPasswordSendErrorGeneric
                        errorDescription = .Scammer
                    case let .Internal(description):
                        errorMessage = LGLocalizedString.resetPasswordSendErrorGeneric
                        errorDescription = .Internal(description: description)
                    case .Forbidden:
                        errorMessage = LGLocalizedString.resetPasswordSendErrorGeneric
                        errorDescription = .Forbidden
                    case .Unauthorized:
                        errorMessage = LGLocalizedString.resetPasswordSendErrorGeneric
                        errorDescription = .Unauthorized
                    case .NonExistingEmail:
                        errorMessage = LGLocalizedString.resetPasswordSendErrorGeneric
                        errorDescription = .NonExistingEmail
                    }
                    if let errorDescription = errorDescription {
                        TrackerProxy.sharedInstance.trackEvent(TrackerEvent.passwordResetError(errorDescription))
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
