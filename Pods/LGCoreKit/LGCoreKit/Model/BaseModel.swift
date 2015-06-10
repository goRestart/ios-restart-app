//
//  BaseModel.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 30/04/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

@objc public protocol BaseModel {
    var objectId: String! { get }
    var updatedAt: NSDate! { get }
    var createdAt: NSDate! { get }
    
    var isSaved: Bool { get }
}