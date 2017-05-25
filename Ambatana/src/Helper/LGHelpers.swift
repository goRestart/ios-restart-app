//
//  LGHelpers.swift
//  LetGo
//
//  Created by Nestor on 25/05/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation

class LGHelpers {
    static func division(numerator: CGFloat, denominator: CGFloat) -> CGFloat {
        guard denominator > 0 else { return 0 }
        return numerator / denominator
    }
    
    static func division(numerator: Float, denominator: Float) -> Float {
        guard denominator > 0 else { return 0 }
        return numerator / denominator
    }
    
    static func division(numerator: Double, denominator: Double) -> Double {
        guard denominator > 0 else { return 0 }
        return numerator / denominator
    }
}
