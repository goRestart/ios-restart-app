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

    var websocketChat: Bool { get }
    var userReviews: Bool { get }
    var showNPSSurvey: Bool { get }
    var postAfterDeleteMode: PostAfterDeleteMode { get }
    var freePostingModeAllowed: Bool { get }
    var postingMultiPictureEnabled: Bool { get }
    var newQuickAnswers: Bool { get }
    var favoriteWithBadgeOnProfile: Bool { get }
    var favoriteWithBubbleToChat: Bool { get }
    var locationMatchesCountry: Bool { get }
    var captchaTransparent: Bool { get }
    var passiveBuyersShowKeyboard: Bool { get }
    var filterIconWithLetters: Bool { get }
    var editDeleteItemUxImprovement: Bool { get }
    var onboardingReview: OnboardingReview { get }
    var freeBumpUpEnabled: Bool { get }
    var pricedBumpUpEnabled: Bool { get }
    var bumpUpFreeTimeLimit: Int { get }
    var userRatingMarkAsSold: Bool { get }
    var productDetailNextRelated: Bool { get }
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

    var postAfterDeleteMode: PostAfterDeleteMode {
        if Bumper.enabled {
            return Bumper.postAfterDeleteMode
        }
        return PostAfterDeleteMode.fromPosition(ABTests.postAfterDeleteMode.value)
    }
    
    var postingMultiPictureEnabled: Bool {
        if Bumper.enabled {
            return Bumper.postingMultiPictureEnabled
        }
        return ABTests.postingMultiPictureEnabled.value
    }
    
    var favoriteWithBadgeOnProfile: Bool {
        if Bumper.enabled {
            return Bumper.favoriteWithBadgeOnProfile
        }
        return ABTests.favoriteWithBadgeOnProfile.value
    }
    
    var favoriteWithBubbleToChat: Bool {
        if Bumper.enabled {
            return Bumper.favoriteWithBubbleToChat
        }
        return ABTests.favoriteWithBubbleToChat.value
    }

    var newQuickAnswers: Bool {
        if Bumper.enabled {
            return Bumper.newQuickAnswers
        }
        return ABTests.newQuickAnswers.value
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
    
    var filterIconWithLetters: Bool {
        if Bumper.enabled {
            return Bumper.filterIconWithLetters
        }
        return ABTests.filterIconWithLetters.value
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

    var bumpUpFreeTimeLimit: Int {
        let hoursToMilliseconds = 60 * 60 * 1000
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
        return Int(timeLimit)
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

    
    // MARK: - Country features

    var freePostingModeAllowed: Bool {
        guard let countryCode = countryCode else { return true }
        switch countryCode {
        case .turkey:
            return false
        }
    }
    
    var locationMatchesCountry: Bool {
        guard let countryCodeString = carrierCountryInfo.countryCode, let countryCode = CountryCode(rawValue: countryCodeString) else { return true }
        switch countryCode {
        case .turkey:
            return locationManager.countryMatchesWith(countryCode: countryCodeString)
        }
    }

    
    // MARK: - Private
    
    /// Return CountryCode from location or phone Region
    private var countryCode: CountryCode? {
        let systemCountryCode = locale.lg_countryCode
        let countryCode = (locationManager.currentLocation?.countryCode ?? systemCountryCode).lowercase
        return CountryCode(rawValue: countryCode)
    }
}
