//
//  Int+LG.swift
//  LetGo
//
//  Created by Dídac on 07/07/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

extension Int {
    static func random(_ min: Int = 0, _ max: Int = 100) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }

    func secondsToCountdownFormat() -> String? {
        guard self >= 0 else { return nil }
        let hours = self/3600
        let mins = (self%3600)/60
        let secs = self%60
        return "\(String(format: "%02d", hours)):\(String(format: "%02d", mins)):\(String(format: "%02d", secs))"
    }
}
