//
//  PasswordlessUsernameViewModel.swift
//  LetGo
//
//  Created by Isaac Roldan on 30/4/18.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
import LGComponents

final class PasswordlessUsernameViewModel: BaseViewModel {

    private let myUserRepository: MyUserRepository
    private let tracker: Tracker
    private let token: String
    weak var delegate: BaseViewModelDelegate?
    weak var navigator: PasswordlessUsernameNavigator?

    init(myUserRepository: MyUserRepository, tracker: Tracker, token: String) {
        self.myUserRepository = myUserRepository
        self.tracker = tracker
        self.token = token
    }

    convenience init(token: String) {
        self.init(myUserRepository: Core.myUserRepository,
                  tracker: TrackerProxy.sharedInstance,
                  token: token)
    }

    func didTapDoneWith(name: String) {
        myUserRepository.updateName(name) { [weak self] result in
            if let _ = result.value {
                self?.navigator?.closePasswordlessConfirmUsername()
            } else {
                self?.delegate?.vmShowAlert(R.Strings.commonErrorTitle,
                                      message: R.Strings.commonError,
                                      cancelLabel: R.Strings.commonOk,
                                      actions: [])
            }
        }
    }

    func didTapHelp() {
        navigator?.openHelp()
    }
}
