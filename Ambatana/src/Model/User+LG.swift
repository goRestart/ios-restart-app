//
//  User+Accounts.swift
//  LetGo
//
//  Created by Albert Hernández López on 15/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

enum UserReputationBadge: String {
    case noBadge = ""
    case silver = "silver"
    case gold = "gold"
}

extension User {
    var facebookAccount: Account? {
        return accountWithProvider(.facebook)
    }
    var googleAccount: Account? {
        return accountWithProvider(.google)
    }
    var emailAccount: Account? {
        return accountWithProvider(.email)
    }
    private func accountWithProvider(_ provider: AccountProvider) -> Account? {
        return accounts.filter { $0.provider == provider }.first
    }
    var isVerified: Bool {
        return accounts.filter { $0.verified }.count > 0
    }
    var reputationBadge: UserReputationBadge {
        return reputationPoints >= Constants.Reputation.minScore ? .silver : .noBadge
    }
    var hasBadge: Bool {
        return reputationBadge != .noBadge
    }
}

extension User {
    var shortName: String? {
        return name?.trunc(18)
    }
}

extension User {
    var isProfessional: Bool {
        switch self.type {
        case .dummy, .user:
            return false
        case .pro:
            return true
        }
    }
}
