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
        return false
    }()

    static var userRatings: Bool {
        if Bumper.enabled {
            return Bumper.userRatings
        }
        return false
    }
    
    static var showNPSSurvey: Bool {
        if Bumper.enabled {
            return Bumper.showNPSSurvey
        }
        return ABTests.showNPSSurvey.value
    }

    static var nonStopProductDetail: Bool {
        if Bumper.enabled {
            return Bumper.nonStopProductDetail
        }
        return ABTests.nonStopProductDetail.value
    }

    static var onboardinPermissionsMode: OnboardingPermissionsMode {
        if Bumper.enabled {
            return Bumper.onboardingPermissionsMode
        }
        return OnboardingPermissionsMode.fromPosition(ABTests.onboardingPermissionsMode.value)
    }

    static var incentivizePostingMode: IncentivizePostingMode {
        if Bumper.enabled {
            return Bumper.incentivizePostingMode
        }
        return IncentivizePostingMode.fromPosition(ABTests.incentivatePostingMode.value)
    }

    static var messageOnFavorite: MessageOnFavoriteMode {
        if Bumper.enabled {
            return Bumper.messageOnFavoriteMode
        }
        return MessageOnFavoriteMode.fromPosition(ABTests.messageOnFavorite.value)
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
    
    static var halfCameraButton: Bool {
        if Bumper.enabled {
            return Bumper.halfCameraButton
        }
        return ABTests.halfCameraButton.value
    }

    static var freePostingMode: FreePostingMode {
        let locale = NSLocale.currentLocale()
        let locationManager = Core.locationManager
        guard freePostingModeAllowed(locale, locationManager: locationManager) else { return .Disabled }

        if Bumper.enabled {
            return Bumper.freePostingMode
        }
        return FreePostingMode.fromPosition(ABTests.freePostingMode.value)
    }

    private static func freePostingModeAllowed(locale: NSLocale, locationManager: LocationManager) -> Bool {
        // Free posting is not allowed in Turkey. Check location & phone region.
        let turkey = "tr"
        let systemCountryCode = (locale.objectForKey(NSLocaleCountryCode) as? String ?? "").lowercaseString
        let countryCode = (locationManager.currentPostalAddress?.countryCode ?? systemCountryCode).lowercaseString

        return systemCountryCode != turkey && countryCode != turkey
    }
}
