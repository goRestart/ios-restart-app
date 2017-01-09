//
//  Double+Rounding.swift
//  LetGo
//
//  Created by Dídac on 26/09/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//


extension Double {
    /* Rounds to the nearest given decimal. Examples:

     Double(4.24).roundNearest(0.5) -> 4
     Double(4.5).roundNearest(0.5)  -> 4.5
     Double(4.74).roundNearest(0.5) -> 4.5
     Double(4.76).roundNearest(0.5) -> 5

     Double(4.24).roundNearest(0.1) -> 4.2
     Double(4.25).roundNearest(0.1) -> 4.3 */
    func roundNearest(_ nearest: Double) -> Double {
        guard nearest != 0 else { return self}
        let n = 1/nearest
        let numberToRound = self * n
        return numberToRound.rounded() / n
    }
}
