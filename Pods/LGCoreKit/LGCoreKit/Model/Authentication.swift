//
//  Authentication.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 17/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

protocol Authentication {
    var myUserId: String { get }
    var token: String { get }
}
