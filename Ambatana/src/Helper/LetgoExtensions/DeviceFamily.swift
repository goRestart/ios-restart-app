//
//  UIScreen+LG.swift
//  LetGo
//
//  Created by Isaac Roldan on 8/2/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

enum DeviceFamily {
    case iPhone4        // height = 480
    case iPhone5        // height = 568
    case iPhone6        // height = 667
    case iPhone6Plus    // height = 736
    case biggerUnknown
    
    static var current: DeviceFamily {
        switch UIScreen.main.bounds.height {
        case 0..<567:
            return .iPhone4
        case 568:
            return .iPhone5
        case 569..<668:
            return .iPhone6
        case 668..<737:
            return iPhone6Plus
        default:
            return .biggerUnknown
        }
    }
    
    func isWiderOrEqualThan(_ deviceFamily: DeviceFamily) -> Bool {
        return self >= deviceFamily
    }
    
    static var isiPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
}

func >=(lhs: DeviceFamily, rhs: DeviceFamily) -> Bool {
    switch (lhs, rhs) {
    case (.iPhone4, .iPhone4):
        return true
    case (.iPhone5, .iPhone4), (.iPhone5, .iPhone5):
        return true
    case (.iPhone6, .iPhone4), (.iPhone6, .iPhone5), (.iPhone6, .iPhone6):
        return true
    case (.iPhone6Plus, .iPhone4), (.iPhone6Plus, .iPhone5), (.iPhone6Plus, .iPhone6), (.iPhone6Plus, .iPhone6Plus):
        return true
    case (.biggerUnknown, _):
        return true
    case (.iPhone4, _), (.iPhone5, _), (.iPhone6, _), (.iPhone6Plus, _):
        return false
    }
}
