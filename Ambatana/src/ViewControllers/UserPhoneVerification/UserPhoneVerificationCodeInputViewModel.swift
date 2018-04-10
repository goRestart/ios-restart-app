//
//  UserPhoneVerificationCodeInputViewModel.swift
//  LetGo
//
//  Created by Sergi Gracia on 05/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit

final class UserPhoneVerificationCodeInputViewModel: BaseViewModel {

    weak var navigator: UserPhoneVerificationNavigator?

    init(fake: String? = "") {
        super.init()
    }
}
