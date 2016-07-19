//
//  User.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 03/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

public protocol User: BaseModel {
    var name: String? { get }
    var avatar: File? { get }
    var postalAddress: PostalAddress { get }

    var accounts: [Account]? { get }    // TODO: When switching to bouncer only make ratings & accounts non-optional
    var ratingAverage: Float? { get }
    var ratingCount: Int? { get }

    var status: UserStatus { get }
    
    var isDummy: Bool { get }
}
