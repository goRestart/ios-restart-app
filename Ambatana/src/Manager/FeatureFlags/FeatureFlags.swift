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
    static var freePostingMode: FreePostingMode { get }
    static var directPostInOnboarding: Bool { get }
    static var shareButtonWithIcon: Bool { get }
    static var productDetailShareMode: ProductDetailShareMode { get }
    static var periscopeChat: Bool { get }
    static var chatHeadBubbles: Bool { get }
    static var showLiquidProductsToNewUser: Bool { get }
}

struct FeatureFlags: FeatureFlaggeable {
    static func setup() {
        Bumper.initialize()
    }

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

    static var freePostingMode: FreePostingMode {
        guard freePostingModeAllowed else { return .Disabled }

        if Bumper.enabled {
            return Bumper.freePostingMode
        }
        return FreePostingMode.fromPosition(ABTests.freePostingMode.value)
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

    static var postAfterDeleteMode: PostAfterDeleteMode {
        if Bumper.enabled {
            return Bumper.postAfterDeleteMode
        }
        return PostAfterDeleteMode.fromPosition(ABTests.postAfterDeleteMode.value)
    }


    // MARK: - Private

    private static var freePostingModeAllowed: Bool {
        let locale = NSLocale.currentLocale()
        let locationManager = Core.locationManager

        // Free posting is not allowed in Turkey. Check location & phone region.
        let turkey = "tr"
        let systemCountryCode = locale.lg_countryCode
        let countryCode = (locationManager.currentPostalAddress?.countryCode ?? systemCountryCode).lowercaseString

        return systemCountryCode != turkey && countryCode != turkey
    }
}
