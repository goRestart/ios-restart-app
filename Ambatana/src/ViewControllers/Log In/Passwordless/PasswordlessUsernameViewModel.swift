//
//  PasswordlessUsernameViewModel.swift
//  LetGo
//
//  Created by Isaac Roldan on 30/4/18.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

final class PasswordlessUsernameViewModel: BaseViewModel {

    private let myUserRepository: MyUserRepository
    private let tracker: Tracker
    var delegate: BaseViewModelDelegate?

    init(myUserRepository: MyUserRepository, tracker: Tracker) {
        self.myUserRepository = myUserRepository
        self.tracker = tracker
    }

    func didTapDoneWith(name: String) {
        myUserRepository.updateName(name) { [weak self] result in
            if let _ = result.value {
                // Close view
            } else {
                self?.delegate?.vmShowAlert(LGLocalizedString.commonErrorTitle,
                                      message: LGLocalizedString.commonError,
                                      cancelLabel: LGLocalizedString.commonOk,
                                      actions: [])
            }
        }
    }

    func didTapHelp() {
        // FIXME: implement
    }
}
