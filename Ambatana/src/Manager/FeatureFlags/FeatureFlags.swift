//
//  FeatureFlags.swift
//  LetGo
//
//  Created by Eli Kohen on 18/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import CoreTelephony
import bumper
import RxSwift

protocol FeatureFlaggeable {

    var syncedData: Observable<Bool> { get }

    var showNPSSurvey: Bool { get }
    var surveyUrl: String { get }
    var surveyEnabled: Bool { get }

    var websocketChat: Bool { get }
    var userReviews: Bool { get }
    var postAfterDeleteMode: PostAfterDeleteMode { get }
    var favoriteWithBadgeOnProfile: Bool { get }
    var shouldContactSellerOnFavorite: Bool { get }
    var captchaTransparent: Bool { get }
    var passiveBuyersShowKeyboard: Bool { get }
    var editDeleteItemUxImprovement: Bool { get }
    var onboardingReview: OnboardingReview { get }
    var freeBumpUpEnabled: Bool { get }
    var pricedBumpUpEnabled: Bool { get }
    var bumpUpFreeTimeLimit: TimeInterval { get }
    var userRatingMarkAsSold: Bool { get }
    var productDetailNextRelated: Bool { get }
    var signUpLoginImprovement: SignUpLoginImprovement { get }
    var periscopeRemovePredefinedText: Bool { get }
    var hideTabBarOnFirstSession: Bool { get }

    // Country dependant features
    var freePostingModeAllowed: Bool { get }
    var locationMatchesCountry: Bool { get }
    var signUpEmailNewsletterAcceptRequired: Bool { get }
    var signUpEmailTermsAndConditionsAcceptRequired: Bool { get }
}


class FeatureFlags: FeatureFlaggeable {

    static let sharedInstance: FeatureFlags = FeatureFlags()
    
    private let locale: Locale
    private let locationManager: LocationManager
    private let carrierCountryInfo: CountryConfigurable
    
    init(locale: Locale, locationManager: LocationManager, countryInfo: CountryConfigurable) {
        Bumper.initialize()

        // Initialize all vars that shouldn't change over application lifetime
        if Bumper.enabled {
            self.websocketChat = Bumper.websocketChat
        } else {
            self.websocketChat = false
        }

        self.locale = locale
        self.locationManager = locationManager
        self.carrierCountryInfo = countryInfo
    }

    convenience init() {
        self.init(locale: Locale.current, locationManager: Core.locationManager, countryInfo: CTTelephonyNetworkInfo())
    }


    // MARK: - A/B Tests features

    var syncedData: Observable<Bool> {
        return ABTests.trackingData.asObservable().map { $0 != nil }
    }

    let websocketChat: Bool

    var userReviews: Bool {
        if Bumper.enabled {
            return Bumper.userReviews
        }
        return ABTests.userReviews.value
    }

    var showNPSSurvey: Bool {
        if Bumper.enabled {
            return Bumper.showNPSSurvey
        }
        return ABTests.showNPSSurvey.value
    }

    var surveyUrl: String {
        if Bumper.enabled {
            return Bumper.surveyEnabled ? Constants.surveyDefaultTestUrl : ""
        }
        return ABTests.surveyURL.value
    }

    var surveyEnabled: Bool {
        if Bumper.enabled {
            return Bumper.surveyEnabled
        }
        return ABTests.surveyEnabled.value
    }

    var postAfterDeleteMode: PostAfterDeleteMode {
        if Bumper.enabled {
            return Bumper.postAfterDeleteMode
        }
        return PostAfterDeleteMode.fromPosition(ABTests.postAfterDeleteMode.value)
    }
    
    var favoriteWithBadgeOnProfile: Bool {
        if Bumper.enabled {
            return Bumper.favoriteWithBadgeOnProfile
        }
        return ABTests.favoriteWithBadgeOnProfile.value
    }
    
    var shouldContactSellerOnFavorite: Bool {
        if Bumper.enabled {
            return Bumper.contactSellerOnFavorite
        }
        return ABTests.contactSellerOnFavorite.value
    }

    var captchaTransparent: Bool {
        if Bumper.enabled {
            return Bumper.captchaTransparent
        }
        return ABTests.captchaTransparent.value
    }

    var passiveBuyersShowKeyboard: Bool {
        if Bumper.enabled {
            return Bumper.passiveBuyersShowKeyboard
        }
        return ABTests.passiveBuyersShowKeyboard.value
    }
    
    var editDeleteItemUxImprovement: Bool {
        if Bumper.enabled {
            return Bumper.editDeleteItemUxImprovement
        }
        return ABTests.editDeleteItemUxImprovement.value
    }

    var onboardingReview: OnboardingReview {
        if Bumper.enabled {
            return Bumper.onboardingReview
        }
        return OnboardingReview.fromPosition(ABTests.onboardingReview.value)
    }

    var freeBumpUpEnabled: Bool {
        if Bumper.enabled {
            return Bumper.freeBumpUpEnabled
        }
        return ABTests.freeBumpUpEnabled.value
    }

    var pricedBumpUpEnabled: Bool {
        if Bumper.enabled {
            return Bumper.pricedBumpUpEnabled
        }
        return ABTests.pricedBumpUpEnabled.value
    }

    var bumpUpFreeTimeLimit: TimeInterval {
        let hoursToMilliseconds: TimeInterval = 60 * 60 * 1000
        if Bumper.enabled {
            switch Bumper.bumpUpFreeTimeLimit {
            case .oneMin:
                return hoursToMilliseconds/60
            case .eightHours:
                return 8 * hoursToMilliseconds
            case .twelveHours:
                return 12 * hoursToMilliseconds
            case .twentyFourHours:
                return 24 * hoursToMilliseconds
            }
        }
        let timeLimit = ABTests.bumpUpFreeTimeLimit.value * Float(hoursToMilliseconds)
        return TimeInterval(timeLimit)
    }

    var userRatingMarkAsSold: Bool {
        if Bumper.enabled {
            return Bumper.userRatingMarkAsSold
        }
        return ABTests.userRatingMarkAsSold.value
    }

    var productDetailNextRelated: Bool {
        if Bumper.enabled {
            return Bumper.productDetailNextRelated
        }
        return ABTests.productDetailNextRelated.value
    }

    var signUpLoginImprovement: SignUpLoginImprovement {
        if Bumper.enabled {
            return Bumper.signUpLoginImprovement
        }
        return SignUpLoginImprovement.fromPosition(ABTests.signUpLoginImprovement.value)
    }
    
    var periscopeRemovePredefinedText: Bool {
        if Bumper.enabled {
            return Bumper.periscopeRemovePredefinedText
        }
        return ABTests.periscopeRemovePredefinedText.value
    }

    var hideTabBarOnFirstSession: Bool {
        if Bumper.enabled {
            return Bumper.hideTabBarOnFirstSession
        }
        return ABTests.hideTabBarOnFirstSession.value
    }
    
    
    // MARK: - Country features

    var freePostingModeAllowed: Bool {
        switch (locationCountryCode, localeCountryCode) {
        case (.turkey?, _), (_, .turkey?):
            return false
        default:
            return true
        }
    }
    
    var locationMatchesCountry: Bool {
        guard let countryCodeString = carrierCountryInfo.countryCode, let countryCode = CountryCode(rawValue: countryCodeString) else { return true }
        switch countryCode {
        case .turkey:
            return locationManager.countryMatchesWith(countryCode: countryCodeString)
        }
    }

    var signUpEmailNewsletterAcceptRequired: Bool {
        switch (locationCountryCode, localeCountryCode) {
        case (.turkey?, _), (_, .turkey?):
            return true
        default:
            return false
        }
    }

    var signUpEmailTermsAndConditionsAcceptRequired: Bool {
        switch (locationCountryCode, localeCountryCode) {
        case (.turkey?, _), (_, .turkey?):
            return true
        default:
            return false
        }
    }

    
    // MARK: - Private
    
    private var locationCountryCode: CountryCode? {
        guard let countryCode = locationManager.currentLocation?.countryCode else { return nil }
        return CountryCode(rawValue: countryCode)
    }

    private var localeCountryCode: CountryCode? {
        return CountryCode(rawValue: locale.lg_countryCode)
    }
}
