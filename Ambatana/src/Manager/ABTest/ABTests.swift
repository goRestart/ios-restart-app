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
    let captchaTransparent = BoolABDynamicVar(key: "captchaTransparent", defaultValue: false)
    let passiveBuyersShowKeyboard = BoolABDynamicVar(key: "passiveBuyersShowKeyboard", defaultValue: false)
    let freeBumpUpEnabled = BoolABDynamicVar(key: "freeBumpUpEnabled", defaultValue: false)
    let pricedBumpUpEnabled = BoolABDynamicVar(key: "pricedBumpUpEnabled", defaultValue: false)
    let newMarkAsSoldFlow = BoolABDynamicVar(key: "newMarkAsSoldFlow", defaultValue: false)
    let newCarsMultiRequesterEnabled = BoolABDynamicVar(key: "newCarsMultiRequesterEnabled", defaultValue: false)
    let newOnboardingPhase1 = BoolABDynamicVar(key: "newOnboardingPhase1", defaultValue: false)
    let searchParamDisc129 = IntABDynamicVar(key: "SearchParamDisc129", defaultValue: 0)
    let inAppRatingIOS10 = BoolABDynamicVar(key: "20170711inAppRatingIOS10", defaultValue: false)
    let addSuperKeywordsOnFeed = IntABDynamicVar(key: "20170719AddSuperKeywordsOnFeed", defaultValue: 0)
    let copiesImprovementOnboarding = IntABDynamicVar(key: "20170803CopiesImprovementOnboarding", defaultValue: 0)
    let openGalleryInPosting = IntABDynamicVar(key: "20170810OpenGalleryInPosting", defaultValue: 0)
    let tweaksCarPostingFlow = IntABDynamicVar(key: "20170810tweaksCarPostingFlow", defaultValue: 0)
    let userReviewsReportEnabled = BoolABDynamicVar(key: "20170823userReviewsReportEnabled", defaultValue: true)
    let dynamicQuickAnswers = IntABDynamicVar(key: "20170816DynamicQuickAnswers", defaultValue: 0)
    let appRatingDialogInactive = BoolABDynamicVar(key: "20170831AppRatingDialogInactive", defaultValue: false)
    let feedFilterRadiusValues = IntABDynamicVar(key: "20170904feedFilterRadiusValues", defaultValue: 0)
    let expandableCategorySelectionMenu = IntABDynamicVar(key: "20170904ExpandableCategorySelectionMenu", defaultValue: 0)
    let locationDataSourceType = IntABDynamicVar(key: "20170830LocationDataSourceType", defaultValue: 0)
    let defaultRadiusDistanceFeed = IntABDynamicVar(key: "20170922DefaultRadiusDistanceFeed", defaultValue: 0)
    let searchAutocomplete = IntABDynamicVar(key: "20170914SearchAutocomplete", defaultValue: 0)
    let newCarouselTapNextPhotoNavigationEnabled = IntABDynamicVar(key: "20170914NewCarouselTapNextPhotoNavigationEnabled", defaultValue: 0)
    let realEstateEnabled = BoolABDynamicVar(key: "20170927realEstateEnabled", defaultValue: false)
    let requestsTimeOut = IntABDynamicVar(key: "20170929RequestTimeOut", defaultValue: 30)

    init() {
    }
    
    private var allVariables: [ABVariable] {
        var result = [ABVariable]()

        result.append(marketingPush)
        
        result.append(showNPSSurvey)
        result.append(surveyURL)
        result.append(surveyEnabled)

        result.append(websocketChat)
        result.append(passiveBuyersShowKeyboard)
        result.append(captchaTransparent)
        result.append(freeBumpUpEnabled)
        result.append(pricedBumpUpEnabled)
        result.append(newMarkAsSoldFlow)
        result.append(newCarsMultiRequesterEnabled)
        result.append(newOnboardingPhase1)
        result.append(searchParamDisc129)
        result.append(inAppRatingIOS10)
        result.append(addSuperKeywordsOnFeed)
        result.append(copiesImprovementOnboarding)
        result.append(openGalleryInPosting)
        result.append(tweaksCarPostingFlow)
        result.append(userReviewsReportEnabled)
        result.append(dynamicQuickAnswers)
        result.append(appRatingDialogInactive)
        result.append(feedFilterRadiusValues)
        result.append(expandableCategorySelectionMenu)
        result.append(locationDataSourceType)
        result.append(defaultRadiusDistanceFeed)
        
        result.append(searchAutocomplete)
        result.append(newCarouselTapNextPhotoNavigationEnabled)
        result.append(realEstateEnabled)
        result.append(requestsTimeOut)
        
        return result
    }

    func registerVariables() {
        allVariables.forEach { $0.register() }
    }

    func variablesUpdated() {
        trackingData.value = allVariables.flatMap { $0.trackingData }
    }
}
