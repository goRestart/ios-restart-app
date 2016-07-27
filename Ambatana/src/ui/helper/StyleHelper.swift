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
    private static let highlightedWhite = StyleHelper.gray238

    //TODO: Remove all those and switch to the closer from the gray palette
    private static let gray74 = UIColor(rgb: 0x4a4a4a)
    private static let gray117 = UIColor(rgb: 0x757575)
    private static let gray153 = UIColor(rgb: 0x999999)
    private static let gray167 = UIColor(rgb: 0xA7A7A7)
    private static let gray204 = UIColor(rgb: 0xCCCCCC)
    private static let gray213 = UIColor(rgb: 0xD5D5D5)
    private static let gray222 = UIColor(rgb: 0xDEDEDE)
    private static let gray225 = UIColor(rgb: 0xE1E1E1)
    private static let gray235 = UIColor(rgb: 0xEBEBEB)
    private static let gray238 = UIColor(rgb: 0xEEEEEE)
    private static let gray245 = UIColor(rgb: 0xF5F5F5)

    
    // > Palette
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
    static let productOnboardingTipsCornerRadius: CGFloat = 10
    static let ratingCornerRadius: CGFloat = 16
    static let alertCornerRadius: CGFloat = 15

    // state-depending features
    static let enabledButtonHeight: CGFloat = 50
    private static let disabledItemAlpha : CGFloat = 0.32
    
    private static let palette = [UIColor.gray, UIColor.grayLight, brownDark, cream, brownLight, brownMedium, greenMedium]


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
        return UIColor.black
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
        return UIColor.black
    }
    
    static var navBarTitleFont: UIFont {
        return systemMediumFont(size: 17)
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
        return UIColor.black
    }
    
    static var tabBarSellIconBgColor: UIColor {
        return red
    }
    
    static var tabBarTooltipBgColor: UIColor {
        return red
    }
    
    static var tabBarTooltipTextColor: UIColor {
        return UIColor.white
    }
    
    static var tabBarTooltipTextFont: UIFont {
        return systemBoldFont(size: 16)
    }


    // MARK: - UIPageControl

    static var pageIndicatorTintColor: UIColor {
        return UIColor.white.colorWithAlphaComponent(0.5)
    }

    static var currentPageIndicatorTintColor: UIColor {
        return UIColor.white
    }
    
    static var pageIndicatorTintColorDark: UIColor {
        return UIColor.black.colorWithAlphaComponent(0.16)
    }
    
    static var currentPageIndicatorTintColorDark: UIColor {
        return UIColor.black.colorWithAlphaComponent(0.7)
    }

    // MARK: - Trending searches

    static var trendingSearchesTitleFont: UIFont {
        return StyleHelper.systemFont(size: 20)
    }

    static var trendingSearchesTitleColor: UIColor {
        return UIColor.grayDark
    }
    
    // MARK: - Filter Tag

    static var filterTagFont : UIFont {
        return systemFont(size: 14)
    }
    
    // MARK: - Product Cell

    static var productCellImageBgColor: UIColor {
        return palette[Int(arc4random_uniform(UInt32(palette.count)))]
    }

    // MARK: - Edit Product

    static var editProductAddPhotoCellBgColor: UIColor {
        return UIColor.black
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
        return UIColor.black
    }
    
    static var conversationProductColor: UIColor {
        return gray117
    }
    
    static var conversationTimeColor: UIColor {
        return gray117
    }

    static var conversationBlockedColor: UIColor {
        return gray74
    }

    static var conversationProductDeletedColor: UIColor {
        return UIColor.black
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
    
    static var directAnswerBackgroundColor: UIColor {
        return red
    }
    
    static var directAnswerHighlightedColor: UIColor {
        return highlightedRed
    }


    // MARK: - Notifications

    static var notificationCellImageBgColor: UIColor {
        return palette[Int(arc4random_uniform(UInt32(palette.count)))]
    }

    static var notificationTitleUnreadFont: UIFont {
        return systemBoldFont(size: 17)
    }

    static var notificationSubtitleUnreadFont: UIFont {
        return systemBoldFont(size: 14)
    }

    static var notificationTimeUnreadFont: UIFont {
        return systemBoldFont(size: 13)
    }

    static var notificationTitleFont: UIFont {
        return systemLightFont(size: 17)
    }

    static var notificationSubtitleFont: UIFont {
        return systemLightFont(size: 14)
    }

    static var notificationTimeFont: UIFont {
        return systemLightFont(size: 13)
    }

    static var notificationTitleColor: UIColor {
        return UIColor.black
    }

    static var notificationSubtitleColor: UIColor {
        return gray117
    }

    static var notificationTimeColor: UIColor {
        return gray117
    }


    // MARK: - ProductVC

    static var productAutogeneratedTitleFont: UIFont {
        return systemItalicFont(size: 13)
    }

    static var productAutogeneratedTitleTextColor: UIColor {
        return gray117
    }

    static var productDescriptionTextColor: UIColor {
        return gray117
    }
    

    // MARK: - Edit

    static var editTitleDisclaimerTextColor: UIColor {
        return gray117
    }

    static var editTitleDisclaimerFont: UIFont {
        return systemRegularFont(size: 13)
    }


    // MARK: - Post product

    static var postProductTabFont: UIFont {
        return systemBoldFont(size: 15)
    }

    static var postProductTabColor: UIColor {
        return UIColor.black
    }

    static var postProductDisabledPostButton: UIColor {
        return UIColor.black
    }

    
    // MARK: - Chat
    
    static var chatOthersBubbleBgColor: UIColor {
        return UIColor.white
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
        return UIColor.black
    }
    
    static var chatProductViewUserColor: UIColor {
        return gray153
    }
    
    static var chatProductViewPriceColor: UIColor {
        return UIColor.black
    }
    
    static var chatCellAvatarBorderColor: UIColor {
        return gray213
    }
    
    static var chatSendButtonTintColor: UIColor {
        return red
    }
    
    static var chatLeftButtonColor: UIColor {
        return gray117
    }
    
    static var chatInfoLabelFont: UIFont {
        return systemFont(size: 13)
    }

    static var chatInfoBackgrounColorAccountDeactivated: UIColor {
        return gray74
    }

    static var chatInfoBackgrounColorBlockedBy: UIColor {
        return gray74
    }

    static var chatInfoBackgrounColorBlocked: UIColor {
        return red
    }

    static var chatInfoBackgroundColorProductDeleted: UIColor {
        return gray74
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
        return UIColor.black
    }
    
    static var chatCellMessageColor: UIColor {
        return UIColor.black
    }
    
    static var chatCellTimeColor: UIColor {
        return gray117
    }

    // MARK: - Chat disclaimer

    static var chatDisclaimerMessageColor: UIColor {
        return gray117
    }

    // MARK: - User

    static var userTabSelectedFont: UIFont {
        return systemBoldFont(size: 15)
    }

    static var userTabNonSelectedFont: UIFont {
        return systemRegularFont(size: 15)
    }

    static var userTabNonSelectedColor: UIColor {
        return UIColor.black
    }

    static var userRelationLabelFont: UIFont {
        return systemMediumFont(size: 14)
    }

    static var userRelationLabelColor: UIColor {
        return StyleHelper.red
    }

    static var userAccountsVerifiedTitleFont: UIFont {
        return systemLightFont(size: 15)
    }

    static var userAccountsVerifiedTitleColor: UIColor {
        return StyleHelper.gray117
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
        return UIColor.black
    }
    
    
    // MARK: - PrePremission Push Settings
    
    static var notificationsSettingsCellTextFont: UIFont {
        return systemRegularFont(size: 15)
    }
    
    static var notificationsSettingsCellTextMiniFont: UIFont {
        return systemRegularFont(size: 14)
    }
    
    
    // MARK: - Chat safety tips
    
    static var tipTextColor: UIColor {
        return gray117
    }
    
    static var tipTextFont: UIFont {
        return systemMediumFont(size: 14)
    }

    static var safetyTipsPageIndicatorTintColor: UIColor {
        return gray167
    }

    static var safetyTipsPageIndicatorCurrentPageTintColor: UIColor {
        return UIColor.black
    }


    // MARK: - Rating

    static var ratingBannerBackgroundColor: UIColor? {
        guard let patternImage = UIImage(named: "pattern_red") else { return nil }
        return UIColor(patternImage: patternImage)
    }


    // MARK: - Report users

    static var reportPlaceholderColor: UIColor {
        return gray153
    }

    static var reportTextColor: UIColor {
        return UIColor.black
    }

    // MARK: - User

    static var userProductListBgColor: UIColor {
        return reddishWhite
    }

    
    // MARK: - LGTextField
    
    static var textFieldTintColor: UIColor {
        return red
    }

    
    // MARK: -  Button

    static var defaultButtonFont: UIFont {
        return systemSemiBoldFont(size: 17)
    }

    static var smallButtonFont: UIFont {
        return systemSemiBoldFont(size: 15)
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

    static var emptyViewContentBgColor: UIColor {
        return UIColor.white
    }

    static var emptyViewContentBorderRadius: CGFloat {
        return StyleHelper.defaultCornerRadius
    }

    static var emptyViewContentBorderWith: CGFloat {
        return 0.5
    }

    static var emptyViewContentBackgroundColor: UIColor {
        return UIColor.white
    }

    static var emptyViewTitleFont: UIFont {
        return systemFont(size: 17)
    }

    static var emptyViewTitleColor: UIColor {
        return UIColor.black
    }

    static var emptyViewBodyFont: UIFont {
        return systemFont(size: 17)
    }

    static var emptyViewBodyColor: UIColor {
        return gray117
    }

    static var emptyViewActionButtonFont: UIFont {
        return systemFont(size: 18)
    }

    static var emptyViewActionButtonColor: UIColor {
        return UIColor.white
    }
    
    
    // MARK: - Video Button (Commercializer)
    
    static var commercialButtonFont: UIFont {
        return systemMediumFont(size: 15)
    }
    
    static var commercialButtonBackgroundColor: UIColor {
        return UIColor.white
    }
    
    static var commercialButtonHighLightedColor: UIColor {
        return highlightedWhite
    }
    
    static var commercialButtonTextColor: UIColor {
        return primaryColor
    }

    
    // MARK: - Commercializer from Setings
    
    static var commercialFromSettingsTitleColor: UIColor {
        return UIColor.black
    }
    
    static var commercialFromSettingsTitleFont: UIFont {
        return systemRegularFont(size: 15)
    }
    

    // MARK: - UserView

    static func userViewBgColor(style: UserViewStyle) -> UIColor {
        switch style {
        case .Full:
            return UIColor.white.colorWithAlphaComponent(0.9)
        case .CompactShadow, .CompactBorder:
            return UIColor.clearColor()
        }
    }

    static func userViewUsernameLabelFont(style: UserViewStyle) -> UIFont {
        switch style {
        case .Full:
            return StyleHelper.systemRegularFont(size: 15)
        case .CompactShadow, .CompactBorder:
            return StyleHelper.systemRegularFont(size: 13)
        }
    }

    static func userViewUsernameLabelColor(style: UserViewStyle) -> UIColor {
        switch style {
        case .Full:
            return UIColor.black
        case .CompactShadow, .CompactBorder:
            return UIColor.white
        }
    }

    static func userViewSubtitleLabelFont(style: UserViewStyle) -> UIFont {
        switch style {
        case .Full:
            return StyleHelper.systemLightFont(size: 13)
        case .CompactShadow, .CompactBorder:
            return StyleHelper.systemLightFont(size: 11)
        }
    }

    static func userViewSubtitleLabelColor(style: UserViewStyle) -> UIColor {
        switch style {
        case .Full:
            return UIColor.black
        case .CompactShadow, .CompactBorder:
            return UIColor.white
        }
    }

    static func userViewAvatarBorderColor(style: UserViewStyle) -> UIColor? {
        switch style {
        case .Full, .CompactShadow:
            return nil
        case .CompactBorder:
            return UIColor.white
        }
    }
}


// Product Carousel & MoreInfo
extension StyleHelper {
    static var productTitleFont: UIFont {
        return UIFont.systemSemiBoldFont(size: 17)
    }
    static var productPriceFont: UIFont {
        return UIFont.systemBoldFont(size: 21)
    }
    static var productTitleDisclaimersFont: UIFont {
        return UIFont.systemItalicFont(size: 13)
    }
    static var productAddresFont: UIFont {
        return UIFont.systemMediumFont(size: 13)
    }
    static var productDistanceFont: UIFont {
        return UIFont.systemBoldFont(size: 13)
    }
    static var productSocialShareTitleFont: UIFont {
        return UIFont.systemRegularFont(size: 13)
    }
    static var productMoreInfoDescriptionTextColor: UIColor {
        return gray222
    }
    static var productStatusSoldFont: UIFont {
        return UIFont.systemMediumFont(size: 13)
    }
    static var productMapCornerRadius: CGFloat = 15.0
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
        layer.cornerRadius = 15
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowRadius = 15
        layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        layer.shadowOpacity = 0.12
        layer.shadowRadius = 8.0
    }
}


// MARK: - Avatars

extension StyleHelper {
    static let defaultAvatarColor = StyleHelper.avatarRed
    static let defaultBackgroundColor = StyleHelper.bgRed

    // Avatar Colors
    private static let avatarRed = UIColor(rgb: 0xFC919D)
    private static let avatarOrange = UIColor(rgb: 0xF3B685)
    private static let avatarYellow = UIColor(rgb: 0xF5CD77)
    private static let avatarGreen = UIColor(rgb: 0xA6c488)
    private static let avatarBlue = UIColor(rgb: 0x73BDC5)
    private static let avatarDarkBlue = UIColor(rgb: 0x86B0DE)
    private static let avatarPurple = UIColor(rgb: 0xBEA8D2)
    private static let avatarBrown = UIColor(rgb: 0xC9B5B8)

    // Bg Colors
    private static let bgRed = UIColor(rgb: 0xfc4259)
    private static let bgOrange = UIColor(rgb: 0xed9859)
    private static let bgYellow = UIColor(rgb: 0xf0b74a)
    private static let bgGreen = UIColor(rgb: 0x82ab5a)
    private static let bgBlue = UIColor(rgb: 0x3da2ac)
    private static let bgDarkBlue = UIColor(rgb: 0x5690cf)
    private static let bgPurple = UIColor(rgb: 0xa285bd)
    private static let bgBrown = UIColor(rgb: 0xb29196)
    
    private static let avatarColors: [UIColor] = [StyleHelper.avatarOrange,
        StyleHelper.avatarYellow, StyleHelper.avatarGreen, StyleHelper.avatarBlue,
        StyleHelper.avatarDarkBlue, StyleHelper.avatarPurple, StyleHelper.avatarBrown]

    private static let bgColors: [UIColor] = [StyleHelper.bgOrange,
        StyleHelper.bgYellow, StyleHelper.bgGreen, StyleHelper.bgBlue,
        StyleHelper.bgDarkBlue, StyleHelper.bgPurple, StyleHelper.bgBrown]
    
    static var avatarFont: UIFont {
        return StyleHelper.systemRegularFont(size: 60)
    }
    
    static func avatarColorForString(string: String?) -> UIColor {
        guard let id = string else { return StyleHelper.defaultAvatarColor }
        guard let asciiValue = id.unicodeScalars.first?.value else { return StyleHelper.defaultAvatarColor }
        let colors = StyleHelper.avatarColors
        return colors[Int(asciiValue) % colors.count]
    }

    static func backgroundColorForString(string: String?) -> UIColor {
        guard let id = string else { return StyleHelper.defaultBackgroundColor }
        guard let asciiValue = id.unicodeScalars.first?.value else { return StyleHelper.defaultBackgroundColor }
        let colors = StyleHelper.bgColors
        return colors[Int(asciiValue) % colors.count]
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

        clipsToBounds = true
        layer.cornerRadius = StyleHelper.buttonCornerRadius

        setBackgroundImage(StyleHelper.primaryColor.imageWithSize(CGSize(width: 1, height: 1)), forState: .Normal)
        setBackgroundImage(StyleHelper.primaryColorHighlighted.imageWithSize(CGSize(width: 1, height: 1)),
            forState: .Highlighted)
        setBackgroundImage(StyleHelper.primaryColorDisabled.imageWithSize(CGSize(width: 1, height: 1)), forState: .Disabled)

        titleLabel?.font = StyleHelper.defaultButtonFont
        setTitleColor(UIColor.whiteColor(), forState: .Normal)
    }
    
    func setPrimaryStyleRounded() {
        setPrimaryStyle()
        layer.cornerRadius = bounds.height/2
    }

    func setSecondaryStyle() {
        clipsToBounds = true
        layer.borderWidth = 1
        layer.cornerRadius = StyleHelper.buttonCornerRadius
        layer.borderColor = StyleHelper.primaryColor.CGColor

        setBackgroundImage(UIColor.white.imageWithSize(CGSize(width: 1, height: 1)), forState: .Normal)
        setBackgroundImage(StyleHelper.highlightedWhite.imageWithSize(CGSize(width: 1, height: 1)), forState: .Highlighted)

        titleLabel?.font = StyleHelper.defaultButtonFont
        setTitleColor(StyleHelper.primaryColor, forState: .Normal)
    }

    func setCustomButtonStyle() {
        clipsToBounds = true
        setBackgroundImage(backgroundColor?.imageWithSize(CGSize(width: 1, height: 1)), forState: .Normal)
        layer.cornerRadius = StyleHelper.defaultCornerRadius
    }
}
