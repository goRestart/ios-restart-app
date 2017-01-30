//
//  MockFeatureFlags.swift
//  LetGo
//
//  Created by Juan Iglesias on 18/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

@testable import LetGo
import Foundation
import RxSwift

class MockFeatureFlags: FeatureFlaggeable {

    var syncedData: Observable<Bool> {
        return syncedDataVar.asObservable()
    }

    let syncedDataVar = Variable<Bool>(false)

    var websocketChat: Bool = false
    var notificationsSection: Bool = false
    var userReviews: Bool = false
    var showNPSSurvey: Bool = false
    var postAfterDeleteMode: PostAfterDeleteMode = .original
    var keywordsTravelCollection: KeywordsTravelCollection = .standard
    var postingMultiPictureEnabled: Bool = true
    var relatedProductsOnMoreInfo: Bool = true
    var newQuickAnswers: Bool = false
    var favoriteWithBadgeOnProfile: Bool = false
    var favoriteWithBubbleToChat: Bool = false
    var captchaTransparent: Bool = false
    var passiveBuyersShowKeyboard: Bool = false
    var filterIconWithLetters: Bool = false
    var editDeleteItemUxImprovement: Bool = false
    var onboardingReview: OnboardingReview = .testA
    var freeBumpUpEnabled: Bool = false
    var pricedBumpUpEnabled: Bool = false
    var bumpUpFreeTimeLimit: Int = 5000 // 5 secs

    // Country dependant features
    var freePostingModeAllowed = false
    var locationMatchesCountry = false
    var signUpEmailNewsletterAcceptRequired = false
    var signUpEmailTermsAndConditionsAcceptRequired = false
}
