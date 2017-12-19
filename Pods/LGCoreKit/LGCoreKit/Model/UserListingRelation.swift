//
//  UserListingRelation.swift
//  LGCoreKit
//
//  Created by Dídac on 21/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

public protocol UserListingRelation {
    var isFavorited: Bool { get } //False as default
    var isReported: Bool { get }  //False as default
}

