//
//  WSChatStatus+LG.swift
//  LetGo
//
//  Created by Juan Iglesias on 19/01/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit

extension WSChatStatus {
    var verifiedPending: Bool {
        switch self {
        case .closed, .closing, .opening, .openAuthenticated, .openNotAuthenticated:
            return false
        case .openNotVerified:
            return true
        }
    }
    
    var available: Bool {
        switch self {
        case .closed, .closing, .opening, .openNotVerified, .openNotAuthenticated:
            return false
        case .openAuthenticated:
            return true
        }
    }
}
