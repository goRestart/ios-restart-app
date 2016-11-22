//
//  SessionEvent+LG.swift
//  LetGo
//
//  Created by Eli Kohen on 22/11/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

extension SessionEvent {
    var isLogin: Bool {
        switch self {
        case .Login:
            return true
        case .Logout:
            return false
        }
    }

    var isLogout: Bool {
        switch self {
        case .Login:
            return false
        case .Logout:
            return true
        }
    }
}
