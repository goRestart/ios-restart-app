//
//  ResponseObjectSerializable.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 01/07/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

@objc public protocol ResponseObjectSerializable {
    init?(response: NSHTTPURLResponse, representation: AnyObject)
}

