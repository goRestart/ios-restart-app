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
        case .login:
            return true
        case .logout:
            return false
        }
    }

    var isLogout: Bool {
        switch self {
        case .login:
            return false
        case .logout:
            return true
        }
    }
}
