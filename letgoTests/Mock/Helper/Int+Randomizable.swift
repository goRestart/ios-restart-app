//
//  Int+Randomizable.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 28/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Foundation


extension Int {
    public static func random(_ min: Int = 0, _ max: Int = 100) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
}
