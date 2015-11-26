//
//  SignUpLoginViewModel.swift
//  LetGo
//
//  Created by Dídac on 19/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

public  enum LoginActionType: Int{
    case Signup, Login
}

public protocol SignUpLogInViewModelDelegate: class {
    
    // visual
    func viewModel(viewModel: SignUpLogInViewModel, updateSendButtonEnabledState enabled: Bool)
    func viewModel(viewModel: SignUpLogInViewModel, updateShowPasswordVisible visible: Bool)
    
    // signup
    func viewModelDidStartSigningUp(viewModel: SignUpLogInViewModel)
    func viewModel(viewModel: SignUpLogInViewModel, didFinishSigningUpWithResult result: UserSignUpServiceResult)

    // login
    func viewModelDidStartLoggingIn(viewModel: SignUpLogInViewModel)
    func viewModel(viewModel: SignUpLogInViewModel, didFinishLoggingInWithResult result: UserLogInEmailServiceResult)

    // fb login
    func viewModelDidStartLoggingWithFB(viewModel: SignUpLogInViewModel)
    func viewModel(viewModel: SignUpLogInViewModel, didFinishLoggingWithFBWithResult result: UserLogInFBResult)
}

public class SignUpLogInViewModel: BaseViewModel {

    // Login source
    let loginSource: EventParameterLoginSourceValue
    
    // Delegate
    weak var delegate: SignUpLogInViewModelDelegate?
    
    // Action Type
    var currentActionType : LoginActionType {
        didSet {
            delegate?.viewModel(self, updateSendButtonEnabledState: sendButtonShouldBeEnabled())
        }
    }
    
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
            delegate?.viewModel(self, updateShowPasswordVisible: showPasswordShouldBeVisible)
        }
    }

    var showPasswordShouldBeVisible : Bool {
        return password.characters.count > 0
    }
    

    // MARK: - Lifecycle
    
    init(source: EventParameterLoginSourceValue, action: LoginActionType) {
        loginSource = source
        username = ""
        email = ""
        password = ""
        currentActionType = action
        super.init()
    }
    
    
    // MARK: - Public methods
    
    public func erasePassword() {
        password = ""
    }
    
    public func signUp() {
        
        // Notify the delegate about it started
        delegate?.viewModelDidStartSigningUp(self)
        
        // Validation
        let fullName = username.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if usernameContainsLetgoString(fullName) {
            delegate?.viewModel(self, didFinishSigningUpWithResult: UserSignUpServiceResult(error: .UsernameTaken))
        }
        else if fullName.characters.count < Constants.fullNameMinLength {
            delegate?.viewModel(self, didFinishSigningUpWithResult: UserSignUpServiceResult(error: .InvalidUsername))
        }
        else if !email.isEmail() {
            delegate?.viewModel(self, didFinishSigningUpWithResult: UserSignUpServiceResult(error: .InvalidEmail))
        }
        else if password.characters.count < Constants.passwordMinLength || password.characters.count > Constants.passwordMaxLength {
            delegate?.viewModel(self, didFinishSigningUpWithResult: UserSignUpServiceResult(error: .InvalidPassword))
        }
        else {
            MyUserManager.sharedInstance.signUpWithEmail(email.lowercaseString, password: password, publicUsername: fullName) { [weak self] (result: UserSignUpServiceResult) -> Void in
                
                guard let strongSelf = self else { return }

                // Tracking
                if let myUser = MyUserManager.sharedInstance.myUser() {
                    TrackerProxy.sharedInstance.setUser(myUser)
                }
                
                TrackerProxy.sharedInstance.trackEvent(TrackerEvent.signupEmail(strongSelf.loginSource))
                
                // Notify the delegate about it finished
                if let actualDelegate = strongSelf.delegate {
                    actualDelegate.viewModel(strongSelf, didFinishSigningUpWithResult: result)
                }
            }
        }
    }
    
    public func logIn() {
        
        // Notify the delegate about it started
        delegate?.viewModelDidStartLoggingIn(self)
        
        // Validation
        if !email.isEmail() {
            delegate?.viewModel(self, didFinishLoggingInWithResult: UserLogInEmailServiceResult(error: .InvalidEmail))
        }
        else if password.characters.count < Constants.passwordMinLength {
            delegate?.viewModel(self, didFinishLoggingInWithResult: UserLogInEmailServiceResult(error: .InvalidPassword))
        }
        else {
            MyUserManager.sharedInstance.logInWithEmail(email, password: password) { [weak self] (result: UserLogInEmailServiceResult) in
                
                guard let strongSelf = self else { return }
                
                // Success
                if let user = result.value {
                    // Tracking
                    TrackerProxy.sharedInstance.setUser(user)
                    
                    let trackerEvent = TrackerEvent.loginEmail(strongSelf.loginSource)
                    TrackerProxy.sharedInstance.trackEvent(trackerEvent)
                }
                
                // Notify the delegate about it finished
                if let actualDelegate = strongSelf.delegate {
                    actualDelegate.viewModel(strongSelf, didFinishLoggingInWithResult: result)
                }
            }
        }
    }
    
    public func logInWithFacebook() {
        // Notify the delegate about it started
        delegate?.viewModelDidStartLoggingWithFB(self)
        
        // Log in
        MyUserManager.sharedInstance.logInWithFacebook { [weak self] (result: UserLogInFBResult) in
            
            guard let strongSelf = self else { return }
            
            // Tracking
            if let user = result.value {
                TrackerProxy.sharedInstance.setUser(user)
            }
            let trackerEvent = TrackerEvent.loginFB(strongSelf.loginSource)
            TrackerProxy.sharedInstance.trackEvent(trackerEvent)
            
            // Notify the delegate about it finished
            if let actualDelegate = strongSelf.delegate {
                actualDelegate.viewModel(strongSelf, didFinishLoggingWithFBWithResult: result)
            }
        }
    }
    
    public func loginFailedWithError(error: EventParameterLoginError) {
        TrackerProxy.sharedInstance.trackEvent(TrackerEvent.loginError(error))
    }
    
    public func signupFailedWithError(error: EventParameterLoginError) {
        TrackerProxy.sharedInstance.trackEvent(TrackerEvent.signupError(error))
    }
    
    // MARK: - Private methods
    
    private func sendButtonShouldBeEnabled() -> Bool {
        return  email.characters.count > 0 && password.characters.count > 0 && (currentActionType == .Login || ( currentActionType == .Signup && username.characters.count > 0))
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
