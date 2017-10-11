//
//  UIFont+LG.swift
//  LetGo
//
//  Created by Isaac Roldan on 26/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

extension UIFont {

    // Avatar Font
    static var avatarFont: UIFont { return systemRegularFont(size: 60) }

    // Titles
    static var bigHeadlineFont: UIFont { return systemRegularFont(size: 30) }
    static var mediumHeadlineFont: UIFont { return systemSemiBoldFont(size: 19) }
    static var pageTitleFont: UIFont { return systemSemiBoldFont(size: 17) }

    // Bar Buttons
    static var boldBarButtonFont: UIFont { return systemSemiBoldFont(size: 17) }
    static var regularBarButtonFont: UIFont { return systemRegularFont(size: 17) }

    // Body
    static var bigBodyFont: UIFont { return systemRegularFont(size: 17) }
    static var mediumBodyFont: UIFont { return systemRegularFont(size: 15) }
    static var smallBodyFont: UIFont { return systemRegularFont(size: 13) }
    static var subtitleFont: UIFont { return systemRegularFont(size: 11) }

    static var bigBodyFontLight: UIFont { return systemLightFont(size: 17) }
    static var mediumBodyFontLight: UIFont { return systemLightFont(size: 15) }
    static var smallBodyFontLight: UIFont { return systemLightFont (size: 13) }
    static var subtitleFontLight: UIFont { return systemLightFont(size: 11) }

    // Tabs
    static var inactiveTabFont: UIFont { return systemRegularFont(size: 15) }
    static var activeTabFont: UIFont { return systemSemiBoldFont(size: 15) }

    // Section Title
    static var sectionTitleFont: UIFont { return systemRegularFont(size: 13) }

    // Button
    static var veryBigButtonFont: UIFont { return systemSemiBoldFont(size: 21) }
    static var bigButtonFont: UIFont { return systemSemiBoldFont(size: 19) }
    static var mediumButtonFont: UIFont { return systemMediumFont(size: 17) }
    static var smallButtonFont: UIFont { return systemMediumFont(size: 15) }
    
    // Posting Flow 
    
    static var headline: UIFont { return systemBoldFont(size: 35) }
    static var body: UIFont { return systemBoldFont(size: 27) }
    static var selectableItem: UIFont { return systemBoldFont(size: 23) }


    // MARK: Private methods
    
    static func systemFont(size: Int) -> UIFont {
        return self.systemFont(ofSize: CGFloat(size))
    }
    
    static func systemMediumFont(size: Int) -> UIFont {
        if #available(iOS 9.0, *) {
            return self.systemFont(ofSize: CGFloat(size), weight: UIFontWeightMedium)
        } else {
            return UIFont(name: "HelveticaNeue-Medium", size: CGFloat(size))!
        }
    }
    
    static func systemLightFont(size: Int) -> UIFont {
        if #available(iOS 9.0, *) {
            return self.systemFont(ofSize: CGFloat(size), weight: UIFontWeightLight)
        } else {
            return UIFont(name: "HelveticaNeue-Light", size: CGFloat(size))!
        }
    }
    
    static func systemRegularFont(size: Int) -> UIFont {
        if #available(iOS 9.0, *) {
            return self.systemFont(ofSize: CGFloat(size), weight: UIFontWeightRegular)
        } else {
            return UIFont(name: "HelveticaNeue", size: CGFloat(size))!
        }
    }
    
    static func systemSemiBoldFont(size: Int) -> UIFont {
        if #available(iOS 9.0, *) {
            return self.systemFont(ofSize: CGFloat(size), weight: UIFontWeightSemibold)
        } else {
            return UIFont(name: "HelveticaNeue-Bold", size: CGFloat(size))!
        }
    }
    
    static func systemBoldFont(size: Int) -> UIFont {
        return boldSystemFont(ofSize: CGFloat(size))
    }
    
    static func systemItalicFont(size: Int) -> UIFont {
        return italicSystemFont(ofSize: CGFloat(size))
    }
}


// MARK: > Chat Fonts
extension UIFont {
    // Chat header view
    static var chatListingViewNameFont: UIFont { return systemFont(size: 13) }
    static var chatListingViewUserFont: UIFont { return systemBoldFont(size: 13) }
    static var chatListingViewPriceFont: UIFont { return systemBoldFont(size: 13) }

    // Chat cells
    static var conversationUserNameUnreadFont: UIFont { return systemBoldFont(size: 17) }
    static var conversationProductUnreadFont: UIFont { return systemBoldFont(size: 14) }
    static var conversationTimeUnreadFont: UIFont { return systemBoldFont(size: 13) }

    static var conversationUserNameFont: UIFont { return bigBodyFontLight }
    static var conversationProductFont: UIFont { return systemLightFont(size: 14) }

    static var conversationBadgeFont: UIFont { return smallBodyFont }

    static var conversationTimeFont: UIFont { return smallBodyFontLight }
    static var conversationBlockedFont: UIFont {return smallBodyFontLight }

    static var conversationProductDeletedFont: UIFont { return smallBodyFont }
    static var conversationProductSoldFont: UIFont { return smallBodyFont }
}


// MARK: > Notification fonts

extension UIFont {
    static var notificationTitleFont: UIFont { return systemRegularFont(size: 17) }
    static func notificationSubtitleFont(read: Bool) -> UIFont { return read ? systemLightFont(size: 15) : systemSemiBoldFont(size: 15) }
    static var notificationTimeFont: UIFont { return systemLightFont(size: 15) }
}


// MARK: > Product caroussel
extension UIFont {
    static var productTitleFont: UIFont { return UIFont.systemSemiBoldFont(size: 17) }
    static var productPriceFont: UIFont { return UIFont.systemBoldFont(size: 21) }
    static var productTitleDisclaimersFont: UIFont { return UIFont.systemItalicFont(size: 13) }
    static var productDescriptionFont: UIFont { return UIFont.systemLightFont(size: 15) }
    static var productAddresFont: UIFont { return UIFont.systemMediumFont(size: 13) }
    static var productDistanceFont: UIFont { return UIFont.systemBoldFont(size: 13) }
    static var productSocialShareTitleFont: UIFont { return UIFont.systemRegularFont(size: 13) }
    static var productRelatedItemsTitleFont: UIFont { return UIFont.systemRegularFont(size: 13) }
    static var productStatusSoldFont: UIFont { return UIFont.systemMediumFont(size: 13) }
}


// MARK: - Tour
extension UIFont {
    static var tourButtonFont: UIFont { return systemMediumFont(size: 17) }
    static var tourNotificationsTitleFont: UIFont { return systemMediumFont(size: 30) }
    static var tourNotificationsTitleMiniFont: UIFont { return systemMediumFont(size: 24) }
    static var tourNotificationsSubtitleFont: UIFont { return systemRegularFont(size: 17) }
    static var tourNotificationsSubtitleMiniFont: UIFont { return systemRegularFont(size: 15) }
    static var tourLocationDistanceLabelFont: UIFont { return systemMediumFont(size: 16) }
}


// MARK: > PrePremission Push Settings
extension UIFont {
    static var notificationsSettingsCellTextFont: UIFont { return mediumBodyFont }
    static var notificationsSettingsCellTextMiniFont: UIFont { return smallBodyFont }
}
