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
    var websocketChat = false
    var notificationsSection = false
    var userReviews = false
    var showNPSSurvey = false
    var postAfterDeleteMode = PostAfterDeleteMode.original
    var keywordsTravelCollection = KeywordsTravelCollection.standard
    var shareAfterPosting = false
    var postingMultiPictureEnabled = true
    var relatedProductsOnMoreInfo = true
    var monetizationEnabled = false
    var newQuickAnswers = false
    var favoriteWithBadgeOnProfile = false
    var favoriteWithBubbleToChat = false
    var captchaTransparent = false
    var passiveBuyersShowKeyboard = false
    var filterIconWithLetters = false
    var editDeleteItemUxImprovement: Bool = false

    var freePostingModeAllowed = false
    var locationMatchesCountry = false
    var signUpEmailNewsletterAcceptRequired = false
    var signUpEmailTermsAndConditionsAcceptRequired = false
}
