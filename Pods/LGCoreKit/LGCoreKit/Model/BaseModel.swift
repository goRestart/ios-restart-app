//
//  BaseModel.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 30/04/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

public protocol BaseModel: class {
    var objectId: String? { get set }
    var updatedAt: NSDate? { get }
    var createdAt: NSDate? { get }
    
    var isSaved: Bool { get }
}