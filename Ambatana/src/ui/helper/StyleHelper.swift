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
    private static let gray213 = UIColor(rgb: 0xD5D5D5)
    
    private static let palette = [darkPink, lightPink, ultraLightPink, white, brown, gray72, gray182]
    
    // MARK: - Common
    
    static var lineColor: UIColor {
        return gray213
    }
    
    // MARK: - NavBar
    
    static var navBarBgColor: UIColor {
        return white
    }
    
    static var navBarBgImage: UIImage {
        return white.imageWithSize(CGSize(width: 1, height: 1)).applyBlurWithRadius(10, tintColor: nil, saturationDeltaFactor: 0, maskImage: nil)
    }
    
    static var navBarShadowImage: UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.mainScreen().scale);
        let context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, lineColor.CGColor);
        let fillRect = CGRect(x: 0, y: 0, width: 1, height: 1)  // height: 0.5)
        CGContextFillRect(context, fillRect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }
    
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
