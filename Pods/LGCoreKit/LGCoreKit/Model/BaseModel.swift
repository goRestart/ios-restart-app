//
//  BaseModel.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 30/04/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

public protocol BaseModel {
    // Optional: Has value if saved (either cache or remote)
    var objectId: String? { get }
}

public extension BaseModel {
    public var isSaved: Bool {
        return objectId != nil
    }

    func toDictionary() -> [String: AnyObject] {
        return Mirror(reflecting: self).toDictionary()
    }
}
