//
//  PartialUser.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 02/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

public protocol ProductUser {
    var objectId: String? { get set }
    
    var publicUsername: String? { get set }
    var avatarURL: NSURL? { get set }

    var postalAddress: PostalAddress? { get set }
}


