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
    case unknown

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

    static var isWideScreen: Bool {
        return UIScreen.mainScreen().bounds.width > DeviceFamily.iPhone6ScreenWidth
    }

    private static let iPhone6ScreenWidth: CGFloat = 375
}
