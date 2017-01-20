//
//  Bool+Randomizable.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 22/01/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//


extension Bool {
    public static func random() -> Bool {
        return Int.random(0, 1) == 0
    }
}
