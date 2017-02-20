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
    var userReviews: Bool = false
    var showNPSSurvey: Bool = false
    var filtersReorder: Bool = false
    var directPostInOnboarding: Bool = false
    var postAfterDeleteMode: PostAfterDeleteMode = .original
    var freePostingModeAllowed: Bool = true
    var favoriteWithBadgeOnProfile: Bool = false
    var favoriteWithBubbleToChat: Bool = false
    var locationMatchesCountry: Bool = false
    var captchaTransparent: Bool = false
    var passiveBuyersShowKeyboard: Bool = false
    var editDeleteItemUxImprovement: Bool = false
    var onboardingReview: OnboardingReview = .testA
    var freeBumpUpEnabled: Bool = false
    var pricedBumpUpEnabled: Bool = false
    var bumpUpFreeTimeLimit: Int = 5000 // 5 secs
    var userRatingMarkAsSold: Bool = false
    var productDetailNextDiscovery: Bool = false
}
