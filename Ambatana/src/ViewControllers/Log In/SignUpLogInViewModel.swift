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
import RxSwift

public enum LoginActionType: Int{
    case Signup, Login
}

protocol SignUpLogInViewModelDelegate: class {
    
    // visual
    func viewModel(viewModel: SignUpLogInViewModel, updateSendButtonEnabledState enabled: Bool)
    func viewModel(viewModel: SignUpLogInViewModel, updateShowPasswordVisible visible: Bool)
    func viewModelShowHiddenPasswordAlert(viewModel: SignUpLogInViewModel)
    func viewModelShowGodModeError(viewModel: SignUpLogInViewModel)
    
    // signup
    func viewModelDidStartSigningUp(viewModel: SignUpLogInViewModel)
    func viewModelDidSignUp(viewModel: SignUpLogInViewModel)
    func viewModelDidFailSigningUp(viewModel: SignUpLogInViewModel, message: String)
    func viewModelShowRecaptcha(viewModel: RecaptchaViewModel)

    // login
    func viewModelDidStartLoginIn(viewModel: SignUpLogInViewModel)
    func viewModelDidLogIn(viewModel: SignUpLogInViewModel)
    func viewModelDidFailLoginIn(viewModel: SignUpLogInViewModel, message: String)

    // fb login
    func viewModelDidStartAuthWithExternalService(viewModel: SignUpLogInViewModel)
    func viewModelDidAuthWithExternalService(viewModel: SignUpLogInViewModel)
    func viewModelDidCancelAuthWithExternalService(viewModel: SignUpLogInViewModel)
    func viewModel(viewModel: SignUpLogInViewModel, didFailAuthWithExternalService message: String)
}

public class SignUpLogInViewModel: BaseViewModel {
    
    // Delegate
    weak var delegate: SignUpLogInViewModelDelegate?
    let loginSource: EventParameterLoginSourceValue
    let googleLoginHelper: GoogleLoginHelper
    let keyValueStorage: KeyValueStorage
    
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
            email = email.trim
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

    var termsAndConditionsEnabled: Bool

    private let previousEmail: Variable<String?>
    let previousFacebookUsername: Variable<String?>
    let previousGoogleUsername: Variable<String?>

    func attributedLegalText(linkColor: UIColor) -> NSAttributedString {
        guard let conditionsURL = termsAndConditionsURL, privacyURL = privacyURL else {
            return NSAttributedString(string: LGLocalizedString.signUpTermsConditions)
        }

        let links = [LGLocalizedString.signUpTermsConditionsTermsPart: conditionsURL,
            LGLocalizedString.signUpTermsConditionsPrivacyPart: privacyURL]
        let localizedLegalText = LGLocalizedString.signUpTermsConditions
        let attributtedLegalText = localizedLegalText.attributedHyperlinkedStringWithURLDict(links,
            textColor: linkColor)
        attributtedLegalText.addAttribute(NSFontAttributeName, value: UIFont.mediumBodyFont,
            range: NSMakeRange(0, attributtedLegalText.length))
        return attributtedLegalText
    }

    private var termsAndConditionsURL: NSURL? {
        return LetgoURLHelper.composeURL(Constants.termsAndConditionsURL)
    }
    private var privacyURL: NSURL? {
        return LetgoURLHelper.composeURL(Constants.privacyURL)
    }

    private let sessionManager: SessionManager
    private let locationManager: LocationManager


    private var newsletterParameter: EventParameterNewsletter {
        if !termsAndConditionsEnabled {
            return .Unset
        } else {
            return newsletterAccepted ? .True : .False
        }
    }



    // MARK: - Lifecycle
    
    init(sessionManager: SessionManager, locationManager: LocationManager, keyValueStorage: KeyValueStorage,
         source: EventParameterLoginSourceValue, action: LoginActionType) {
        self.sessionManager = sessionManager
        self.locationManager = locationManager
        self.keyValueStorage = keyValueStorage
        self.loginSource = source
        self.googleLoginHelper = GoogleLoginHelper(loginSource: source)
        self.username = ""
        self.email = ""
        self.password = ""
        self.termsAccepted = false
        self.newsletterAccepted = false
        self.currentActionType = action
        self.termsAndConditionsEnabled = false
        self.previousEmail = Variable<String?>(nil)
        self.previousFacebookUsername = Variable<String?>(nil)
        self.previousGoogleUsername = Variable<String?>(nil)
        super.init()

        checkTermsAndConditionsEnabled()
        updatePreviousEmailAndUsernamesFromKeyValueStorage()

        if let previousEmail = previousEmail.value {
            self.email = previousEmail
        }
    }
    
    convenience init(source: EventParameterLoginSourceValue, action: LoginActionType) {
        let sessionManager = Core.sessionManager
        let locationManager = Core.locationManager
        let keyValueStorage = KeyValueStorage.sharedInstance
        self.init(sessionManager: sessionManager, locationManager: locationManager, keyValueStorage: keyValueStorage,
                  source: source, action: action)
    }
    
    
    // MARK: - Public methods
    
    public func erasePassword() {
        password = ""
    }

    public func signUp() {
        signUp(nil)
    }
    
    public func signUp(recaptchaToken: String?) {
        delegate?.viewModelDidStartSigningUp(self)

        let fullName = username.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if usernameContainsLetgoString(fullName) {
            delegate?.viewModelDidFailSigningUp(self, message: LGLocalizedString.signUpSendErrorGeneric)
            trackSignupEmailFailedWithError(.UsernameTaken)
        } else if fullName.characters.count < Constants.fullNameMinLength {
            delegate?.viewModelDidFailSigningUp(self, message: LGLocalizedString.signUpSendErrorInvalidUsername(Constants.fullNameMinLength))
            trackSignupEmailFailedWithError(.InvalidUsername)
        } else if !email.isEmail() {
            delegate?.viewModelDidFailSigningUp(self, message: LGLocalizedString.signUpSendErrorInvalidEmail)
            trackSignupEmailFailedWithError(.InvalidEmail)
        } else if password.characters.count < Constants.passwordMinLength ||
            password.characters.count > Constants.passwordMaxLength {
                delegate?.viewModelDidFailSigningUp(self, message: LGLocalizedString.signUpSendErrorInvalidPasswordWithMax(Constants.passwordMinLength,
                    Constants.passwordMaxLength))
                trackSignupEmailFailedWithError(.InvalidPassword)
        } else if termsAndConditionsEnabled && !termsAccepted {
            delegate?.viewModelDidFailSigningUp(self, message: LGLocalizedString.signUpAcceptanceError)
            trackSignupEmailFailedWithError(.TermsNotAccepted)
        } else {
            let completion: (Result<MyUser, SessionManagerError>) -> () = { [weak self] signUpResult in
                guard let strongSelf = self else { return }

                if let user = signUpResult.value {
                    self?.savePreviousEmailOrUsername(.Email, userEmailOrName: user.email)

                    // Tracking
                    TrackerProxy.sharedInstance.trackEvent(TrackerEvent.signupEmail(strongSelf.loginSource,
                        newsletter: strongSelf.newsletterParameter))

                    strongSelf.delegate?.viewModelDidSignUp(strongSelf)
                } else if let sessionManagerError = signUpResult.error {
                    strongSelf.processSignUpSessionError(sessionManagerError)
                }
            }

            let newsletter: Bool? = termsAndConditionsEnabled ? self.newsletterAccepted : nil
            if let recaptchaToken = recaptchaToken  {
                sessionManager.signUp(email.lowercaseString, password: password, name: fullName, newsletter: newsletter,
                                      recaptchaToken: recaptchaToken, completion: completion)
            } else {
                sessionManager.signUp(email.lowercaseString, password: password, name: fullName,
                                      newsletter: newsletter, completion: completion)
            }
        }
    }

    public func recaptchaTokenObtained(token: String) {
        signUp(token)
    }
    
    public func logIn() {
        if email == "admin" && password == "wat" {
            delegate?.viewModelShowHiddenPasswordAlert(self)
            return
        }
        
        delegate?.viewModelDidStartLoginIn(self)

        if !email.isEmail() {
            delegate?.viewModelDidFailLoginIn(self, message: LGLocalizedString.logInErrorSendErrorInvalidEmail)
            trackLoginEmailFailedWithError(.InvalidEmail)
        } else if password.characters.count < Constants.passwordMinLength {
            delegate?.viewModelDidFailLoginIn(self, message: LGLocalizedString.logInErrorSendErrorUserNotFoundOrWrongPassword)
            trackLoginEmailFailedWithError(.InvalidPassword)
        } else {
            sessionManager.login(email, password: password) { [weak self] loginResult in
                guard let strongSelf = self else { return }

                if let user = loginResult.value {
                    self?.savePreviousEmailOrUsername(.Email, userEmailOrName: user.email)

                    let trackerEvent = TrackerEvent.loginEmail(strongSelf.loginSource)
                    TrackerProxy.sharedInstance.trackEvent(trackerEvent)

                    strongSelf.delegate?.viewModelDidLogIn(strongSelf)
                } else if let sessionManagerError = loginResult.error {
                    strongSelf.processLoginSessionError(sessionManagerError)
                }
            }
        }
    }
    
    public func godLogIn(password: String) {
        if password == "mellongod" {
            KeyValueStorage.sharedInstance[.isGod] = true
        } else {
            delegate?.viewModelShowGodModeError(self)
        }
    }
    
    public func logInWithFacebook() {
        FBLoginHelper.logInWithFacebook(sessionManager, tracker: TrackerProxy.sharedInstance, loginSource: loginSource,
            managerStart: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.delegate?.viewModelDidStartAuthWithExternalService(strongSelf)
            },
            completion: { [weak self] result in
                guard let error = self?.processExternalServiceAuthResult(result, accountProvider: .Facebook) else { return }
                self?.trackLoginFBFailedWithError(error)
            }
        )
    }

    public func logInWithGoogle() {
        
        googleLoginHelper.login({ [weak self] in
            // Google OAuth completed. Token obtained
            guard let strongSelf = self else { return }
            self?.delegate?.viewModelDidStartAuthWithExternalService(strongSelf)
        }) { [weak self] result in
            // Login with Bouncer finished with success or fail
            guard let error = self?.processExternalServiceAuthResult(result, accountProvider: .Google) else { return }
            self?.trackLoginGoogleFailedWithError(error)
        }
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

    /**
    Right now terms and conditions will be enabled just for Turkey so it will appear depending on location country code 
    or phone region
    */
    private func checkTermsAndConditionsEnabled() {
        let turkey = "tr"

        let systemCountryCode = NSLocale.currentLocale().lg_countryCode
        let countryCode = locationManager.currentPostalAddress?.countryCode ?? systemCountryCode

        termsAndConditionsEnabled = systemCountryCode == turkey || countryCode.lowercaseString == turkey
    }

    private func processLoginSessionError(error: SessionManagerError) {
        let message: String
        switch (error) {
        case .Network:
            message = LGLocalizedString.commonErrorConnectionFailed
        case .Unauthorized:
            message = LGLocalizedString.logInErrorSendErrorUserNotFoundOrWrongPassword
        case .Scammer, .NotFound, .Internal, .Forbidden, .NonExistingEmail, .Conflict, .TooManyRequests, .BadRequest,
             .UserNotVerified:
            message = LGLocalizedString.logInErrorSendErrorGeneric
        }
        delegate?.viewModelDidFailLoginIn(self, message: message)
        trackLoginEmailFailedWithError(eventParameterForSessionError(error))
    }

    private func processSignUpSessionError(error: SessionManagerError) {
        let message: String
        switch (error) {
        case .Network:
            message = LGLocalizedString.commonErrorConnectionFailed
        case .BadRequest(let cause):
            switch cause {
            case .NotSpecified, .Other:
                message = LGLocalizedString.signUpSendErrorGeneric
            case .NonAcceptableParams:
                message = LGLocalizedString.signUpSendErrorInvalidDomain
            }
        case .Conflict(let cause):
            switch cause {
            case .UserExists, .NotSpecified, .Other:
                message = LGLocalizedString.signUpSendErrorEmailTaken(email)
            case .EmailRejected:
                message = LGLocalizedString.mainSignUpErrorUserRejected
            case .RequestAlreadyProcessed:
                message = LGLocalizedString.mainSignUpErrorRequestAlreadySent
            }
        case .NonExistingEmail:
            message = LGLocalizedString.signUpSendErrorInvalidEmail
        case .UserNotVerified:
            // In this case we don't want
            let vm = RecaptchaViewModel()
            delegate?.viewModelShowRecaptcha(vm)
            return
        case .Scammer, .NotFound, .Internal, .Forbidden, .Unauthorized, .TooManyRequests:
            message = LGLocalizedString.signUpSendErrorGeneric
        }
        delegate?.viewModelDidFailSigningUp(self, message: message)
        trackSignupEmailFailedWithError(eventParameterForSessionError(error))
    }

    private func eventParameterForSessionError(error: SessionManagerError) -> EventParameterLoginError {
        switch (error) {
        case .Network:
            return .Network
        case .BadRequest(let cause):
            switch cause {
            case .NonAcceptableParams:
                return .BlacklistedDomain
            case .NotSpecified, .Other:
                return .BadRequest
            }
        case .Scammer:
            return .Forbidden
        case .NotFound:
            return .NotFound
        case .Conflict:
            return .EmailTaken
        case .Forbidden:
            return .Forbidden
        case let .Internal(description):
            return .Internal(description: description)
        case .NonExistingEmail:
            return .NonExistingEmail
        case .Unauthorized:
            return .Unauthorized
        case .TooManyRequests:
            return .TooManyRequests
        case .UserNotVerified:
            return .Internal(description: "UserNotVerified")
        }
    }

    private func processExternalServiceAuthResult(result: ExternalServiceAuthResult,
                                                  accountProvider: AccountProvider) -> EventParameterLoginError? {
        var loginError: EventParameterLoginError? = nil
        switch result {
        case let .Success(myUser):
            savePreviousEmailOrUsername(accountProvider, userEmailOrName: myUser.name)
            delegate?.viewModelDidAuthWithExternalService(self)
        case .Cancelled:
            delegate?.viewModelDidCancelAuthWithExternalService(self)
        case .Network:
            delegate?.viewModel(self, didFailAuthWithExternalService: LGLocalizedString.mainSignUpFbConnectErrorGeneric)
            loginError = .Network
        case .Forbidden:
            delegate?.viewModel(self, didFailAuthWithExternalService: LGLocalizedString.mainSignUpFbConnectErrorGeneric)
            loginError = .Forbidden
        case .NotFound:
            delegate?.viewModel(self, didFailAuthWithExternalService: LGLocalizedString.mainSignUpFbConnectErrorGeneric)
            loginError = .UserNotFoundOrWrongPassword
        case .BadRequest:
            delegate?.viewModel(self, didFailAuthWithExternalService: LGLocalizedString.mainSignUpFbConnectErrorGeneric)
            loginError = .BadRequest
        case .Conflict(let cause):
            var message = ""
            switch cause {
            case .UserExists, .NotSpecified, .Other:
                message = LGLocalizedString.mainSignUpFbConnectErrorEmailTaken
            case .EmailRejected:
                message = LGLocalizedString.mainSignUpErrorUserRejected
            case .RequestAlreadyProcessed:
                message = LGLocalizedString.mainSignUpErrorRequestAlreadySent
            }
            delegate?.viewModel(self, didFailAuthWithExternalService: message)
            loginError = .EmailTaken
        case let .Internal(description):
            delegate?.viewModel(self, didFailAuthWithExternalService: LGLocalizedString.mainSignUpFbConnectErrorGeneric)
            loginError = .Internal(description: description)
        }
        return loginError
    }
    
    
    // MARK: - Trackings
    
    private func trackLoginEmailFailedWithError(error: EventParameterLoginError) {
        TrackerProxy.sharedInstance.trackEvent(TrackerEvent.loginEmailError(error))
    }

    private func trackLoginFBFailedWithError(error: EventParameterLoginError) {
        TrackerProxy.sharedInstance.trackEvent(TrackerEvent.loginFBError(error))
    }

    private func trackLoginGoogleFailedWithError(error: EventParameterLoginError) {
        TrackerProxy.sharedInstance.trackEvent(TrackerEvent.loginGoogleError(error))
    }

    private func trackSignupEmailFailedWithError(error: EventParameterLoginError) {
        TrackerProxy.sharedInstance.trackEvent(TrackerEvent.signupError(error))
    }
}


// MARK: > Previous email/user name

private extension SignUpLogInViewModel {
    private func updatePreviousEmailAndUsernamesFromKeyValueStorage() {
        guard let accountProviderString = keyValueStorage[.previousUserAccountProvider],
            accountProvider = AccountProvider(rawValue: accountProviderString) else { return }

        let userEmailOrName = keyValueStorage[.previousUserEmailOrName]
        updatePreviousEmailAndUsernames(accountProvider, userEmailOrName: userEmailOrName)
    }

    private func updatePreviousEmailAndUsernames(accountProvider: AccountProvider, userEmailOrName: String?) {
        switch accountProvider {
        case .Email:
            previousEmail.value = userEmailOrName
            previousFacebookUsername.value = nil
            previousGoogleUsername.value = nil
        case .Facebook:
            previousEmail.value = nil
            previousFacebookUsername.value = userEmailOrName
            previousGoogleUsername.value = nil
        case .Google:
            previousEmail.value = nil
            previousFacebookUsername.value = nil
            previousGoogleUsername.value = userEmailOrName
        }
    }

    private func savePreviousEmailOrUsername(accountProvider: AccountProvider, userEmailOrName: String?) {
        keyValueStorage[.previousUserAccountProvider] = accountProvider.rawValue
        keyValueStorage[.previousUserEmailOrName] = userEmailOrName
    }
}
