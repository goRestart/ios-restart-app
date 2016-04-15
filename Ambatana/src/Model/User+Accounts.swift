//
//  User+Accounts.swift
//  LetGo
//
//  Created by Albert Hernández López on 15/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

extension User {
    var facebookAccount: Account? {
        return accountWithProvider(.Facebook)
    }
    var googleAccount: Account? {
        return accountWithProvider(.Google)
    }
    var emailAccount: Account? {
        return accountWithProvider(.Email)
    }
    private func accountWithProvider(provider: AccountProvider) -> Account? {
        return accounts?.filter { $0.provider == provider }.first
    }
}

