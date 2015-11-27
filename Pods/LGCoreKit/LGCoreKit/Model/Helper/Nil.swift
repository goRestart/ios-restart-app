//
//  Nil.swift
//  LGCoreKit
//
//  Created by AHL on 17/6/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

public struct Nil: Equatable {
    public init() {}
}
public func ==(lhs: Nil, rhs: Nil) -> Bool {
    return true
}
