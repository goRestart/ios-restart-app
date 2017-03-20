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

    var showNPSSurvey: Bool = false
    var surveyUrl: String = ""
    var surveyEnabled: Bool = false

    var websocketChat: Bool = false
    var userReviews: Bool = false
    var shouldContactSellerOnFavorite: Bool = false
    var captchaTransparent: Bool = false
    var passiveBuyersShowKeyboard: Bool = false
    var onboardingReview: OnboardingReview = .testA
    var freeBumpUpEnabled: Bool = false
    var pricedBumpUpEnabled: Bool = false
    var userRatingMarkAsSold: Bool = false
    var productDetailNextRelated: Bool = false
    var signUpLoginImprovement: SignUpLoginImprovement = .v1
    var periscopeRemovePredefinedText: Bool = false
    var hideTabBarOnFirstSession: Bool = false
    var postingGallery: PostingGallery = .singleSelection
    var quickAnswersRepeatedTextField: Bool = false
    var carsVerticalEnabled: Bool = false
    var carsCategoryAfterPicture: Bool = false

    // Country dependant features
    var freePostingModeAllowed = false
    var locationMatchesCountry = false
    var signUpEmailNewsletterAcceptRequired = false
    var signUpEmailTermsAndConditionsAcceptRequired = false
}
