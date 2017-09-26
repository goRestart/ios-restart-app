//
//  UIColor+LG.swift
//  LetGo
//
//  Created by Isaac Roldan on 26/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

// MARK: > Basic Letgo Palette

extension UIColor {
    static var soldColor: UIColor { return tealBlue }
    static var soldFreeColor: UIColor { return tealBlue }
}

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

    fileprivate static let watermelon = UIColor(rgb: 0xff3f55)
    fileprivate static let tealBlue = UIColor(rgb: 0x009aab)
    
    fileprivate static let rosa = UIColor(rgb: 0xfc919d)
    fileprivate static let lightPink = UIColor(rgb: 0xffd8dd)
    fileprivate static let paleTeal = UIColor(rgb: 0x73bdc5)

    fileprivate static let lightRose = UIColor(rgb: 0xffc5cc)
    fileprivate static let lightBlueGrey = UIColor(rgb: 0xb2e0e5)
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
    fileprivate static let cornflower = UIColor(rgb: 0x689df6)
    
    private static let cloudyBlue = UIColor(rgb: 0xc5cddf)
    private static let lightPeriwinkle = UIColor(rgb: 0xc6dafb)

    private static let pale = UIColor(rgb: 0xfff1d2)
}


// MARK: > Gray Palette

extension UIColor {

    // Solid Grays
    static var lgBlack: UIColor { return UIColor(rgb: 0x2c2c2c) }
    static var grayDark: UIColor { return UIColor(rgb: 0x757575) }
    static var gray: UIColor { return UIColor(rgb: 0xbdbdbd) }
    static var grayLight: UIColor { return UIColor(rgb: 0xdddddd) }
    static var grayLighter: UIColor { return UIColor(rgb: 0xede9e9) }
    static var grayBackground: UIColor { return UIColor(rgb: 0xF7F3F3) }


    // Alpha grays
    fileprivate static let blackAlpha80 = black.withAlphaComponent(0.8)
    fileprivate static let blackAlpha50 = black.withAlphaComponent(0.5)
    fileprivate static let blackAlpha30 = black.withAlphaComponent(0.3)
    fileprivate static let blackAlpha15 = black.withAlphaComponent(0.15)

    fileprivate static let whiteAlpha70 = white.withAlphaComponent(0.7)
    fileprivate static let whiteAlpha30 = white.withAlphaComponent(0.3)
    fileprivate static let whiteAlpha10 = white.withAlphaComponent(0.1)
}


// MARK: > View Controller Color: 

extension UIColor {
    
    static var viewControllerBackground: UIColor { return grayBackground }
}

// MARK: > Categories colors

extension UIColor {

    static let asparagus = UIColor(rgb: 0x81ac56)
    static let macaroniAndCheese = UIColor(rgb: 0xf1b83d)
    private static let wisteria = UIColor(rgb: 0xa384bf)
    private static let desert = UIColor(rgb: 0xa384bf)

    static var unassignedCategory: UIColor { return clear }
    static var electronicsCategory: UIColor { return tealBlue }
    static var carsMotorsCategory: UIColor { return UIColor(rgb: 0x9b9b9b) }
    static var sportsGamesCategory: UIColor { return asparagus }
    static var homeGardenCategory: UIColor { return macaroniAndCheese }
    static var moviesBooksCategory: UIColor { return wisteria }
    static var fashionAccessoriesCategory: UIColor { return UIColor(rgb: 0xfe6e7f) }
    static var babyChildCategory: UIColor { return cornflower }
    static var otherCategory: UIColor { return desert }
    static var carCategory: UIColor { return desert }
    static var realEstateCategory: UIColor { return desert }
}

// MARK: > Text colors

extension UIColor {

    // Light Background
    static var blackText: UIColor { return lgBlack }
    static var darkGrayText: UIColor { return grayDark }
    static var grayText: UIColor { return gray }
    static var redText: UIColor { return watermelon }
    static var soldText: UIColor { return soldColor }
    static var blackTextHighAlpha: UIColor { return blackAlpha50 }
    static var blackTextLowAlpha: UIColor { return blackAlpha30 }

    // Dark Background
    static var whiteText: UIColor { return white }
    static var pinkText: UIColor { return rosa }
    static var whiteTextHighAlpha: UIColor { return whiteAlpha70 }
    static var whiteTextLowAlpha: UIColor { return whiteAlpha30 }

    static var grayPlaceholderText: UIColor { return gray }
}


// MARK: > Nav Bar Colors

extension UIColor {

    // Light bar
    static var lightBarBackground: UIColor { return white }
    static var lightBarTitle: UIColor { return black }
    static var lightBarSubtitle: UIColor { return black }
    static var lightBarButton: UIColor { return watermelon }

    // Dark bar
    static var darkBarBackground: UIColor { return blackAlpha50 }
    static var darkBarTitle: UIColor { return white }
    static var darkBarSubtitle: UIColor { return white }
    static var darkBarButton: UIColor { return white }

    // Red bar
    static var redBarBackground: UIColor { return watermelon }
    static var redBarTitle: UIColor { return white }
    static var redBarSubtitle: UIColor { return white }
    static var redBarButton: UIColor { return white }

    // Clear bar
    static var clearBarBackground: UIColor { return clear }
    static var clearBarTitle: UIColor { return white }
    static var clearBarSubtitle: UIColor { return white }
    static var clearBarButton: UIColor { return white }
}

extension UIColor {
    static var tabBarIconSelectedColor: UIColor { return watermelon }
    static var tabBarIconUnselectedColor: UIColor { return black }
    static var tabBarSellIconBgColor: UIColor { return watermelon }
    static var tabBarTooltipBgColor: UIColor { return watermelon }
    static var tabBarTooltipTextColor: UIColor { return white }
}


// MARK: > UIPageControl

extension UIColor {
    static var pageIndicatorTintColor: UIColor { return whiteAlpha30 }
    static var currentPageIndicatorTintColor: UIColor { return white }
    static var pageIndicatorTintColorDark: UIColor { return blackAlpha15 }
    static var currentPageIndicatorTintColorDark: UIColor { return blackAlpha80 }
}


// MARK: > Separation lines

extension UIColor {
    static var lineGray: UIColor { return grayLight }
    static var lineWhite: UIColor { return white }
}


// MARK: > pattern colors

extension UIColor {
    static var ratingViewBackgroundColor: UIColor? {
        guard let patternImage = UIImage(named: "pattern_red") else { return nil }
        return UIColor(patternImage: patternImage)
    }

    static var emptyViewBackgroundColor: UIColor? {
        guard let patternImage = UIImage(named: "pattern_white") else { return nil }
        return UIColor(patternImage: patternImage)
    }
}


// MARK: > Chat colors

extension UIColor {

    static var listBackgroundColor: UIColor { return grayBackground }

    static var chatMyBubbleBgColor: UIColor { return primaryColorAlpha16 }
    static var chatMyBubbleBgColorSelected: UIColor { return primaryColorAlpha30 }

    static var chatOthersBubbleBgColor: UIColor { return white }
    static var chatOthersBubbleBgColorSelected: UIColor { return grayLighter }

    private static let primaryColorAlpha16 = UIColor(rgb: 0xFFE0E4)
    private static let primaryColorAlpha30 = UIColor(rgb: 0xFFC6CD)

}

// MARK: > Placeholder colors

extension UIColor {
    private static let brownDark = UIColor(rgb: 0xBBA298)
    private static let cream = UIColor(rgb: 0xF3F1EC)
    private static let brownLight = UIColor(rgb: 0xE9E2D7)
    private static let brownMedium = UIColor(rgb: 0xD8CAB7)
    private static let greenMedium = UIColor(rgb: 0xC7C8B5)
    

    // Placeholder Colors array
    private static let palette = [gray, grayLight, brownDark, cream, brownLight, brownMedium, greenMedium]

    static func placeholderBackgroundColor() -> UIColor {
        return palette[Int(arc4random_uniform(UInt32(palette.count)))]
    }
    
    static func placeholderBackgroundColor(_ id: String?) -> UIColor {
        guard let id = id else { return brownDark }
        guard let asciiValue = id.unicodeScalars.first?.value else { return brownDark }
        let color = palette[Int(asciiValue) % palette.count]
        return color
    }
}


// MARK: > Avatars

extension UIColor {
    static var defaultAvatarColor: UIColor { return avatarRed }
    static var defaultBackgroundColor: UIColor { return bgRed }

    // Avatar Colors
    private static let avatarRed = rosa
    private static let avatarGreen = UIColor(rgb: 0xA6c488)
    private static let avatarBlue = paleTeal
    private static let avatarDarkBlue = UIColor(rgb: 0x86B0DE)
    private static let avatarPurple = UIColor(rgb: 0xBEA8D2)

    // Bg Colors
    private static let bgRed = UIColor(rgb: 0xfc4259)
    private static let bgGreen = UIColor(rgb: 0x82ab5a)
    private static let bgBlue = UIColor(rgb: 0x3da2ac)
    private static let bgDarkBlue = UIColor(rgb: 0x5690cf)
    private static let bgPurple = UIColor(rgb: 0xa285bd)

    private static let avatarColors: [UIColor] = [avatarGreen, avatarBlue, avatarDarkBlue, avatarPurple]

    private static let bgColors: [UIColor] = [bgGreen, bgBlue, bgDarkBlue, bgPurple]


    static func avatarColorForString(_ string: String?) -> UIColor {
        guard let id = string else { return defaultAvatarColor }
        guard let asciiValue = id.unicodeScalars.first?.value else { return defaultAvatarColor }
        let colors = avatarColors
        return colors[Int(asciiValue) % colors.count]
    }

    static func backgroundColorForString(_ string: String?) -> UIColor {
        guard let id = string else { return defaultBackgroundColor }
        guard let asciiValue = id.unicodeScalars.first?.value else { return defaultBackgroundColor }
        let colors = bgColors
        return colors[Int(asciiValue) % colors.count]
    }
}
