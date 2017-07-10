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
    let captchaTransparent = BoolABDynamicVar(key: "captchaTransparent", defaultValue: false)
    let passiveBuyersShowKeyboard = BoolABDynamicVar(key: "passiveBuyersShowKeyboard", defaultValue: false)
    let freeBumpUpEnabled = BoolABDynamicVar(key: "freeBumpUpEnabled", defaultValue: false)
    let pricedBumpUpEnabled = BoolABDynamicVar(key: "pricedBumpUpEnabled", defaultValue: false)
    let productDetailNextRelated = BoolABDynamicVar(key: "productDetailNextRelated", defaultValue: false)
    let carsVerticalEnabled = BoolABDynamicVar(key: "carsVerticalEnabled", defaultValue: false)
    let carsCategoryAfterPicture = BoolABDynamicVar(key: "carsCategoryAfterPicture", defaultValue: false)
    let newMarkAsSoldFlow = BoolABDynamicVar(key: "newMarkAsSoldFlow", defaultValue: false)
    let editLocationBubble = IntABDynamicVar(key: "editLocationBubble20170525", defaultValue: 0)
    let newCarsMultiRequesterEnabled = BoolABDynamicVar(key: "newCarsMultiRequesterEnabled", defaultValue: false)
    let newCarouselNavigationEnabled = BoolABDynamicVar(key: "newCarouselNavigationEnabled20170606", defaultValue: false)
    let newOnboardingPhase1 = BoolABDynamicVar(key: "newOnboardingPhase1", defaultValue: false)
    let searchParamDisc24 = IntABDynamicVar(key: "searchParamDisc24", defaultValue: 0)
    let inAppRatingIOS10 = BoolABDynamicVar(key: "inAppRatingIOS10", defaultValue: true)

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
        result.append(passiveBuyersShowKeyboard)
        result.append(captchaTransparent)
        result.append(freeBumpUpEnabled)
        result.append(pricedBumpUpEnabled)
        result.append(productDetailNextRelated)
        result.append(carsVerticalEnabled)
        result.append(carsCategoryAfterPicture)
        result.append(newMarkAsSoldFlow)
        result.append(editLocationBubble)
        result.append(newCarsMultiRequesterEnabled)
        result.append(newCarouselNavigationEnabled)
        result.append(newOnboardingPhase1)
        result.append(searchParamDisc24)
        result.append(inAppRatingIOS10)

        return result
    }

    func registerVariables() {
        allVariables.forEach { $0.register() }
    }

    func variablesUpdated() {
        trackingData.value = allVariables.flatMap { $0.trackingData }
    }
}
