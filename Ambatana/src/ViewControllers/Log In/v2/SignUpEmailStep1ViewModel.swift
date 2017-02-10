//
//  SignUpStep1ViewModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 11/01/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

struct SignUpEmailStep1FormErrors: OptionSet {
    let rawValue: Int

    static let invalidEmail     = SignUpEmailStep1FormErrors(rawValue: 1 << 0)
    static let shortPassword    = SignUpEmailStep1FormErrors(rawValue: 1 << 1)
    static let longPassword     = SignUpEmailStep1FormErrors(rawValue: 1 << 2)
}

final class SignUpEmailStep1ViewModel: BaseViewModel {
    let email: Variable<String?>
    var suggestedEmail: Observable<String?> {
        return suggestedEmailVar.asObservable()
    }
    let password: Variable<String?>
    var nextStepEnabled: Observable<Bool> {
        return nextStepEnabledVar.asObservable()
    }

    weak var navigator: SignUpEmailStep1Navigator?

    fileprivate let isRememberedEmail: Bool
    fileprivate let suggestedEmailVar: Variable<String?>
    fileprivate let source: EventParameterLoginSourceValue
    fileprivate let collapsedEmail: EventParameterCollapsedEmailField?
    fileprivate let keyValueStorage: KeyValueStorageable
    fileprivate let nextStepEnabledVar: Variable<Bool>
    fileprivate let tracker: Tracker
    fileprivate let disposeBag: DisposeBag


    // MARK: - Lifecycle

    convenience init(source: EventParameterLoginSourceValue,
                     collapsedEmail: EventParameterCollapsedEmailField?) {
        self.init(source: source,
                  collapsedEmail: collapsedEmail,
                  keyValueStorage: KeyValueStorage.sharedInstance)
    }

    convenience init(source: EventParameterLoginSourceValue,
                     collapsedEmail: EventParameterCollapsedEmailField?,
                     keyValueStorage: KeyValueStorageable) {
        let email = SignUpEmailStep1ViewModel.readPreviousEmail(fromKeyValueStorageable: keyValueStorage)
        let isRememberedEmail = email != nil
        self.init(email: email,
                  isRememberedEmail: isRememberedEmail,
                  source: source,
                  collapsedEmail: collapsedEmail,
                  keyValueStorage: keyValueStorage,
                  tracker: TrackerProxy.sharedInstance)
    }

    convenience init(email: String?,
                     isRememberedEmail: Bool,
                     source: EventParameterLoginSourceValue,
                     collapsedEmail: EventParameterCollapsedEmailField?) {
        self.init(email: email,
                  isRememberedEmail: isRememberedEmail,
                  source: source,
                  collapsedEmail: collapsedEmail,
                  keyValueStorage: KeyValueStorage.sharedInstance,
                  tracker: TrackerProxy.sharedInstance)
    }

    init(email: String?,
         isRememberedEmail: Bool,
         source: EventParameterLoginSourceValue,
         collapsedEmail: EventParameterCollapsedEmailField?,
         keyValueStorage: KeyValueStorageable,
         tracker: Tracker) {
        self.email = Variable<String?>(email)
        self.password = Variable<String?>(nil)

        self.isRememberedEmail = isRememberedEmail
        self.suggestedEmailVar = Variable<String?>(nil)
        self.source = source
        self.collapsedEmail = collapsedEmail
        self.keyValueStorage = keyValueStorage
        self.nextStepEnabledVar = Variable<Bool>(false)
        self.tracker = tracker
        self.disposeBag = DisposeBag()
        super.init()

        setupRx()
    }
}


// MARK: - Public methods

extension SignUpEmailStep1ViewModel {
    func openHelp() {
        navigator?.openHelpFromSignUpEmailStep1()
    }

    func acceptSuggestedEmail() {
        guard let suggestedEmail = suggestedEmailVar.value else { return }
        email.value = suggestedEmail
    }

    func openLogIn() {
        openLogIn(email: email.value, password: password.value)
    }

    func openNextStep() -> SignUpEmailStep1FormErrors {
        var errors: SignUpEmailStep1FormErrors = []
        guard nextStepEnabledVar.value else { return errors }

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
            openNextStep(email: email, password: password)
        } else {
            trackFormValidationFailed(errors: errors)
        }
        return errors
    }
}


// MARK: - Private methods
// MARK: > Rx

fileprivate extension SignUpEmailStep1ViewModel {
    func setupRx() {
        // Next step is enabled when email & password are not empty
        Observable.combineLatest(email.asObservable(), password.asObservable()) { (email, password) -> Bool in
            guard let email = email, let password = password else { return false }
            return email.characters.count > 0 && password.characters.count > 0
        }.bindTo(nextStepEnabledVar).addDisposableTo(disposeBag)

        // Email auto suggest
        email.asObservable()
            .map { $0?.suggestEmail(domains: Constants.emailSuggestedDomains) }
            .bindTo(suggestedEmailVar)
            .addDisposableTo(disposeBag)
    }
}

// MARK: > Previous email

fileprivate extension SignUpEmailStep1ViewModel {
    static func readPreviousEmail(fromKeyValueStorageable keyValueStorageble: KeyValueStorageable) -> String? {
        guard let accountProviderString = keyValueStorageble[.previousUserAccountProvider],
              let accountProvider = AccountProvider(rawValue: accountProviderString),
              accountProvider == .email else { return nil }
        return keyValueStorageble[.previousUserEmailOrName]
    }
}


// MARK: > Tracking

fileprivate extension SignUpEmailStep1ViewModel {
    func trackFormValidationFailed(errors: SignUpEmailStep1FormErrors) {
        guard let error = errors.trackingError else { return }
        let event = TrackerEvent.signupError(error)
        tracker.trackEvent(event)
    }
}

fileprivate extension SignUpEmailStep1FormErrors {
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

fileprivate extension SignUpEmailStep1ViewModel {
    func openNextStep(email: String, password: String) {
        navigator?.openNextStepFromSignUpEmailStep1(email: email, password: password,
                                                    isRememberedEmail: isRememberedEmail,
                                                    collapsedEmail: collapsedEmail)
    }

    func openLogIn(email: String?, password: String?) {
        navigator?.openLogInFromSignUpEmailStep1(email: email,
                                                 isRememberedEmail: isRememberedEmail,
                                                 collapsedEmail: collapsedEmail)
    }
}
