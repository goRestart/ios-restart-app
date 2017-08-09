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

enum LoginActionType: Int {
    case signup, login
}

struct SignUpFormErrors: OptionSet {
    let rawValue: Int
    
    static let invalidEmail     = SignUpFormErrors(rawValue: 1 << 0)
    static let shortPassword    = SignUpFormErrors(rawValue: 1 << 1)
    static let longPassword     = SignUpFormErrors(rawValue: 1 << 2)
    static let usernameTaken    = SignUpFormErrors(rawValue: 1 << 3)
    static let invalidUsername  = SignUpFormErrors(rawValue: 1 << 4)
    static let termsNotAccepted = SignUpFormErrors(rawValue: 1 << 5)
}

struct LogInEmailFormErrors: OptionSet {
    let rawValue: Int
    
    static let invalidEmail     = LogInEmailFormErrors(rawValue: 1 << 0)
    static let shortPassword    = LogInEmailFormErrors(rawValue: 1 << 1)
    static let longPassword     = LogInEmailFormErrors(rawValue: 1 << 2)
}

struct SignUpForm {
    var username: String = ""
    var email: String = ""
    var password: String = ""
    var errors: SignUpFormErrors = []
}

protocol SignUpLogInViewModelDelegate: BaseViewModelDelegate {
    func vmShowHiddenPasswordAlert()
}

class SignUpLogInViewModel: BaseViewModel {
    fileprivate static let unauthorizedErrorCountRememberPwd = 2

    let loginSource: EventParameterLoginSourceValue
    let googleLoginHelper: ExternalAuthHelper
    let fbLoginHelper: ExternalAuthHelper
    let tracker: Tracker
    let keyValueStorage: KeyValueStorageable
    let featureFlags: FeatureFlaggeable
    let locale: Locale

    weak var delegate: SignUpLogInViewModelDelegate?
    weak var navigator: SignUpLogInNavigator?
    
    // Action Type
    var currentActionType : LoginActionType
    
    // Input
    var username: Variable<String?>
    var termsAccepted: Bool
    var newsletterAccepted: Bool
    
    var email: Variable<String?>
    var suggestedEmail: Observable<String?> {
        return suggestedEmailVar.asObservable()
    }
    var password: Variable<String?>
    var sendButtonEnabled: Observable<Bool> {
        return sendButtonEnabledVar.asObservable()
    }

    var showPasswordVisible : Variable<Bool>

    var termsAndConditionsEnabled: Bool

    fileprivate var unauthorizedErrorCount: Int
    fileprivate let suggestedEmailVar: Variable<String?>
    fileprivate let previousEmail: Variable<String?>
    fileprivate var emailTrimmed: Variable<String?>
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

    fileprivate var termsAndConditionsURL: URL? {
        return LetgoURLHelper.buildTermsAndConditionsURL()
    }
    fileprivate var privacyURL: URL? {
        return LetgoURLHelper.buildPrivacyURL()
    }

    fileprivate let sessionManager: SessionManager
    private let installationRepository: InstallationRepository
    private let locationManager: LocationManager
    fileprivate let sendButtonEnabledVar: Variable<Bool>
    fileprivate let disposeBag: DisposeBag
    
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
         tracker: Tracker, featureFlags: FeatureFlaggeable, locale: Locale, source: EventParameterLoginSourceValue, action: LoginActionType) {
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
        self.username = Variable<String?>("")
        self.email = Variable<String?>("")
        self.emailTrimmed = Variable<String?>(nil)
        self.password = Variable<String?>("")
        self.termsAccepted = false
        self.newsletterAccepted = false
        self.currentActionType = action
        self.termsAndConditionsEnabled = false
        self.unauthorizedErrorCount = 0
        self.suggestedEmailVar = Variable<String?>(nil)
        self.previousEmail = Variable<String?>(nil)
        self.previousFacebookUsername = Variable<String?>(nil)
        self.previousGoogleUsername = Variable<String?>(nil)
        self.sendButtonEnabledVar = Variable<Bool>(false)
        self.showPasswordVisible = Variable<Bool>(false)
        self.disposeBag = DisposeBag()
        super.init()

        checkTermsAndConditionsEnabled()
        updatePreviousEmailAndUsernamesFromKeyValueStorage()

        if let previousEmail = previousEmail.value {
            self.email.value = previousEmail
        }
        
        setupRx()
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

    func cancel() {
        navigator?.cancelSignUpLogIn()
    }

    func openHelp() {
        navigator?.openHelpFromSignUpLogin()
    }

    func openRememberPassword() {
        navigator?.openRememberPasswordFromSignUpLogIn(email: emailTrimmed.value)
    }

    func open(url: URL) {
        navigator?.open(url: url)
    }

    func acceptSuggestedEmail() -> Bool {
        guard let suggestedEmail = suggestedEmailVar.value else { return false }
        email.value = suggestedEmail
        return true
    }

    func erasePassword() {
        password.value = ""
    }

    func signUp(_ recaptchaToken: String?) {
        let signUpForm = validateSignUpForm()
        if signUpForm.errors.isEmpty {
            sendSignUp(signUpForm, recaptchaToken: recaptchaToken)
        } else {
            delegate?.vmHideLoading(signUpForm.errors.errorMessage, afterMessageCompletion: nil)
            trackFormSignUpValidationFailed(errors: signUpForm.errors)
        }
    }
    
    func validateSignUpForm() -> SignUpForm {
        var signUpForm = SignUpForm()

        guard sendButtonEnabledVar.value else { return signUpForm }
        
        guard let username = username.value else {
            signUpForm.errors.insert(.invalidUsername)
            return signUpForm
        }
        guard let emailTrimmed = emailTrimmed.value else {
            signUpForm.errors.insert(.invalidEmail)
            return signUpForm
        }
        guard let password = password.value else {
            signUpForm.errors.insert(.shortPassword)
            return signUpForm
        }
        
        let trimmedUsername = username.trim
        if trimmedUsername.containsLetgo() {
            signUpForm.errors.insert(.usernameTaken)
        } else if trimmedUsername.characters.count < Constants.fullNameMinLength {
            signUpForm.errors.insert(.invalidUsername)
        } else {
            signUpForm.username = trimmedUsername
        }
        
        if !emailTrimmed.isEmail() {
            signUpForm.errors.insert(.invalidEmail)
        } else {
            signUpForm.email = emailTrimmed
        }
        
        if password.characters.count < Constants.passwordMinLength {
            signUpForm.errors.insert(.shortPassword)
        } else if password.characters.count > Constants.passwordMaxLength {
            signUpForm.errors.insert(.longPassword)
        } else {
            signUpForm.password = password
        }
        
        if termsAndConditionsEnabled && !termsAccepted {
            signUpForm.errors.insert(.termsNotAccepted)
        }
        
        return signUpForm
    }
    
    func sendSignUp(_ signUpForm: SignUpForm, recaptchaToken: String?) {
        delegate?.vmShowLoading(nil)

        let completion: (Result<MyUser, SignupError>) -> () = { [weak self] signUpResult in
            guard let strongSelf = self else { return }
            
            if let user = signUpResult.value {
                self?.savePreviousEmailOrUsername(.email, userEmailOrName: user.email)
                
                // Tracking
                self?.tracker.trackEvent(
                    TrackerEvent.signupEmail(strongSelf.loginSource, newsletter: strongSelf.newsletterParameter))
                
                strongSelf.delegate?.vmHideLoading(nil) { [weak self] in
                    self?.navigator?.closeSignUpLogInSuccessful(with: user)
                }
            } else if let signUpError = signUpResult.error {
                if signUpError.isUserExists {
                    strongSelf.sessionManager.login(signUpForm.email, password: signUpForm.password) { [weak self] loginResult in
                        guard let strongSelf = self else { return }
                        if let myUser = loginResult.value {
                            let rememberedAccount = strongSelf.previousEmail.value != nil
                            let trackerEvent = TrackerEvent.loginEmail(strongSelf.loginSource,
                                                                       rememberedAccount: rememberedAccount)
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
        let trimmedUsername = signUpForm.username.trim
        if let recaptchaToken = recaptchaToken {
            sessionManager.signUp(signUpForm.email.lowercased(), password: signUpForm.password, name: trimmedUsername, newsletter: newsletter,
                                      recaptchaToken: recaptchaToken, completion: completion)
        } else {
            sessionManager.signUp(signUpForm.email.lowercased(), password: signUpForm.password, name: trimmedUsername,
                                      newsletter: newsletter, completion: completion)
        }
    }
    
    func logIn() {
        let errors = validateLogInForm()
        if errors.isEmpty {
            
            sendLogIn()
        }
    }
    
    func validateLogInForm() -> LogInEmailFormErrors {
        var errors: LogInEmailFormErrors = []
        guard sendButtonEnabledVar.value else { return errors }
        
        if emailTrimmed.value == "admin" && password.value == "wat" {
            delegate?.vmShowHiddenPasswordAlert()
            return errors
        }
        
        delegate?.vmShowLoading(nil)
        
        // Form validation
        if let emailTrimmed = emailTrimmed.value {
            if !emailTrimmed.isEmail() {
                errors.insert(.invalidEmail)
            }
        } else {
            errors.insert(.invalidEmail)
        }
        if let password = password.value {
            if password.characters.count < Constants.passwordMinLength {
                errors.insert(.shortPassword)
            } else if password.characters.count > Constants.passwordMaxLength {
                errors.insert(.longPassword)
            }
        } else {
            errors.insert(.shortPassword)
        }
        
        if !errors.isEmpty {
            delegate?.vmHideLoading(errors.errorMessage, afterMessageCompletion: nil)
            trackFormLogInValidationFailed(errors: errors)
        }
        
        return errors
    }
    
    func sendLogIn() {
        if let emailTrimmed = emailTrimmed.value, let password = password.value {
            sessionManager.login(emailTrimmed, password: password) { [weak self] loginResult in
                guard let strongSelf = self else { return }
                
                if let user = loginResult.value {
                    self?.savePreviousEmailOrUsername(.email, userEmailOrName: user.email)
                    
                    let rememberedAccount = strongSelf.previousEmail.value != nil
                    let trackerEvent = TrackerEvent.loginEmail(strongSelf.loginSource, rememberedAccount: rememberedAccount)
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
            keyValueStorage[.isGod] = true
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
    // MARK: > Rx
    
    fileprivate func setupRx() {
        // Send is enabled when email & password are not empty
        Observable.combineLatest(email.asObservable(), password.asObservable(), username.asObservable()) { [weak self] (email, password, username) -> Bool in
            guard let strongSelf = self else { return false }
            guard let email = email, let password = password else { return false }
            switch strongSelf.currentActionType {
            case .login:
                return email.characters.count > 0 && password.characters.count > 0
            case .signup:
                guard let username = username else { return false }
                return email.characters.count > 0 && password.characters.count > 0 && username.characters.count > 0
            }
        }.bindTo(sendButtonEnabledVar).addDisposableTo(disposeBag)
        
        // Email trim
        email.asObservable()
            .map { $0?.trim }
            .bindTo(emailTrimmed)
            .addDisposableTo(disposeBag)
        
        // Email auto suggest
        emailTrimmed.asObservable()
            .map { $0?.suggestEmail(domains: Constants.emailSuggestedDomains) }
            .bindTo(suggestedEmailVar)
            .addDisposableTo(disposeBag)
    }

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
                self?.showScammerAlert(self?.emailTrimmed.value, network: .email)
            }
        case .deviceNotAllowed:
            afterMessageCompletion = { [weak self] in
                self?.showDeviceNotAllowedAlert(self?.emailTrimmed.value, network: .email)
            }
        case .unauthorized:
            unauthorizedErrorCount = unauthorizedErrorCount + 1
            if unauthorizedErrorCount >= SignUpLogInViewModel.unauthorizedErrorCountRememberPwd {
                afterMessageCompletion = { [weak self] in
                    self?.showRememberPasswordAlert()
                }
            }
        case .network, .badRequest, .notFound, .forbidden, .conflict, .tooManyRequests, .userNotVerified, .internalError:
            break
        }

        delegate?.vmHideLoading(error.errorMessage, afterMessageCompletion: afterMessageCompletion)
    }

    private func process(signupError: SignupError) {
        
        switch signupError {
        case .scammer:
            trackSignupEmailFailedWithError(signupError.trackingError)
            delegate?.vmHideLoading(nil) { [weak self] in
                self?.showScammerAlert(self?.emailTrimmed.value, network: .email)
            }
        case .userNotVerified:
            delegate?.vmHideLoading(nil) { [weak self] in
                self?.navigator?.openRecaptcha(transparentMode: self?.featureFlags.captchaTransparent ?? false)
            }
        case .network, .badRequest, .notFound, .forbidden, .unauthorized, .conflict, .nonExistingEmail,
             .tooManyRequests, .internalError:
            trackSignupEmailFailedWithError(signupError.trackingError)
            let message = signupError.errorMessage(userEmail: emailTrimmed.value)
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
                self?.showScammerAlert(self?.emailTrimmed.value, network: accountProvider.accountNetwork)
            }
        case .deviceNotAllowed:
            delegate?.vmHideLoading(nil) { [weak self] in
                self?.showDeviceNotAllowedAlert(self?.emailTrimmed.value, network: accountProvider.accountNetwork)
            }
        case .cancelled, .network, .notFound, .conflict, .badRequest, .internalError, .loginError:
            delegate?.vmHideLoading(result.errorMessage, afterMessageCompletion: nil)
        }
    }

    private func showScammerAlert(_ userEmail: String?, network: EventParameterAccountNetwork) {
        guard let contactURL = LetgoURLHelper.buildContactUsURL(userEmail: userEmail,
                                                                installation: installationRepository.installation,
                                                                listing: nil,
                                                                type: .scammer) else {
            navigator?.cancelSignUpLogIn()
            return
        }
        navigator?.closeSignUpLogInAndOpenScammerAlert(contactURL: contactURL, network: network)
    }

    private func showDeviceNotAllowedAlert(_ userEmail: String?, network: EventParameterAccountNetwork) {
        guard let contactURL = LetgoURLHelper.buildContactUsURL(userEmail: userEmail,
                                                                installation: installationRepository.installation,
                                                                listing: nil,
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

    fileprivate func trackPasswordRecoverFailed(error: RecoverPasswordError) {
        let event = TrackerEvent.passwordResetError(error.trackingError)
        tracker.trackEvent(event)
    }
    
    func trackFormLogInValidationFailed(errors: LogInEmailFormErrors) {
        guard let trackingError = errors.trackingError else { return }
        let event = TrackerEvent.loginEmailError(trackingError)
        tracker.trackEvent(event)
    }
    
    func trackFormSignUpValidationFailed(errors: SignUpFormErrors) {
        guard let trackingError = errors.trackingError else { return }
        let event = TrackerEvent.signupError(trackingError)
        tracker.trackEvent(event)
    }
}

fileprivate extension LogInEmailFormErrors {
    var trackingError: EventParameterLoginError? {
        let error: EventParameterLoginError?
        if contains(.invalidEmail) {
            error = .invalidEmail
        } else if contains(.shortPassword) || contains(.longPassword) {
            error = .invalidPassword
        } else {
            error = nil
        }
        return error
    }
    
    var errorMessage: String? {
        let message: String?
        if contains(.invalidEmail) {
            message = LGLocalizedString.logInErrorSendErrorInvalidEmail
        } else if contains(.shortPassword) || contains(.longPassword) {
            message = LGLocalizedString.logInErrorSendErrorUserNotFoundOrWrongPassword
        } else {
            message = nil
        }
        return message
    }
}

fileprivate extension SignUpFormErrors {
    var trackingError: EventParameterLoginError? {
        let error: EventParameterLoginError?
        if contains(.invalidEmail) {
            error = .invalidEmail
        } else if contains(.shortPassword) || contains(.longPassword) {
            error = .invalidPassword
        } else if contains(.usernameTaken) {
            error = .usernameTaken
        } else if contains(.invalidUsername) {
            error = .invalidUsername
        } else if contains(.termsNotAccepted) {
            error = .termsNotAccepted
        } else {
            error = nil
        }
        return error
    }
    
    var errorMessage: String? {
        let message: String?
        if contains(.invalidEmail) {
            message = LGLocalizedString.signUpSendErrorInvalidEmail
        } else if contains(.shortPassword) || contains(.longPassword) {
            message = LGLocalizedString.signUpSendErrorInvalidPasswordWithMax(Constants.passwordMinLength,
                                                                             Constants.passwordMaxLength)
        } else if contains(.usernameTaken) {
            message = LGLocalizedString.signUpSendErrorGeneric
        } else if contains(.invalidUsername) {
            message = LGLocalizedString.signUpSendErrorInvalidUsername(Constants.fullNameMinLength)
        } else if contains(.termsNotAccepted) {
            message = LGLocalizedString.signUpAcceptanceError
        } else {
            message = nil
        }
        return message
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


// MARK: > Recover password

fileprivate extension SignUpLogInViewModel {
    func showRememberPasswordAlert() {
        let title = LGLocalizedString.logInEmailForgotPasswordAlertTitle
        var message = ""
        if let emailTrimmed = emailTrimmed.value {
            message = LGLocalizedString.logInEmailForgotPasswordAlertMessage(emailTrimmed)
        }
        let cancelAction = UIAction(interface: .styledText(LGLocalizedString.logInEmailForgotPasswordAlertCancelAction, .cancel),
                                    action: {})
        let recoverPasswordAction = UIAction(interface: .styledText(LGLocalizedString.logInEmailForgotPasswordAlertRememberAction, .destructive),
                                             action: { [weak self] in
                                                guard let emailTrimmed = self?.emailTrimmed else { return }
                                                if let emailTrimmed = emailTrimmed.value {
                                                    self?.recoverPassword(email: emailTrimmed)
                                                }
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
        if let emailTrimmed = emailTrimmed.value {
            let message = LGLocalizedString.resetPasswordSendOk(emailTrimmed)
            delegate?.vmHideLoading(message, afterMessageCompletion: nil)
        }
    }

    func recoverPasswordFailed(error: RecoverPasswordError) {
        trackPasswordRecoverFailed(error: error)

        var message: String? = nil
        switch error {
        case .network:
            message = LGLocalizedString.commonErrorConnectionFailed
        case .notFound:
            if let emailTrimmed = emailTrimmed.value {
                message = LGLocalizedString.resetPasswordSendErrorUserNotFoundOrWrongPassword(emailTrimmed)
            }
        case .conflict, .tooManyRequests:
            message = LGLocalizedString.resetPasswordSendTooManyRequests
        case .badRequest, .scammer, .internalError, .userNotVerified, .forbidden, .unauthorized, .nonExistingEmail:
            message = LGLocalizedString.resetPasswordSendErrorGeneric
        }
        delegate?.vmHideLoading(message, afterMessageCompletion: nil)
    }
}
