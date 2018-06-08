import Foundation
import LGComponents

// MARK: > Basic Letgo Palette

extension UIColor {
    static var soldColor: UIColor { return tealBlue }
    static var soldFreeColor: UIColor { return tealBlue }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        self.init(red: CGFloat(red) / 255.0,
                  green: CGFloat(green) / 255.0,
                  blue: CGFloat(blue) / 255.0,
                  alpha: 1)
    }
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

    fileprivate static let watermelon = UIColor(rgb: 0xff3f55) // (255, 63, 85)
    fileprivate static let tealBlue = UIColor(rgb: 0x009aab) // (0, 154, 171)
    
    fileprivate static let rosa = UIColor(rgb: 0xfc919d) // (252, 145, 157)
    fileprivate static let lightPink = UIColor(rgb: 0xffd8dd) // (255, 216, 221)
    fileprivate static let paleTeal = UIColor(rgb: 0x73bdc5) // (115, 189, 197)
    fileprivate static let lightRose = UIColor(rgb: 0xffc5cc) // (255, 197, 204)
    fileprivate static let lightBlueGrey = UIColor(rgb: 0xb2e0e5) // (178, 224, 14)
    fileprivate static let celestialBlue = UIColor(rgb: 0x86b0de) // (134, 176, 222)
    fileprivate static let budGreen = UIColor(rgb: 0xa6c488) // (166, 196, 8)
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
    static var blackTooltip: UIColor { return lgBlack }


    private static let denimBlue = UIColor(rgb: 0x3f5b96) // (63, 91, 150)
    private static let dodgerBlue = UIColor(rgb: 0x4285f4) // (66, 133, 244)

    private static let dustyBlue = UIColor(rgb: 0x657cab) // (101, 124, 171)
    fileprivate static let cornflower = UIColor(rgb: 0x689df6) // (104, 157, 246)
    
    private static let cloudyBlue = UIColor(rgb: 0xc5cddf) // (197, 205, 223)
    private static let lightPeriwinkle = UIColor(rgb: 0xc6dafb) // (198, 218, 251)

    private static let pale = UIColor(rgb: 0xfff1d2) // (255, 241, 210)
}


// MARK: > Gray Palette

extension UIColor {
    // Solid Grays
    static var lgBlack: UIColor { return UIColor(rgb: 0x2c2c2c) } // (44,44,44)
    static var grayDarker: UIColor { return UIColor(rgb: 0x4a4a4a) } // (74,74,74)
    static var grayDark: UIColor { return UIColor(rgb: 0x757575) } // (117,117,117)
    static var gray: UIColor { return UIColor(rgb: 0xbdbdbd) } // (189,189,189)
    static var grayLight: UIColor { return UIColor(rgb: 0xdddddd) } // (221,221,221)
    static var grayLighter: UIColor { return UIColor(rgb: 0xede9e9) } // (237,233,233)
    static var grayBackground: UIColor { return UIColor(rgb: 0xF7F3F3) } // (247,143,243)
    static var grayDisclaimerText: UIColor { return UIColor(rgb: 0x9b9b9b) } // (155, 155, 155)

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

    static let asparagus = UIColor(rgb: 0x81ac56) // (129, 172, 86)
    static let macaroniAndCheese = UIColor(rgb: 0xf1b83d)
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
    static var blackBackgroundAlpha: UIColor { return blackAlpha30 }

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
    static var separatorFilters: UIColor { return UIColor(rgb: 0xcccccc) }
    static var lineGray: UIColor { return grayLight }
    static var lineWhite: UIColor { return white }
}

extension UIColor {
    static let filterCellsGrey = UIColor(rgb: 0xAAAAAA)
}


// MARK: > pattern colors

extension UIColor {
    static var ratingViewBackgroundColor: UIColor? {
        return UIColor(patternImage: R.Asset.BackgroundsAndImages.patternRed.image)
    }

    static var emptyViewBackgroundColor: UIColor? {
        return UIColor(patternImage: R.Asset.BackgroundsAndImages.patternWhite.image)
    }
}


// MARK: > Chat colors

extension UIColor {

    static var listBackgroundColor: UIColor { return grayBackground }

    static var chatMyBubbleBgColor: UIColor { return primaryColorAlpha16 }
    static var chatMyBubbleBgColorSelected: UIColor { return primaryColorAlpha30 }

    static var chatOthersBubbleBgColor: UIColor { return white }
    static var chatOthersBubbleBgColorSelected: UIColor { return grayLighter }

    static var assistantConversationCellBgColor: UIColor { return primaryColorAlpha08 }

    private static let primaryColorAlpha08 = UIColor(rgb: 0xFFE0F1)
    private static let primaryColorAlpha16 = UIColor(rgb: 0xFFE0E4) // (255, 224, 228)
    private static let primaryColorAlpha30 = UIColor(rgb: 0xFFC6CD) // (255, 198, 205)

}

// MARK: > Placeholder colors

extension UIColor {
    private static let brownDark = UIColor(rgb: 0xBBA298) // (187, 162, 152)
    private static let cream = UIColor(rgb: 0xF3F1EC) // (243, 241, 236)
    private static let brownLight = UIColor(rgb: 0xE9E2D7) // (233, 226, 215)
    private static let brownMedium = UIColor(rgb: 0xD8CAB7) // (216, 202, 183)
    private static let greenMedium = UIColor(rgb: 0xC7C8B5) // (199, 200, 181)
    

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
    private static let avatarGreen = budGreen
    private static let avatarBlue = paleTeal
    private static let avatarDarkBlue = celestialBlue
    private static let avatarPurple = UIColor(rgb: 0xBEA8D2) // (190, 168, 210)

    // Bg Colors
    private static let bgRed = UIColor(rgb: 0xfc4259) // (252, 66, 89)
    private static let bgGreen = UIColor(rgb: 0x82ab5a) // (130, 171, 90)
    private static let bgBlue = UIColor(rgb: 0x3da2ac) // (61, 162, 172)
    private static let bgDarkBlue = UIColor(rgb: 0x5690cf) // (86, 144, 207)
    private static let bgPurple = UIColor(rgb: 0xa285bd) // (162, 133, 189)

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

// MARK: > Superkeyword groups

extension UIColor {
    struct Taxonomy {
        static var electronics: UIColor { return paleTeal }
        static var vehiclesAndBicycles: UIColor { return celestialBlue }
        static var homeAndGarden: UIColor { return cyanBlueAzure }
        static var hobbiesAndEntertainment: UIColor { return budGreen }
        static var fashionAndAccessories: UIColor { return rosa }
        static var family: UIColor { return amber }
        static var others: UIColor { return earthYellow }
        
        fileprivate static let amber = UIColor(rgb: 0x538fd1) // (83, 143, 209)
        fileprivate static let cyanBlueAzure = UIColor(rgb: 0xf5cd77) // (245, 205, 119)
        fileprivate static let earthYellow = UIColor(rgb: 0xcd1a960) // (205, 26, 150)
    }
}

// MARK: - Camera

extension UIColor {
    struct Camera {
        static var cameraButton: UIColor { return almostWatermelon }
        static var cameraButtonHighlighted: UIColor { return almostWatermelonDarker }
        static var selectedPhotoVideoButton: UIColor { return almostWatermelon }
        static var unselectedPhotoVideoButton: UIColor { return UIColor.white }

        fileprivate static let almostWatermelon = UIColor(rgb: 0xf6416c) // (244, 65, 108)
        fileprivate static let almostWatermelonDarker = UIColor(rgb: 0xa93f56) // (169, 63, 86)
    }
}
// MARK: > Edit User Bio

extension UIColor {
    static var placeholder: UIColor { return UIColor(rgb: 0x999999) } // 153, 153, 153
    static var verificationGreen: UIColor { return UIColor(rgb: 0xa3ce71 ) } // 163, 206, 113
}

// MARK: > User Verifications

extension UIColor {
    static var verificationPoints: UIColor { return UIColor(rgb: 0xa3ce71) } //  163, 206, 113
}


// MARK: > Toast color

extension UIColor {
    static let toastBackground = UIColor.grayDarker
}
