//
//  LogInViewModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 08/06/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import Parse
import Result

public protocol LogInViewModelDelegate: class {
    func viewModel(viewModel: LogInViewModel, updateSendButtonEnabledState enabled: Bool)
    func viewModelDidStartLoggingIn(viewModel: LogInViewModel)
    func viewModel(viewModel: LogInViewModel, didFinishLoggingInWithResult result: Result<User, UserLogInEmailServiceError>)
}

public class LogInViewModel: BaseViewModel {
   
    // Login source
    let loginSource: TrackingParameterLoginSourceValue
    
    // Delegate
    weak var delegate: LogInViewModelDelegate?
    
    // Input
    var email: String {
        didSet {
            delegate?.viewModel(self, updateSendButtonEnabledState: sendButtonShouldBeEnabled())
        }
    }
    var password: String {
        didSet {
            delegate?.viewModel(self, updateSendButtonEnabledState: sendButtonShouldBeEnabled())
        }
    }
    
    // MARK: - Lifecycle
    
    init(source: TrackingParameterLoginSourceValue) {
        email = ""
        password = ""
        loginSource = source
        super.init()
    }
    
    // MARK: - Public methods
    
    public func logIn() {

        // Notify the delegate about it started
        delegate?.viewModelDidStartLoggingIn(self)
        
        // Validation
        if !email.isEmail() {
            delegate?.viewModel(self, didFinishLoggingInWithResult: Result<User, UserLogInEmailServiceError>.failure(.InvalidEmail))
        }
        else if count(password) < Constants.passwordMinLength {
            delegate?.viewModel(self, didFinishLoggingInWithResult: Result<User, UserLogInEmailServiceError>.failure(.InvalidPassword))
        }
        else {
            MyUserManager.sharedInstance.logInWithEmail(email, password: password) { [weak self] (result: Result<User, UserLogInEmailServiceError>) in
                if let strongSelf = self {

                    // Tracking
                    if let user = result.value, let email = user.email {
                        TrackingHelper.setUserId(email)
                    }
                    TrackingHelper.trackEvent(.LoginEmail, withLoginSource: strongSelf.loginSource)
                    
                    // Notify the delegate about it finished
                    if let actualDelegate = strongSelf.delegate {
                        actualDelegate.viewModel(strongSelf, didFinishLoggingInWithResult: result)
                    }
                }
            }
        }
    }
    
    // MARK: - Private methods
    
    private func sendButtonShouldBeEnabled() -> Bool {
        return count(email) > 0 && count(password) > 0
    }
}
