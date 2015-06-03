//
//  LGProductUser.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 02/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

@objc public class LGProductUser: ProductUser {
    
    // ProductUser iVars
    public var objectId: String?
    
    public var publicUsername: String?
    public var avatarURL: NSURL?
    
    public var postalAddress: PostalAddress?
}