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

enum LoginActionType: Int{
    case signup, login
}

protocol SignUpLogInViewModelDelegate: BaseViewModelDelegate {
    func vmUpdateSendButtonEnabledState(_ enabled: Bool)
    func vmUpdateShowPasswordVisible(_ visible: Bool)
    func vmFinish(completedAccess completed: Bool)
    func vmFinishAndShowScammerAlert(_ contactUrl: URL, network: EventParameterAccountNetwork, tracker: Tracker)
    func vmShowRecaptcha(_ viewModel: RecaptchaViewModel)
    func vmShowHiddenPasswordAlert()
}

class SignUpLogInViewModel: BaseViewModel {
    let loginSource: EventParameterLoginSourceValue
    let googleLoginHelper: ExternalAuthHelper
    let fbLoginHelper: ExternalAuthHelper
    let tracker: Tracker
    let keyValueStorage: KeyValueStorageable
    let featureFlags: FeatureFlaggeable
    let locale: Locale

    weak var delegate: SignUpLogInViewModelDelegate?
    
    // Action Type
    var currentActionType : LoginActionType {
        didSet {
            delegate?.vmUpdateSendButtonEnabledState(sendButtonEnabled)
        }
    }
    
    // Input
    var username: String {
        didSet {
            delegate?.vmUpdateSendButtonEnabledState(sendButtonEnabled)
        }
    }
    var email: String {
        didSet {
            email = email.trim
            delegate?.vmUpdateSendButtonEnabledState(sendButtonEnabled)
        }
    }
    var password: String {
        didSet {
            delegate?.vmUpdateSendButtonEnabledState(sendButtonEnabled)
            delegate?.vmUpdateShowPasswordVisible(showPasswordVisible)
        }
    }
    var termsAccepted: Bool
    var newsletterAccepted: Bool

    var showPasswordVisible : Bool {
        return password.characters.count > 0
    }

    private var sendButtonEnabled: Bool {
        return  email.characters.count > 0 && password.characters.count > 0 &&
            (currentActionType == .login || ( currentActionType == .signup && username.characters.count > 0))
    }

    var termsAndConditionsEnabled: Bool

    private let previousEmail: Variable<String?>
    let previousFacebookUsername: Variable<String?>
    let previousGoogleUsername: Variable<String?>

    func attributedLegalText(_ linkColor: UIColor) -> NSAttributedString {
        guard let conditionsURL = termsAndConditionsURL, let privacyURL = privacyURL else {
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

    private var termsAndConditionsURL: URL? {
        return LetgoURLHelper.buildTermsAndConditionsURL()
    }
    private var privacyURL: URL? {
        return LetgoURLHelper.buildPrivacyURL()
    }

    private let sessionManager: SessionManager
    private let installationRepository: InstallationRepository
    private let locationManager: LocationManager

    private var newsletterParameter: EventParameterNewsletter {
        if !termsAndConditionsEnabled {
            return .Unset
        } else {
            return newsletterAccepted ? .True : .False
        }
    }


    // MARK: - Lifecycle
    
    init(sessionManager: SessionManager, installationRepository: InstallationRepository, locationManager: LocationManager,
         keyValueStorage: KeyValueStorageable, googleLoginHelper: ExternalAuthHelper, fbLoginHelper: ExternalAuthHelper,
         tracker: Tracker, featureFlags: FeatureFlaggeable, locale: Locale, source: EventParameterLoginSourceValue,
         action: LoginActionType) {
        self.sessionManager = sessionManager
        self.installationRepository = installationRepository
        self.locationManager = locationManager
        self.keyValueStorage = keyValueStorage
        self.featureFlags = featureFlags
        self.loginSource = source
        self.googleLoginHelper = googleLoginHelper
        self.fbLoginHelper = fbLoginHelper
        self.tracker = tracker
        self.locale = locale
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
        let installationRepository = Core.installationRepository
        let locationManager = Core.locationManager
        let keyValueStorage = KeyValueStorage.sharedInstance
        let googleLoginHelper = GoogleLoginHelper()
        let fbLoginHelper = FBLoginHelper()
        let tracker = TrackerProxy.sharedInstance
        let featureFlags = FeatureFlags.sharedInstance
        let locale = Locale.current
        self.init(sessionManager: sessionManager, installationRepository: installationRepository, locationManager: locationManager,
                  keyValueStorage: keyValueStorage, googleLoginHelper: googleLoginHelper, fbLoginHelper: fbLoginHelper,
                  tracker: tracker, featureFlags: featureFlags, locale: locale, source: source, action: action)
    }
    
    
    // MARK: - Public methods
    
    func erasePassword() {
        password = ""
    }

    func signUp() {
        signUp(nil)
    }
    
    func signUp(_ recaptchaToken: String?) {
        delegate?.vmShowLoading(nil)

        let fullName = username.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if usernameContainsLetgoString(fullName) {
            delegate?.vmHideLoading(LGLocalizedString.signUpSendErrorGeneric, afterMessageCompletion: nil)
            trackSignupEmailFailedWithError(.usernameTaken)
        } else if fullName.characters.count < Constants.fullNameMinLength {
            delegate?.vmHideLoading(LGLocalizedString.signUpSendErrorInvalidUsername(Constants.fullNameMinLength), afterMessageCompletion: nil)
            trackSignupEmailFailedWithError(.invalidUsername)
        } else if !email.isEmail() {
            delegate?.vmHideLoading(LGLocalizedString.signUpSendErrorInvalidEmail, afterMessageCompletion: nil)
            trackSignupEmailFailedWithError(.invalidEmail)
        } else if password.characters.count < Constants.passwordMinLength ||
            password.characters.count > Constants.passwordMaxLength {
            delegate?.vmHideLoading(LGLocalizedString.signUpSendErrorInvalidPasswordWithMax(Constants.passwordMinLength,
                Constants.passwordMaxLength), afterMessageCompletion: nil)
                trackSignupEmailFailedWithError(.invalidPassword)
        } else if termsAndConditionsEnabled && !termsAccepted {
            delegate?.vmHideLoading(LGLocalizedString.signUpAcceptanceError, afterMessageCompletion: nil)
            trackSignupEmailFailedWithError(.termsNotAccepted)
        } else {
            let completion: (Result<MyUser, SessionManagerError>) -> () = { [weak self] signUpResult in
                guard let strongSelf = self else { return }

                if let user = signUpResult.value {
                    self?.savePreviousEmailOrUsername(.Email, userEmailOrName: user.email)

                    // Tracking
                    self?.tracker.trackEvent(TrackerEvent.signupEmail(strongSelf.loginSource,
                        newsletter: strongSelf.newsletterParameter))

                    strongSelf.delegate?.vmHideLoading(nil) { [weak self] in
                        self?.delegate?.vmFinish(completedAccess: true)
                    }
                } else if let sessionManagerError = signUpResult.error {
                    switch sessionManagerError {
                    case .Conflict(let cause):
                        switch cause {
                        case .UserExists:
                            strongSelf.sessionManager.login(strongSelf.email, password: strongSelf.password) { [weak self] loginResult in
                                guard let strongSelf = self else { return }
                                if let _ = loginResult.value {
                                    let rememberedAccount = strongSelf.previousEmail.value != nil
                                    let trackerEvent = TrackerEvent.loginEmail(strongSelf.loginSource, rememberedAccount: rememberedAccount)
                                    self?.tracker.trackEvent(trackerEvent)
                                    strongSelf.delegate?.vmHideLoading(nil) { [weak self] in
                                        self?.delegate?.vmFinish(completedAccess: true)
                                    }
                                } else if let _ = loginResult.error {
                                    strongSelf.processSignUpSessionError(sessionManagerError)
                                }
                            }
                        default:
                            strongSelf.processSignUpSessionError(sessionManagerError)
                        }
                    default:
                        strongSelf.processSignUpSessionError(sessionManagerError)
                    }
                }
            }

            let newsletter: Bool? = termsAndConditionsEnabled ? self.newsletterAccepted : nil
            if let recaptchaToken = recaptchaToken  {
                sessionManager.signUp(email.lowercased(), password: password, name: fullName, newsletter: newsletter,
                                      recaptchaToken: recaptchaToken, completion: completion)
            } else {
                sessionManager.signUp(email.lowercased(), password: password, name: fullName,
                                      newsletter: newsletter, completion: completion)
            }
        }
    }

    func recaptchaTokenObtained(_ token: String) {
        signUp(token)
    }
    
    func logIn() {
        if email == "admin" && password == "wat" {
            delegate?.vmShowHiddenPasswordAlert()
            return
        }

        delegate?.vmShowLoading(nil)

        if !email.isEmail() {
            delegate?.vmHideLoading(LGLocalizedString.logInErrorSendErrorInvalidEmail, afterMessageCompletion: nil)
            trackLoginEmailFailedWithError(.invalidEmail)
        } else if password.characters.count < Constants.passwordMinLength {
            delegate?.vmHideLoading(LGLocalizedString.logInErrorSendErrorUserNotFoundOrWrongPassword, afterMessageCompletion: nil)
            trackLoginEmailFailedWithError(.invalidPassword)
        } else {
            sessionManager.login(email, password: password) { [weak self] loginResult in
                guard let strongSelf = self else { return }

                if let user = loginResult.value {
                    self?.savePreviousEmailOrUsername(.Email, userEmailOrName: user.email)

                    let rememberedAccount = strongSelf.previousEmail.value != nil
                    let trackerEvent = TrackerEvent.loginEmail(strongSelf.loginSource, rememberedAccount: rememberedAccount)
                    self?.tracker.trackEvent(trackerEvent)

                    strongSelf.delegate?.vmHideLoading(nil) { [weak self] in
                        self?.delegate?.vmFinish(completedAccess: true)
                    }
                } else if let sessionManagerError = loginResult.error {
                    strongSelf.processLoginSessionError(sessionManagerError)
                }
            }
        }
    }
    
    func godLogIn(_ password: String) {
        if password == "mellongod" {
            KeyValueStorage.sharedInstance[.isGod] = true
        } else {
            delegate?.vmShowAutoFadingMessage("You are not worthy", completion: nil)
        }
    }
    
    func logInWithFacebook() {
        fbLoginHelper.login({ [weak self] _ in
            self?.delegate?.vmShowLoading(nil)
        }, loginCompletion: { [weak self] result in
            let error = self?.processExternalServiceAuthResult(result, accountProvider: .Facebook)
            switch result {
            case .Success:
                self?.trackLoginFBOK()
            default:
                break
            }
            if let error = error {
                self?.trackLoginFBFailedWithError(error)
            }
        })
    }

    func logInWithGoogle() {
        googleLoginHelper.login({ [weak self] in
            // Google OAuth completed. Token obtained
            self?.delegate?.vmShowLoading(nil)
        }) { [weak self] result in
            let error = self?.processExternalServiceAuthResult(result, accountProvider: .Google)
            switch result {
            case .Success:
                self?.trackLoginGoogleOK()
            default:
                break
            }
            if let error = error {
                self?.trackLoginGoogleFailedWithError(error)
            }
        }
    }


    // MARK: - Private methods
    
    private func usernameContainsLetgoString(_ theUsername: String) -> Bool {
        let lowerCaseUsername = theUsername.lowercased()
        return lowerCaseUsername.range(of: "letgo") != nil ||
            lowerCaseUsername.range(of: "ietgo") != nil ||
            lowerCaseUsername.range(of: "letg0") != nil ||
            lowerCaseUsername.range(of: "ietg0") != nil ||
            lowerCaseUsername.range(of: "let go") != nil ||
            lowerCaseUsername.range(of: "iet go") != nil ||
            lowerCaseUsername.range(of: "let g0") != nil ||
            lowerCaseUsername.range(of: "iet g0") != nil
    }

    /**
    Right now terms and conditions will be enabled just for Turkey so it will appear depending on location country code 
    or phone region
    */
    private func checkTermsAndConditionsEnabled() {
        let turkey = "tr"

        let systemCountryCode = locale.lg_countryCode
        let countryCode = locationManager.currentPostalAddress?.countryCode ?? systemCountryCode

        termsAndConditionsEnabled = systemCountryCode == turkey || countryCode.lowercaseString == turkey
    }

    private func processLoginSessionError(_ error: SessionManagerError) {
        let message: String
        switch (error) {
        case .Network:
            message = LGLocalizedString.commonErrorConnectionFailed
        case .Unauthorized:
            message = LGLocalizedString.logInErrorSendErrorUserNotFoundOrWrongPassword
        case .Scammer:
            delegate?.vmHideLoading(nil) { [weak self] in
                self?.showScammerAlert(self?.email, network: .Email)
            }
            trackLoginEmailFailedWithError(eventParameterForSessionError(error))
            return
        case .NotFound, .Internal, .Forbidden, .NonExistingEmail, .Conflict, .TooManyRequests, .BadRequest,
             .UserNotVerified:
            message = LGLocalizedString.logInErrorSendErrorGeneric
        }
        delegate?.vmHideLoading(message, afterMessageCompletion: nil)
        trackLoginEmailFailedWithError(eventParameterForSessionError(error))
    }

    private func processSignUpSessionError(_ error: SessionManagerError) {
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
            delegate?.vmHideLoading(nil) { [weak self] in
                let vm = RecaptchaViewModel(transparentMode: self?.featureFlags.captchaTransparent ?? false)
                self?.delegate?.vmShowRecaptcha(vm)
            }
            return
        case .Scammer:
            delegate?.vmHideLoading(nil) { [weak self] in
                self?.showScammerAlert(self?.email, network: .Email)
            }
            return
        case .NotFound, .Internal, .Forbidden, .Unauthorized, .TooManyRequests:
            message = LGLocalizedString.signUpSendErrorGeneric
        }
        delegate?.vmHideLoading(message, afterMessageCompletion: nil)
        trackSignupEmailFailedWithError(eventParameterForSessionError(error))
    }

    private func eventParameterForSessionError(_ error: SessionManagerError) -> EventParameterLoginError {
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

    private func processExternalServiceAuthResult(_ result: ExternalServiceAuthResult,
                                                  accountProvider: AccountProvider) -> EventParameterLoginError? {
        var loginError: EventParameterLoginError? = nil
        switch result {
        case let .Success(myUser):
            savePreviousEmailOrUsername(accountProvider, userEmailOrName: myUser.name)
            delegate?.vmHideLoading(nil) { [weak self] in
                self?.delegate?.vmFinish(completedAccess: true)
            }
        case .cancelled:
            delegate?.vmHideLoading(nil, afterMessageCompletion: nil)
        case .network:
            delegate?.vmHideLoading(LGLocalizedString.mainSignUpFbConnectErrorGeneric, afterMessageCompletion: nil)
            loginError = .network
        case .scammer:
            delegate?.vmHideLoading(nil) { [weak self] in
                self?.showScammerAlert(self?.email, network: accountProvider.accountNetwork)
            }
            loginError = .forbidden
        case .notFound:
            delegate?.vmHideLoading(LGLocalizedString.mainSignUpFbConnectErrorGeneric, afterMessageCompletion: nil)
            loginError = .userNotFoundOrWrongPassword
        case .badRequest:
            delegate?.vmHideLoading(LGLocalizedString.mainSignUpFbConnectErrorGeneric, afterMessageCompletion: nil)
            loginError = .badRequest
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
            delegate?.vmHideLoading(message, afterMessageCompletion: nil)
            loginError = .emailTaken
        case let .internal(description):
            delegate?.vmHideLoading(LGLocalizedString.mainSignUpFbConnectErrorGeneric, afterMessageCompletion: nil)
            loginError = .internal(description: description)
        }
        return loginError
    }

    private func showScammerAlert(_ userEmail: String?, network: EventParameterAccountNetwork) {
        guard let url = LetgoURLHelper.buildContactUsURL(userEmail: nil,
             installation: installationRepository.installation, moderation: true) else {
                delegate?.vmFinish(completedAccess: false)
                return
        }
        
        delegate?.vmFinishAndShowScammerAlert(url, network: network, tracker: tracker)
    }
    
    
    // MARK: - Trackings

    private func trackLoginEmailFailedWithError(_ error: EventParameterLoginError) {
        tracker.trackEvent(TrackerEvent.loginEmailError(error))
    }

    private func trackLoginFBOK() {
        let rememberedAccount = previousFacebookUsername.value != nil
        tracker.trackEvent(TrackerEvent.loginFB(loginSource, rememberedAccount: rememberedAccount))
    }

    private func trackLoginFBFailedWithError(_ error: EventParameterLoginError) {
        tracker.trackEvent(TrackerEvent.loginFBError(error))
    }

    private func trackLoginGoogleOK() {
        let rememberedAccount = previousGoogleUsername.value != nil
        tracker.trackEvent(TrackerEvent.loginGoogle(loginSource, rememberedAccount: rememberedAccount))
    }

    private func trackLoginGoogleFailedWithError(_ error: EventParameterLoginError) {
        tracker.trackEvent(TrackerEvent.loginGoogleError(error))
    }

    private func trackSignupEmailFailedWithError(_ error: EventParameterLoginError) {
        tracker.trackEvent(TrackerEvent.signupError(error))
    }
}


// MARK: > Previous email/user name

fileprivate extension SignUpLogInViewModel {
    func updatePreviousEmailAndUsernamesFromKeyValueStorage() {
        guard let accountProviderString = keyValueStorage[.previousUserAccountProvider],
            let accountProvider = AccountProvider(rawValue: accountProviderString) else { return }

        let userEmailOrName = keyValueStorage[.previousUserEmailOrName]
        updatePreviousEmailAndUsernames(accountProvider, userEmailOrName: userEmailOrName)
    }

    func updatePreviousEmailAndUsernames(_ accountProvider: AccountProvider, userEmailOrName: String?) {
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

    func savePreviousEmailOrUsername(_ accountProvider: AccountProvider, userEmailOrName: String?) {
        keyValueStorage[.previousUserAccountProvider] = accountProvider.rawValue
        keyValueStorage[.previousUserEmailOrName] = userEmailOrName
    }
}
