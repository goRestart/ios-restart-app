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
    var messageOnFavoriteRound2: MessageOnFavoriteRound2Mode = .NoMessage
    var interestedUsersMode: InterestedUsersMode = .NoNotification
    var filtersReorder: Bool = false
    var directPostInOnboarding: Bool = false
    var shareButtonWithIcon: Bool = false
    var productDetailShareMode: ProductDetailShareMode = .Native
    var chatHeadBubbles: Bool = false
    var saveMailLogout: Bool = false
    var showLiquidProductsToNewUser: Bool = false
    var expressChatBanner: Bool = true
    var postAfterDeleteMode: PostAfterDeleteMode = .Original
    var keywordsTravelCollection: KeywordsTravelCollection = .Standard
    var shareAfterPosting: Bool = false
    var freePostingModeAllowed: Bool = true
    var commercializerAfterPosting: Bool = true
    var postingMultiPictureEnabled: Bool = true
    var relatedProductsOnMoreInfo: Bool = true
    var periscopeImprovement: Bool = false
}
