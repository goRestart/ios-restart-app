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
        case .facebook:
            return .facebook
        case .google:
            return .google
        case .email:
            return .email
        }
    }
}
