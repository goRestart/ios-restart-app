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
    var interestedUsersMode: InterestedUsersMode { get }
    var filtersReorder: Bool { get }
    var directPostInOnboarding: Bool { get }
    var shareButtonWithIcon: Bool { get }
    var productDetailShareMode: ProductDetailShareMode { get }
    var chatHeadBubbles: Bool { get }
    var saveMailLogout: Bool { get }
    var showLiquidProductsToNewUser: Bool { get }
    var expressChatBanner: Bool { get }
    var postAfterDeleteMode: PostAfterDeleteMode { get }
    var keywordsTravelCollection: KeywordsTravelCollection { get }
    var shareAfterPosting: Bool { get }
    var freePostingModeAllowed: Bool { get }
    var commercializerAfterPosting: Bool { get }
    var relatedProductsOnMoreInfo: Bool { get }
    var periscopeImprovement: Bool { get }
    var favoriteWithBadgeOnProfile: Bool { get }
    var favoriteWithBubbleToChat: Bool { get }
}

class FeatureFlags: FeatureFlaggeable {
    
    static let sharedInstance: FeatureFlags = FeatureFlags()
    
    private let locale: NSLocale
    private let locationManager: LocationManager
    
    init(locale: NSLocale, locationManager: LocationManager) {
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
    }

    
    convenience init() {
        self.init(locale: NSLocale.currentLocale(), locationManager: Core.locationManager)
    }


    // MARK: - A/B Tests features

     let websocketChat: Bool
    
     let notificationsSection: Bool

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

     var chatHeadBubbles: Bool {
        if Bumper.enabled {
            return Bumper.chatHeadBubbles
        }
        return ABTests.chatHeadBubbles.value
    }

    var saveMailLogout: Bool {
        if Bumper.enabled {
            return Bumper.saveMailLogout
        }
        return ABTests.saveMailLogout.value
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

    var commercializerAfterPosting: Bool {
        if Bumper.enabled {
            return Bumper.commercializerAfterPosting
        }
        return ABTests.commercializerAfterPosting.value
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
