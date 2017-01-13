//
//  MockFeatureFlags.swift
//  LetGo
//
//  Created by Juan Iglesias on 18/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

@testable import LetGo
import Foundation

class MockFeatureFlags: FeatureFlaggeable {
    var websocketChat: Bool = false
    var notificationsSection: Bool = false
    var userReviews: Bool = false
    var showNPSSurvey: Bool = false
    var interestedUsersMode: InterestedUsersMode = .noNotification
    var filtersReorder: Bool = false
    var directPostInOnboarding: Bool = false
    var productDetailShareMode: ProductDetailShareMode = .native
    var expressChatBanner: Bool = true
    var postAfterDeleteMode: PostAfterDeleteMode = .original
    var keywordsTravelCollection: KeywordsTravelCollection = .standard
    var shareAfterPosting: Bool = false
    var freePostingModeAllowed: Bool = true
    var postingMultiPictureEnabled: Bool = true
    var relatedProductsOnMoreInfo: Bool = true
    var monetizationEnabled: Bool = false
    var periscopeImprovement: Bool = false
    var newQuickAnswers: Bool = false
    var favoriteWithBadgeOnProfile: Bool = false
    var favoriteWithBubbleToChat: Bool = false
    var locationMatchesCountry: Bool = false
    var captchaTransparent: Bool = false
    var passiveBuyersShowKeyboard: Bool = false
    var filterIconWithLetters: Bool = false
}
