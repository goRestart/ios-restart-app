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

    let captchaTransparent = BoolABDynamicVar(key: "captchaTransparent", defaultValue: false)
    let freeBumpUpEnabled = BoolABDynamicVar(key: "freeBumpUpEnabled", defaultValue: false)
    let pricedBumpUpEnabled = BoolABDynamicVar(key: "pricedBumpUpEnabled", defaultValue: false)
    let newCarsMultiRequesterEnabled = BoolABDynamicVar(key: "newCarsMultiRequesterEnabled", defaultValue: false)
    let inAppRatingIOS10 = BoolABDynamicVar(key: "20170711inAppRatingIOS10", defaultValue: false)
    let tweaksCarPostingFlow = IntABDynamicVar(key: "20170810tweaksCarPostingFlow", defaultValue: 0)
    let userReviewsReportEnabled = BoolABDynamicVar(key: "20170823userReviewsReportEnabled", defaultValue: true)
    let dynamicQuickAnswers = IntABDynamicVar(key: "20170816DynamicQuickAnswers", defaultValue: 0)
    let appRatingDialogInactive = BoolABDynamicVar(key: "20170831AppRatingDialogInactive", defaultValue: false)
    let expandableCategorySelectionMenu = IntABDynamicVar(key: "20170904ExpandableCategorySelectionMenu", defaultValue: 0)
    let locationDataSourceType = IntABDynamicVar(key: "20170830LocationDataSourceType", defaultValue: 0)
    let defaultRadiusDistanceFeed = IntABDynamicVar(key: "20170922DefaultRadiusDistanceFeed", defaultValue: 0)
    let searchAutocomplete = IntABDynamicVar(key: "20170914SearchAutocomplete", defaultValue: 0)
    let realEstateEnabled = BoolABDynamicVar(key: "20171106realEstateEnabled", defaultValue: false)
    let showPriceAfterSearchOrFilter = IntABDynamicVar(key: "20170928ShowPriceAfterSearchOrFilter", defaultValue: 0)
    let requestsTimeOut = IntABDynamicVar(key: "20170929RequestTimeOut", defaultValue: 30)
    let newBumpUpExplanation = IntABDynamicVar(key: "20171004NewBumpUpExplanation", defaultValue: 0)
    let homeRelatedEnabled = IntABDynamicVar(key: "20171011HomeRelatedEnabled", defaultValue: 0)
    let hideChatButtonOnFeaturedCells = IntABDynamicVar(key: "20171011ChatButtonOnFeaturedCells", defaultValue: 0)
    let moreInfoAdActive = IntABDynamicVar(key: "20171018MoreInfoAdActive", defaultValue: 0)
    let newItemPage = IntABDynamicVar(key: "20171027NewItemPage", defaultValue: 0)
    let taxonomiesAndTaxonomyChildrenInFeed = IntABDynamicVar(key: "20171031TaxonomiesAndTaxonomyChildrenInFeed", defaultValue: 0)
    let showPriceStepRealEstatePosting = IntABDynamicVar(key: "20171106RealEstatePostingOrder", defaultValue: 0)
    let showClockInDirectAnswer = IntABDynamicVar(key: "20171031ShowClockInDirectAnswer", defaultValue: 0)
    let bumpUpPriceDifferentiation = IntABDynamicVar(key: "20171114BumpUpPriceDifferentiation", defaultValue: 0)
    let promoteBumpUpAfterSell = IntABDynamicVar(key: "20171127PromoteBumpUpAfterSell", defaultValue: 0)
    
    init() {
    }
    
    private var allVariables: [ABVariable] {
        var result = [ABVariable]()

        result.append(marketingPush)
        result.append(showNPSSurvey)
        result.append(surveyURL)
        result.append(surveyEnabled)
        result.append(captchaTransparent)
        result.append(freeBumpUpEnabled)
        result.append(pricedBumpUpEnabled)
        result.append(newCarsMultiRequesterEnabled)
        result.append(inAppRatingIOS10)
        result.append(tweaksCarPostingFlow)
        result.append(userReviewsReportEnabled)
        result.append(dynamicQuickAnswers)
        result.append(appRatingDialogInactive)
        result.append(expandableCategorySelectionMenu)
        result.append(locationDataSourceType)
        result.append(defaultRadiusDistanceFeed)
        result.append(searchAutocomplete)
        result.append(realEstateEnabled)
        result.append(showPriceAfterSearchOrFilter)
        result.append(requestsTimeOut)
        result.append(newBumpUpExplanation)
        result.append(homeRelatedEnabled)
        result.append(hideChatButtonOnFeaturedCells)
        result.append(moreInfoAdActive)
        result.append(newItemPage)
        result.append(taxonomiesAndTaxonomyChildrenInFeed)
        result.append(showPriceStepRealEstatePosting)
        result.append(showClockInDirectAnswer)
        result.append(bumpUpPriceDifferentiation)
        result.append(promoteBumpUpAfterSell)
        
        return result
    }

    func registerVariables() {
        allVariables.forEach { $0.register() }
    }

    func variablesUpdated() {
        trackingData.value = allVariables.flatMap { $0.trackingData }
    }
}
