//
//  StyleHelper.swift
//  LetGo
//
//  Created by AHL on 27/4/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit
import Foundation

class StyleHelper {

    // Colors
    private static let red = UIColor(rgb: 0xFB2444)
    private static let darkPink = UIColor(rgb: 0xC2185B)
    private static let lightPink = UIColor(rgb: 0xE91E63)
    private static let ultraLightPink = UIColor(rgb: 0xF8BBD0)
    private static let brown = UIColor(rgb: 0x795548)
    
    private static let white = UIColor(rgb: 0xFFFFFF)
    private static let gray21 = UIColor(rgb: 0x212121)
    private static let gray72 = UIColor(rgb: 0x727272)
    private static let gray182 = UIColor(rgb: 0xB6B6B6)
    
    private static let palette = [darkPink, lightPink, ultraLightPink, white, brown, gray72, gray182]
    
    // MARK: - TabBar
    
    static var tabBarIconSelectedColor: UIColor {
        return red
    }
    
    static var tabBarIconUnselectedColor: UIColor {
        return gray21
    }
    
    static var tabBarSellIconBgColor: UIColor {
        return red
    }
    
    // MARK: - Product Cell
    
    static var productCellBgColor: UIColor {
        return palette[Int(arc4random_uniform(UInt32(palette.count)))]
    }
}
