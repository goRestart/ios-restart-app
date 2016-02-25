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
    static var primaryColor: UIColor { return StyleHelper.red }
    static var primaryColorHighlighted: UIColor { return StyleHelper.highlightedRed }
    static var primaryColorDisabled: UIColor { return StyleHelper.disabledRed }
    static var backgroundColor: UIColor { return StyleHelper.reddishWhite }

    private static let red = UIColor(rgb: 0xFF3F55)
    private static let highlightedRed = UIColor(rgb: 0xFE6E7F)
    private static let disabledRed = UIColor(rgb: 0xF6C7CC)
    private static let reddishWhite = UIColor(rgb: 0xF7F3F3)

    private static let black = UIColor(rgb: 0x000000)
    private static let gray21 = UIColor(rgb: 0x212121)
    private static let gray44 = UIColor(rgb: 0x2c2c2c)
    private static let gray75 = UIColor(rgb: 0x757575)
    private static let gray153 = UIColor(rgb: 0x999999)
    private static let gray167 = UIColor(rgb: 0xA7A7A7)
    private static let gray204 = UIColor(rgb: 0xCCCCCC)
    private static let gray213 = UIColor(rgb: 0xD5D5D5)
    private static let gray222 = UIColor(rgb: 0xDEDEDE)
    private static let gray225 = UIColor(rgb: 0xE1E1E1)
    private static let gray235 = UIColor(rgb: 0xEBEBEB)
    private static let gray238 = UIColor(rgb: 0xEEEEEE)
    private static let gray245 = UIColor(rgb: 0xF5F5F5)
    private static let white = UIColor(rgb: 0xFFFFFF)
    
    // > Palette
    private static let grayMedium = UIColor(rgb: 0xD5D3D3)
    private static let grayLight = UIColor(rgb: 0xE9E5E5)
    private static let brownDark = UIColor(rgb: 0xBBA298)
    private static let cream = UIColor(rgb: 0xF3F1EC)
    private static let brownLight = UIColor(rgb: 0xE9E2D7)
    private static let brownMedium = UIColor(rgb: 0xD8CAB7)
    private static let greenMedium = UIColor(rgb: 0xC7C8B5)
    private static let turquoise = UIColor(rgb: 0x009AAB)
    private static let blue = UIColor(rgb: 0x0092D4)
    private static let blueDark = UIColor(rgb: 0x007CB1)
    private static let blue2 = UIColor(rgb: 0x009AAB)
    private static let primaryColorAlpha16 = UIColor(rgb: 0xFFE0E4)
    private static let primaryColorAlpha30 = UIColor(rgb: 0xFFC6CD)

    
    // Fonts
    private static func systemFont(size size: Int) -> UIFont {
        return UIFont.systemFontOfSize(CGFloat(size))
    }

    private static func systemMediumFont(size size: Int) -> UIFont {
        if #available(iOS 9.0, *) {
            return UIFont.systemFontOfSize(CGFloat(size), weight: UIFontWeightMedium)
        } else {
            return UIFont(name: "HelveticaNeue-Medium", size: CGFloat(size))!
        }
    }
    
    private static func systemLightFont(size size: Int) -> UIFont {
        if #available(iOS 9.0, *) {
            return UIFont.systemFontOfSize(CGFloat(size), weight: UIFontWeightLight)
        } else {
            return UIFont(name: "HelveticaNeue-Light", size: CGFloat(size))!
        }
    }
    
    private static func systemRegularFont(size size: Int) -> UIFont {
        if #available(iOS 9.0, *) {
            return UIFont.systemFontOfSize(CGFloat(size), weight: UIFontWeightRegular)
        } else {
            return UIFont(name: "HelveticaNeue", size: CGFloat(size))!
        }
    }

    private static func systemSemiBoldFont(size size: Int) -> UIFont {
        if #available(iOS 9.0, *) {
            return UIFont.systemFontOfSize(CGFloat(size), weight: UIFontWeightSemibold)
        } else {
            return UIFont(name: "HelveticaNeue-Bold", size: CGFloat(size))!
        }
    }
    
    private static func systemBoldFont(size size: Int) -> UIFont {
        return UIFont.boldSystemFontOfSize(CGFloat(size))
    }
    
    private static func systemItalicFont(size size: Int) -> UIFont {
        return UIFont.italicSystemFontOfSize(CGFloat(size))
    }

    // Corners
    static let defaultCornerRadius: CGFloat = 4
    static var buttonCornerRadius: CGFloat { return StyleHelper.defaultCornerRadius }
    
    // state-depending features
    static let enabledButtonHeight: CGFloat = 44
    private static let disabledItemAlpha : CGFloat = 0.32
    
    private static let palette = [grayMedium, grayLight, brownDark, cream, brownLight, brownMedium, greenMedium]


    // MARK: - Common
    
    static var lineColor: UIColor {
        return gray204
    }
    
    static var darkLineColor: UIColor {
        return gray153
    }
    

    static var disabledButtonBackgroundColor: UIColor {
        return  red //gray204
    }

    static var emptypictureCellBackgroundColor: UIColor {
        return gray225
    }
    
    static var soldColor: UIColor {
        return turquoise
    }
    
    static var standardTextColor: UIColor {
        return gray44
    }
    
    static var onePixelSize: CGFloat {
        return 1 / UIScreen.mainScreen().scale
    }

    static var termsConditionsBasecolor: UIColor {
        return gray153
    }

    static var termsConditionsFont: UIFont {
        return systemFont(size: 15)
    }

    static var termsConditionsSmallFont: UIFont {
        return systemFont(size: 13)
    }


    // MARK: - NavBar
    
    static var navBarButtonsColor: UIColor {
        return primaryColor;
    }
    
    static var navBarTitleColor: UIColor {
        return gray44
    }
    
    static var navBarTitleFont: UIFont {
        return systemMediumFont(size: 17)
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
    
    static var navBarSearchFieldBgColor: UIColor {
        return UIColor.whiteColor()
    }
    
    static var navBarSearchBorderColor: UIColor {
        return UIColor(rgb: 0xaeaaab)
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
    
    static var tabBarTooltipBgColor: UIColor {
        return red
    }
    
    static var tabBarTooltipTextColor: UIColor {
        return white
    }
    
    static var tabBarTooltipTextFont: UIFont {
        return systemBoldFont(size: 16)
    }


    // MARK: - UIPageControl

    static var pageIndicatorTintColor: UIColor {
        return StyleHelper.white.colorWithAlphaComponent(0.5)
    }

    static var currentPageIndicatorTintColor: UIColor {
        return StyleHelper.white
    }


    // MARK: - Filter Tag

    static var filterTagFont : UIFont {
        return systemFont(size: 14)
    }
    
    // MARK: - Product Cell
    
    static var productCellBgColor: UIColor {
        return palette[Int(arc4random_uniform(UInt32(palette.count)))]
    }
    
    
    // MARK: - Conversation Cell
    
    static var conversationCellBgColor: UIColor {
        return palette[Int(arc4random_uniform(UInt32(palette.count)))]
    }
    
    static var badgeBgColor: UIColor {
        return red
    }
    
    static var conversationUserNameUnreadFont: UIFont {
        return systemBoldFont(size: 17)
    }
    
    static var conversationProductUnreadFont: UIFont {
        return systemBoldFont(size: 14)
    }
    
    static var conversationTimeUnreadFont: UIFont {
        return systemBoldFont(size: 13)
    }
    
    static var conversationUserNameFont: UIFont {
        return systemLightFont(size: 17)
    }
    
    static var conversationProductFont: UIFont {
        return systemLightFont(size: 14)
    }
    
    static var conversationBadgeFont: UIFont {
        return systemRegularFont(size: 13)
    }
    
    static var conversationTimeFont: UIFont {
        return systemLightFont(size: 13)
    }

    static var conversationBlockedFont: UIFont {
        return systemLightFont(size: 13)
    }

    static var conversationProductDeletedFont: UIFont {
        return systemRegularFont(size: 13)
    }
    
    static var conversationProductSoldFont: UIFont {
        return systemRegularFont(size: 13)
    }
    
    static var conversationUserNameColor: UIColor {
        return gray44
    }
    
    static var conversationProductColor: UIColor {
        return gray75
    }
    
    static var conversationTimeColor: UIColor {
        return gray75
    }

    static var conversationBlockedColor: UIColor {
        return gray75
    }

    static var conversationProductDeletedColor: UIColor {
        return gray44
    }
    
    static var conversationProductSoldColor: UIColor {
        return blue2
    }
    
    static var conversationAccountDeactivatedColor: UIColor {
        return red
    }

    static var directAnswerFont: UIFont {
        return systemRegularFont(size: 15)
    }
     
    
    // MARK: - Chat
    
    static var chatOthersBubbleBgColor: UIColor {
        return white
    }
    
    static var chatOthersBubbleBgColorSelected: UIColor {
        return gray238
    }
    
    static var chatMyBubbleBgColor: UIColor {
        return primaryColorAlpha16
    }
    
    static var chatMyBubbleBgColorSelected: UIColor {
        return primaryColorAlpha30
    }
    
    static var chatTableViewBgColor: UIColor {
        return gray245
    }
    
    static var chatSendButtonFont: UIFont {
        return systemMediumFont(size: 15)
    }

    static var chatProductViewNameFont: UIFont {
        return systemFont(size: 13)
    }
    
    static var chatProductViewUserFont: UIFont {
        return systemBoldFont(size: 13)
    }
    
    static var chatProductViewPriceFont: UIFont {
        return systemBoldFont(size: 13)
    }
    
    static var chatProductViewNameColor: UIColor {
        return black
    }
    
    static var chatProductViewUserColor: UIColor {
        return gray153
    }
    
    static var chatProductViewPriceColor: UIColor {
        return black
    }
    
    static var chatCellAvatarBorderColor: UIColor {
        return gray213
    }
    
    static var chatSendButtonTintColor: UIColor {
        return red
    }

    static var chatInfoLabelFont: UIFont {
        return systemFont(size: 13)
    }

    static var chatInfoBackgrounColorAccountDeactivated: UIColor {
        return gray75
    }

    static var chatInfoBackgrounColorBlockedBy: UIColor {
        return gray75
    }

    static var chatInfoBackgrounColorBlocked: UIColor {
        return red
    }

    static var chatInfoBackgroundColorProductInactive: UIColor {
        return gray75
    }

    static var chatInfoBackgroundColorProductSold: UIColor {
        return turquoise
    }

    static var chatCellUserNameFont: UIFont {
        return systemBoldFont(size: 13)
    }
    
    static var chatCellMessageFont: UIFont {
        return systemRegularFont(size: 17)
    }
    
    static var chatCellTimeFont: UIFont {
        return systemLightFont(size: 13)
    }
    
    static var chatCellUserNameColor: UIColor {
        return gray44
    }
    
    static var chatCellMessageColor: UIColor {
        return gray44
    }
    
    static var chatCellTimeColor: UIColor {
        return gray75
    }
    
    // MARK: - Tour
    
    static var tourButtonFont: UIFont {
        return systemMediumFont(size: 17)
    }
    
    static var tourNotificationsTitleFont: UIFont {
        return systemMediumFont(size: 30)
    }
    
    static var tourNotificationsTitleMiniFont: UIFont {
        return systemMediumFont(size: 24)
    }
    
    static var tourNotificationsSubtitleFont: UIFont {
        return systemRegularFont(size: 17)
    }
    
    static var tourNotificationsSubtitleMiniFont: UIFont {
        return systemRegularFont(size: 15)
    }
    
    static var tourLocationDistanceLabelFont: UIFont {
        return systemMediumFont(size: 16)
    }
    
    static var tourLocationDistanceLabelColor: UIColor {
        return gray44
    }
    
    
    // MARK: - Chat safety tips
    
    static var tipTextColor: UIColor {
        return gray75
    }
    
    static var tipTextFont: UIFont {
        return systemMediumFont(size: 14)
    }

    static var safetyTipsPageIndicatorTintColor: UIColor {
        return StyleHelper.gray167
    }

    static var safetyTipsPageIndicatorCurrentPageTintColor: UIColor {
        return StyleHelper.black
    }


    // MARK: - Report users

    static var reportPlaceholderColor: UIColor {
        return gray153
    }

    static var reportTextColor: UIColor {
        return gray21
    }

    
    // MARK: - LGTextField
    
    static var textFieldTintColor: UIColor {
        return red
    }

    
    // MARK: -  Button

    static var defaultButtonFont: UIFont {
        return systemSemiBoldFont(size: 17)
    }
    
    static var highlightedRedButtonColor: UIColor {
        return highlightedRed
    }
    
    static var disabledButtonAlpha: CGFloat {
        return disabledItemAlpha
    }


    // MARK: - LGEmptyView

    static var emptyViewBackgroundColor: UIColor? {
        guard let patternImage = UIImage(named: "pattern_white") else { return nil }
        return UIColor(patternImage: patternImage)
    }

    static var emptyViewContentBorderColor: UIColor {
        return StyleHelper.lineColor
    }

    static var emptyViewContentBorderRadius: CGFloat {
        return StyleHelper.defaultCornerRadius
    }

    static var emptyViewContentBorderWith: CGFloat {
        return 0.5
    }

    static var emptyViewContentBackgroundColor: UIColor {
        return StyleHelper.white
    }

    static var emptyViewTitleFont: UIFont {
        return systemFont(size: 17)
    }

    static var emptyViewTitleColor: UIColor {
        return StyleHelper.gray44
    }

    static var emptyViewBodyFont: UIFont {
        return systemFont(size: 17)
    }

    static var emptyViewBodyColor: UIColor {
        return StyleHelper.gray75
    }

    static var emptyViewActionButtonFont: UIFont {
        return systemFont(size: 18)
    }

    static var emptyViewActionButtonColor: UIColor {
        return StyleHelper.white
    }


    // MARK: - UserView

    static func userViewBgColor(style: UserViewStyle) -> UIColor {
        switch style {
        case .Full:
            return StyleHelper.white.colorWithAlphaComponent(0.9)
        case .Compact:
            return UIColor.clearColor()
        }
    }

    static func userViewUsernameLabelFont(style: UserViewStyle) -> UIFont {
        switch style {
        case .Full:
            return StyleHelper.systemRegularFont(size: 15)
        case .Compact:
            return StyleHelper.systemRegularFont(size: 13)
        }
    }

    static func userViewUsernameLabelColor(style: UserViewStyle) -> UIColor {
        switch style {
        case .Full:
            return StyleHelper.gray44
        case .Compact:
            return StyleHelper.white
        }
    }
}


// MARK: - Shadows

extension StyleHelper {
    static func applyDefaultShadow(layer: CALayer) {
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 1
        layer.shadowOpacity = 0.3
    }
    static func applyInfoBubbleShadow(layer: CALayer) {
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowRadius = 15
        layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        layer.shadowOpacity = 0.12
        layer.shadowRadius = 8.0
    }
}


// MARK: - Avatars

extension StyleHelper {
    // Avatar Colors
    private static let avatarRed = UIColor(rgb: 0xFC919D)
    private static let avatarOrange = UIColor(rgb: 0xF3B685)
    private static let avatarYellow = UIColor(rgb: 0xF5CD77)
    private static let avatarGreen = UIColor(rgb: 0xA6c488)
    private static let avatarBlue = UIColor(rgb: 0x73BDC5)
    private static let avatarDarkBlue = UIColor(rgb: 0x86B0DE)
    private static let avatarPurple = UIColor(rgb: 0xBEA8D2)
    private static let avatarBrown = UIColor(rgb: 0xC9B5B8)
    
    private static let avatarColors: [UIColor] = [StyleHelper.avatarRed, StyleHelper.avatarOrange,
        StyleHelper.avatarYellow, StyleHelper.avatarGreen, StyleHelper.avatarBlue,
        StyleHelper.avatarDarkBlue, StyleHelper.avatarPurple, StyleHelper.avatarBrown]
    
    static var avatarFont: UIFont {
        return StyleHelper.systemRegularFont(size: 60)
    }
    
    static func avatarColorForString(string: String?) -> UIColor {
        guard let id = string else { return StyleHelper.avatarColors[0] }
        guard let asciiValue = id.unicodeScalars.first?.value else { return StyleHelper.avatarColors[0] }
        return StyleHelper.avatarColors[Int(asciiValue) % 8]
    }
}


extension UIButton {

    /**
        Will set default corner radius and button background to the app primary color
    */
    func setPrimaryStyle() {
        guard buttonType == UIButtonType.Custom else {
            print("💣 => primaryStyle can only be applied to customStyle Buttons")
            return
        }
        setBackgroundImage(StyleHelper.primaryColor.imageWithSize(CGSize(width: 1, height: 1)), forState: .Normal)
        setBackgroundImage(StyleHelper.primaryColorHighlighted.imageWithSize(CGSize(width: 1, height: 1)),
            forState: .Highlighted)
        setBackgroundImage(StyleHelper.primaryColorDisabled.imageWithSize(CGSize(width: 1, height: 1)), forState: .Disabled)
        layer.cornerRadius = StyleHelper.buttonCornerRadius
        titleLabel?.font = StyleHelper.defaultButtonFont
        setTitleColor(UIColor.whiteColor(), forState: .Normal)
    }

    func setSecondaryStyle() {
        guard buttonType == UIButtonType.System else {
            print("💣 => secondaryStyle can only be applied to systemStyle Buttons")
            return
        }
        
        layer.cornerRadius = StyleHelper.buttonCornerRadius
        layer.borderColor = StyleHelper.primaryColor.CGColor
        layer.borderWidth = 2
        setBackgroundImage(StyleHelper.primaryColor.imageWithSize(CGSize(width: 1, height: 1)), forState: .Normal)
        setBackgroundImage(StyleHelper.white.imageWithSize(CGSize(width: 1, height: 1)), forState: .Normal)
        titleLabel?.font = StyleHelper.defaultButtonFont
    }

    func setCustomButtonStyle() {
        setBackgroundImage(backgroundColor?.imageWithSize(CGSize(width: 1, height: 1)), forState: .Normal)
        layer.cornerRadius = StyleHelper.defaultCornerRadius
    }
}
