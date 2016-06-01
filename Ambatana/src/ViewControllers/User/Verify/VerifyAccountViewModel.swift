//
//  VerifyAccountViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 31/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

enum VerificationType {
    case Facebook, Google, Email(present: String?)
}

protocol VerifyAccountViewModelDelegate: BaseViewModelDelegate {
}


class VerifyAccountViewModel: BaseViewModel {

    weak var delegate: VerifyAccountViewModelDelegate?
    let type: VerificationType

    private let googleHelper: GoogleLoginHelper
    private let myUserRepository: MyUserRepository

    convenience init(verificationType: VerificationType) {
        let myUserRepository = Core.myUserRepository
        let googleHelper = GoogleLoginHelper(loginSource: .Profile)
        self.init(verificationType: verificationType, myUserRepository: myUserRepository, googleHelper: googleHelper)
    }

    init(verificationType: VerificationType, myUserRepository: MyUserRepository, googleHelper: GoogleLoginHelper) {
        self.type = verificationType
        self.myUserRepository = myUserRepository
        self.googleHelper = googleHelper
    }


    // MARK: - Public Methods

    func closeButtonPressed() {
        delegate?.vmDismiss(nil)
    }

    func actionButtonPressed(typedEmail: String?) {
        switch type {
        case .Facebook:
            connectWithFacebook()
        case .Google:
            connectWithGoogle()
        case let .Email(present):
            let email = present ?? typedEmail
            guard let emailToVerify = email else { return }
            emailVerification(emailToVerify)
        }
    }


    // MARK: - Private methods

    func connectWithFacebook() {
        FBLoginHelper.connectWithFacebook { [weak self] result in
            switch result {
            case let .Success(token):
                self?.myUserRepository.linkAccountFacebook(token) { result in
                    if let _ = result.value {
                        self?.delegate?.vmDismiss(nil)
                    } else {
                        self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.mainSignUpFbConnectErrorGeneric, completion: nil)
                    }
                }
            case .Cancelled:
                break
            case .Error:
                self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.mainSignUpFbConnectErrorGeneric, completion: nil)
            }
        }
    }

    func connectWithGoogle() {
        googleHelper.googleSignIn { [weak self] result in
            switch result {
            case let .Success(serverAuthToken):
                self?.myUserRepository.linkAccountGoogle(serverAuthToken) { result in
                    if let _ = result.value {
                        self?.delegate?.vmDismiss(nil)
                    } else {
                        self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.mainSignUpFbConnectErrorGeneric, completion: nil)
                    }
                }
            case .Cancelled:
                break
            case .Error:
                self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.mainSignUpFbConnectErrorGeneric, completion: nil)
            }
        }
    }

    func emailVerification(email: String) {
        myUserRepository.linkAccount(email) { [weak self] result in
            if let _ = result.value {
                self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.profileVerifyEmailSuccess) {
                    self?.delegate?.vmDismiss(nil)
                }
            } else {
            }
        }
    }
}
