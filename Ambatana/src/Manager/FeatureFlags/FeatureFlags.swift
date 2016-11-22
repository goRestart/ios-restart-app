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
    var websocketChat: Bool { get }
    var notificationsSection: Bool { get }
    var userReviews: Bool { get }
    var showNPSSurvey: Bool { get }
    var messageOnFavoriteRound2: MessageOnFavoriteRound2Mode { get }
    var interestedUsersMode: InterestedUsersMode { get }
    var filtersReorder: Bool { get }
    var directPostInOnboarding: Bool { get }
    var shareButtonWithIcon: Bool { get }
    var productDetailShareMode: ProductDetailShareMode { get }
    var periscopeChat: Bool { get }
    var chatHeadBubbles: Bool { get }
    var showLiquidProductsToNewUser: Bool { get }
    var expressChatBanner: Bool { get }
    var keywordsTravelCollection: KeywordsTravelCollection { get }
    var freePostingModeAllowed: Bool { get }
}

class FeatureFlags: FeatureFlaggeable {
    
    static let sharedInstance: FeatureFlags = FeatureFlags()
    
    private let locale: NSLocale
    private let locationManager: LocationManager
    
    init(locale: NSLocale, locationManager: LocationManager) {
        self.locale = locale
        self.locationManager = locationManager
        Bumper.initialize()
    }
    
    convenience init() {
        self.init(locale: NSLocale.currentLocale(), locationManager: Core.locationManager)
    }


    // MARK: - A/B Tests features

     var websocketChat: Bool = {
        if Bumper.enabled {
            return Bumper.websocketChat
        }
        return false
    }()
    
     var notificationsSection: Bool = {
        if Bumper.enabled {
            return Bumper.notificationsSection
        }
        return ABTests.notificationCenterEnabled.value
    }()

     var userReviews: Bool {
        if Bumper.enabled {
            return Bumper.userReviews
        }
        return false
    }

     var showNPSSurvey: Bool {
        if Bumper.enabled {
            return Bumper.showNPSSurvey
        }
        return ABTests.showNPSSurvey.value
    }

     var messageOnFavoriteRound2: MessageOnFavoriteRound2Mode {
        if Bumper.enabled {
            return Bumper.messageOnFavoriteRound2Mode
        }
        return MessageOnFavoriteRound2Mode.fromPosition(ABTests.messageOnFavoriteRound2.value)
    }

     var interestedUsersMode: InterestedUsersMode {
        if Bumper.enabled {
            return Bumper.interestedUsersMode
        }
        return InterestedUsersMode.fromPosition(ABTests.interestedUsersMode.value)
    }

     var filtersReorder: Bool {
        if Bumper.enabled {
            return Bumper.filtersReorder
        }
        return ABTests.filtersReorder.value
    }

     var directPostInOnboarding: Bool {
        if Bumper.enabled {
            return Bumper.directPostInOnboarding
        }
        return ABTests.directPostInOnboarding.value
    }
    
     var shareButtonWithIcon: Bool {
        if Bumper.enabled {
            return Bumper.shareButtonWithIcon
        }
        return ABTests.shareButtonWithIcon.value
    }

     var productDetailShareMode: ProductDetailShareMode {
        if Bumper.enabled {
            return Bumper.productDetailShareMode
        }
        return ProductDetailShareMode.fromPosition(ABTests.productDetailShareMode.value)
    }

     var periscopeChat: Bool {
        if Bumper.enabled {
            return Bumper.periscopeChat
        }
        return ABTests.persicopeChat.value
    }

     var chatHeadBubbles: Bool {
        if Bumper.enabled {
            return Bumper.chatHeadBubbles
        }
        return ABTests.chatHeadBubbles.value
    }
    
     var showLiquidProductsToNewUser: Bool {
        if Bumper.enabled {
            return Bumper.showLiquidProductsToNewUser
        }
        return ABTests.showLiquidProductsToNewUser.value
    }

     var expressChatBanner: Bool {
        if Bumper.enabled {
            return Bumper.expressChatBanner
        }
        return ABTests.expressChatBanner.value
    }

     var keywordsTravelCollection: KeywordsTravelCollection {
        if Bumper.enabled {
            return Bumper.keywordsTravelCollection
        }
        return KeywordsTravelCollection.fromPosition(ABTests.keywordsTravelCollection.value)
    }

    // MARK: - Country features

    var freePostingModeAllowed: Bool {
        return !matchesLocationOrRegion("tr")
    }
    
    // MARK: - Private
    
    /// Checks location & phone region.
    private func matchesLocationOrRegion(code: String) -> Bool {
        let systemCountryCode = locale.lg_countryCode
        let countryCode = (locationManager.currentPostalAddress?.countryCode ?? systemCountryCode).lowercaseString
        return systemCountryCode == code || countryCode == code
    }
}
