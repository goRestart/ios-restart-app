//
//  FeatureFlags.swift
//  LetGo
//
//  Created by Eli Kohen on 18/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import bumper
import LGCoreKit
import CoreTelephony

protocol FeatureFlaggeable {
    var websocketChat: Bool { get }
    var notificationsSection: Bool { get }
    var userReviews: Bool { get }
    var showNPSSurvey: Bool { get }
    var interestedUsersMode: InterestedUsersMode { get }
    var shareButtonWithIcon: Bool { get }
    var productDetailShareMode: ProductDetailShareMode { get }
    var expressChatBanner: Bool { get }
    var postAfterDeleteMode: PostAfterDeleteMode { get }
    var keywordsTravelCollection: KeywordsTravelCollection { get }
    var shareAfterPosting: Bool { get }
    var freePostingModeAllowed: Bool { get }
    var postingMultiPictureEnabled: Bool { get }
    var relatedProductsOnMoreInfo: Bool { get }
    var monetizationEnabled: Bool { get }
    var periscopeImprovement: Bool { get }
    var newQuickAnswers: Bool { get }
    var favoriteWithBadgeOnProfile: Bool { get }
    var favoriteWithBubbleToChat: Bool { get }
    var locationNoMatchesCountry: Bool { get }
    var captchaTransparent: Bool { get }
    var passiveBuyersShowKeyboard: Bool { get }
    var filterIconWithLetters: Bool { get }
}

class FeatureFlags: FeatureFlaggeable {
    
    static let sharedInstance: FeatureFlags = FeatureFlags()
    
    private let locale: NSLocale
    private let locationManager: LocationManager
    private let countryInfo: CountryConfigurable
    
    init(locale: NSLocale, locationManager: LocationManager, countryInfo: CountryConfigurable) {
        Bumper.initialize()

        // Initialize all vars that shouldn't change over application lifetime
        if Bumper.enabled {
            self.websocketChat = Bumper.websocketChat
            self.notificationsSection = Bumper.notificationsSection
        } else {
            self.websocketChat = false
            self.notificationsSection = ABTests.notificationCenterEnabled.value
        }

        self.locale = locale
        self.locationManager = locationManager
        self.countryInfo = countryInfo
    }

    
    convenience init() {
        self.init(locale: NSLocale.currentLocale(), locationManager: Core.locationManager, countryInfo: CTTelephonyNetworkInfo())
    }


    // MARK: - A/B Tests features

     let websocketChat: Bool
    
     let notificationsSection: Bool

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

     var interestedUsersMode: InterestedUsersMode {
        if Bumper.enabled {
            return Bumper.interestedUsersMode
        }
        return InterestedUsersMode.fromPosition(ABTests.interestedUsersMode.value)
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

    var expressChatBanner: Bool {
        if Bumper.enabled {
            return Bumper.expressChatBanner
        }
        return ABTests.expressChatBanner.value
    }

    var postAfterDeleteMode: PostAfterDeleteMode {
        if Bumper.enabled {
            return Bumper.postAfterDeleteMode
        }
        return PostAfterDeleteMode.fromPosition(ABTests.postAfterDeleteMode.value)
    }

    var keywordsTravelCollection: KeywordsTravelCollection {
        if Bumper.enabled {
            return Bumper.keywordsTravelCollection
        }
        return KeywordsTravelCollection.fromPosition(ABTests.keywordsTravelCollection.value)
    }
    
    var shareAfterPosting: Bool {
        if Bumper.enabled {
            return Bumper.shareAfterPosting
        }
        return ABTests.shareAfterPosting.value
    }

    var postingMultiPictureEnabled: Bool {
        if Bumper.enabled {
            return Bumper.postingMultiPictureEnabled
        }
        return ABTests.postingMultiPictureEnabled.value
    }

    var relatedProductsOnMoreInfo: Bool {
        if Bumper.enabled {
            return Bumper.relatedProductsOnMoreInfo
        }
        return ABTests.relatedProductsOnMoreInfo.value
    }
    
    var periscopeImprovement: Bool {
        if Bumper.enabled {
            return Bumper.periscopeImprovement
        }
        return ABTests.periscopeImprovement.value
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

    var monetizationEnabled: Bool {
        if Bumper.enabled {
            return Bumper.monetizationEnabled
        }
        return false
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


    // MARK: - Country features

    var freePostingModeAllowed: Bool {
        guard let countryCode = countryCode else { return true }
        switch countryCode {
        case .Turkey:
            return false
        }
    }
    
    var locationNoMatchesCountry: Bool {
        guard let countryCode = countryCode else { return false }
        switch countryCode {
        case .Turkey:
            return locationManager.countryNoMatchWith(countryInfo)
        }
    }

    
    // MARK: - Private
    
    /// Return CountryCode from location or phone Region
    private var countryCode: CountryCode? {
        let systemCountryCode = locale.lg_countryCode
        let countryCode = (locationManager.currentPostalAddress?.countryCode ?? systemCountryCode).lowercaseString
        return CountryCode(rawValue: countryCode)
    }
}
