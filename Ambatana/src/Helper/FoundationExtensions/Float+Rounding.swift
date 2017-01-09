//
//  Float+Rounding.swift
//  LetGo
//
//  Created by Albert Hernández López on 20/07/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

extension Float {
    /* Rounds to the nearest given decimal. Examples:
        
     Float(4.24).roundNearest(0.5) -> 4
     Float(4.5).roundNearest(0.5)  -> 4.5
     Float(4.74).roundNearest(0.5) -> 4.5
     Float(4.76).roundNearest(0.5) -> 5

     Float(4.24).roundNearest(0.1) -> 4.2
     Float(4.25).roundNearest(0.1) -> 4.3 */
    
     func roundNearest(_ nearest: Float) -> Float {
        // Rounded method change on swift 3: http://stackoverflow.com/questions/38767635/xcode-8-beta-4-swift-3-round-behaviour-changed
        guard nearest != 0 else { return self}
        let n: Float = 1/nearest
        let numberToRound = self * n
        return (numberToRound.rounded()) / n
    }
}
