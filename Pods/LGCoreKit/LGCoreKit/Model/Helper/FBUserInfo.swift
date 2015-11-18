//
//  FBUserInfo.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 09/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Foundation

public class FBUserInfo {
    public let facebookId: String
    public let name: String?
    public let firstName: String?
    public let lastName: String?
    public let email: String?
    public let avatarURL: NSURL
    
    public init(facebookId: String, name: String?, firstName: String?, lastName: String?, email: String?, avatarURL: NSURL) {
        self.facebookId = facebookId
        self.name = name
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.avatarURL = avatarURL
    }
}