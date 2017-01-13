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
        return UIAction(interface: .Text(LGLocalizedString.mainSignUpHelpButton), action: { [weak self] in
            self?.openHelp()
        }, accessibilityId: .SignUpEmailHelpButton)
    }()
    let email: String
    let username: Variable<String>
    let termsAndConditionsAcceptRequired: Bool
    let termsAndConditionsAccepted: Variable<Bool>
    let newsLetterAcceptRequired: Bool
    let newsLetterAccepted: Variable<Bool>
    var signUpEnabled: Observable<Bool> {
        return signUpEnabledVar.asObservable()
    }

    weak var navigator: SignUpEmailStep2Navigator?

    private let password: String
    private let signUpEnabledVar: Variable<Bool>
    private let disposeBag: DisposeBag


    // MARK : - Lifecycle

    init(email: String, password: String) {
        self.email = email
        self.username = Variable<String>("")
        self.termsAndConditionsAcceptRequired = false   // TODO: Rely on country (AB test)
        self.termsAndConditionsAccepted = Variable<Bool>(false)
        self.newsLetterAcceptRequired = false
        self.newsLetterAccepted = Variable<Bool>(false)

        self.password = password
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
        let trimmedUsername = username.value.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if SignUpEmailStep2ViewModel.containsLetgo(trimmedUsername) {
            errors.append(.usernameContainsLetgo)
        }
        if trimmedUsername.characters.count < Constants.fullNameMinLength {
            errors.append(.shortUsername)
        }

        if errors.isEmpty {
            signUp(email: email, password: password, username: username.value)
        }
        return errors
    }
}


// MARK: - Private methods
// MARK: > Rx

private extension SignUpEmailStep2ViewModel {
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

private extension SignUpEmailStep2ViewModel {
    func signUp(email email: String, password: String, username: String) {

    }
}


// MARK: > Navigation

private extension SignUpEmailStep2ViewModel {
    func openHelp() {
        navigator?.openHelpFromSignUpEmailStep2()
    }
}


// MARK: > Helper

// TODO: move this method as String extension and test it
private extension SignUpEmailStep2ViewModel {
    static func containsLetgo(string: String) -> Bool {
        let lowercaseString = string.lowercaseString
        return lowercaseString.rangeOfString("letgo") != nil ||
            lowercaseString.rangeOfString("ietgo") != nil ||
            lowercaseString.rangeOfString("letg0") != nil ||
            lowercaseString.rangeOfString("ietg0") != nil ||
            lowercaseString.rangeOfString("let go") != nil ||
            lowercaseString.rangeOfString("iet go") != nil ||
            lowercaseString.rangeOfString("let g0") != nil ||
            lowercaseString.rangeOfString("iet g0") != nil
    }
}
