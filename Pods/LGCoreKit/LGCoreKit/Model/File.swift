//
//  File.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 08/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Foundation

public func ==(lhs: File, rhs: File) -> Bool {
    return lhs.fileURL == rhs.fileURL && lhs.objectId == rhs.objectId
}

public protocol File : BaseModel {
    var fileURL: URL? { get }
}
