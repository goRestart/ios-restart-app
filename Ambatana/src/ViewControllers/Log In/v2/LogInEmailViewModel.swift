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

final class LogInEmailViewModel: BaseViewModel {
    fileprivate static let unauthorizedErrorCountRememberPwd = 2

    let email: Variable<String?>
    var suggestedEmail: Observable<String?> {
        return suggestedEmailVar.asObservable()
    }
    let password: Variable<String?>
    var logInEnabled: Observable<Bool> {
        return logInEnabledVar.asObservable()
    }

    weak var delegate: LogInEmailViewModelDelegate?
    weak var navigator: LogInEmailNavigator?

    fileprivate let isRememberedEmail: Bool
    fileprivate var unauthorizedErrorCount: Int
    fileprivate let suggestedEmailVar: Variable<String?>
    fileprivate let source: EventParameterLoginSourceValue
    fileprivate let collapsedEmail: EventParameterBoolean?

    fileprivate let sessionManager: SessionManager
    fileprivate let installationRepository: InstallationRepository
    fileprivate let keyValueStorage: KeyValueStorageable
    fileprivate let logInEnabledVar: Variable<Bool>
    fileprivate let tracker: Tracker
    fileprivate let disposeBag: DisposeBag


    // MARK: - Lifecycle

    convenience init(source: EventParameterLoginSourceValue,
                     collapsedEmail: EventParameterBoolean?) {
        self.init(source: source,
                  collapsedEmail: collapsedEmail,
                  keyValueStorage: KeyValueStorage.sharedInstance)
    }

    convenience init(source: EventParameterLoginSourceValue,
                     collapsedEmail: EventParameterBoolean?,
                     keyValueStorage: KeyValueStorageable) {
        let email = LogInEmailViewModel.readPreviousEmail(fromKeyValueStorageable: keyValueStorage)
        let isRememberedEmail = email != nil
        self.init(email: email,
                  isRememberedEmail: isRememberedEmail,
                  source: source,
                  collapsedEmail: collapsedEmail,
                  sessionManager: Core.sessionManager,
                  installationRepository: Core.installationRepository,
                  keyValueStorage: keyValueStorage,
                  tracker: TrackerProxy.sharedInstance)
    }

    convenience init(email: String?,
                     isRememberedEmail: Bool,
                     source: EventParameterLoginSourceValue,
                     collapsedEmail: EventParameterBoolean?) {
        self.init(email: email,
                  isRememberedEmail: isRememberedEmail,
                  source: source,
                  collapsedEmail: collapsedEmail,
                  sessionManager: Core.sessionManager,
                  installationRepository: Core.installationRepository,
                  keyValueStorage: KeyValueStorage.sharedInstance,
                  tracker: TrackerProxy.sharedInstance)
    }

    init(email: String?,
         isRememberedEmail: Bool,
         source: EventParameterLoginSourceValue,
         collapsedEmail: EventParameterBoolean?,
         sessionManager: SessionManager,
         installationRepository: InstallationRepository,
         keyValueStorage: KeyValueStorageable,
         tracker: Tracker) {
        self.email = Variable<String?>(email)
        self.password = Variable<String?>(nil)

        self.isRememberedEmail = isRememberedEmail
        self.unauthorizedErrorCount = 0
        self.suggestedEmailVar = Variable<String?>(nil)
        self.source = source
        self.collapsedEmail = collapsedEmail

        self.sessionManager = sessionManager
        self.installationRepository = installationRepository
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
    func closeButtonPressed() {
        navigator?.cancelLogInEmail()
    }
    
    func helpButtonPressed() {
        navigator?.openHelpFromLogInEmail()
    }
    
    func acceptSuggestedEmail() -> Bool {
        guard let suggestedEmail = suggestedEmailVar.value else { return false }
        email.value = suggestedEmail
        return true
    }

    func logInButtonPressed() -> LogInEmailFormErrors {
        var errors: LogInEmailFormErrors = []
        guard logInEnabledVar.value else { return errors }

        // God mode
        if email.value == "admin" && password.value == "wat" {
            delegate?.vmGodModePasswordAlert()
            return errors
        }

        // Form validation
        if let email = email.value {
            if !email.isEmail() {
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

        if let email = email.value, let password = password.value, errors.isEmpty {
            logIn(email: email, password: password)
        } else {
            trackFormValidationFailed(errors: errors)
        }
        return errors
    }

    func godModePasswordTyped(godPassword: String) {
        if godPassword == "mellongod" {
            keyValueStorage[.isGod] = true
        } else {
            delegate?.vmShowAutoFadingMessage("You are not worthy", completion: nil)
        }
    }

    func rememberPasswordButtonPressed() {
        openRememberPassword(email: email.value)
    }

    func footerButtonPressed() {
        openSignUp(email: email.value, password: password.value)
    }
}


// MARK: - Private methods
// MARK: > Rx

fileprivate extension LogInEmailViewModel {
    func setupRx() {
        // Next step is enabled when email & password are not empty
        Observable.combineLatest(email.asObservable(), password.asObservable()) { (email, password) -> Bool in
            guard let email = email, let password = password else { return false }
            return email.characters.count > 0 && password.characters.count > 0
        }.bindTo(logInEnabledVar).addDisposableTo(disposeBag)

        // Email auto suggest
        email.asObservable()
            .map { $0?.suggestEmail(domains: Constants.emailSuggestedDomains) }
            .bindTo(suggestedEmailVar)
            .addDisposableTo(disposeBag)
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

    func savePrevious(email: String?) {
        guard let email = email else { return }
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
            } else if let logInError = loginResult.error {
                self?.logInFailed(logInError: logInError)
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

    func logInFailed(logInError: LoginError) {
        var afterMessageCompletion: (() -> ())? = nil
        if logInError.isScammer {
            afterMessageCompletion = { [weak self] in
                guard let contactURL = self?.scammerContactURL else { return }
                self?.navigator?.openScammerAlertFromLogInEmail(contactURL: contactURL)
            }
        } else if logInError.isDeviceNotAllowed {
            afterMessageCompletion = { [weak self] in
                guard let contactURL = self?.deviceNotAllowedContactURL else { return }
                self?.navigator?.openDeviceNotAllowedAlertFromLogInEmail(contactURL: contactURL)
            }
        } else if logInError.isUnauthorized {
            unauthorizedErrorCount = unauthorizedErrorCount + 1
        }

        if unauthorizedErrorCount >= LogInEmailViewModel.unauthorizedErrorCountRememberPwd && afterMessageCompletion == nil {
            afterMessageCompletion = { [weak self] in
                self?.showRememberPasswordAlert()
            }
        }
        delegate?.vmHideLoading(logInError.errorMessage, afterMessageCompletion: afterMessageCompletion)
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
        let message = LGLocalizedString.resetPasswordSendOk(email.value ?? "")
        delegate?.vmHideLoading(message, afterMessageCompletion: nil)
    }

    func recoverPasswordFailed(error: RecoverPasswordError) {
        trackPasswordRecoverFailed(error: error)

        var message: String? = nil
        switch error {
        case .network:
            message = LGLocalizedString.commonErrorConnectionFailed
        case .notFound:
            message = LGLocalizedString.resetPasswordSendErrorUserNotFoundOrWrongPassword(email.value ?? "")
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
        let title = LGLocalizedString.logInEmailForgotPasswordAlertTitle
        let message = LGLocalizedString.logInEmailForgotPasswordAlertMessage(email.value ?? "")
        let cancelAction = UIAction(interface: .styledText(LGLocalizedString.logInEmailForgotPasswordAlertCancelAction, .cancel),
                                    action: {})
        let recoverPasswordAction = UIAction(interface: .styledText(LGLocalizedString.logInEmailForgotPasswordAlertRememberAction, .destructive),
                                             action: { [weak self] in
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
        let event = TrackerEvent.loginEmail(source, rememberedAccount: isRememberedEmail, collapsedEmail: collapsedEmail)
        tracker.trackEvent(event)
    }

    func trackLogInFailed(error: LoginError) {
        let event = TrackerEvent.loginEmailError(error.trackingError)
        tracker.trackEvent(event)
    }

    func trackPasswordRecoverFailed(error: RecoverPasswordError) {
        let event = TrackerEvent.passwordResetError(error.trackingError)
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
}


// MARK: > Navigation

fileprivate extension LogInEmailViewModel {
    func openRememberPassword(email: String?) {
        navigator?.openRememberPasswordFromLogInEmail(email: email)
    }

    func openSignUp(email: String?, password: String?) {
        navigator?.openSignUpEmailFromLogInEmail(email: email, 
                                                 isRememberedEmail: isRememberedEmail,
                                                 collapsedEmail: collapsedEmail)
    }
}


// MARK: > Helper

fileprivate extension LogInEmailViewModel {
    var scammerContactURL: URL? {
        return LetgoURLHelper.buildContactUsURL(userEmail: email.value,
                                                installation: installationRepository.installation,
                                                type: .scammer)
    }

    var deviceNotAllowedContactURL: URL? {
        return LetgoURLHelper.buildContactUsURL(userEmail: email.value,
                                                installation: installationRepository.installation,
                                                type: .deviceNotAllowed)
    }
}
