//
//  UserUserRelation.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 10/02/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

public protocol UserUserRelation {
    var isBlocked: Bool { get } //False as default
    var isBlocking: Bool { get }  //False as default
}
