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

protocol SignUpEmailStep1Navigator: class {
    func openHelpFromSignUpEmailStep1()
    func openNextStepFromSignUpEmailStep1(email: String, password: String)
    func openLogInFromSignUpEmailStep1(email: String, password: String) // TODO: Call navigator to pop + push login
}

final class SignUpEmailStep1ViewModel: BaseViewModel {
    lazy var helpAction: UIAction = {
        // TODO: New string?
        return UIAction(interface: .text(LGLocalizedString.mainSignUpHelpButton), action: { [weak self] in
            self?.openHelp()
        }, accessibilityId: .SignUpEmailHelpButton)
    }()
    let email: Variable<String>
    let password: Variable<String>
    var nextStepEnabled: Observable<Bool> {
        return nextStepEnabledVar.asObservable()
    }

    weak var navigator: SignUpEmailStep1Navigator?

    fileprivate let source: EventParameterLoginSourceValue
    fileprivate let keyValueStorage: KeyValueStorageable
    fileprivate let nextStepEnabledVar: Variable<Bool>
    fileprivate let disposeBag: DisposeBag


    // MARK: - Lifecycle

//    convenience override init() {
//        let keyValueStorage = KeyValueStorage.sharedInstance
//        self.init(keyValueStorage: keyValueStorage)
//    }

    init(source: EventParameterLoginSourceValue, keyValueStorage: KeyValueStorageable) {
        let email = SignUpEmailStep1ViewModel.readPreviousEmail(fromKeyValueStorageable: keyValueStorage) ?? ""
        self.email = Variable<String>(email)
        self.password = Variable<String>("")

        self.source = source
        self.keyValueStorage = keyValueStorage
        self.nextStepEnabledVar = Variable<Bool>(false)
        self.disposeBag = DisposeBag()
        super.init()

        setupRx()
    }
}


// MARK: - Public methods

extension SignUpEmailStep1ViewModel {
    func openLogIn() {
        openLogIn(email: email.value, password: password.value)
    }

    func openNextStep() -> SignUpEmailStep1FormErrors {
        var errors: SignUpEmailStep1FormErrors = []
        guard nextStepEnabledVar.value else { return errors }

        if !email.value.isEmail() {
            errors.insert(.invalidEmail)
        }
        if password.value.characters.count < Constants.passwordMinLength {
            errors.insert(.shortPassword)
        } else if password.value.characters.count > Constants.passwordMaxLength {
            errors.insert(.longPassword)
        }

        if errors.isEmpty {
            openNextStep(email: email.value, password: password.value)
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
            return email.characters.count > 0 && password.characters.count > 0
        }.bindTo(nextStepEnabledVar).addDisposableTo(disposeBag)
    }
}

// MARK: > Previous email

fileprivate extension SignUpEmailStep1ViewModel {
    static func readPreviousEmail(fromKeyValueStorageable keyValueStorageble: KeyValueStorageable) -> String? {
        // TODO: Check remember pwd AB test (in step 2 :))
        guard let accountProviderString = keyValueStorageble[.previousUserAccountProvider],
              let accountProvider = AccountProvider(rawValue: accountProviderString),
              accountProvider == .email else { return nil }
        return keyValueStorageble[.previousUserEmailOrName]
    }
}


// MARK: > Navigation

fileprivate extension SignUpEmailStep1ViewModel {
    func openHelp() {
        navigator?.openHelpFromSignUpEmailStep1()
    }

    func openNextStep(email: String, password: String) {
        navigator?.openNextStepFromSignUpEmailStep1(email: email, password: password)
    }

    func openLogIn(email: String, password: String) {
        navigator?.openLogInFromSignUpEmailStep1(email: email, password: password)
    }
}
