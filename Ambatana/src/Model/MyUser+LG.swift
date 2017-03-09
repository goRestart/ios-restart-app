//
//  MyUser+LG.swift
//  LetGo
//
//  Created by Eli Kohen on 09/03/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

extension MyUser {
    var emailOrId: String {
        if let email = email, !email.isEmpty {
            return email
        } else {
            return objectId ?? ""
        }
    }
}
