//
//  UIScreen+LG.swift
//  LetGo
//
//  Created by Isaac Roldan on 8/2/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

enum DeviceFamily: Int {
    case iPhone4 = 480
    case iPhone5 = 568
    case iPhone6 = 667
    case iPhone6Plus = 736
    case unknown = 0

    static var current: DeviceFamily {
        switch UIScreen.mainScreen().bounds.height {
        case 0..<481:
            return .iPhone4
        case 481..<569:
            return .iPhone5
        case 569..<668:
            return .iPhone6
        case 668..<737:
            return iPhone6Plus
        default:
            return unknown
        }
    }
}