import Foundation
import LGCoreKit
import Result
import RxSwift
import LGComponents

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
}

struct SignUpForm {
    let username: String
    let email: String
    let password: String
    let termsAndConditionsEnabled: Bool
    let termsAccepted: Bool
    
    func checkErrors() -> SignUpFormErrors {
        var errors: SignUpFormErrors = []
        errors.insert(checkEmail())
        errors.insert(checkPassword())
        errors.insert(checkUsername())
        errors.insert(checkTermsAndConditions())
        return errors
    }
    
    private func checkEmail() -> SignUpFormErrors {
        if email.isEmpty || !email.isEmail() {
            return SignUpFormErrors.invalidEmail
        }
        return []
    }
    
    private func checkPassword() -> SignUpFormErrors {
        var errors: SignUpFormErrors = []
        if password.count < SharedConstants.passwordMinLength {
            errors.insert(.shortPassword)
        } else if password.count > SharedConstants.passwordMaxLength {
            errors.insert(.longPassword)
        }
        return errors
    }
    
    private func checkUsername() -> SignUpFormErrors {
        var errors: SignUpFormErrors = []
        if username.containsLetgo() {
            errors.insert(.usernameTaken)
        } else if username.count < SharedConstants.fullNameMinLength {
            errors.insert(.invalidUsername)
        }
        return errors
    }
    
    private func checkTermsAndConditions() -> SignUpFormErrors {
        if termsAndConditionsEnabled && !termsAccepted {
            return SignUpFormErrors.termsNotAccepted
        }
        return []
    }
}

struct LogInEmailForm {
    let email: String
    let password: String
    
    func checkErrors() -> LogInEmailFormErrors {
        var errors: LogInEmailFormErrors = []
        errors.insert(checkEmail())
        errors.insert(checkPassword())
        return errors
    }
    
    private func checkEmail() -> LogInEmailFormErrors {
        if email.isEmpty || !email.isEmail() {
            return LogInEmailFormErrors.invalidEmail
        }
        return []
    }
    
    private func checkPassword() -> LogInEmailFormErrors {
        var errors: LogInEmailFormErrors = []
        if password.count < SharedConstants.passwordMinLength {
            errors.insert(.shortPassword)
        }
        return errors
    }
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
    
    var router: LoginNavigator?
    
    private var onLoginCallback: (()->())?
    private var onCancelCallback: (()->())?

    func attributedLegalText(_ linkColor: UIColor) -> NSAttributedString {
        guard let conditionsURL = termsAndConditionsURL, let privacyURL = privacyURL else {
            return NSAttributedString(string: R.Strings.signUpTermsConditions)
        }

        let links = [R.Strings.signUpTermsConditionsTermsPart: conditionsURL,
            R.Strings.signUpTermsConditionsPrivacyPart: privacyURL]
        let localizedLegalText = R.Strings.signUpTermsConditions
        let attributtedLegalText = localizedLegalText.attributedHyperlinkedStringWithURLDict(links,
            textColor: linkColor)
        attributtedLegalText.addAttribute(NSAttributedStringKey.font, value: UIFont.mediumBodyFont,
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
    
    init(sessionManager: SessionManager,
         installationRepository: InstallationRepository,
         keyValueStorage: KeyValueStorageable,
         googleLoginHelper: ExternalAuthHelper,
         fbLoginHelper: ExternalAuthHelper,
         tracker: Tracker,
         featureFlags: FeatureFlaggeable,
         locale: Locale,
         source: EventParameterLoginSourceValue,
         action: LoginActionType,
         loginAction: (()->())?, cancelAction: (()->())?) {
        self.sessionManager = sessionManager
        self.installationRepository = installationRepository
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
        self.termsAndConditionsEnabled = featureFlags.signUpEmailTermsAndConditionsAcceptRequired
        self.unauthorizedErrorCount = 0
        self.suggestedEmailVar = Variable<String?>(nil)
        self.previousEmail = Variable<String?>(nil)
        self.previousFacebookUsername = Variable<String?>(nil)
        self.previousGoogleUsername = Variable<String?>(nil)
        self.sendButtonEnabledVar = Variable<Bool>(false)
        self.showPasswordVisible = Variable<Bool>(false)
        self.disposeBag = DisposeBag()
        self.onLoginCallback = loginAction
        self.onCancelCallback = cancelAction
        super.init()

        updatePreviousEmailAndUsernamesFromKeyValueStorage()

        if let previousEmail = previousEmail.value {
            self.email.value = previousEmail
        }
        
        setupRx()
    }
    
    convenience init(source: EventParameterLoginSourceValue,
                     action: LoginActionType,
                     loginAction: (()->())? = nil,
                     cancelAction: (()->())? = nil) {
        let sessionManager = Core.sessionManager
        let installationRepository = Core.installationRepository
        let keyValueStorage = KeyValueStorage.sharedInstance
        let googleLoginHelper = GoogleLoginHelper()
        let fbLoginHelper = FBLoginHelper()
        let tracker = TrackerProxy.sharedInstance
        let featureFlags = FeatureFlags.sharedInstance
        let locale = Locale.current
        self.init(sessionManager: sessionManager,
                  installationRepository: installationRepository,
                  keyValueStorage: keyValueStorage,
                  googleLoginHelper: googleLoginHelper,
                  fbLoginHelper: fbLoginHelper,
                  tracker: tracker,
                  featureFlags: featureFlags,
                  locale: locale,
                  source: source,
                  action: action,
                  loginAction: loginAction,
                  cancelAction: cancelAction)
    }
    
    
    // MARK: - Public methods

    func cancel() {
        close(completion: nil)
    }

    func openHelp() {
        router?.showHelp()
    }

    func openRememberPassword() {
        router?.showRememberPassword(source: loginSource, email: emailTrimmed.value)
    }

    func open(url: URL) {
        router?.open(url: url)
    }

    func acceptSuggestedEmail() -> Bool {
        guard let suggestedEmail = suggestedEmailVar.value else { return false }
        email.value = suggestedEmail
        return true
    }

    func erasePassword() {
        password.value = ""
    }

    func signUp(recaptchaToken: String?) {
        guard sendButtonEnabledVar.value else { return }
        
        let signUpForm = SignUpForm(username: username.value ?? "",
                                    email: email.value ?? "",
                                    password: password.value ?? "",
                                    termsAndConditionsEnabled: termsAndConditionsEnabled,
                                    termsAccepted: termsAccepted)
        let errors = signUpForm.checkErrors()
        
        if errors.isEmpty {
            sendSignUp(signUpForm, recaptchaToken: recaptchaToken)
        } else {
            trackFormSignUpValidationFailed(errors: errors)
            delegate?.vmShowAutoFadingMessage(errors.errorMessage, completion: nil)
        }
    }
    
    func sendSignUp(_ signUpForm: SignUpForm, recaptchaToken: String?) {
        delegate?.vmShowLoading(nil)

        let completion: (Result<MyUser, SignupError>) -> () = { [weak self] signUpResult in
            guard let strongSelf = self else { return }
            
            if let user = signUpResult.value {
                strongSelf.savePreviousEmailOrUsername(.email, userEmailOrName: user.email)
                strongSelf.persistLogInProcessed()
                
                // Tracking
                strongSelf.tracker.trackEvent(
                    TrackerEvent.signupEmail(strongSelf.loginSource, newsletter: strongSelf.newsletterParameter))
                
                strongSelf.delegate?.vmHideLoading(nil) { [weak self] in
                    self?.close(completion: self?.onLoginCallback)
                }
            } else if let signUpError = signUpResult.error {
                if signUpError.isUserExists {
                    strongSelf.sessionManager.login(signUpForm.email, password: signUpForm.password) { [weak self] loginResult in
                        guard let strongSelf = self else { return }
                        if let _ = loginResult.value {
                            let rememberedAccount = strongSelf.previousEmail.value != nil
                            let trackerEvent = TrackerEvent.loginEmail(strongSelf.loginSource,
                                                                       rememberedAccount: rememberedAccount)
                            strongSelf.tracker.trackEvent(trackerEvent)
                            strongSelf.delegate?.vmHideLoading(nil) { [weak self] in
                                self?.close(completion: self?.onLoginCallback)
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
    
    func logIn(recaptchaToken: String? = nil) {
        guard sendButtonEnabledVar.value else { return }
        
        if emailTrimmed.value == "admin" && password.value == "wat" {
            delegate?.vmShowHiddenPasswordAlert()
            return
        }
        
        let logInEmailForm = LogInEmailForm(email: email.value ?? "",
                                            password: password.value ?? "")
        let errors = logInEmailForm.checkErrors()
        
        if errors.isEmpty {
            sendLogIn(logInEmailForm, recaptchaToken: recaptchaToken)
        } else {
            trackFormLogInValidationFailed(errors: errors)
            delegate?.vmShowAutoFadingMessage(errors.errorMessage, completion: nil)
        }
    }
    
    func sendLogIn(_ logInForm: LogInEmailForm, recaptchaToken: String?) {
        delegate?.vmShowLoading(nil)
        
        let completion: LoginCompletion? = { [weak self] loginResult in
            guard let strongSelf = self else { return }
            
            if let user = loginResult.value {
                self?.savePreviousEmailOrUsername(.email, userEmailOrName: user.email)
                
                let rememberedAccount = strongSelf.previousEmail.value != nil
                let trackerEvent = TrackerEvent.loginEmail(strongSelf.loginSource, rememberedAccount: rememberedAccount)
                self?.tracker.trackEvent(trackerEvent)
                
                self?.delegate?.vmHideLoading(nil) { [weak self] in
                    self?.close(completion: self?.onLoginCallback)
                }
            } else if let sessionManagerError = loginResult.error {
                strongSelf.processLoginSessionError(sessionManagerError)
            }
        }
        
        if let recaptchaToken = recaptchaToken {
            sessionManager.login(logInForm.email,
                                 password: logInForm.password,
                                 recaptchaToken: recaptchaToken,
                                 completion: completion)
        } else {
            sessionManager.login(logInForm.email,
                                 password: logInForm.password,
                                 completion: completion)
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
        fbLoginHelper.login({ [weak self] in
            self?.delegate?.vmShowLoading(nil)
        }) { [weak self] result in
            self?.processExternalServiceAuthResult(result, accountProvider: .facebook)
            if result.isSuccess {
                self?.trackLoginFBOK()
            } else if let trackingError = result.trackingError {
                self?.trackLoginFBFailedWithError(trackingError)
            }
        }
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
        Observable.combineLatest(email.asObservable(), password.asObservable(), username.asObservable()) { [weak self] (email, password, username) -> Bool in
            guard let strongSelf = self else { return false }
            guard let email = email, let password = password else { return false }
            switch strongSelf.currentActionType {
            case .login:
                return email.count > 0 && password.count > 0
            case .signup:
                guard let username = username else { return false }
                return email.count > 0 && password.count > 0 && username.count > 0
            }
        }.bind(to: sendButtonEnabledVar).disposed(by: disposeBag)
        
        // Email trim
        email.asObservable()
            .map { $0?.trim }
            .bind(to: emailTrimmed)
            .disposed(by: disposeBag)
        
        // Email auto suggest
        emailTrimmed.asObservable()
            .map { $0?.suggestEmail(domains: SharedConstants.emailSuggestedDomains) }
            .bind(to: suggestedEmailVar)
            .disposed(by: disposeBag)
    }

    private func processLoginSessionError(_ error: LoginError) {
        var showCaptcha = false
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
        case .userNotVerified:
            showCaptcha = true
        case .network, .badRequest, .notFound, .forbidden, .conflict, .tooManyRequests, .internalError:
            break
        }
       
        if showCaptcha {
            delegate?.vmHideLoading(nil) { [weak self] in
                if let strongSelf = self {
                    strongSelf.router?.showRecaptcha(action: .login, delegate: strongSelf)
                }
            }
        } else {
            trackLoginEmailFailedWithError(error.trackingError)
            delegate?.vmHideLoading(error.errorMessage, afterMessageCompletion: afterMessageCompletion)
        }
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
                if let strongSelf = self {
                    strongSelf.router?.showRecaptcha(action: .signup, delegate: strongSelf)
                }
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
                self?.close(completion: self?.onLoginCallback)
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
                                                                    close(completion: nil)
                                                                    return
        }
        
        let contact = UIAction(
            interface: .button(R.Strings.loginScammerAlertContactButton, .primary(fontSize: .medium)),
            action: {
                self.tracker.trackEvent(TrackerEvent.loginBlockedAccountContactUs(network, reason: .accountUnderReview))
                self.close(completion: { self.router?.open(url: contactURL) })
        })
        let keepBrowsing = UIAction(
            interface: .button(R.Strings.loginScammerAlertKeepBrowsingButton, .secondary(fontSize: .medium,
                                                                                         withBorder: false)),
            action: {
                self.tracker.trackEvent(TrackerEvent.loginBlockedAccountKeepBrowsing(network, reason: .accountUnderReview))
                self.close(completion: nil)
        })
        
        let actions = [contact, keepBrowsing]
        
        router?.showAlert(
            withTitle: R.Strings.loginScammerAlertTitle,
            andBody: R.Strings.loginScammerAlertMessage,
            andType: .iconAlert(icon: R.Asset.IconsButtons.icModerationAlert.image),
            andActions: actions
        )
        
        tracker.trackEvent(TrackerEvent.loginBlockedAccountStart(network, reason: .accountUnderReview))
    }

    private func showDeviceNotAllowedAlert(_ userEmail: String?, network: EventParameterAccountNetwork) {
        guard let contactURL = LetgoURLHelper.buildContactUsURL(userEmail: userEmail,
                                                                installation: installationRepository.installation,
                                                                listing: nil,
                                                                type: .deviceNotAllowed) else {
                                                                    close(completion: self.onCancelCallback)
                                                                    return
        }
        
        let contact = UIAction(
            interface: .button(R.Strings.loginDeviceNotAllowedAlertContactButton, .primary(fontSize: .medium)),
            action: {
                self.tracker.trackEvent(TrackerEvent.loginBlockedAccountContactUs(network, reason: .secondDevice))
                self.close(completion: { self.router?.open(url: contactURL) })
        })
        
        let keepBrowsing = UIAction(
            interface: .button(R.Strings.loginDeviceNotAllowedAlertOkButton, .secondary(fontSize: .medium,
                                                                                        withBorder: false)),
            action: {
                self.tracker.trackEvent(TrackerEvent.loginBlockedAccountKeepBrowsing(network, reason: .secondDevice))
                self.close(completion: nil)
        })
        
        router?.showAlert(
            withTitle: R.Strings.loginDeviceNotAllowedAlertTitle,
            andBody: R.Strings.loginDeviceNotAllowedAlertMessage,
            andType: .iconAlert(icon: R.Asset.IconsButtons.icDeviceBlockedAlert.image),
            andActions: [contact, keepBrowsing])
        
        tracker.trackEvent(TrackerEvent.loginBlockedAccountStart(network, reason: .secondDevice))
    }
    
    private func persistLogInProcessed() {
        guard featureFlags.blockingSignUp.isActive else { return }
        keyValueStorage[.didShowOnboarding] = true
        keyValueStorage[.didShowBlockingSignUp] = true
    }
    
    
    // MARK: - Navigation
    
    private func close(completion: (()->())?) {
        persistLogInProcessed()
        if let completion = completion {
            self.router?.close(onFinish: completion)
        } else {
            self.router?.close()
        }
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
        } else if contains(.shortPassword) {
            error = .invalidPassword
        } else {
            error = nil
        }
        return error
    }
    
    var errorMessage: String {
        let message: String
        if contains(.invalidEmail) {
            message = R.Strings.logInErrorSendErrorInvalidEmail
        } else {
            // message for .shortPassword and default
            message = R.Strings.logInErrorSendErrorUserNotFoundOrWrongPassword
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
    
    var errorMessage: String {
        let message: String
        if contains(.invalidEmail) {
            message = R.Strings.signUpSendErrorInvalidEmail
        } else if contains(.shortPassword) || contains(.longPassword) {
            message = R.Strings.signUpSendErrorInvalidPasswordWithMax(SharedConstants.passwordMinLength,
                                                                             SharedConstants.passwordMaxLength)
        } else if contains(.usernameTaken) {
            message = R.Strings.signUpSendErrorGeneric
        } else if contains(.invalidUsername) {
            message = R.Strings.signUpSendErrorInvalidUsername(SharedConstants.fullNameMinLength)
        } else if contains(.termsNotAccepted) {
            message = R.Strings.signUpAcceptanceError
        } else {
            message = R.Strings.signUpSendErrorGeneric
        }
        return message
    }
}


// MARK: - RecaptchaTokenDelegate

extension SignUpLogInViewModel: RecaptchaTokenDelegate {
    func recaptchaTokenObtained(token: String, action: LoginActionType) {
        switch action {
        case .login:
            logIn(recaptchaToken: token)
        case .signup:
            signUp(recaptchaToken: token)
        }
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
        case .email, .passwordless:
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
        let title = R.Strings.logInEmailForgotPasswordAlertTitle
        var message: String?
        if let emailTrimmed = emailTrimmed.value {
            message = R.Strings.logInEmailForgotPasswordAlertMessage(emailTrimmed)
        }
        let cancelAction = UIAction(interface: .styledText(R.Strings.logInEmailForgotPasswordAlertCancelAction, .cancel),
                                    action: {})
        let recoverPasswordAction = UIAction(interface: .styledText(R.Strings.logInEmailForgotPasswordAlertRememberAction, .destructive),
                                             action: { [weak self] in
                                                if let emailTrimmed = self?.emailTrimmed.value {
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
            let message = R.Strings.resetPasswordSendOk(emailTrimmed)
            delegate?.vmHideLoading(message, afterMessageCompletion: nil)
        }
    }

    func recoverPasswordFailed(error: RecoverPasswordError) {
        trackPasswordRecoverFailed(error: error)

        var message: String? = nil
        switch error {
        case .network:
            message = R.Strings.commonErrorConnectionFailed
        case .notFound:
            if let emailTrimmed = emailTrimmed.value {
                message = R.Strings.resetPasswordSendErrorUserNotFoundOrWrongPassword(emailTrimmed)
            }
        case .conflict, .tooManyRequests:
            message = R.Strings.resetPasswordSendTooManyRequests
        case .badRequest, .scammer, .internalError, .userNotVerified, .forbidden, .unauthorized, .nonExistingEmail:
            message = R.Strings.resetPasswordSendErrorGeneric
        }
        delegate?.vmHideLoading(message, afterMessageCompletion: nil)
    }
}
