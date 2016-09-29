//
//  FeatureFlags.swift
//  LetGo
//
//  Created by Eli Kohen on 18/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import FlipTheSwitch

enum AppInviteListingMode: Int {
    case None = 0
    case Text = 1
    case Emoji = 2
}

enum OnboardingPermissionsMode: Int {
    case Original = 0
    case OneButtonOriginalImages = 1
    case OneButtonNewImages = 2
}

enum IncentivizePostingMode: Int {
    case Original = 0
    case VariantA = 1
    case VariantB = 2
    case VariantC = 3
}

enum MessageOnFavoriteMode: Int {
    case NoMessage = 0
    case NotificationPreMessage = 1
    case DirectMessage = 2
}

enum ExpressChatMode: Int {
    case NoChat
    case ContactXSellers
    case AskAvailable
}

enum InterestedUsersMode: Int {
    case NoNotification
    case Original
    case LimitedPrints
}

struct FeatureFlags {
    static var websocketChat: Bool = {
        return FTSFlipTheSwitch.websocketChat
    }()
    
    static var notificationsSection: Bool = {
        if FTSFlipTheSwitch.overridesABTests {
            return FTSFlipTheSwitch.notificationsSection
        }
        return false
    }()

    static var userRatings: Bool {
        return FTSFlipTheSwitch.userRatings
    }
    
    static var showNPSSurvey: Bool {
        if FTSFlipTheSwitch.overridesABTests {
            return FTSFlipTheSwitch.showNPSSurvey
        }
        return ABTests.showNPSSurvey.value
    }

    static var profileVerifyOneButton: Bool {
        if FTSFlipTheSwitch.overridesABTests {
            return FTSFlipTheSwitch.profileVerifyOneButton
        }
        return ABTests.profileVerifyOneButton.value
    }

    static var nonStopProductDetail: Bool {
        if FTSFlipTheSwitch.overridesABTests {
            return FTSFlipTheSwitch.nonStopProductDetail
        }
        return ABTests.nonStopProductDetail.value
    }

    static var onboardinPermissionsMode: OnboardingPermissionsMode {
        if FTSFlipTheSwitch.overridesABTests {
            return FTSFlipTheSwitch.onboardingPermissionsMode ? .OneButtonNewImages : .OneButtonOriginalImages
        }
        return OnboardingPermissionsMode(rawValue: ABTests.onboardingPermissionsMode.value) ?? .Original
    }

    static var incentivizePostingMode: IncentivizePostingMode {
        if FTSFlipTheSwitch.overridesABTests {
            return FTSFlipTheSwitch.incentivizePostingMode
        }
        return IncentivizePostingMode(rawValue: ABTests.incentivatePostingMode.value) ?? .Original
    }

    static var messageOnFavorite: MessageOnFavoriteMode {
        if FTSFlipTheSwitch.overridesABTests {
            return FTSFlipTheSwitch.messageOnFavorite
        }
        return MessageOnFavoriteMode(rawValue: ABTests.messageOnFavorite.value) ?? .NoMessage
    }

    static var expressChatMode: ExpressChatMode {
        if FTSFlipTheSwitch.overridesABTests {
            return FTSFlipTheSwitch.expressChatMode
        }
        return ExpressChatMode(rawValue: ABTests.expressChatMode.value) ?? .NoChat
    }

    static var interestedUsersMode: InterestedUsersMode {
        if FTSFlipTheSwitch.overridesABTests {
            return FTSFlipTheSwitch.interestedUsersMode
        }
        return InterestedUsersMode(rawValue: ABTests.interestedUsersMode.value) ?? .NoNotification
    }

}

private extension FTSFlipTheSwitch {
    static var overridesABTests: Bool {
        return FTSFlipTheSwitch.sharedInstance().isFeatureEnabled("overrides_abtests")
    }

    static var websocketChat: Bool {
        return FTSFlipTheSwitch.sharedInstance().isFeatureEnabled("websocket_chat")
    }

    static var notificationsSection: Bool {
        return FTSFlipTheSwitch.sharedInstance().isFeatureEnabled("notifications_replaces_categories")
    }
    
    static var userRatings: Bool {
        return FTSFlipTheSwitch.sharedInstance().isFeatureEnabled("user_ratings")
    }

    static var showNPSSurvey: Bool {
        return FTSFlipTheSwitch.sharedInstance().isFeatureEnabled("show_nps_survey")
    }

    static var profileVerifyOneButton: Bool {
        return FTSFlipTheSwitch.sharedInstance().isFeatureEnabled("profile_verify_one_button")
    }

    static var nonStopProductDetail: Bool {
        return FTSFlipTheSwitch.sharedInstance().isFeatureEnabled("non_stop_product_detail")
    }

    static var onboardingPermissionsMode: Bool {
        return FTSFlipTheSwitch.sharedInstance().isFeatureEnabled("onboarding_permissions_mode")
    }

    static var incentivizePostingMode: IncentivizePostingMode {
        if FTSFlipTheSwitch.sharedInstance().isFeatureEnabled("incentivize_posting_a") {
            return .VariantA
        }
        if FTSFlipTheSwitch.sharedInstance().isFeatureEnabled("incentivize_posting_b") {
            return .VariantB
        }
        if FTSFlipTheSwitch.sharedInstance().isFeatureEnabled("incentivize_posting_c") {
            return .VariantC
        }
        return .Original
    }

    static var messageOnFavorite: MessageOnFavoriteMode {
        if FTSFlipTheSwitch.sharedInstance().isFeatureEnabled("fav_no_message") {
            return .NoMessage
        }
        if FTSFlipTheSwitch.sharedInstance().isFeatureEnabled("fav_notification_pre_message") {
            return .NotificationPreMessage
        }
        if FTSFlipTheSwitch.sharedInstance().isFeatureEnabled("fav_direct_message") {
            return .DirectMessage
        }
        return .NoMessage
    }

    static var expressChatMode: ExpressChatMode {
        if FTSFlipTheSwitch.sharedInstance().isFeatureEnabled("no_express_chat") {
            return .NoChat
        }
        if FTSFlipTheSwitch.sharedInstance().isFeatureEnabled("contact_x_sellers_express_chat") {
            return .ContactXSellers
        }
        if FTSFlipTheSwitch.sharedInstance().isFeatureEnabled("ask_available_express_chat") {
            return .AskAvailable
        }
        return .NoChat
    }

    static var interestedUsersMode: InterestedUsersMode {
        if FTSFlipTheSwitch.sharedInstance().isFeatureEnabled("interested_no_notification") {
            return .NoNotification
        }
        if FTSFlipTheSwitch.sharedInstance().isFeatureEnabled("interested_original") {
            return .Original
        }
        if FTSFlipTheSwitch.sharedInstance().isFeatureEnabled("interested_limited_prints") {
            return .LimitedPrints
        }
        return .NoNotification
    }
}
