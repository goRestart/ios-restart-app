//
//  ABTests.swift
//  LetGo
//
//  Created by Dídac on 12/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import RxSwift

struct ABTests {

    static let trackingData = Variable<[String]?>(nil)

    // Not used in code, Just a helper for marketing team
    static var marketingPush = IntABDynamicVar(key: "marketingPush", defaultValue: 0)

    static var showNPSSurvey = BoolABDynamicVar(key: "showNPSSurvey", defaultValue: false)
    static var postAfterDeleteMode = IntABDynamicVar(key: "postAfterDeleteMode", defaultValue: 0)
    static var userReviews = BoolABDynamicVar(key: "userReviews", defaultValue: false)
    static var favoriteWithBadgeOnProfile = BoolABDynamicVar(key: "favoriteWithBadgeOnProfile", defaultValue: false)
    static var captchaTransparent = BoolABDynamicVar(key: "captchaTransparent", defaultValue: false)
    static var passiveBuyersShowKeyboard = BoolABDynamicVar(key: "passiveBuyersShowKeyboard", defaultValue: false)
    static var editDeleteItemUxImprovement = BoolABDynamicVar(key: "editDeleteItemUxImprovement", defaultValue: false)
    static var onboardingReview = IntABDynamicVar(key: "onboardingReview", defaultValue: 0)
    static var bumpUpFreeTimeLimit = FloatABDynamicVar(key: "bumpUpFreeTimeLimit", defaultValue: 8)
    static var freeBumpUpEnabled = BoolABDynamicVar(key: "freeBumpUpEnabled", defaultValue: false)
    static var pricedBumpUpEnabled = BoolABDynamicVar(key: "pricedBumpUpEnabled", defaultValue: false)
    static var userRatingMarkAsSold = BoolABDynamicVar(key: "userRatingMarkAsSold", defaultValue: false)
    static var signUpLoginImprovement = IntABDynamicVar(key: "signUpLoginImprovement", defaultValue: 0)

    static private var allVariables: [ABVariable] {
        var result = [ABVariable]()

        result.append(marketingPush)
        result.append(showNPSSurvey)
        result.append(postAfterDeleteMode)
        result.append(userReviews)
        result.append(favoriteWithBadgeOnProfile)
        result.append(passiveBuyersShowKeyboard)
        result.append(captchaTransparent)
        result.append(editDeleteItemUxImprovement)
        result.append(onboardingReview)
        result.append(bumpUpFreeTimeLimit)
        result.append(freeBumpUpEnabled)
        result.append(pricedBumpUpEnabled)
        result.append(userRatingMarkAsSold)
        result.append(signUpLoginImprovement)

        return result
    }

    static func registerVariables() {
        allVariables.forEach { $0.register() }
    }

    static func variablesUpdated() {
        trackingData.value = allVariables.flatMap { $0.trackingData }
    }
}
