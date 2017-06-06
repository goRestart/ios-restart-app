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

    // Not an A/B just flags and variables for surveys
    static var showNPSSurvey = BoolABDynamicVar(key: "showNPSSurvey", defaultValue: false)
    static var surveyURL = StringABDynamicVar(key: "surveyURL", defaultValue: "")
    static var surveyEnabled = BoolABDynamicVar(key: "surveyEnabled", defaultValue: false)

    static var websocketChat = BoolABDynamicVar(key: "websocketChat", defaultValue: false)
    static var userReviews = BoolABDynamicVar(key: "userReviews", defaultValue: false)
    static var contactSellerOnFavorite = BoolABDynamicVar(key: "contactSellerOnFavorite", defaultValue: false)
    static var captchaTransparent = BoolABDynamicVar(key: "captchaTransparent", defaultValue: false)
    static var passiveBuyersShowKeyboard = BoolABDynamicVar(key: "passiveBuyersShowKeyboard", defaultValue: false)
    static var onboardingReview = IntABDynamicVar(key: "onboardingReview", defaultValue: 0)
    static var freeBumpUpEnabled = BoolABDynamicVar(key: "freeBumpUpEnabled", defaultValue: false)
    static var pricedBumpUpEnabled = BoolABDynamicVar(key: "pricedBumpUpEnabled", defaultValue: false)
    static var productDetailNextRelated = BoolABDynamicVar(key: "productDetailNextRelated", defaultValue: false)
    static var signUpLoginImprovement = IntABDynamicVar(key: "signUpLoginImprovement", defaultValue: 0)
    static var periscopeRemovePredefinedText = BoolABDynamicVar(key: "periscopeRemovePredefinedText", defaultValue: false)
    static var hideTabBarOnFirstSessionV2 = BoolABDynamicVar(key: "hideTabBarOnFirstSessionV2", defaultValue: false)
    static var postingGallery = IntABDynamicVar(key: "postingGallery", defaultValue: 0)
    static var quickAnswersRepeatedTextField = BoolABDynamicVar(key: "quickAnswersRepeatedTextField", defaultValue: false)
    static var carsVerticalEnabled = BoolABDynamicVar(key: "carsVerticalEnabled", defaultValue: false)
    static var carsCategoryAfterPicture = BoolABDynamicVar(key: "carsCategoryAfterPicture", defaultValue: false)
    static var newMarkAsSoldFlow = BoolABDynamicVar(key: "newMarkAsSoldFlow", defaultValue: false)
    static var editLocationBubble = IntABDynamicVar(key: "editLocationBubble20170525", defaultValue: 0)
    static var newCarsMultiRequesterEnabled = BoolABDynamicVar(key: "newCarsMultiRequesterEnabled", defaultValue: false)
    static var newCarouselNavigationEnabled = BoolABDynamicVar(key: "newCarouselNavigationEnabled20170606", defaultValue: false)

    static private var allVariables: [ABVariable] {
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
        result.append(newCarouselNavigationEnabled)

        return result
    }

    static func registerVariables() {
        allVariables.forEach { $0.register() }
    }

    static func variablesUpdated() {
        trackingData.value = allVariables.flatMap { $0.trackingData }
    }
}
