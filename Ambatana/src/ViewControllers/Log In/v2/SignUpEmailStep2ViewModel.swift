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

    fileprivate var trackingError: EventParameterLoginError? {
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

protocol SignUpEmailStep2Navigator: class {
    func openHelpFromSignUpEmailStep2()
    func openRecaptchaFromSignUpEmailStep2()
    //                let vm = RecaptchaViewModel(transparentMode: self?.featureFlags.captchaTransparent ?? false)
    //                self?.delegate?.vmShowRecaptcha(vm)
    func openScammerAlertFromSignUpEmailStep2()
//    private func showScammerAlert(_ userEmail: String?, network: EventParameterAccountNetwork) {
//        guard let url = LetgoURLHelper.buildContactUsURL(userEmail: nil,
//             installation: installationRepository.installation, moderation: true) else {
//                delegate?.vmFinish(completedAccess: false)
//                return
//        }
//        
//        delegate?.vmFinishAndShowScammerAlert(url, network: network, tracker: tracker)
//    }
    func closeAfterSignUpSuccessful()
}

protocol SignUpEmailStep2ViewModelDelegate: BaseViewModelDelegate {}

final class SignUpEmailStep2ViewModel: BaseViewModel {
    lazy var helpAction: UIAction = {
        // TODO: New string?
        return UIAction(interface: .text(LGLocalizedString.mainSignUpHelpButton), action: { [weak self] in
            self?.openHelp()
        }, accessibilityId: .SignUpEmailHelpButton)
    }()
    let email: String
    let username: Variable<String>
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

    weak var delegate: SignUpEmailStep2ViewModelDelegate?
    weak var navigator: SignUpEmailStep2Navigator?

    fileprivate let isRememberedEmail: Bool
    fileprivate let password: String
    fileprivate let source: EventParameterLoginSourceValue
    fileprivate let signUpEnabledVar: Variable<Bool>

    fileprivate let sessionManager: SessionManager
    fileprivate let keyValueStorage: KeyValueStorageable
    fileprivate let featureFlags: FeatureFlaggeable
    fileprivate let tracker: Tracker
    fileprivate let disposeBag: DisposeBag


    // MARK : - Lifecycle

    convenience init(email: String, isRememberedEmail: Bool, password: String, source: EventParameterLoginSourceValue) {
        let sessionManager = Core.sessionManager
        let keyValueStorage = KeyValueStorage.sharedInstance
        let featureFlags = FeatureFlags.sharedInstance
        let tracker = TrackerProxy.sharedInstance
        self.init(email: email, isRememberedEmail: isRememberedEmail, password: password, source: source,
                  sessionManager: sessionManager, keyValueStorage: keyValueStorage,
                  featureFlags: featureFlags, tracker: tracker)
    }

    init(email: String, isRememberedEmail: Bool, password: String, source: EventParameterLoginSourceValue,
         sessionManager: SessionManager, keyValueStorage: KeyValueStorageable,
         featureFlags: FeatureFlaggeable, tracker: Tracker) {
        self.email = email
        self.username = Variable<String>("")
        self.termsAndConditionsAccepted = Variable<Bool>(false)
        self.newsLetterAccepted = Variable<Bool>(false)

        self.isRememberedEmail = isRememberedEmail
        self.password = password
        self.source = source
        self.signUpEnabledVar = Variable<Bool>(false)

        self.sessionManager = sessionManager
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
        let trimmedUsername = username.value.trim
        if trimmedUsername.containsLetgo() {
            errors.insert(.usernameContainsLetgo)
        }
        if trimmedUsername.characters.count < Constants.fullNameMinLength {
            errors.insert(.shortUsername)
        }
        if termsAndConditionsAcceptRequired && !termsAndConditionsAccepted.value {
            errors.insert(.termsAndConditionsNotAccepted)
        }

        if errors.isEmpty {
            let newsletter: Bool? = newsLetterAcceptRequired ? newsLetterAccepted.value : nil
            signUp(email: email, password: password, username: trimmedUsername, newsletter: newsletter)
        } else {
            trackFormValidationFailure(errors: errors)
        }
        return errors
    }
}


// MARK: - Private methods
// MARK: > Rx

fileprivate extension SignUpEmailStep2ViewModel {
    func setupRx() {
        // Sign up is enabled when username is not empty & the required checks are enabled
        let requiredChecks: Observable<Bool>?
        if termsAndConditionsAcceptRequired  && newsLetterAcceptRequired {
            requiredChecks = Observable.combineLatest(termsAndConditionsAccepted.asObservable(),
                                                      newsLetterAccepted.asObservable()) { $0.0 && $0.1 }
        } else if termsAndConditionsAcceptRequired {
            requiredChecks = termsAndConditionsAccepted.asObservable()
        } else if newsLetterAcceptRequired {
            requiredChecks = newsLetterAccepted.asObservable()
        } else {
            requiredChecks = nil
        }
        let usernameNotEmpty = username.asObservable().map { !$0.characters.isEmpty }
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
    func signUp(email: String, password: String, username: String, newsletter: Bool?) {
        delegate?.vmShowLoading(nil)
        sessionManager.signUp(email, password: password, name: username, newsletter: newsletter) { [weak self] result in
            if let myUser = result.value {
                self?.signUpSucceeded(myUser: myUser, newsletter: newsletter)
            } else if let signUpError = result.error {
                self?.signUpFailed(signUpError: signUpError)
            }
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
                self?.navigator?.openRecaptchaFromSignUpEmailStep2()
            }
        case .scammer:
            afterMessageCompletion = { [weak self] in
                self?.navigator?.openScammerAlertFromSignUpEmailStep2()
            }
            return
        case .notFound, .internalError, .forbidden, .unauthorized, .tooManyRequests:
            message = LGLocalizedString.signUpSendErrorGeneric
        }

        trackSignUpFailed(error: signUpError)
        delegate?.vmHideLoading(message, afterMessageCompletion: afterMessageCompletion)
    }
}


// MARK: > Tracking

fileprivate extension SignUpEmailStep2ViewModel {
    func trackFormValidationFailure(errors: SignUpEmailStep2FormErrors) {
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
        let event = TrackerEvent.signupEmail(source, newsletter: newsletterTrackingParam)
        tracker.trackEvent(event)
    }

    func trackSignUpFailed(error: SessionManagerError) {
        let event = TrackerEvent.signupError(error.trackingError)
        tracker.trackEvent(event)
    }

    func trackLogIn() {
        let event = TrackerEvent.loginEmail(source, rememberedAccount: isRememberedEmail)
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


// MARK: > Previous email

fileprivate extension SignUpEmailStep2ViewModel {
    func savePrevious(email: String?) {
        guard let email = email else { return }
        keyValueStorage[.previousUserAccountProvider] = AccountProvider.email.rawValue
        keyValueStorage[.previousUserEmailOrName] = email
    }
}


// MARK: > Navigation

fileprivate extension SignUpEmailStep2ViewModel {
    func openHelp() {
        navigator?.openHelpFromSignUpEmailStep2()
    }
}
