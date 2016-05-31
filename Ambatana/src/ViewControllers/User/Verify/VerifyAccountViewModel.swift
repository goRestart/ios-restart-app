//
//  VerifyAccountViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 31/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

enum VerificationType {
    case Facebook, Google, Email(present: String?)
}

protocol VerifyAccountViewModelDelegate: BaseViewModelDelegate {

}


class VerifyAccountViewModel: BaseViewModel {

    weak var delegate: VerifyAccountViewModelDelegate?
    let type: VerificationType

    init(verificationType: VerificationType) {
        self.type = verificationType
    }



    // MARK: - Public Methods

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
        
    }

    func connectWithGoogle() {

    }

    func emailVerification(email: String) {

    }
}
