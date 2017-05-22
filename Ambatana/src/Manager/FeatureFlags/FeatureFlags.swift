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
    var shouldContactSellerOnFavorite: Bool { get }
    var captchaTransparent: Bool { get }
    var passiveBuyersShowKeyboard: Bool { get }
    var onboardingReview: OnboardingReview { get }
    var freeBumpUpEnabled: Bool { get }
    var pricedBumpUpEnabled: Bool { get }
    var userRatingMarkAsSold: Bool { get }
    var productDetailNextRelated: Bool { get }
    var signUpLoginImprovement: SignUpLoginImprovement { get }
    var periscopeRemovePredefinedText: Bool { get }
    var hideTabBarOnFirstSessionV2: Bool { get }
    var postingGallery: PostingGallery { get }
    var quickAnswersRepeatedTextField: Bool { get }
    var carsVerticalEnabled: Bool { get }
    var carsCategoryAfterPicture: Bool { get }

    // Country dependant features
    var freePostingModeAllowed: Bool { get }
    var locationRequiresManualChangeSuggestion: Bool { get }
    var signUpEmailNewsletterAcceptRequired: Bool { get }
    var signUpEmailTermsAndConditionsAcceptRequired: Bool { get }
    func commercialsAllowedFor(productCountryCode: String?) -> Bool
    func collectionsAllowedFor(countryCode: String?) -> Bool
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
            self.websocketChat = ABTests.websocketChat.value
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
    
    var postingGallery: PostingGallery {
        if Bumper.enabled {
            return Bumper.postingGallery
        }
        return PostingGallery.fromPosition(ABTests.postingGallery.value)
    }

    var hideTabBarOnFirstSessionV2: Bool {
        if Bumper.enabled {
            return Bumper.hideTabBarOnFirstSessionV2
        }
        return ABTests.hideTabBarOnFirstSessionV2.value
    }
    
    var quickAnswersRepeatedTextField: Bool {
        if Bumper.enabled {
            return Bumper.quickAnswersRepeatedTextField
        }
        return ABTests.quickAnswersRepeatedTextField.value
    }
    
    var carsVerticalEnabled: Bool {
        if Bumper.enabled {
            return Bumper.carsVerticalEnabled
        }
        return ABTests.carsVerticalEnabled.value
    }
    
    var carsCategoryAfterPicture: Bool {
        if Bumper.enabled {
            return Bumper.carsCategoryAfterPicture
        }
        return ABTests.carsCategoryAfterPicture.value
    }
    
    var newMarkAsSoldFlow: Bool {
        if Bumper.enabled {
            return Bumper.newMarkAsSoldFlow
        }
        return ABTests.newMarkAsSoldFlow.value
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
    
    var locationRequiresManualChangeSuggestion: Bool {
        // Manual location is already ok
        guard let currentLocation = locationManager.currentLocation, currentLocation.isAuto else { return false }
        guard let countryCodeString = carrierCountryInfo.countryCode, let countryCode = CountryCode(string: countryCodeString) else { return false }
        switch countryCode {
        case .turkey:
            // In turkey, if current location country doesn't match carrier one we must sugest user to change it
            return !locationManager.countryMatchesWith(countryCode: countryCodeString)
        case .usa:
            return false
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

    func commercialsAllowedFor(productCountryCode: String?) -> Bool {
        guard let code = productCountryCode, let countryCode = CountryCode(string: code) else { return false }
        switch countryCode {
        case .usa:
            return true
        default:
            return false
        }
    }

    func collectionsAllowedFor(countryCode: String?) -> Bool {
        guard let code = countryCode, let countryCode = CountryCode(string: code) else { return false }
        switch countryCode {
        case .usa:
            return true
        default:
            return false
        }
    }
    
    // MARK: - Private
    
    private var locationCountryCode: CountryCode? {
        guard let countryCode = locationManager.currentLocation?.countryCode else { return nil }
        return CountryCode(string: countryCode)
    }

    private var localeCountryCode: CountryCode? {
        return CountryCode(string: locale.lg_countryCode)
    }
}
