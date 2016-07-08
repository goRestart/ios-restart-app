//
//  Int+LG.swift
//  LetGo
//
//  Created by Dídac on 07/07/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

extension Int {
    public static func random(min: Int = 0, _ max: Int = 100) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
}
