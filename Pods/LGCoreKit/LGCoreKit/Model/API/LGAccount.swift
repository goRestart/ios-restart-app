//
//  LGAccount.swift
//  LGCoreKit
//
//  Created by Nestor on 24/10/2017.
//  Copyright © 2017 Nestor. All rights reserved.
//

import Foundation

struct LGAccount: Account, Decodable {
    let provider: AccountProvider
    let verified: Bool

    init(provider: AccountProvider, verified: Bool) {
        self.provider = provider
        self.verified = verified
    }
    
    init(account: Account) {
        self.init(provider: account.provider, verified: account.verified)
    }
    
    // MARK: - Decodable
    
    /*
     {
     "type": "letgo",
     "verified": true
     }
     */
    
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        provider = try keyedContainer.decode(AccountProvider.self, forKey: .provider)
        verified = try keyedContainer.decode(Bool.self, forKey: .verified)
    }
    
    enum CodingKeys: String, CodingKey {
        case provider = "type"
        case verified
    }
}
