//
//  SignUpLoginViewModel.swift
//  LetGo
//
//  Created by Dídac on 19/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
import Result

enum SignUpLogInError: ErrorType {
    case UsernameTaken, InvalidUsername, InvalidEmail, InvalidPassword, TermsNotAccepted
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

public enum LoginActionType: Int{
    case Signup, Login
}

protocol SignUpLogInViewModelDelegate: class {
    
    // visual
    func viewModel(viewModel: SignUpLogInViewModel, updateSendButtonEnabledState enabled: Bool)
    func viewModel(viewModel: SignUpLogInViewModel, updateShowPasswordVisible visible: Bool)
    
    // signup
    func viewModelDidStartSigningUp(viewModel: SignUpLogInViewModel)
    func viewModel(viewModel: SignUpLogInViewModel, didFinishSigningUpWithResult
        result: Result<MyUser, SignUpLogInError>)

    // login
    func viewModelDidStartLoggingIn(viewModel: SignUpLogInViewModel)
    func viewModel(viewModel: SignUpLogInViewModel, didFinishLoggingInWithResult
        result: Result<MyUser, SignUpLogInError>)

    // fb login
    func viewModelDidStartLoggingWithFB(viewModel: SignUpLogInViewModel)
    func viewModel(viewModel: SignUpLogInViewModel, didFinishLoggingWithFBWithResult result: FBLoginResult)
}

public class SignUpLogInViewModel: BaseViewModel {

    let sessionManager: SessionManager
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
    var termsAccepted: Bool
    var newsletterAccepted: Bool

    var showPasswordShouldBeVisible : Bool {
        return password.characters.count > 0
    }

    var termsAndConditionsEnabled: Bool {
        //TODO: CHECK TURKEY!
        return true
    }

    var termsAndConditionsURL: NSURL? {
        return LetgoURLHelper.composeURL(Constants.termsAndConditionsURL)
    }
    var privacyURL: NSURL? {
        return LetgoURLHelper.composeURL(Constants.privacyURL)
    }

    // MARK: - Lifecycle
    
    init(sessionManager: SessionManager, source: EventParameterLoginSourceValue, action: LoginActionType) {
        self.sessionManager = sessionManager
        self.loginSource = source
        self.username = ""
        self.email = ""
        self.password = ""
        self.termsAccepted = false
        self.newsletterAccepted = false
        self.currentActionType = action
        super.init()
    }
    
    convenience init(source: EventParameterLoginSourceValue, action: LoginActionType) {
        let sessionManager = SessionManager.sharedInstance
        self.init(sessionManager: sessionManager, source: source, action: action)
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
            delegate?.viewModel(self, didFinishSigningUpWithResult:
                Result<MyUser, SignUpLogInError>(error: .UsernameTaken))
        } else if fullName.characters.count < Constants.fullNameMinLength {
            delegate?.viewModel(self, didFinishSigningUpWithResult:
                Result<MyUser, SignUpLogInError>(error: .InvalidUsername))
        } else if !email.isEmail() {
            delegate?.viewModel(self, didFinishSigningUpWithResult:
                Result<MyUser, SignUpLogInError>(error: .InvalidEmail))
        } else if password.characters.count < Constants.passwordMinLength ||
            password.characters.count > Constants.passwordMaxLength {
                delegate?.viewModel(self, didFinishSigningUpWithResult:
                    Result<MyUser, SignUpLogInError>(error: .InvalidPassword))
        } else if termsAndConditionsEnabled && (!termsAccepted || !newsletterAccepted) {
            delegate?.viewModel(self, didFinishSigningUpWithResult:
                Result<MyUser, SignUpLogInError>(error: .TermsNotAccepted))
        } else {
            sessionManager.signUp(email.lowercaseString, password: password, name: fullName) {
                [weak self] signUpResult in
                
                guard let strongSelf = self else { return }
                
                var result = Result<MyUser, SignUpLogInError>(error: .Internal)
                if let value = signUpResult.value {
                    result = Result<MyUser, SignUpLogInError>(value: value)

                    TrackerProxy.sharedInstance.setUser(value)
                    TrackerProxy.sharedInstance.trackEvent(TrackerEvent.signupEmail(strongSelf.loginSource))
                } else if let repositoryError = signUpResult.error {
                    let error = SignUpLogInError(repositoryError: repositoryError)
                    result = Result<MyUser, SignUpLogInError>(error: error)
                }

                strongSelf.delegate?.viewModel(strongSelf, didFinishSigningUpWithResult: result)
            }
        }
    }
    
    public func logIn() {
        
        // Notify the delegate about it started
        delegate?.viewModelDidStartLoggingIn(self)
        
        // Validation
        if !email.isEmail() {
            delegate?.viewModel(self, didFinishLoggingInWithResult:
                Result<MyUser, SignUpLogInError>(error: .InvalidEmail))
        } else if password.characters.count < Constants.passwordMinLength {
            delegate?.viewModel(self, didFinishLoggingInWithResult:
                Result<MyUser, SignUpLogInError>(error: .InvalidPassword))
        } else {
            sessionManager.login(email, password: password) { [weak self] loginResult in
                guard let strongSelf = self else { return }
                
                var result = Result<MyUser, SignUpLogInError>(error: .Internal)
                if let myUser = loginResult.value {
                    result = Result<MyUser, SignUpLogInError>(value: myUser)

                    TrackerProxy.sharedInstance.setUser(myUser)
                    let trackerEvent = TrackerEvent.loginEmail(strongSelf.loginSource)
                    TrackerProxy.sharedInstance.trackEvent(trackerEvent)
                } else if let repositoryError = loginResult.error {
                    let error = SignUpLogInError(repositoryError: repositoryError)
                    result = Result<MyUser, SignUpLogInError>(error: error)
                }

                strongSelf.delegate?.viewModel(strongSelf, didFinishLoggingInWithResult: result)
            }
        }
    }
    
    public func logInWithFacebook() {
        FBLoginHelper.logInWithFacebook(sessionManager, tracker: TrackerProxy.sharedInstance, loginSource: loginSource,
            managerStart: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.delegate?.viewModelDidStartLoggingWithFB(strongSelf)
            },
            completion: { [weak self] result in
                guard let strongSelf = self else { return }
                strongSelf.delegate?.viewModel(strongSelf, didFinishLoggingWithFBWithResult: result)
            }
        )
    }
    
    public func loginFailedWithError(error: EventParameterLoginError) {
        TrackerProxy.sharedInstance.trackEvent(TrackerEvent.loginError(error))
    }
    
    public func signupFailedWithError(error: EventParameterLoginError) {
        TrackerProxy.sharedInstance.trackEvent(TrackerEvent.signupError(error))
    }
    
    
    // MARK: - Private methods
    
    private func sendButtonShouldBeEnabled() -> Bool {
        return  email.characters.count > 0 && password.characters.count > 0 &&
            (currentActionType == .Login || ( currentActionType == .Signup && username.characters.count > 0))
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
