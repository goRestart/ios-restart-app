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

    let websocketChat = BoolABDynamicVar(key: "websocketChat20170609", defaultValue: true)
    let userReviews = BoolABDynamicVar(key: "userReviews", defaultValue: false)
    let captchaTransparent = BoolABDynamicVar(key: "captchaTransparent", defaultValue: false)
    let passiveBuyersShowKeyboard = BoolABDynamicVar(key: "passiveBuyersShowKeyboard", defaultValue: false)
    let freeBumpUpEnabled = BoolABDynamicVar(key: "freeBumpUpEnabled", defaultValue: false)
    let pricedBumpUpEnabled = BoolABDynamicVar(key: "pricedBumpUpEnabled", defaultValue: false)
    let productDetailNextRelated = BoolABDynamicVar(key: "productDetailNextRelated", defaultValue: false)
    let newMarkAsSoldFlow = BoolABDynamicVar(key: "newMarkAsSoldFlow", defaultValue: false)
    let editLocationBubble = IntABDynamicVar(key: "editLocationBubble20170525", defaultValue: 1)
    let newCarsMultiRequesterEnabled = BoolABDynamicVar(key: "newCarsMultiRequesterEnabled", defaultValue: false)
    let newCarouselNavigationEnabled = BoolABDynamicVar(key: "newCarouselNavigationEnabled20170606", defaultValue: false)
    let newOnboardingPhase1 = BoolABDynamicVar(key: "newOnboardingPhase1", defaultValue: false)
    let searchParamDisc24 = IntABDynamicVar(key: "searchParamDisc24", defaultValue: 0)
    let inAppRatingIOS10 = BoolABDynamicVar(key: "20170711inAppRatingIOS10", defaultValue: false)
    let suggestedSearches = IntABDynamicVar(key: "20170717suggestedSearches", defaultValue: 0)
    let addSuperKeywordsOnFeed = IntABDynamicVar(key: "20170719AddSuperKeywordsOnFeed", defaultValue: 0)
    let copiesImprovementOnboarding = IntABDynamicVar(key: "20170803CopiesImprovementOnboarding", defaultValue: 0)
    let bumpUpImprovementBanner = IntABDynamicVar(key: "20170804BumpUpImprovementBanner", defaultValue: 0)

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
        result.append(newMarkAsSoldFlow)
        result.append(editLocationBubble)
        result.append(newCarsMultiRequesterEnabled)
        result.append(newCarouselNavigationEnabled)
        result.append(newOnboardingPhase1)
        result.append(searchParamDisc24)
        result.append(inAppRatingIOS10)
        result.append(suggestedSearches)
        result.append(addSuperKeywordsOnFeed)
        result.append(copiesImprovementOnboarding)
        result.append(bumpUpImprovementBanner)

        return result
    }

    func registerVariables() {
        allVariables.forEach { $0.register() }
    }

    func variablesUpdated() {
        trackingData.value = allVariables.flatMap { $0.trackingData }
    }
}
