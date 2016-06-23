//
//  UIColor+LG.swift
//  LetGo
//
//  Created by Isaac Roldan on 26/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation


// MARK: > Basic Buttons Palette

extension UIColor {
    
    static var primaryColor: UIColor { return watermelon }
    static var secondaryColor: UIColor { return white }
    static var terciaryColor: UIColor { return tealBlue }
    
    static var primaryColorHighlighted: UIColor { return rosa }
    static var secondaryColorHighlighted: UIColor { return lightPink }
    static var terciaryColorHighlighted: UIColor { return paleTeal }
    
    static var primaryColorDisabled: UIColor { return lightRose }
    static var secondaryColorDisabled: UIColor { return white }
    static var terciaryColorDisabled: UIColor { return lightBlueGrey }

    private static let watermelon = UIColor(rgb: 0xff3f55)
    private static let tealBlue = UIColor(rgb: 0x009aab)
    
    private static let rosa = UIColor(rgb: 0xfc919d)
    private static let lightPink = UIColor(rgb: 0xffd8dd)
    private static let paleTeal = UIColor(rgb: 0x73bdc5)

    private static let lightRose = UIColor(rgb: 0xffc5cc)
    private static let lightBlueGrey = UIColor(rgb: 0xb2e0e5)
}


// MARK: > Extended Buttons Palette

extension UIColor {
    static var facebookColor: UIColor { return denimBlue }
    static var googleColor: UIColor { return dodgerBlue }
    
    static var facebookColorHighlighted: UIColor { return dustyBlue }
    static var googleColorHighlighted: UIColor { return cornflower }

    static var facebookColorDisabled: UIColor { return cloudyBlue }
    static var googleColorDisabled: UIColor { return lightPeriwinkle }

    static var disclaimerColor: UIColor { return pale }

    static var blueTooltip: UIColor { return cornflower}
    static var blackTooltip: UIColor { return black }

    private static let denimBlue = UIColor(rgb: 0x3f5b96)
    private static let dodgerBlue = UIColor(rgb: 0x4285f4)

    private static let dustyBlue = UIColor(rgb: 0x657cab)
    private static let cornflower = UIColor(rgb: 0x689df6)
    
    private static let cloudyBlue = UIColor(rgb: 0xc5cddf)
    private static let lightPeriwinkle = UIColor(rgb: 0xc6dafb)

    private static let pale = UIColor(rgb: 0xfff1d2)
}


// MARK: > Text colors

extension UIColor {

    // Light Background
    static var blackText: UIColor { return black }
    static var darkGrayText: UIColor { return grayDark }
    static var redText: UIColor { return watermelon }

    // Dark Background
    static var whiteText: UIColor { return white }
    static var pinkText: UIColor { return rosa }



    // TODO: decide if is better fix one of the already decided colors with alpha and use a var instead of a func
    static func blackTextColoredBG(alpha: CGFloat) -> UIColor {
        return black.colorWithAlphaComponent(alpha)
    }

    static func whiteTextColoredBG(alpha: CGFloat) -> UIColor {
        return white.colorWithAlphaComponent(alpha)
    }
}

// MARK: > Gray Palette

extension UIColor {
    static var black: UIColor { return UIColor(rgb: 0x2c2c2c) }
    static var grayDark: UIColor { return  UIColor(rgb: 0x757575) }
    static var gray: UIColor { return  UIColor(rgb: 0xbdbdbd) }
    static var grayLight: UIColor { return  UIColor(rgb: 0xdddddd) }
    static var grayLighter: UIColor { return  UIColor(rgb: 0xede9e9) }
    static var white: UIColor { return  UIColor(rgb: 0xFFFFFF) }
}


// MARK: > Alpha Palette

extension UIColor {
    static var blackAlpha80: UIColor { return black.colorWithAlphaComponent(0.8) }
    static var blackAlpha50: UIColor { return black.colorWithAlphaComponent(0.5) }
    static var blackAlpha30: UIColor { return black.colorWithAlphaComponent(0.3) }
    static var blackAlpha15: UIColor { return black.colorWithAlphaComponent(0.15) }

    static var whiteAlpha70: UIColor { return white.colorWithAlphaComponent(0.7) }
    static var whiteAlpha30: UIColor { return white.colorWithAlphaComponent(0.3) }
    static var whiteAlpha10: UIColor { return white.colorWithAlphaComponent(0.1) }
}


// MARK: > Bar Colors

extension UIColor {

    // Light bar

    // Dark bar

    // Red bar

    // Clear bar


}


