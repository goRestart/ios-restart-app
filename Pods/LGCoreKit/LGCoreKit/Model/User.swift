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
    var accounts: [Account]? { get }    // TODO: When switching to bouncer only make accounts non-optional
    
    var isDummy: Bool { get }
}
