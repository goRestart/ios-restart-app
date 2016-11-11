//
//  FeatureFlags.swift
//  LetGo
//
//  Created by Eli Kohen on 18/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import bumper
import LGCoreKit

struct FeatureFlags {
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
