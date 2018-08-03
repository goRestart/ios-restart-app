//
//  PasswordlessEmailSentViewModel.swift
//  LetGo
//
//  Created by Sergi Gracia on 30/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation
import LGComponents

final class PasswordlessEmailSentViewModel: BaseViewModel {

    weak var navigator: PasswordlessNavigator?
    let email: String

    init(email: String) {
        self.email = email
    }

    func didTapClose() {
        navigator?.closePasswordlessEmailSent()
    }

    func didTapHelp() {
        navigator?.openHelpFromPasswordless()
    }
}
