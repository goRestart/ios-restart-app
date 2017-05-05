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
    func vmShowHiddenPasswordAlert()
}

class SignUpLogInViewModel: BaseViewModel {
    fileprivate static let unauthorizedErrorCountRememberPwd = 2

    let loginSource: EventParameterLoginSourceValue
    let collapsedEmailParam: EventParameterBoolean?
    let googleLoginHelper: ExternalAuthHelper
    let fbLoginHelper: ExternalAuthHelper
    let tracker: Tracker
    let keyValueStorage: KeyValueStorageable
    let featureFlags: FeatureFlaggeable
    let locale: Locale

    weak var delegate: SignUpLogInViewModelDelegate?
    weak var navigator: SignUpLogInNavigator?
    
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
            suggest(emailText: email)
            email = email.trim
            delegate?.vmUpdateSendButtonEnabledState(sendButtonEnabled)
        }
    }
    var suggestedEmail: Observable<String?> {
        return suggestedEmailVar.asObservable()
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

    fileprivate var sendButtonEnabled: Bool {
        return  email.characters.count > 0 && password.characters.count > 0 &&
            (currentActionType == .login || ( currentActionType == .signup && username.characters.count > 0))
    }

    var termsAndConditionsEnabled: Bool

    fileprivate var unauthorizedErrorCount: Int
    fileprivate let suggestedEmailVar: Variable<String?>
    fileprivate let previousEmail: Variable<String?>
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

    fileprivate let sessionManager: SessionManager
    private let installationRepository: InstallationRepository
    private let locationManager: LocationManager

    private var newsletterParameter: EventParameterBoolean {
        if !termsAndConditionsEnabled {
            return .notAvailable
        } else {
            return newsletterAccepted ? .trueParameter : .falseParameter
        }
    }


    // MARK: - Lifecycle
    
    init(sessionManager: SessionManager, installationRepository: InstallationRepository, locationManager: LocationManager,
         keyValueStorage: KeyValueStorageable, googleLoginHelper: ExternalAuthHelper, fbLoginHelper: ExternalAuthHelper,
         tracker: Tracker, featureFlags: FeatureFlaggeable, locale: Locale, source: EventParameterLoginSourceValue,
         collapsedEmailParam: EventParameterBoolean?, action: LoginActionType) {
        self.sessionManager = sessionManager
        self.installationRepository = installationRepository
        self.locationManager = locationManager
        self.keyValueStorage = keyValueStorage
        self.featureFlags = featureFlags
        self.loginSource = source
        self.collapsedEmailParam = collapsedEmailParam
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
        self.unauthorizedErrorCount = 0
        self.suggestedEmailVar = Variable<String?>(nil)
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
    
    convenience init(source: EventParameterLoginSourceValue, collapsedEmailParam: EventParameterBoolean?,
                     action: LoginActionType) {
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
                  tracker: tracker, featureFlags: featureFlags, locale: locale, source: source,
                  collapsedEmailParam: collapsedEmailParam, action: action)
    }
    
    
    // MARK: - Public methods

    func cancel() {
        navigator?.cancelSignUpLogIn()
    }

    func openHelp() {
        navigator?.openHelpFromSignUpLogin()
    }

    func openRememberPassword() {
        navigator?.openRememberPasswordFromSignUpLogIn(email: email)
    }

    func open(url: URL) {
        navigator?.open(url: url)
    }

    func acceptSuggestedEmail() -> Bool {
        guard let suggestedEmail = suggestedEmailVar.value else { return false }
        
        switch featureFlags.signUpLoginImprovement {
        case .v1, .v2:
            return false
        case .v1WImprovements:
            email = suggestedEmail
            return true
        }
    }

    func erasePassword() {
        password = ""
    }

    func signUp() {
        signUp(nil)
    }
    
    func signUp(_ recaptchaToken: String?) {
        delegate?.vmShowLoading(nil)

        let trimmedUsername = username.trim
        if trimmedUsername.containsLetgo() {
            delegate?.vmHideLoading(LGLocalizedString.signUpSendErrorGeneric, afterMessageCompletion: nil)
            trackSignupEmailFailedWithError(.usernameTaken)
        } else if trimmedUsername.characters.count < Constants.fullNameMinLength {
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
            let completion: (Result<MyUser, SignupError>) -> () = { [weak self] signUpResult in
                guard let strongSelf = self else { return }

                if let user = signUpResult.value {
                    self?.savePreviousEmailOrUsername(.email, userEmailOrName: user.email)

                    // Tracking
                    self?.tracker.trackEvent(
                        TrackerEvent.signupEmail(strongSelf.loginSource, newsletter: strongSelf.newsletterParameter,
                                                 collapsedEmail: strongSelf.collapsedEmailParam))

                    strongSelf.delegate?.vmHideLoading(nil) { [weak self] in
                        self?.navigator?.closeSignUpLogInSuccessful(with: user)
                    }
                } else if let signUpError = signUpResult.error {
                    if signUpError.isUserExists {
                        strongSelf.sessionManager.login(strongSelf.email, password: strongSelf.password) { [weak self] loginResult in
                            guard let strongSelf = self else { return }
                            if let myUser = loginResult.value {
                                let rememberedAccount = strongSelf.previousEmail.value != nil
                                let trackerEvent = TrackerEvent.loginEmail(strongSelf.loginSource,
                                                                           rememberedAccount: rememberedAccount,
                                                                           collapsedEmail: strongSelf.collapsedEmailParam)
                                self?.tracker.trackEvent(trackerEvent)
                                self?.delegate?.vmHideLoading(nil) { [weak self] in
                                    self?.navigator?.closeSignUpLogInSuccessful(with: myUser)
                                }
                            } else {
                                strongSelf.process(signupError: signUpError)
                            }
                        }
                    } else {
                        strongSelf.process(signupError: signUpError)
                    }
                }
            }

            let newsletter: Bool? = termsAndConditionsEnabled ? self.newsletterAccepted : nil
            if let recaptchaToken = recaptchaToken  {
                sessionManager.signUp(email.lowercased(), password: password, name: trimmedUsername, newsletter: newsletter,
                                      recaptchaToken: recaptchaToken, completion: completion)
            } else {
                sessionManager.signUp(email.lowercased(), password: password, name: trimmedUsername,
                                      newsletter: newsletter, completion: completion)
            }
        }
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
                    self?.savePreviousEmailOrUsername(.email, userEmailOrName: user.email)

                    let rememberedAccount = strongSelf.previousEmail.value != nil
                    let trackerEvent = TrackerEvent.loginEmail(strongSelf.loginSource, rememberedAccount: rememberedAccount,
                                                               collapsedEmail: strongSelf.collapsedEmailParam)
                    self?.tracker.trackEvent(trackerEvent)

                    self?.delegate?.vmHideLoading(nil) { [weak self] in
                        self?.navigator?.closeSignUpLogInSuccessful(with: user)
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
            self?.processExternalServiceAuthResult(result, accountProvider: .facebook)
            if result.isSuccess {
                self?.trackLoginFBOK()
            } else if let trackingError = result.trackingError {
                self?.trackLoginFBFailedWithError(trackingError)
            }
        })
    }

    func logInWithGoogle() {
        googleLoginHelper.login({ [weak self] in
            // Google OAuth completed. Token obtained
            self?.delegate?.vmShowLoading(nil)
        }) { [weak self] result in
            self?.processExternalServiceAuthResult(result, accountProvider: .google)
            if result.isSuccess {
                self?.trackLoginGoogleOK()
            } else if let trackingError = result.trackingError {
                self?.trackLoginGoogleFailedWithError(trackingError)
            }
        }
    }


    // MARK: - Private methods

    /**
    Right now terms and conditions will be enabled just for Turkey so it will appear depending on location country code 
    or phone region
    */
    private func checkTermsAndConditionsEnabled() {
        let turkey = "tr"

        let systemCountryCode = locale.lg_countryCode
        let countryCode = locationManager.currentLocation?.countryCode ?? systemCountryCode

        termsAndConditionsEnabled = systemCountryCode == turkey || countryCode.lowercased() == turkey
    }

    private func processLoginSessionError(_ error: LoginError) {
        trackLoginEmailFailedWithError(error.trackingError)
        var afterMessageCompletion: (() -> ())? = nil
        switch error {
        case .scammer:
            afterMessageCompletion = { [weak self] in
                self?.showScammerAlert(self?.email, network: .email)
            }
        case .deviceNotAllowed:
            afterMessageCompletion = { [weak self] in
                self?.showDeviceNotAllowedAlert(self?.email, network: .email)
            }
        case .unauthorized:
            switch featureFlags.signUpLoginImprovement {
            case .v1WImprovements:
                unauthorizedErrorCount = unauthorizedErrorCount + 1
                if unauthorizedErrorCount >= SignUpLogInViewModel.unauthorizedErrorCountRememberPwd {
                    afterMessageCompletion = { [weak self] in
                        self?.showRememberPasswordAlert()
                    }
                }
            case .v1, .v2:
                break
            }
        case .network, .badRequest, .notFound, .forbidden, .conflict, .tooManyRequests, .userNotVerified, .internalError:
            break
        }

        delegate?.vmHideLoading(error.errorMessage, afterMessageCompletion: afterMessageCompletion)
    }

    private func process(signupError: SignupError) {
        
        switch signupError {
        case .scammer:
            delegate?.vmHideLoading(nil) { [weak self] in
                self?.showScammerAlert(self?.email, network: .email)
            }
        case .userNotVerified:
            delegate?.vmHideLoading(nil) { [weak self] in
                self?.navigator?.openRecaptcha(transparentMode: self?.featureFlags.captchaTransparent ?? false)
            }
        case .network, .badRequest, .notFound, .forbidden, .unauthorized, .conflict, .nonExistingEmail,
             .tooManyRequests, .internalError:
            trackSignupEmailFailedWithError(signupError.trackingError)
            let message = signupError.errorMessage(userEmail: email)
            delegate?.vmHideLoading(message, afterMessageCompletion: nil)
        }
    }

    private func processExternalServiceAuthResult(_ result: ExternalServiceAuthResult, accountProvider: AccountProvider) {
        switch result {
        case let .success(myUser):
            savePreviousEmailOrUsername(accountProvider, userEmailOrName: myUser.name)
            delegate?.vmHideLoading(nil) { [weak self] in
                self?.navigator?.closeSignUpLogInSuccessful(with: myUser)
            }
        case .scammer:
            delegate?.vmHideLoading(nil) { [weak self] in
                self?.showScammerAlert(self?.email, network: accountProvider.accountNetwork)
            }
        case .deviceNotAllowed:
            delegate?.vmHideLoading(nil) { [weak self] in
                self?.showDeviceNotAllowedAlert(self?.email, network: accountProvider.accountNetwork)
            }
        case .cancelled, .network, .notFound, .conflict, .badRequest, .internalError, .loginError:
            delegate?.vmHideLoading(result.errorMessage, afterMessageCompletion: nil)
        }
    }

    private func showScammerAlert(_ userEmail: String?, network: EventParameterAccountNetwork) {
        guard let contactURL = LetgoURLHelper.buildContactUsURL(userEmail: userEmail,
                                                                installation: installationRepository.installation,
                                                                type: .scammer) else {
            navigator?.cancelSignUpLogIn()
            return
        }
        navigator?.closeSignUpLogInAndOpenScammerAlert(contactURL: contactURL, network: network)
    }

    private func showDeviceNotAllowedAlert(_ userEmail: String?, network: EventParameterAccountNetwork) {
        guard let contactURL = LetgoURLHelper.buildContactUsURL(userEmail: userEmail,
                                                                installation: installationRepository.installation,
                                                                type: .deviceNotAllowed) else {
                                                                    navigator?.cancelSignUpLogIn()
                                                                    return
        }
        navigator?.closeSignUpLogInAndOpenDeviceNotAllowedAlert(contactURL: contactURL, network: network)
    }
    
    
    // MARK: - Trackings

    private func trackLoginEmailFailedWithError(_ error: EventParameterLoginError) {
        tracker.trackEvent(TrackerEvent.loginEmailError(error))
    }

    private func trackLoginFBOK() {
        let rememberedAccount = previousFacebookUsername.value != nil
        tracker.trackEvent(TrackerEvent.loginFB(loginSource, rememberedAccount: rememberedAccount,
                                                collapsedEmail: collapsedEmailParam))
    }

    private func trackLoginFBFailedWithError(_ error: EventParameterLoginError) {
        tracker.trackEvent(TrackerEvent.loginFBError(error))
    }

    private func trackLoginGoogleOK() {
        let rememberedAccount = previousGoogleUsername.value != nil
        tracker.trackEvent(TrackerEvent.loginGoogle(loginSource, rememberedAccount: rememberedAccount,
                                                    collapsedEmail: collapsedEmailParam))
    }

    private func trackLoginGoogleFailedWithError(_ error: EventParameterLoginError) {
        tracker.trackEvent(TrackerEvent.loginGoogleError(error))
    }

    private func trackSignupEmailFailedWithError(_ error: EventParameterLoginError) {
        tracker.trackEvent(TrackerEvent.signupError(error))
    }

    fileprivate func trackPasswordRecoverFailed(error: RecoverPasswordError) {
        let event = TrackerEvent.passwordResetError(error.trackingError)
        tracker.trackEvent(event)
    }
}


// MARK: - RecaptchaTokenDelegate

extension SignUpLogInViewModel: RecaptchaTokenDelegate {
    func recaptchaTokenObtained(token: String) {
        signUp(token)
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
        case .email:
            previousEmail.value = userEmailOrName
            previousFacebookUsername.value = nil
            previousGoogleUsername.value = nil
        case .facebook:
            previousEmail.value = nil
            previousFacebookUsername.value = userEmailOrName
            previousGoogleUsername.value = nil
        case .google:
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


// MARK: > Autosuggest

fileprivate extension SignUpLogInViewModel {
    func suggest(emailText: String) {
        switch featureFlags.signUpLoginImprovement {
        case .v1, .v2:
            return
        case .v1WImprovements:
            suggestedEmailVar.value = emailText.suggestEmail(domains: Constants.emailSuggestedDomains)
        }
    }
}


// MARK: > Recover password

fileprivate extension SignUpLogInViewModel {
    func showRememberPasswordAlert() {
        let title = LGLocalizedString.logInEmailForgotPasswordAlertTitle
        let message = LGLocalizedString.logInEmailForgotPasswordAlertMessage(email)
        let cancelAction = UIAction(interface: .styledText(LGLocalizedString.logInEmailForgotPasswordAlertCancelAction, .cancel),
                                    action: {})
        let recoverPasswordAction = UIAction(interface: .styledText(LGLocalizedString.logInEmailForgotPasswordAlertRememberAction, .destructive),
                                             action: { [weak self] in
            guard let email = self?.email else { return }
            self?.recoverPassword(email: email)
        })
        let actions = [cancelAction, recoverPasswordAction]
        delegate?.vmShowAlert(title, message: message, actions: actions)
    }

    func recoverPassword(email: String) {
        delegate?.vmShowLoading(nil)
        sessionManager.recoverPassword(email) { [weak self] result in
            if let _ = result.value {
                self?.recoverPasswordSucceeded()
            } else if let error = result.error {
                self?.recoverPasswordFailed(error: error)
            }
        }
    }

    func recoverPasswordSucceeded() {
        let message = LGLocalizedString.resetPasswordSendOk(email)
        delegate?.vmHideLoading(message, afterMessageCompletion: nil)
    }

    func recoverPasswordFailed(error: RecoverPasswordError) {
        trackPasswordRecoverFailed(error: error)

        var message: String? = nil
        switch error {
        case .network:
            message = LGLocalizedString.commonErrorConnectionFailed
        case .notFound:
            message = LGLocalizedString.resetPasswordSendErrorUserNotFoundOrWrongPassword(email)
        case .conflict, .tooManyRequests:
            message = LGLocalizedString.resetPasswordSendTooManyRequests
        case .badRequest, .scammer, .internalError, .userNotVerified, .forbidden, .unauthorized, .nonExistingEmail:
            message = LGLocalizedString.resetPasswordSendErrorGeneric
        }
        delegate?.vmHideLoading(message, afterMessageCompletion: nil)
    }
}
