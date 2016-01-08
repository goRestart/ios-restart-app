//
//  RememberPasswordViewModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 15/06/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import Parse
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
        let sessionManager = SessionManager.sharedInstance
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
                    case .Api(let apiError):
                        switch apiError {
                        case .Network:
                            errorMessage = LGLocalizedString.commonErrorConnectionFailed
                            errorDescription = .Network
                        case .NotFound:
                            errorMessage = LGLocalizedString.resetPasswordSendErrorUserNotFoundOrWrongPassword(
                                strongSelf.email)
                            errorDescription = .NotFound
                        case .AlreadyExists:
                            //Treating AlreadyExists as Success. //TODO: Show "Email already sent" error in the future
                            strongSelf.delegate?.viewModelDidFinishResetPassword(strongSelf)
                        case .Scammer, .Internal, .Unauthorized, .InternalServerError:
                            errorMessage = LGLocalizedString.resetPasswordSendErrorGeneric
                            errorDescription = .Internal
                        }
                    case .Internal:
                        errorMessage = LGLocalizedString.resetPasswordSendErrorGeneric
                        errorDescription = .Internal
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
