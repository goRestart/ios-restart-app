//
//  SignUpViewModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 10/06/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import Parse
import Result

public protocol SignUpViewModelDelegate: class {
    func viewModel(viewModel: SignUpViewModel, updateSendButtonEnabledState enabled: Bool)
    func viewModelDidStartSigningUp(viewModel: SignUpViewModel)
    func viewModel(viewModel: SignUpViewModel, didFinishSigningUpWithResult result: Result<Nil, UserSignUpServiceError>)
}

public class SignUpViewModel: BaseViewModel {
    
    // Constants & enums
    private static let minPasswordLength = 6
    
    // Login source
    let loginSource: TrackingParameterLoginSourceValue
    
    // Delegate
    weak var delegate: SignUpViewModelDelegate?
    
    // Input
    var username: String {
        didSet {
            delegate?.viewModel(self, updateSendButtonEnabledState: sendButtonShouldBeEnabled())
        }
    }
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
        loginSource = source
        username = ""
        email = ""
        password = ""
        super.init()
    }
    
    // MARK: - Public methods
    
    public func signUp() {

        // Notify the delegate about it started
        delegate?.viewModelDidStartSigningUp(self)
        
        // Validation
        if count(username.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())) < 1 {
            delegate?.viewModel(self, didFinishSigningUpWithResult: Result<Nil, UserSignUpServiceError>.failure(.InvalidUsername))
        }
        else if !email.isEmail() {
            delegate?.viewModel(self, didFinishSigningUpWithResult: Result<Nil, UserSignUpServiceError>.failure(.InvalidEmail))
        }
        else if count(password) < SignUpViewModel.minPasswordLength {
            delegate?.viewModel(self, didFinishSigningUpWithResult: Result<Nil, UserSignUpServiceError>.failure(.InvalidPassword))
        }
        else {
            MyUserManager.sharedInstance.signUpWithEmail(email, password: password, publicUsername: username) { [weak self] (result: Result<Nil, UserSignUpServiceError>) -> Void in
                if let strongSelf = self {
                    
                    // Tracking
                    TrackingHelper.setUserId(strongSelf.email)
                    TrackingHelper.trackEvent(.SignupEmail, withLoginSource: strongSelf.loginSource)
                    
                    // Notify the delegate about it finished
                    if let actualDelegate = strongSelf.delegate {
                        actualDelegate.viewModel(strongSelf, didFinishSigningUpWithResult: result)
                    }
                }
            }
        }
    }
    
    // MARK: - Private methods
    
    private func sendButtonShouldBeEnabled() -> Bool {
        return count(username) > 0 && count(email) > 0 && count(password) > 0
    }
}
