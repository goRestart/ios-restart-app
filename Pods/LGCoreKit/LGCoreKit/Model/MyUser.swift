//
//  MyUser.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 28/10/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

public protocol MyUser: class, User {

    //MyUser only vars
    var username: String? { get set }
    var password: String? { get set }
    var email: String? { get set }
    var gpsCoordinates: LGLocationCoordinates2D? { get set }

    //TODO: CHANGE TO BOOL
    var processed: NSNumber? { get set }

    var isAnonymous: Bool { get }
    var isScammer: NSNumber? { get }

    var sessionToken: String? { get }

    var didLogInByFacebook: Bool { get }
    
    //User vars
    var publicUsername: String? { get set }
    var avatar: File? { get set }
    var postalAddress: PostalAddress { get set }
    var isDummy: Bool { get }
}
