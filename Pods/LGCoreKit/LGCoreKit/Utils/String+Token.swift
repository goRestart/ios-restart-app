//
//  String+Token.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 19/10/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import JWT

extension String {
    var tokenAuthLevel: AuthLevel? {
        guard let roles = tokenRoles else { return nil }

        if roles.contains("user") {
            return .user
        } else if roles.contains("app") {
            return .installation
        } else {
            return .none
        }
    }

    var isPasswordRecoveryToken: Bool {
        guard let roles = tokenRoles else { return false }

        return roles.contains("password_recovery")
    }

    private var tokenRoles: [String]? {
        guard let payload = try? JWT.decode(self, algorithm: .hs256(Data()), verify: false),
            let data = payload["data"] as? [String: Any] else {
                return nil
        }
        return data["roles"] as? [String]
    }
}
