//
//  VerifyAccountViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 31/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

protocol VerifyAccountDelegate: class {
    func accountVerified(type: VerificationType)
}

enum VerificationType {
    case Facebook, Google, Email(String?)
}

enum ActionState {
    case Disabled, Loading, Enabled
}


class VerifyAccountViewModel: BaseViewModel {

    weak var verificationDelegate: VerifyAccountDelegate?
    weak var delegate: BaseViewModelDelegate?
    let type: VerificationType

    let actionState = Variable<ActionState> (.Disabled)
    let typedEmail = Variable<String?>(nil)

    private let googleHelper: GoogleLoginHelper
    private let myUserRepository: MyUserRepository

    private let disposeBag = DisposeBag()

    convenience init(verificationType: VerificationType) {
        let myUserRepository = Core.myUserRepository
        let googleHelper = GoogleLoginHelper(loginSource: .Profile)
        self.init(verificationType: verificationType, myUserRepository: myUserRepository, googleHelper: googleHelper)
    }

    init(verificationType: VerificationType, myUserRepository: MyUserRepository, googleHelper: GoogleLoginHelper) {
        self.type = verificationType
        self.myUserRepository = myUserRepository
        self.googleHelper = googleHelper

        super.init()

        setupState()
        setupRxBindings()
    }


    // MARK: - Public Methods

    func closeButtonPressed() {
        delegate?.vmDismiss(nil)
    }

    func actionButtonPressed() {
        switch type {
        case .Facebook:
            connectWithFacebook()
        case .Google:
            connectWithGoogle()
        case let .Email(current):
            let email = current ?? typedEmail.value
            guard let emailToVerify = email else { return }
            emailVerification(emailToVerify.trim)
        }
    }


    // MARK: - Private methods

    func setupState() {
        switch type {
        case .Facebook, .Google:
            actionState.value = .Enabled
        case let .Email(current):
            actionState.value = current != nil ? .Enabled : .Disabled
        }
    }

    func setupRxBindings() {
        switch type {
        case .Facebook, .Google:
            break
        case let .Email(present):
            guard present == nil else { break }
            typedEmail.asObservable().bindNext { [weak self] email in
                guard let actionState = self?.actionState where actionState.value != .Loading else { return }
                let isEmail = email?.isEmail() ?? false
                actionState.value = isEmail ? .Enabled : .Disabled
                }.addDisposableTo(disposeBag)
        }
    }

    func connectWithFacebook() {
        actionState.value = .Loading
        FBLoginHelper.connectWithFacebook { [weak self] result in
            self?.actionState.value = .Enabled
            switch result {
            case let .Success(token):
                self?.myUserRepository.linkAccountFacebook(token) { result in
                    if let _ = result.value {
                        self?.verificationSuccess()
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
        actionState.value = .Loading
        googleHelper.googleSignIn { [weak self] result in
            self?.actionState.value = .Enabled
            switch result {
            case let .Success(serverAuthToken):
                self?.myUserRepository.linkAccountGoogle(serverAuthToken) { result in
                    if let _ = result.value {
                        self?.verificationSuccess()
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
        actionState.value = .Loading
        myUserRepository.linkAccount(email) { [weak self] result in
            self?.actionState.value = .Enabled
            if let error = result.error {
                switch error {
                case .TooManyRequests:
                    self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.profileVerifyEmailTooManyRequests, completion: nil)
                case .Network:
                    self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.commonErrorNetworkBody, completion: nil)
                case .Forbidden, .Internal, .NotFound, .Unauthorized, .UserNotVerified:
                    self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.commonErrorGenericBody, completion: nil)
                }
            } else {
                self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.profileVerifyEmailSuccess) {
                    self?.delegate?.vmDismiss(nil)
                }
            }
        }
    }

    func verificationSuccess() {
        verificationDelegate?.accountVerified(type)
    }
}
