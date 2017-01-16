//
//  SignUpEmailStep2ViewModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 11/01/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import RxSwift

enum SignUpEmailStep2FormError {
    case invalidEmail
    case invalidPassword
    case usernameContainsLetgo
    case shortUsername
}

protocol SignUpEmailStep2Navigator: class {
    func openHelpFromSignUpEmailStep2()
    func closeAfterSignUpSuccessful()
}

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

    weak var navigator: SignUpEmailStep2Navigator?

    fileprivate let password: String
    fileprivate let featureFlags: FeatureFlaggeable
    fileprivate let signUpEnabledVar: Variable<Bool>
    fileprivate let disposeBag: DisposeBag


    // MARK : - Lifecycle

    convenience init(email: String, password: String) {
        self.init(email: email, password: password, featureFlags: FeatureFlags.sharedInstance)
    }

    init(email: String, password: String, featureFlags: FeatureFlaggeable) {
        self.email = email
        self.username = Variable<String>("")
        self.termsAndConditionsAccepted = Variable<Bool>(false)
        self.newsLetterAccepted = Variable<Bool>(false)

        self.password = password
        self.featureFlags = featureFlags
        self.signUpEnabledVar = Variable<Bool>(false)
        self.disposeBag = DisposeBag()
    }
}


// MARK: - Public methods

extension SignUpEmailStep2ViewModel {
    func signUp() -> [SignUpEmailStep2FormError] {
        guard signUpEnabledVar.value else { return [] }

        var errors: [SignUpEmailStep2FormError] = []
        if !email.isEmail() {
            errors.append(.invalidEmail)
        }
        if password.characters.count < Constants.passwordMinLength ||
           password.characters.count > Constants.passwordMaxLength{
            errors.append(.invalidPassword)
        }
        let trimmedUsername = username.value.trim
        if trimmedUsername.containsLetgo() {
            errors.append(.usernameContainsLetgo)
        }
        if trimmedUsername.characters.count < Constants.fullNameMinLength {
            errors.append(.shortUsername)
        }

        if errors.isEmpty {
            signUp(email: email, password: password, username: trimmedUsername)
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
    func signUp(email: String, password: String, username: String) {

    }
}


// MARK: > Navigation

fileprivate extension SignUpEmailStep2ViewModel {
    func openHelp() {
        navigator?.openHelpFromSignUpEmailStep2()
    }
}
