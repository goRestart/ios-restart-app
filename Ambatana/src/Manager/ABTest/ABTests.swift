//
//  ABTests.swift
//  LetGo
//
//  Created by Dídac on 12/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import RxSwift

class ABTests {
    let trackingData = Variable<[String]?>(nil)

    // Not used in code, Just a helper for marketing team
    let marketingPush = IntABDynamicVar(key: "marketingPush", defaultValue: 0)

    // Not an A/B just flags and variables for surveys
    let showNPSSurvey = BoolABDynamicVar(key: "showNPSSurvey", defaultValue: false)
    let surveyURL = StringABDynamicVar(key: "surveyURL", defaultValue: "")
    let surveyEnabled = BoolABDynamicVar(key: "surveyEnabled", defaultValue: false)

    let websocketChat = BoolABDynamicVar(key: "websocketChat20170609", defaultValue: false)
    let userReviews = BoolABDynamicVar(key: "userReviews", defaultValue: false)
    let contactSellerOnFavorite = BoolABDynamicVar(key: "contactSellerOnFavorite", defaultValue: false)
    let captchaTransparent = BoolABDynamicVar(key: "captchaTransparent", defaultValue: false)
    let passiveBuyersShowKeyboard = BoolABDynamicVar(key: "passiveBuyersShowKeyboard", defaultValue: false)
    let onboardingReview = IntABDynamicVar(key: "onboardingReview", defaultValue: 0)
    let freeBumpUpEnabled = BoolABDynamicVar(key: "freeBumpUpEnabled", defaultValue: false)
    let pricedBumpUpEnabled = BoolABDynamicVar(key: "pricedBumpUpEnabled", defaultValue: false)
    let productDetailNextRelated = BoolABDynamicVar(key: "productDetailNextRelated", defaultValue: false)
    let signUpLoginImprovement = IntABDynamicVar(key: "signUpLoginImprovement", defaultValue: 0)
    let periscopeRemovePredefinedText = BoolABDynamicVar(key: "periscopeRemovePredefinedText", defaultValue: false)
    let hideTabBarOnFirstSessionV2 = BoolABDynamicVar(key: "hideTabBarOnFirstSessionV2", defaultValue: false)
    let postingGallery = IntABDynamicVar(key: "postingGallery", defaultValue: 0)
    let quickAnswersRepeatedTextField = BoolABDynamicVar(key: "quickAnswersRepeatedTextField", defaultValue: false)
    let carsVerticalEnabled = BoolABDynamicVar(key: "carsVerticalEnabled", defaultValue: false)
    let carsCategoryAfterPicture = BoolABDynamicVar(key: "carsCategoryAfterPicture", defaultValue: false)
    let newMarkAsSoldFlow = BoolABDynamicVar(key: "newMarkAsSoldFlow", defaultValue: false)
    let editLocationBubble = IntABDynamicVar(key: "editLocationBubble20170525", defaultValue: 0)
    let newCarsMultiRequesterEnabled = BoolABDynamicVar(key: "newCarsMultiRequesterEnabled", defaultValue: false)
    let newOnboardingPhase1 = BoolABDynamicVar(key: "newOnboardingPhase1", defaultValue: false)

    init() {
    }
    
    private var allVariables: [ABVariable] {
        var result = [ABVariable]()

        result.append(marketingPush)
        
        result.append(showNPSSurvey)
        result.append(surveyURL)
        result.append(surveyEnabled)

        result.append(websocketChat)
        result.append(userReviews)
        result.append(contactSellerOnFavorite)
        result.append(passiveBuyersShowKeyboard)
        result.append(captchaTransparent)
        result.append(onboardingReview)
        result.append(freeBumpUpEnabled)
        result.append(pricedBumpUpEnabled)
        result.append(productDetailNextRelated)
        result.append(signUpLoginImprovement)
        result.append(periscopeRemovePredefinedText)
        result.append(hideTabBarOnFirstSessionV2)
        result.append(postingGallery)
        result.append(quickAnswersRepeatedTextField)
        result.append(carsVerticalEnabled)
        result.append(carsCategoryAfterPicture)
        result.append(newMarkAsSoldFlow)
        result.append(editLocationBubble)
        result.append(newCarsMultiRequesterEnabled)

        return result
    }

    func registerVariables() {
        allVariables.forEach { $0.register() }
    }

    func variablesUpdated() {
        trackingData.value = allVariables.flatMap { $0.trackingData }
    }
}
