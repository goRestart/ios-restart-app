//
//  LogInEmailViewModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 11/01/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

struct LogInEmailFormErrors: OptionSet {
    let rawValue: Int

    static let invalidEmail     = LogInEmailFormErrors(rawValue: 1 << 0)
    static let shortPassword    = LogInEmailFormErrors(rawValue: 1 << 1)
    static let longPassword     = LogInEmailFormErrors(rawValue: 1 << 2)
}

protocol LogInEmailViewModelDelegate: BaseViewModelDelegate {
    func vmGodModePasswordAlert()
}

protocol LogInEmailViewModelNavigator: class {
    func openHelpFromLogInEmail()
    func openRememberPasswordFromLogInEmail(email: String)
    func openSignUpEmailFromLogInEmail(email: String, password: String) // TODO: Call navigator to pop + push signup
    func openScammerAlertFromLogInEmail()
    func closeAfterLogInSuccessful()
}


final class LogInEmailViewModel: BaseViewModel {
    lazy var helpAction: UIAction = {
        return UIAction(interface: .text(LGLocalizedString.mainSignUpHelpButton), action: { [weak self] in
            self?.openHelp()
            }, accessibilityId: .SignUpEmailHelpButton)
    }()
    let email: Variable<String>
    var suggestedEmail: Observable<String?> {
        return suggestedEmailVar.asObservable()
    }
    let password: Variable<String>
    var logInEnabled: Observable<Bool> {
        return logInEnabledVar.asObservable()
    }

    weak var delegate: LogInEmailViewModelDelegate?
    weak var navigator: LogInEmailViewModelNavigator?

    fileprivate let isRememberedEmail: Bool
    fileprivate let suggestedEmailVar: Variable<String?>
    fileprivate var logInError: PublishSubject<SessionManagerError>
    fileprivate let source: EventParameterLoginSourceValue

    fileprivate let sessionManager: SessionManager
    fileprivate let keyValueStorage: KeyValueStorageable
    fileprivate let logInEnabledVar: Variable<Bool>
    fileprivate let tracker: Tracker
    fileprivate let disposeBag: DisposeBag


    // MARK: - Lifecycle

    convenience init(email: String?, isRememberedEmail: Bool, source: EventParameterLoginSourceValue) {
        let sessionManager = Core.sessionManager
        let keyValueStorage = KeyValueStorage.sharedInstance
        let tracker = TrackerProxy.sharedInstance
        self.init(email: email, isRememberedEmail: isRememberedEmail,
                  source: source, sessionManager: sessionManager,
                  keyValueStorage: keyValueStorage, tracker: tracker)
    }

    init(email: String?, isRememberedEmail: Bool,
         source: EventParameterLoginSourceValue, sessionManager: SessionManager,
         keyValueStorage: KeyValueStorageable, tracker: Tracker) {
        let actualEmail = email ?? LogInEmailViewModel.readPreviousEmail(fromKeyValueStorageable: keyValueStorage) ?? ""
        self.email = Variable<String>(actualEmail)
        self.password = Variable<String>("")

        self.isRememberedEmail = isRememberedEmail
        self.suggestedEmailVar = Variable<String?>(nil)
        self.logInError = PublishSubject<SessionManagerError>()
        self.source = source

        self.sessionManager = sessionManager
        self.keyValueStorage = keyValueStorage
        self.logInEnabledVar = Variable<Bool>(false)
        self.tracker = tracker
        self.disposeBag = DisposeBag()
        super.init()

        setupRx()
    }
}


// MARK: - Public methods

extension LogInEmailViewModel {
    func acceptSuggestedEmail() {
        guard let suggestedEmail = suggestedEmailVar.value else { return }
        email.value = suggestedEmail
    }

    func logIn() -> LogInEmailFormErrors {
        var errors: LogInEmailFormErrors = []
        guard logInEnabledVar.value else { return errors }

        // God mode
        if email.value == "admin" && password.value == "wat" {
            delegate?.vmGodModePasswordAlert()
            return errors
        }

        // Form validation
        if !email.value.isEmail() {
            errors.insert(.invalidEmail)
        }
        if password.value.characters.count < Constants.passwordMinLength {
            errors.insert(.shortPassword)
        } else if password.value.characters.count > Constants.passwordMaxLength {
            errors.insert(.longPassword)
        }

        if errors.isEmpty {
            logIn(email: email.value, password: password.value)
        } else {
            trackFormValidationFailed(errors: errors)
        }
        return errors
    }

    func enableGodMode(godPassword: String) {
        if godPassword == "mellongod" {
            keyValueStorage[.isGod] = true
        } else {
            delegate?.vmShowAutoFadingMessage("You are not worthy", completion: nil)
        }
    }

    func openRememberPassword() {
        openRememberPassword(email: email.value)
    }

    func openSignUp() {
        openSignUp(email: email.value, password: password.value)
    }
}


// MARK: - Private methods
// MARK: > Rx

fileprivate extension LogInEmailViewModel {
    func setupRx() {
        // Next step is enabled when email & password are not empty
        Observable.combineLatest(email.asObservable(), password.asObservable()) { (email, password) -> Bool in
            return email.characters.count > 0 && password.characters.count > 0
            }.bindTo(logInEnabledVar).addDisposableTo(disposeBag)

        // Email auto suggest
        email.asObservable()
            .map { $0.suggestEmail(domains: Constants.emailSuggestedDomains) }
            .bindTo(suggestedEmailVar)
            .addDisposableTo(disposeBag)

        // Regular login error display / remember password
        logInError.asObservable().take(1).subscribeNext { [weak self] logInError in
            self?.logInFailed(logInError: logInError, askRememberPassword: false)
        }.addDisposableTo(disposeBag)

        logInError.asObservable().skip(1).subscribeNext { [weak self] logInError in
            self?.logInFailed(logInError: logInError, askRememberPassword: true)
        }.addDisposableTo(disposeBag)
    }
}


// MARK: > Previous email

fileprivate extension LogInEmailViewModel {
    static func readPreviousEmail(fromKeyValueStorageable keyValueStorageble: KeyValueStorageable) -> String? {
        guard let accountProviderString = keyValueStorageble[.previousUserAccountProvider],
            let accountProvider = AccountProvider(rawValue: accountProviderString),
            accountProvider == .email else { return nil }
        return keyValueStorageble[.previousUserEmailOrName]
    }

    func savePrevious(email: String) {
        keyValueStorage[.previousUserAccountProvider] = AccountProvider.email.rawValue
        keyValueStorage[.previousUserEmailOrName] = email
    }
}



// MARK: > Requests

fileprivate extension LogInEmailViewModel {
    func logIn(email: String, password: String) {
        delegate?.vmShowLoading(nil)
        sessionManager.login(email, password: password) { [weak self] loginResult in
            if let myUser = loginResult.value {
                self?.logInSucceeded(myUser: myUser)
            } else if let error = loginResult.error {
                // Error is handled at setupRx
                self?.logInError.onNext(error)
            }
        }
    }

    func logInSucceeded(myUser: MyUser) {
        savePrevious(email: myUser.email ?? email.value)
        trackLogInSucceeded()
        delegate?.vmHideLoading(nil) { [weak self] in
            self?.navigator?.closeAfterLogInSuccessful()
        }
    }

    func logInFailed(logInError: SessionManagerError, askRememberPassword: Bool) {
        var message: String? = nil
        var afterMessageCompletion: (() -> ())? = nil

        switch logInError {
        case .network:
            message = LGLocalizedString.commonErrorConnectionFailed
        case .unauthorized:
            message = LGLocalizedString.logInErrorSendErrorUserNotFoundOrWrongPassword
        case .scammer:
            afterMessageCompletion = { [weak self] in
                self?.navigator?.openScammerAlertFromLogInEmail()
            }
        case .notFound, .internalError, .forbidden, .nonExistingEmail, .conflict, .tooManyRequests, .badRequest,
             .userNotVerified:
            message = LGLocalizedString.logInErrorSendErrorGeneric
        }
        trackLogInFailed(error: logInError)

        if askRememberPassword && afterMessageCompletion == nil {
            afterMessageCompletion = { [weak self] in
                self?.showRememberPasswordAlert()
            }
        }
        delegate?.vmHideLoading(message, afterMessageCompletion: afterMessageCompletion)
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
        let message = LGLocalizedString.resetPasswordSendOk(email.value)
        delegate?.vmHideLoading(message, afterMessageCompletion: nil)
    }

    func recoverPasswordFailed(error: SessionManagerError) {
        trackPasswordRecoverFailed(error: error)

        var message: String? = nil
        switch error {
        case .network:
            message = LGLocalizedString.commonErrorConnectionFailed
        case .notFound:
            message = LGLocalizedString.resetPasswordSendErrorUserNotFoundOrWrongPassword(email.value)
        case .conflict, .tooManyRequests:
            message = LGLocalizedString.resetPasswordSendTooManyRequests
        case .badRequest, .scammer, .internalError, .userNotVerified, .forbidden, .unauthorized, .nonExistingEmail:
            message = LGLocalizedString.resetPasswordSendErrorGeneric
        }
        delegate?.vmHideLoading(message, afterMessageCompletion: nil)
    }
}


// MARK: > Actions

fileprivate extension LogInEmailViewModel {
    func showRememberPasswordAlert() {
        // TODO: strings!
        let title = "Forgot your password?"
        let message = "We can send an email to \(email.value)"
        let cancelAction = UIAction(interface: .styledText("Retry", .cancel), action: {})
        let recoverPasswordAction = UIAction(interface: .styledText("Send email", .destructive), action: { [weak self] in
            guard let email = self?.email.value else { return }
            self?.recoverPassword(email: email)
        })
        let actions = [cancelAction, recoverPasswordAction]
        delegate?.vmShowAlert(title, message: message, actions: actions)
    }
}


// MARK: > Tracking

fileprivate extension LogInEmailViewModel {
    func trackFormValidationFailed(errors: LogInEmailFormErrors) {
        guard let trackingError = errors.trackingError else { return }
        let event = TrackerEvent.loginEmailError(trackingError)
        tracker.trackEvent(event)
    }

    func trackLogInSucceeded() {
        let event = TrackerEvent.loginEmail(source, rememberedAccount: isRememberedEmail)
        tracker.trackEvent(event)
    }

    func trackLogInFailed(error: SessionManagerError) {
        let event = TrackerEvent.loginEmailError(error.trackingError)
        tracker.trackEvent(event)
    }

    func trackPasswordRecoverFailed(error: SessionManagerError) {
        let event = TrackerEvent.passwordResetError(error.trackingError)
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
            return .internalError(description: "UserNotVerified")
        }
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
}


// MARK: > Navigation

fileprivate extension LogInEmailViewModel {
    func openHelp() {
        navigator?.openHelpFromLogInEmail()
    }

    func openRememberPassword(email: String) {
        navigator?.openRememberPasswordFromLogInEmail(email: email)
    }

    func openSignUp(email: String, password: String) {
        navigator?.openSignUpEmailFromLogInEmail(email: email, password: password)
    }
}
