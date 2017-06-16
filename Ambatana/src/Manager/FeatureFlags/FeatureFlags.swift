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

protocol FeatureFlaggeable: class {

    var trackingData: Observable<[String]?> { get }
    var syncedData: Observable<Bool> { get }
    func variablesUpdated()
    
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
    var productDetailNextRelated: Bool { get }
    var signUpLoginImprovement: SignUpLoginImprovement { get }
    var periscopeRemovePredefinedText: Bool { get }
    var hideTabBarOnFirstSessionV2: Bool { get }
    var postingGallery: PostingGallery { get }
    var quickAnswersRepeatedTextField: Bool { get }
    var carsVerticalEnabled: Bool { get }
    var carsCategoryAfterPicture: Bool { get }
    var newMarkAsSoldFlow: Bool { get }
    var editLocationBubble: EditLocationBubble { get }
    var newCarsMultiRequesterEnabled: Bool { get }
    var newCarouselNavigationEnabled: Bool { get }

    // Country dependant features
    var freePostingModeAllowed: Bool { get }
    var locationRequiresManualChangeSuggestion: Bool { get }
    var signUpEmailNewsletterAcceptRequired: Bool { get }
    var signUpEmailTermsAndConditionsAcceptRequired: Bool { get }
    func commercialsAllowedFor(productCountryCode: String?) -> Bool
    func collectionsAllowedFor(countryCode: String?) -> Bool
}

extension FeatureFlaggeable {
    var syncedData: Observable<Bool> {
        return trackingData.map { $0 != nil }
    }
}


class FeatureFlags: FeatureFlaggeable {

    static let sharedInstance: FeatureFlags = FeatureFlags()
    
    let websocketChat: Bool
    private let locale: Locale
    private let locationManager: LocationManager
    private let carrierCountryInfo: CountryConfigurable
    private let abTests: ABTests
    private let dao: FeatureFlagsDAO
    
    init(locale: Locale,
         locationManager: LocationManager,
         countryInfo: CountryConfigurable,
         abTests: ABTests,
         dao: FeatureFlagsDAO) {
        Bumper.initialize()

        // Initialize all vars that shouldn't change over application lifetime
        if Bumper.enabled {
            self.websocketChat = Bumper.websocketChat
        } else {
            self.websocketChat = dao.retrieveWebsocketChatEnabled() ?? abTests.websocketChat.value
        }
        
        self.locale = locale
        self.locationManager = locationManager
        self.carrierCountryInfo = countryInfo
        self.abTests = abTests
        self.dao = dao
    }

    convenience init() {
        self.init(locale: Locale.current,
                  locationManager: Core.locationManager,
                  countryInfo: CTTelephonyNetworkInfo(),
                  abTests: ABTests(),
                  dao: FeatureFlagsUDDAO())
    }

    
    // MARK: - Public methods
    
    func registerVariables() {
        abTests.registerVariables()
    }
    
    
    // MARK: - A/B Tests features

    var trackingData: Observable<[String]?> {
        return abTests.trackingData.asObservable()
    }
    
    func variablesUpdated() {
        dao.save(websocketChatEnabled: abTests.websocketChat.value)
        dao.save(editLocationBubble: EditLocationBubble.fromPosition(abTests.editLocationBubble.value))
        dao.save(carsVerticalEnabled: abTests.carsVerticalEnabled.value)
        abTests.variablesUpdated()
    }

    var userReviews: Bool {
        if Bumper.enabled {
            return Bumper.userReviews
        }
        return abTests.userReviews.value
    }

    var showNPSSurvey: Bool {
        if Bumper.enabled {
            return Bumper.showNPSSurvey
        }
        return abTests.showNPSSurvey.value
    }

    var surveyUrl: String {
        if Bumper.enabled {
            return Bumper.surveyEnabled ? Constants.surveyDefaultTestUrl : ""
        }
        return abTests.surveyURL.value
    }

    var surveyEnabled: Bool {
        if Bumper.enabled {
            return Bumper.surveyEnabled
        }
        return abTests.surveyEnabled.value
    }
    
    var shouldContactSellerOnFavorite: Bool {
        if Bumper.enabled {
            return Bumper.contactSellerOnFavorite
        }
        return abTests.contactSellerOnFavorite.value
    }

    var captchaTransparent: Bool {
        if Bumper.enabled {
            return Bumper.captchaTransparent
        }
        return abTests.captchaTransparent.value
    }

    var passiveBuyersShowKeyboard: Bool {
        if Bumper.enabled {
            return Bumper.passiveBuyersShowKeyboard
        }
        return abTests.passiveBuyersShowKeyboard.value
    }

    var onboardingReview: OnboardingReview {
        if Bumper.enabled {
            return Bumper.onboardingReview
        }
        return OnboardingReview.fromPosition(abTests.onboardingReview.value)
    }

    var freeBumpUpEnabled: Bool {
        if Bumper.enabled {
            return Bumper.freeBumpUpEnabled
        }
        return abTests.freeBumpUpEnabled.value
    }

    var pricedBumpUpEnabled: Bool {
        if Bumper.enabled {
            return Bumper.pricedBumpUpEnabled
        }
        return abTests.pricedBumpUpEnabled.value
    }

    var productDetailNextRelated: Bool {
        if Bumper.enabled {
            return Bumper.productDetailNextRelated
        }
        return abTests.productDetailNextRelated.value
    }

    var signUpLoginImprovement: SignUpLoginImprovement {
        if Bumper.enabled {
            return Bumper.signUpLoginImprovement
        }
        return SignUpLoginImprovement.fromPosition(abTests.signUpLoginImprovement.value)
    }
    
    var periscopeRemovePredefinedText: Bool {
        if Bumper.enabled {
            return Bumper.periscopeRemovePredefinedText
        }
        return abTests.periscopeRemovePredefinedText.value
    }
    
    var postingGallery: PostingGallery {
        if Bumper.enabled {
            return Bumper.postingGallery
        }
        return PostingGallery.fromPosition(abTests.postingGallery.value)
    }

    var hideTabBarOnFirstSessionV2: Bool {
        if Bumper.enabled {
            return Bumper.hideTabBarOnFirstSessionV2
        }
        return abTests.hideTabBarOnFirstSessionV2.value
    }
    
    var quickAnswersRepeatedTextField: Bool {
        if Bumper.enabled {
            return Bumper.quickAnswersRepeatedTextField
        }
        return abTests.quickAnswersRepeatedTextField.value
    }
    
    var carsVerticalEnabled: Bool {
        if Bumper.enabled {
            return Bumper.carsVerticalEnabled
        }
        return dao.retrieveCarsVerticalEnabled() ?? abTests.carsVerticalEnabled.value
    }
    
    var carsCategoryAfterPicture: Bool {
        if Bumper.enabled {
            return Bumper.carsCategoryAfterPicture
        }
        return abTests.carsCategoryAfterPicture.value
    }
    
    var newMarkAsSoldFlow: Bool {
        if Bumper.enabled {
            return Bumper.newMarkAsSoldFlow
        }
        return abTests.newMarkAsSoldFlow.value
    }

    var editLocationBubble: EditLocationBubble {
        if Bumper.enabled {
            return Bumper.editLocationBubble
        }
        return dao.retrieveEditLocationBubble() ?? EditLocationBubble.fromPosition(abTests.editLocationBubble.value)
    }

    var newCarsMultiRequesterEnabled: Bool {
        if Bumper.enabled {
            return Bumper.newCarsMultiRequesterEnabled
        }
        return abTests.newCarsMultiRequesterEnabled.value
    }

    var newCarouselNavigationEnabled: Bool {
        if Bumper.enabled {
            return Bumper.newCarouselNavigationEnabled
        }
        return ABTests.newCarouselNavigationEnabled.value
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
