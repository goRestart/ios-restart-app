//
//  LocalAccount.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 14/04/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

struct LocalAccount: Account, UserDefaultsDecodable {
    let provider: AccountProvider
    let verified: Bool

    init(provider: AccountProvider, verified: Bool) {
        self.provider = provider
        self.verified = verified
    }

    init(account: Account) {
        self.init(provider: account.provider, verified: account.verified)
    }
}

// MARK: - UserDefaultsDecodable

private struct AccountUDKeys {
    static let provider = "provider"
    static let verified = "verified"
}

extension LocalAccount {
    static func decode(_ dictionary: [String: Any]) -> LocalAccount? {
        guard let providerRawValue = dictionary[AccountUDKeys.provider] as? String else { return nil }
        guard let provider = AccountProvider(rawValue: providerRawValue) else { return nil }
        guard let verified = dictionary[AccountUDKeys.verified] as? Bool else { return nil }
        return self.init(provider: provider, verified: verified)
    }

    func encode() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        dictionary[AccountUDKeys.provider] = provider.rawValue
        dictionary[AccountUDKeys.verified] = verified
        return dictionary
    }
}
