//
//  MyUser+AmplitudeUserId.swift
//  LGAnalytics
//
//  Created by Albert Hernández López on 28/03/2018.
//

import LGCoreKit

extension MyUser {
    var amplitudeUserId: String {
        return emailOrId
    }
    
    private var emailOrId: String {
        if let email = email, !email.isEmpty {
            return email
        } else {
            return objectId ?? ""
        }
    }
}
