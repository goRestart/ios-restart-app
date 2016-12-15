//
//  AccountProvider+LG.swift
//  LetGo
//
//  Created by Eli Kohen on 15/12/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

extension AccountProvider {
    var accountNetwork: EventParameterAccountNetwork {
        switch self {
        case .Facebook:
            return .Facebook
        case .Google:
            return .Google
        case .Email:
            return .Email
        }
    }
}
