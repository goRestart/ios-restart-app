import UIKit

public extension UIFont {

    // Avatar Font
    static var avatarFont: UIFont { return systemBoldFont(size: 50) }

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
    static var verySmallButtonFont: UIFont { return systemMediumFont(size: 14) }
    static var verySmallBoldButtonFont: UIFont { return systemSemiBoldFont(size: 14) }
    
    // Posting Flow
    static var postingFlowHeadline: UIFont { return systemBoldFont(size: 35) }
    static var postingFlowHeadlineSubtitle: UIFont { return systemBoldFont(size: 20) }
    static var postingFlowBody: UIFont { return systemBoldFont(size: 27) }
    static var postingFlowSelectableItem: UIFont { return systemBoldFont(size: 23) }

    static var adTitleFont: UIFont { return systemMediumFont(size: 16)}
    static var adDescriptionFont: UIFont { return systemRegularFont(size: 14)}
    static var adCallToActionFont: UIFont { return systemMediumFont(size: 14)}
    static var adTextFont: UIFont { return systemRegularFont(size: 14)}

    // Letgo Tooltip
    static var tooltipMessageFont: UIFont { return systemBoldFont(size: 17) }

    // Community Banner
    static var communityBannerTitleFont: UIFont { return systemBoldFont(size: 22) }

    // MARK: Private methods

    static func systemFont(size: Int) -> UIFont {
        return self.systemFont(ofSize: CGFloat(size))
    }

    static func systemMediumFont(size: Int) -> UIFont {
        return self.systemFont(ofSize: CGFloat(size), weight: UIFont.Weight.medium)
    }

    static func systemLightFont(size: Int) -> UIFont {
        return self.systemFont(ofSize: CGFloat(size), weight: UIFont.Weight.light)
    }

    static func systemRegularFont(size: Int) -> UIFont {
        return self.systemFont(ofSize: CGFloat(size), weight: UIFont.Weight.regular)
    }

    static func systemSemiBoldFont(size: Int) -> UIFont {
        return self.systemFont(ofSize: CGFloat(size), weight: UIFont.Weight.semibold)
    }

    static func systemBoldFont(size: Int) -> UIFont {
        return boldSystemFont(ofSize: CGFloat(size))
    }

    static func systemItalicFont(size: Int) -> UIFont {
        return italicSystemFont(ofSize: CGFloat(size))
    }

    static func systemHeavyFont(size: Int) -> UIFont {
        return systemFont(ofSize: CGFloat(size), weight: .heavy)
    }
}


// MARK: > Chat Fonts
public extension UIFont {
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


// MARK: - Notification fonts

public extension UIFont {
    static var notificationTitleFont: UIFont { return systemRegularFont(size: 17) }
    static func notificationSubtitleFont(read: Bool) -> UIFont { return read ? systemLightFont(size: 15) : systemSemiBoldFont(size: 15) }
    static var notificationTimeFont: UIFont { return systemLightFont(size: 15) }
}


// MARK: - Product caroussel
public extension UIFont {
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
public extension UIFont {
    static var tourButtonFont: UIFont { return systemMediumFont(size: 17) }
    static var tourNotificationsTitleFont: UIFont { return systemMediumFont(size: 30) }
    static var tourNotificationsTitleMiniFont: UIFont { return systemMediumFont(size: 24) }
    static var tourNotificationsSubtitleFont: UIFont { return systemRegularFont(size: 17) }
    static var tourNotificationsSubtitleMiniFont: UIFont { return systemRegularFont(size: 15) }
    static var tourLocationDistanceLabelFont: UIFont { return systemMediumFont(size: 16) }
}

// MARK: - DeckView

public extension UIFont {
    static var deckTitleFont: UIFont { return systemMediumFont(size: 27) }
    static var deckPriceFont: UIFont { return systemBoldFont(size: 17) }
    static var deckDetailFont: UIFont { return systemRegularFont(size: 15) }
    static var deckSocialHeaderFont: UIFont { return systemRegularFont(size: 13) }
    static var deckUsernameFont: UIFont { return systemBoldFont(size: 15) }
}

// MARK: - PrePremission Push Settings
public extension UIFont {
    static var notificationsSettingsCellTextFont: UIFont { return mediumBodyFont }
    static var notificationsSettingsCellTextMiniFont: UIFont { return smallBodyFont }
}

// MARK: - User Profile
public extension UIFont {
    static var userProfileTabsNumberFont: UIFont { return UIFont.systemBoldFont(size: 19) }
    static var userProfileTabsNameFont: UIFont { return UIFont.systemRegularFont(size: 15) }
    static var userProfileTabsNameSelectedFont: UIFont { return UIFont.systemBoldFont(size: 15) }
    static var userProfileTabsNameMiniFont: UIFont { return UIFont.systemRegularFont(size: 13) }
    static var userProfileTabsNameSelectedMiniFont: UIFont { return UIFont.systemBoldFont(size: 13) }
    static var userProfileVerificationSectionSubtitleFont: UIFont { return UIFont.systemRegularFont(size: 12) }
    static var profileUserHeadline: UIFont { return systemBoldFont(size: 35) }
    static var profileKarmaSubtitleBoldFont: UIFont { return systemBoldFont(size: 11) }
    static var profileKarmaScoreTitleFont: UIFont { return systemBoldFont(size: 23) }
    static var profileKarmaOpenVerificationFont: UIFont { return UIFont.systemBoldFont(size: 15) }
    static var verificationItemTitle: UIFont { return systemBoldFont(size: 23) }
    static var verificationEventCountFont: UIFont { return systemBoldFont(size: 10) }
}

public extension UIFont {
    static var smsVerificationInputBigText: UIFont { return UIFont.systemBoldFont(size: 30) }
    static var smsVerificationInputDescription: UIFont { return UIFont.systemMediumFont(size: 20) }
    static var smsVerificationInputSmallDescription: UIFont { return UIFont.systemRegularFont(size: 15) }
    static var smsVerificationInputCodeInformation: UIFont { return UIFont.systemMediumFont(size: 14) }
    static var smsVerificationCountryListCellText: UIFont { return UIFont.systemBoldFont(size: 23) }
    static var smsVerificationCodeInputTextfieldText: UIFont { return UIFont.systemBoldFont(size: 40) }
}

// MARK: - Passwordless
public extension UIFont {
    static var passwordLessEmailTitleFont: UIFont { return systemBoldFont(size: 27) }
    static var passwordLessEmailDescriptionFont: UIFont { return systemRegularFont(size: 15) }
    static var passwordLessEmailTextFieldFont: UIFont { return systemBoldFont(size: 23)}
    static var passwordLessUsernameTitleFont: UIFont { return systemBoldFont(size: 35) }
}
