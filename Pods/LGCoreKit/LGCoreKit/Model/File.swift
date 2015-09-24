//
//  File.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 08/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Foundation

@objc public protocol File {   
    var fileURL: NSURL? { get }
    var isSaved: Bool { get }
    var token: String? { get }
}