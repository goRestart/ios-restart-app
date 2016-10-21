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
        guard let payload = try? JWT.decode(self, algorithm: .HS256(""), verify: false),
            data = payload["data"] as? [String: AnyObject], roles = data["roles"] as? [String] else {
                return nil
        }
        if roles.contains("user") {
            return .User
        } else if roles.contains("app") {
            return .Installation
        } else {
            return .None
        }
    }
}
