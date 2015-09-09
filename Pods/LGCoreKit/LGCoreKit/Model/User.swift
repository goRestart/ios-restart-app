//
//  User.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 03/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

@objc public protocol User: BaseModel {
    var username: String? { get set }
    var password: String? { get set }
    var email: String? { get set }
    var publicUsername: String? { get set }

    var avatar: File? { get set }
    
    var gpsCoordinates: LGLocationCoordinates2D? { get set }
    var postalAddress: PostalAddress { get set }
    
    var processed: NSNumber? { get set }
    
    var isDummy: Bool { get }
    var isAnonymous: Bool { get }
    
    var sessionToken: String? { get }
}