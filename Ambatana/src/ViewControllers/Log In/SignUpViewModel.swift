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
    
    // Login source
    let loginSource: EventParameterLoginSourceValue
    
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
    
    init(source: EventParameterLoginSourceValue) {
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
        let fullName = username.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if usernameContainsLetgoString(fullName) {
            delegate?.viewModel(self, didFinishSigningUpWithResult: Result<Nil, UserSignUpServiceError>.failure(.InvalidUsername))
        }
        else if count(fullName) < Constants.fullNameMinLength {
            delegate?.viewModel(self, didFinishSigningUpWithResult: Result<Nil, UserSignUpServiceError>.failure(.InvalidUsername))
        }
        else if !email.isEmail() {
            delegate?.viewModel(self, didFinishSigningUpWithResult: Result<Nil, UserSignUpServiceError>.failure(.InvalidEmail))
        }
        else if count(password) < Constants.passwordMinLength {
            delegate?.viewModel(self, didFinishSigningUpWithResult: Result<Nil, UserSignUpServiceError>.failure(.InvalidPassword))
        }
        else {
            MyUserManager.sharedInstance.signUpWithEmail(email.lowercaseString, password: password, publicUsername: fullName) { [weak self] (result: Result<Nil, UserSignUpServiceError>) -> Void in
                if let strongSelf = self {
                    // Tracking
                    TrackerProxy.sharedInstance.trackEvent(TrackerEvent.signupEmail(strongSelf.loginSource))
                    
                    if let myUser = MyUserManager.sharedInstance.myUser() {
                        TrackerProxy.sharedInstance.setUser(myUser)
                    }
                    
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
    
    private func usernameContainsLetgoString(theUsername: String) -> Bool {
        let lowerCaseUsername = theUsername.lowercaseString
        return lowerCaseUsername.rangeOfString("letgo") != nil ||
            lowerCaseUsername.rangeOfString("ietgo") != nil ||
            lowerCaseUsername.rangeOfString("letg0") != nil ||
            lowerCaseUsername.rangeOfString("ietg0") != nil ||
            lowerCaseUsername.rangeOfString("let go") != nil ||
            lowerCaseUsername.rangeOfString("iet go") != nil ||
            lowerCaseUsername.rangeOfString("let g0") != nil ||
            lowerCaseUsername.rangeOfString("iet g0") != nil
    }

}
