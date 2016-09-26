//
//  CGFloat+rounding.swift
//  LetGo
//
//  Created by Dídac on 26/09/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//


extension CGFloat {
    /* Rounds to the nearest given decimal. Examples:

     CGFloat(4.24).roundNearest(0.5) -> 4
     CGFloat(4.5).roundNearest(0.5)  -> 4.5
     CGFloat(4.74).roundNearest(0.5) -> 4.5
     CGFloat(4.76).roundNearest(0.5) -> 5

     CGFloat(4.24).roundNearest(0.1) -> 4.2
     CGFloat(4.25).roundNearest(0.1) -> 4.3 */
    func roundNearest(nearest: CGFloat) -> CGFloat {
        let n = 1/nearest
        return round(self * n) / n
    }
}

