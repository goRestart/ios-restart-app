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

enum RememberPasswordError: ErrorType {
    case InvalidEmail
    case Api(apiError: ApiError)
    case Internal
    
    init(repositoryError: RepositoryError) {
        switch repositoryError {
        case .Api(let apiError):
            self = .Api(apiError: apiError)
        case .Internal:
            self = .Internal
        }
    }
}

protocol RememberPasswordViewModelDelegate: class {
    func viewModel(viewModel: RememberPasswordViewModel, updateSendButtonEnabledState enabled: Bool)
    func viewModelDidStartResettingPassword(viewModel: RememberPasswordViewModel)
    func viewModel(viewModel: RememberPasswordViewModel, didFinishResettingPasswordWithResult
        result: Result<Void, RememberPasswordError>)
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
        
        delegate?.viewModelDidStartResettingPassword(self)
        
        // Validation
        if !email.isEmail() {
            delegate?.viewModel(self, didFinishResettingPasswordWithResult: Result<Void, RememberPasswordError>(error: .InvalidEmail))
        }
        else {
            sessionManager.recoverPassword(email) { [weak self] recoverPwdResult in
                guard let strongSelf = self else { return }
                
                var result = Result<Void, RememberPasswordError>(error: .Internal)
                if let value = recoverPwdResult.value {
                    result = Result<Void, RememberPasswordError>(value: value)
                }
                else if let repositoryError = recoverPwdResult.error {
                    let error = RememberPasswordError(repositoryError: repositoryError)
                    result = Result<Void, RememberPasswordError>(error: error)
                }
                strongSelf.delegate?.viewModel(strongSelf, didFinishResettingPasswordWithResult: result)
            }
        }
    }
    
    public func resetPasswordFailedWithError(error: EventParameterLoginError) {
        TrackerProxy.sharedInstance.trackEvent(TrackerEvent.passwordResetError(error))
    }
    
    // MARK: - Private methods
    
    private func sendButtonShouldBeEnabled() -> Bool {
        return email.characters.count > 0
    }
}
