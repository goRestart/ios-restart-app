//
//  FeatureFlags.swift
//  LetGo
//
//  Created by Eli Kohen on 18/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import bumper
import LGCoreKit

protocol FeatureFlaggeable {
    static var websocketChat: Bool { get }
    static var notificationsSection: Bool { get }
    static var userReviews: Bool { get }
    static var messageOnFavoriteRound2: MessageOnFavoriteRound2Mode { get }
    static var interestedUsersMode: InterestedUsersMode { get }
    static var filtersReorder: Bool { get }
    static var directPostInOnboarding: Bool { get }
    static var shareButtonWithIcon: Bool { get }
    static var productDetailShareMode: ProductDetailShareMode { get }
    static var periscopeChat: Bool { get }
    static var chatHeadBubbles: Bool { get }
    static var showLiquidProductsToNewUser: Bool { get }
    static var keywordsTravelCollection: KeywordsTravelCollection { get }
}

struct FeatureFlags: FeatureFlaggeable {
    static func setup() {
        Bumper.initialize()
    }
    
    // MARK: - A/B Tests features

    static var websocketChat: Bool = {
        if Bumper.enabled {
            return Bumper.websocketChat
        }
        return false
    }()
    
    static var notificationsSection: Bool = {
        if Bumper.enabled {
            return Bumper.notificationsSection
        }
        return ABTests.notificationCenterEnabled.value
    }()

    static var userReviews: Bool {
        if Bumper.enabled {
            return Bumper.userReviews
        }
        return false
    }

    static var showNPSSurvey: Bool {
        if Bumper.enabled {
            return Bumper.showNPSSurvey
        }
        return ABTests.showNPSSurvey.value
    }

    static var messageOnFavoriteRound2: MessageOnFavoriteRound2Mode {
        if Bumper.enabled {
            return Bumper.messageOnFavoriteRound2Mode
        }
        return MessageOnFavoriteRound2Mode.fromPosition(ABTests.messageOnFavoriteRound2.value)
    }

    static var interestedUsersMode: InterestedUsersMode {
        if Bumper.enabled {
            return Bumper.interestedUsersMode
        }
        return InterestedUsersMode.fromPosition(ABTests.interestedUsersMode.value)
    }

    static var filtersReorder: Bool {
        if Bumper.enabled {
            return Bumper.filtersReorder
        }
        return ABTests.filtersReorder.value
    }

    static var directPostInOnboarding: Bool {
        if Bumper.enabled {
            return Bumper.directPostInOnboarding
        }
        return ABTests.directPostInOnboarding.value
    }
    
    static var shareButtonWithIcon: Bool {
        if Bumper.enabled {
            return Bumper.shareButtonWithIcon
        }
        return ABTests.shareButtonWithIcon.value
    }

    static var productDetailShareMode: ProductDetailShareMode {
        if Bumper.enabled {
            return Bumper.productDetailShareMode
        }
        return ProductDetailShareMode.fromPosition(ABTests.productDetailShareMode.value)
    }

    static var periscopeChat: Bool {
        if Bumper.enabled {
            return Bumper.periscopeChat
        }
        return ABTests.persicopeChat.value
    }

    static var chatHeadBubbles: Bool {
        if Bumper.enabled {
            return Bumper.chatHeadBubbles
        }
        return ABTests.chatHeadBubbles.value
    }
    
    static var showLiquidProductsToNewUser: Bool {
        if Bumper.enabled {
            return Bumper.showLiquidProductsToNewUser
        }
        return ABTests.showLiquidProductsToNewUser.value
    }

    static var expressChatBanner: Bool {
        if Bumper.enabled {
            return Bumper.expressChatBanner
        }
        return ABTests.expressChatBanner.value
    }

    static var keywordsTravelCollection: KeywordsTravelCollection {
        if Bumper.enabled {
            return Bumper.keywordsTravelCollection
        }
        return KeywordsTravelCollection.fromPosition(ABTests.keywordsTravelCollection.value)
    }

    // MARK: - Country features

    static var freePostingModeAllowed: Bool {
        return !FeatureFlags.matchesLocationOrRegion("tr")
    }
    
    // MARK: - Private
    
    /// Checks location & phone region.
    private static func matchesLocationOrRegion(code: String,
                                                 locale: NSLocale = NSLocale.currentLocale(),
                                                 locationManager: LocationManager = Core.locationManager) -> Bool {
        let systemCountryCode = locale.lg_countryCode
        let countryCode = (locationManager.currentPostalAddress?.countryCode ?? systemCountryCode).lowercaseString
        return systemCountryCode == code || countryCode == code
    }
}
