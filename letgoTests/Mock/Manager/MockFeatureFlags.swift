//
//  MockFeatureFlags.swift
//  LetGo
//
//  Created by Juan Iglesias on 18/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
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
    var postAfterDeleteMode: PostAfterDeleteMode = .original
    var favoriteWithBadgeOnProfile: Bool = false
    var shouldContactSellerOnFavorite: Bool = false
    var captchaTransparent: Bool = false
    var passiveBuyersShowKeyboard: Bool = false
    var editDeleteItemUxImprovement: Bool = false
    var onboardingReview: OnboardingReview = .testA
    var freeBumpUpEnabled: Bool = false
    var pricedBumpUpEnabled: Bool = false
    var bumpUpFreeTimeLimit: TimeInterval = 5000 // 5 secs
    var userRatingMarkAsSold: Bool = false
    var productDetailNextRelated: Bool = false
    var signUpLoginImprovement: SignUpLoginImprovement = .v1
    var periscopeRemovePredefinedText: Bool = false

    // Country dependant features
    var freePostingModeAllowed = false
    var locationMatchesCountry = false
    var signUpEmailNewsletterAcceptRequired = false
    var signUpEmailTermsAndConditionsAcceptRequired = false
}
