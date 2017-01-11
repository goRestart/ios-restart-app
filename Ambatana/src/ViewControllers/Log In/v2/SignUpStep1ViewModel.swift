//
//  SignUpStep1ViewModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 11/01/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

enum SignUpStep1FormError {
    case invalidEmail
    case shortPassword
    case longPassword
}

protocol SignUpStep1Navigator: class {
    func openHelpFromSignUpStep1()
    func openNextStepFromSignUpStep1(email email: String, password: String)
    func openLogInFromSignUpStep1(email email: String, password: String) // TODO: Call navigator to pop + push login
}

final class SignUpStep1ViewModel: BaseViewModel {
    let email: Variable<String>
    let password: Variable<String>
    var nextStepEnabled: Observable<Bool> {
        return nextStepEnabledVar.asObservable()
    }
    lazy var helpAction: UIAction = {
        return UIAction(interface: .Text(LGLocalizedString.mainSignUpHelpButton), action: { [weak self] in
            self?.openHelp()
        }, accessibilityId: .SignUpStep1HelpButton)
    }()

    weak var navigator: SignUpStep1Navigator?

    private let keyValueStorage: KeyValueStorageable
    private let nextStepEnabledVar: Variable<Bool>
    private let disposeBag: DisposeBag


    // MARK: - Lifecycle

//    convenience override init() {
//        let keyValueStorage = KeyValueStorage.sharedInstance
//        self.init(keyValueStorage: keyValueStorage)
//    }

    init(keyValueStorage: KeyValueStorageable) {
        let email = SignUpStep1ViewModel.readPreviousEmail(fromKeyValueStorageable: keyValueStorage) ?? ""
        self.email = Variable<String>(email)
        self.password = Variable<String>("")

        self.keyValueStorage = keyValueStorage
        self.nextStepEnabledVar = Variable<Bool>(false)
        self.disposeBag = DisposeBag()
        super.init()

        setupRx()
    }
}


// MARK: - Public methods
extension SignUpStep1ViewModel {
    func openLogIn() {
        openLogIn(email: email.value, password: password.value)
    }

    func openNextStep() -> [SignUpStep1FormError] {
        var errors: [SignUpStep1FormError] = []
        guard nextStepEnabledVar.value else { return errors }

        if !email.value.isEmail() {
            errors.append(.invalidEmail)
        }

        if password.value.characters.count < Constants.passwordMinLength {
            errors.append(.shortPassword)
        } else if password.value.characters.count > Constants.passwordMaxLength {
            errors.append(.longPassword)
        }

        if errors.isEmpty {
            openNextStep(email: email.value, password: password.value)
        }
        return errors
    }
}


// MARK: - Private methods
// MARK: > Rx

private extension SignUpStep1ViewModel {
    func setupRx() {
        // Next step is enabled when email & password are not empty
        Observable.combineLatest(email.asObservable(), password.asObservable()) { (email, password) -> Bool in
            return email.characters.count > 0 && password.characters.count > 0
        }.bindTo(nextStepEnabledVar).addDisposableTo(disposeBag)
    }
}

// MARK: > Previous email

private extension SignUpStep1ViewModel {
    static func readPreviousEmail(fromKeyValueStorageable keyValueStorageble: KeyValueStorageable) -> String? {
        // TODO: Check remember pwd AB test (in step 2 :))
        guard let accountProviderString = keyValueStorageble[.previousUserAccountProvider],
                  accountProvider = AccountProvider(rawValue: accountProviderString)
                  where accountProvider == .Email else { return nil }
        return keyValueStorageble[.previousUserEmailOrName]
    }

    func savePrevious(email email: String) {
        keyValueStorage[.previousUserAccountProvider] = AccountProvider.Email.rawValue
        keyValueStorage[.previousUserEmailOrName] = email
    }
}


// MARK: > Navigation

private extension SignUpStep1ViewModel {
    func openHelp() {
        navigator?.openHelpFromSignUpStep1()
    }

    func openNextStep(email email: String, password: String) {
        navigator?.openNextStepFromSignUpStep1(email: email, password: password)
    }

    func openLogIn(email email: String, password: String) {
        navigator?.openLogInFromSignUpStep1(email: email, password: password)
    }
}
