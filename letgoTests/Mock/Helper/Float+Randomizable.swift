//
//  Float+Randomizable.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 28/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Foundation


public extension Float {
    public static func random(_ min: Float = 0, _ max: Float = 100) -> Float {
        return (Float(arc4random()) / 0xFFFFFFFF) * (max - min) + min
    }
}
