//
//  UIColor+LG.swift
//  LetGo
//
//  Created by Isaac Roldan on 26/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation


// MARK: > Basic Palette

extension UIColor {
    
    static var primaryColor: UIColor { return watermelon }
    static var secondaryColor: UIColor { return whiteColor() }
    static var terciaryColor: UIColor { return tealBlue }
    
    static var primaryColorHighlighted: UIColor { return rosa }
    static var secondaryColorHighlighted: UIColor { return lightPink }
    static var terciaryColorHighlighted: UIColor { return paleTeal }
    
    static var primaryColorDisabled: UIColor { return lightRose }
    static var secondaryColorDisabled: UIColor { return whiteColor() }
    static var terciaryColorDisabled: UIColor { return lightBlueGrey }
    
    private static var watermelon = UIColor(rgb: 0xff3f55)
    private static var tealBlue = UIColor(rgb: 0x009aab)
    
    private static var rosa = UIColor(rgb: 0xfc919d)
    private static var lightPink = UIColor(rgb: 0xffd8dd)
    private static var paleTeal = UIColor(rgb: 0x73bdc5)
    
    private static var lightRose = UIColor(rgb: 0xffc5cc)
    private static var lightBlueGrey = UIColor(rgb: 0xb2e0e5)
}


// MARK: > Extended Palette

extension UIColor {
    static var facebookColor: UIColor { return denimBlue }
    static var googleColor: UIColor { return dodgerBlue }
    
    static var facebookColorHighlighted: UIColor { return dustyBlue }
    static var googleColorHighlighted: UIColor { return cornflower }

    static var facebookColorDisabled: UIColor { return cloudyBlue }
    static var googleColorDisabled: UIColor { return lightPeriwinkle }

    private static var denimBlue = UIColor(rgb: 0x3f5b96)
    private static var dodgerBlue = UIColor(rgb: 0x4285f4)
    
    private static var dustyBlue = UIColor(rgb: 0x657cab)
    private static var cornflower = UIColor(rgb: 0x689df6)
    
    private static var cloudyBlue = UIColor(rgb: 0xc5cddf)
    private static var lightPeriwinkle = UIColor(rgb: 0xc6dafb)
}
