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

    func actionButtonPressed() {
        switch type {
        case .Facebook:
            connectWithFacebook()
        case .Google:
            connectWithGoogle()
        case let .Email(present):
            guard let emailToVerify = present else { return }
            emailVerification(emailToVerify)
        }
    }


    // MARK: - Private methods

    func connectWithFacebook() {
        FBLoginHelper.connectWithFacebook { result in
            switch result {
            case let .Success(token):
                print("😜 \(token)")
            case .Cancelled:
                break
            case .Error:
                break
            }
        }
    }

    func connectWithGoogle() {
        googleHelper.googleSignIn { result in
            switch result {
            case let .Success(serverAuthToken):
                print("😜 \(serverAuthToken)")
            case .Cancelled:
                break
            case .Error:
                break
            }
        }
    }

    func emailVerification(email: String) {

    }
}
