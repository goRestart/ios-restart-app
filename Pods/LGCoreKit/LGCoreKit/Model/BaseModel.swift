//
//  BaseModel.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 30/04/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Foundation

@objc public protocol BaseModel {
    var objectId: String! { get }
    var updatedAt: NSDate! { get }
    var createdAt: NSDate! { get }
}