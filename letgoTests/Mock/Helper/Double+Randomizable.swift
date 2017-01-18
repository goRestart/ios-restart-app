//
//  Double+Randomizable.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 28/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Foundation


public extension Double {
    public static func random(_ min: Double = 0, _ max: Double = 100) -> Double {
        return (Double(arc4random()) / 0xFFFFFFFF) * (max - min) + min
    }
}
