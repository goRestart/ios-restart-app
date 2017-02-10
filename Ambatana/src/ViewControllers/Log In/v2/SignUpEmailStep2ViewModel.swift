//
//  SignUpEmailStep2ViewModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 11/01/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit
import Result
import RxSwift

struct SignUpEmailStep2FormErrors: OptionSet {
    let rawValue: Int

    static let invalidEmail                     = SignUpEmailStep2FormErrors(rawValue: 1 << 0)
    static let invalidPassword                  = SignUpEmailStep2FormErrors(rawValue: 1 << 1)
    static let usernameContainsLetgo            = SignUpEmailStep2FormErrors(rawValue: 1 << 2)
    static let shortUsername                    = SignUpEmailStep2FormErrors(rawValue: 1 << 3)
    static let termsAndConditionsNotAccepted    = SignUpEmailStep2FormErrors(rawValue: 1 << 4)
}

protocol SignUpEmailStep2Navigator: class {
    func openHelpFromSignUpEmailStep2()
    func openRecaptchaFromSignUpEmailStep2(transparentMode: Bool)
    func openScammerAlertFromSignUpEmailStep2(contactURL: URL)
    func closeAfterSignUpSuccessful()
}

protocol SignUpEmailStep2ViewModelDelegate: BaseViewModelDelegate {}

final class SignUpEmailStep2ViewModel: BaseViewModel {
    lazy var helpAction: UIAction = {
        return UIAction(interface: .text(LGLocalizedString.mainSignUpHelpButton), action: { [weak self] in
            self?.openHelp()
        }, accessibilityId: .SignUpEmailHelpButton)
    }()
    let email: String
    let username: Variable<String?>
    var termsAndConditionsAcceptRequired: Bool {
        return featureFlags.signUpEmailTermsAndConditionsAcceptRequired
    }
    let termsAndConditionsAccepted: Variable<Bool>
    var newsLetterAcceptRequired: Bool {
        return featureFlags.signUpEmailNewsletterAcceptRequired
    }
    let newsLetterAccepted: Variable<Bool>
    var signUpEnabled: Observable<Bool> {
        return signUpEnabledVar.asObservable()
    }
    var termsAndConditionsURL: URL? {
        return LetgoURLHelper.buildTermsAndConditionsURL()
    }
    var privacyURL: URL? {
        return LetgoURLHelper.buildPrivacyURL()
    }

    weak var delegate: SignUpEmailStep2ViewModelDelegate?
    weak var navigator: SignUpEmailStep2Navigator?

    fileprivate let isRememberedEmail: Bool
    fileprivate let password: String
    fileprivate let source: EventParameterLoginSourceValue
    fileprivate let collapsedEmail: EventParameterCollapsedEmailField?
    fileprivate let signUpEnabledVar: Variable<Bool>

    fileprivate let sessionManager: SessionManager
    fileprivate let installationRepository: InstallationRepository
    fileprivate let keyValueStorage: KeyValueStorageable
    fileprivate let featureFlags: FeatureFlaggeable
    fileprivate let tracker: Tracker
    fileprivate let disposeBag: DisposeBag


    // MARK : - Lifecycle

    convenience init(email: String, isRememberedEmail: Bool, password: String,
                     source: EventParameterLoginSourceValue, collapsedEmail: EventParameterCollapsedEmailField?) {
        self.init(email: email,
                  isRememberedEmail: isRememberedEmail,
                  password: password,
                  source: source,
                  collapsedEmail: collapsedEmail,
                  sessionManager: Core.sessionManager,
                  installationRepository: Core.installationRepository,
                  keyValueStorage: KeyValueStorage.sharedInstance,
                  featureFlags: FeatureFlags.sharedInstance,
                  tracker: TrackerProxy.sharedInstance)
    }

    init(email: String,
         isRememberedEmail: Bool,
         password: String,
         source: EventParameterLoginSourceValue,
         collapsedEmail: EventParameterCollapsedEmailField?,
         sessionManager: SessionManager,
         installationRepository: InstallationRepository,
         keyValueStorage: KeyValueStorageable,
         featureFlags: FeatureFlaggeable,
         tracker: Tracker) {
        self.email = email
        let username = email.makeUsernameFromEmail()
        self.username = Variable<String?>(username)
        self.termsAndConditionsAccepted = Variable<Bool>(false)
        self.newsLetterAccepted = Variable<Bool>(false)

        self.isRememberedEmail = isRememberedEmail
        self.password = password
        self.source = source
        self.collapsedEmail = collapsedEmail
        self.signUpEnabledVar = Variable<Bool>(!(username ?? "").isEmpty)

        self.sessionManager = sessionManager
        self.installationRepository = installationRepository
        self.keyValueStorage = keyValueStorage
        self.featureFlags = featureFlags
        self.tracker = tracker
        self.disposeBag = DisposeBag()

        super.init()
        setupRx()
    }
}


// MARK: - Public methods

extension SignUpEmailStep2ViewModel {
    func openHelp() {
        navigator?.openHelpFromSignUpEmailStep2()
    }

    func signUp() -> SignUpEmailStep2FormErrors {
        var errors: SignUpEmailStep2FormErrors = []
        guard signUpEnabledVar.value else { return errors }

        if !email.isEmail() {
            errors.insert(.invalidEmail)
        }
        if password.characters.count < Constants.passwordMinLength ||
           password.characters.count > Constants.passwordMaxLength{
            errors.insert(.invalidPassword)
        }
        if let username = username.value {
            let trimmedUsername = username.trim
            if trimmedUsername.containsLetgo() {
                errors.insert(.usernameContainsLetgo)
            }
            if trimmedUsername.characters.count < Constants.fullNameMinLength {
                errors.insert(.shortUsername)
            }
            if termsAndConditionsAcceptRequired && !termsAndConditionsAccepted.value {
                errors.insert(.termsAndConditionsNotAccepted)
            }
        } else {
            errors.insert(.usernameContainsLetgo)
        }


        if let username = username.value?.trim, errors.isEmpty {
            let newsletter: Bool? = newsLetterAcceptRequired ? newsLetterAccepted.value : nil
            signUp(email: email, password: password, username: username, newsletter: newsletter, recaptchaToken: nil)
        } else {
            trackFormValidationFailed(errors: errors)
        }
        return errors
    }
}


// MARK: - RecaptchaTokenDelegate

extension SignUpEmailStep2ViewModel: RecaptchaTokenDelegate {
    func recaptchaTokenObtained(token: String) {
        guard let username = username.value?.trim else { return }
        let newsletter: Bool? = newsLetterAcceptRequired ? newsLetterAccepted.value : nil
        signUp(email: email, password: password, username: username, newsletter: newsletter, recaptchaToken: token)
    }
}


// MARK: - Private methods
// MARK: > Rx

fileprivate extension SignUpEmailStep2ViewModel {
    func setupRx() {
        // Sign up is enabled when username is not empty & the required checks are enabled
        let requiredChecks: Observable<Bool>?
        if termsAndConditionsAcceptRequired {
            requiredChecks = termsAndConditionsAccepted.asObservable()
        } else {
            requiredChecks = nil
        }

        let usernameNotEmpty = username.asObservable().map { username -> Bool in
            guard let username = username else { return false }
            return !username.characters.isEmpty
        }
        if let requiredChecks = requiredChecks {
            Observable.combineLatest(usernameNotEmpty.asObservable(), requiredChecks) { $0.0 && $0.1 }
                .bindTo(signUpEnabledVar).addDisposableTo(disposeBag)
        } else {
            usernameNotEmpty.asObservable().bindTo(signUpEnabledVar).addDisposableTo(disposeBag)
        }
    }
}


// MARK: > Requests

fileprivate extension SignUpEmailStep2ViewModel {
    func signUp(email: String, password: String, username: String, newsletter: Bool?, recaptchaToken: String?) {
        delegate?.vmShowLoading(nil)

        let completion: SessionMyUserCompletion = { [weak self] result in
            if let myUser = result.value {
                self?.signUpSucceeded(myUser: myUser, newsletter: newsletter)
            } else if let signUpError = result.error {
                self?.signUpFailed(signUpError: signUpError)
            }
        }
        if let recaptchaToken = recaptchaToken {
            sessionManager.signUp(email, password: password, name: username, newsletter: newsletter,
                                  recaptchaToken: recaptchaToken, completion: completion)
        } else {
            sessionManager.signUp(email, password: password, name: username, newsletter: newsletter,
                                  completion: completion)
        }
    }

    func signUpSucceeded(myUser: MyUser, newsletter: Bool?) {
        savePrevious(email: myUser.email ?? email)
        trackSignUpSucceeded(newsletter: newsletter)
        delegate?.vmHideLoading(nil) { [weak self] in
            self?.navigator?.closeAfterSignUpSuccessful()
        }
    }

    func signUpFailed(signUpError: SessionManagerError) {
        let shouldLogin: Bool
        switch signUpError {
        case let .conflict(cause):
            switch cause {
            case .userExists:
                shouldLogin = true
            case .emailRejected, .requestAlreadyProcessed, .notSpecified, .other:
                shouldLogin = false
            }
        case .network, .badRequest, .notFound, .forbidden, .unauthorized, .scammer,
             .nonExistingEmail, .tooManyRequests, .userNotVerified, .internalError:
            shouldLogin = false
        }

        if shouldLogin {
            logIn(email: email, password: password, signUpError: signUpError)
        } else {
            process(signUpError: signUpError)
        }
    }

    func logIn(email: String, password: String, signUpError: SessionManagerError) {
        sessionManager.login(email, password: password) { [weak self] result in
            if let myUser = result.value {
                self?.logInSucceeded(myUser: myUser)
            } else if let _ = result.error {
                self?.process(signUpError: signUpError)
            }
        }
    }

    func logInSucceeded(myUser: MyUser) {
        savePrevious(email: myUser.email ?? email)
        trackLogIn()
        delegate?.vmHideLoading(nil) { [weak self] in
            self?.navigator?.closeAfterSignUpSuccessful()
        }
    }

    private func process(signUpError: SessionManagerError) {
        var message: String? = nil
        var afterMessageCompletion: (() -> ())? = nil

        switch signUpError {
        case .network:
            message = LGLocalizedString.commonErrorConnectionFailed
        case .badRequest(let cause):
            switch cause {
            case .notSpecified, .other:
                message = LGLocalizedString.signUpSendErrorGeneric
            case .nonAcceptableParams:
                message = LGLocalizedString.signUpSendErrorInvalidDomain
            }
        case .conflict(let cause):
            switch cause {
            case .userExists, .notSpecified, .other:
                message = LGLocalizedString.signUpSendErrorEmailTaken(email)
            case .emailRejected:
                message = LGLocalizedString.mainSignUpErrorUserRejected
            case .requestAlreadyProcessed:
                message = LGLocalizedString.mainSignUpErrorRequestAlreadySent
            }
        case .nonExistingEmail:
            message = LGLocalizedString.signUpSendErrorInvalidEmail
        case .userNotVerified:
            afterMessageCompletion = { [weak self] in
                let transparentMode = self?.featureFlags.captchaTransparent ?? false
                self?.navigator?.openRecaptchaFromSignUpEmailStep2(transparentMode: transparentMode)
            }
        case .scammer:
            afterMessageCompletion = { [weak self] in
                guard let contactURL = self?.contactURL else { return }
                self?.navigator?.openScammerAlertFromSignUpEmailStep2(contactURL: contactURL)
            }
        case .notFound, .internalError, .forbidden, .unauthorized, .tooManyRequests:
            message = LGLocalizedString.signUpSendErrorGeneric
        }

        trackSignUpFailed(error: signUpError)
        delegate?.vmHideLoading(message, afterMessageCompletion: afterMessageCompletion)
    }
}


// MARK: > Tracking

fileprivate extension SignUpEmailStep2ViewModel {
    func trackFormValidationFailed(errors: SignUpEmailStep2FormErrors) {
        guard let error = errors.trackingError else { return }
        let event = TrackerEvent.signupError(error)
        tracker.trackEvent(event)
    }

    func trackSignUpSucceeded(newsletter: Bool?) {
        let newsletterTrackingParam: EventParameterNewsletter
        if let newsletter = newsletter {
            newsletterTrackingParam = newsletter ? .trueParameter : .falseParameter
        } else {
            newsletterTrackingParam = .unset
        }
        let event = TrackerEvent.signupEmail(source, newsletter: newsletterTrackingParam, collapsedEmail: collapsedEmail)
        tracker.trackEvent(event)
    }

    func trackSignUpFailed(error: SessionManagerError) {
        let event = TrackerEvent.signupError(error.trackingError)
        tracker.trackEvent(event)
    }

    func trackLogIn() {
        let event = TrackerEvent.loginEmail(source, rememberedAccount: isRememberedEmail, collapsedEmail: collapsedEmail)
        tracker.trackEvent(event)
    }
}

fileprivate extension SessionManagerError {
    var trackingError: EventParameterLoginError {
        switch self {
        case .network:
            return .network
        case .badRequest(let cause):
            switch cause {
            case .nonAcceptableParams:
                return .blacklistedDomain
            case .notSpecified, .other:
                return .badRequest
            }
        case .scammer:
            return .forbidden
        case .notFound:
            return .notFound
        case .conflict:
            return .emailTaken
        case .forbidden:
            return .forbidden
        case let .internalError(description):
            return .internalError(description: description)
        case .nonExistingEmail:
            return .nonExistingEmail
        case .unauthorized:
            return .unauthorized
        case .tooManyRequests:
            return .tooManyRequests
        case .userNotVerified:
            return .internalError(description: "userNotVerified")
        }

    }
}

fileprivate extension SignUpEmailStep2FormErrors {
    var trackingError: EventParameterLoginError? {
        let error: EventParameterLoginError?
        if contains(.invalidEmail) {
            error = .invalidEmail
        } else if contains(.invalidPassword) {
            error = .invalidPassword
        } else if contains(.usernameContainsLetgo) {
            error = .usernameTaken
        } else if contains(.shortUsername) {
            error = .invalidUsername
        } else if contains(.termsAndConditionsNotAccepted) {
            error = .termsNotAccepted
        } else {
            error = nil
        }
        return error
    }
}


// MARK: > Previous email

fileprivate extension SignUpEmailStep2ViewModel {
    func savePrevious(email: String?) {
        guard let email = email else { return }
        keyValueStorage[.previousUserAccountProvider] = AccountProvider.email.rawValue
        keyValueStorage[.previousUserEmailOrName] = email
    }
}


// MARK: > Helper

fileprivate extension SignUpEmailStep2ViewModel {
    var contactURL: URL? {
        return LetgoURLHelper.buildContactUsURL(userEmail: email,
                                                installation: installationRepository.installation,
                                                moderation: true)
    }
}
