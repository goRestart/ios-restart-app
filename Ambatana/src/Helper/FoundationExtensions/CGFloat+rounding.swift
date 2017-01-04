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
    func roundNearest(_ nearest: CGFloat) -> CGFloat {
        let n = 1/nearest
        return round(self * n) / n
    }


    /**
     Maps a percentage inside 0 and maximum:
     
     CGFloat(1.0).percentageTo(0.5) -> 1.0
     CGFloat(0.5).percentageTo(0.5) -> 1.0
     CGFloat(0.25).percentageTo(0.5) -> 0.5
     CGFloat(0).percentageTo(0.5) -> 0.0
    */
    func percentageTo(_ maximum: CGFloat) -> CGFloat {
        guard self < maximum else { return 1 }
        return self / maximum
    }

    /**
     Maps a percentage inside start and end:

     CGFloat(1.0).percentageBetween(start: 0.5, end: 1.5) -> 0.5
     CGFloat(1.2).percentageBetween(start: 1.0, end: 1.4) -> 0.5
     CGFloat(0.9).percentageBetween(start: 1.0, end: 1.4) -> 0
     CGFloat(1.5).percentageBetween(start: 1.0, end: 1.4) -> 1
     */
    func percentageBetween(start: CGFloat, end: CGFloat) -> CGFloat {
        guard self > start else { return 0 }
        guard self < end else { return 1 }
        return (self - start) / (end - start)
    }
}

