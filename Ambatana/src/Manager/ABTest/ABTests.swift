//
//  ABTests.swift
//  LetGo
//
//  Created by Dídac on 12/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import RxSwift

class ABTests {
    let trackingData = Variable<[(String, ABGroupType)]?>(nil)

    // Not used in code, Just a helper for marketing team
    let marketingPush = IntABDynamicVar(key: "marketingPush", defaultValue: 0, abGroupType: .base)

    // Not an A/B just flags and variables for surveys
    let showNPSSurvey = BoolABDynamicVar(key: "showNPSSurvey", defaultValue: false, abGroupType: .base)
    let surveyURL = StringABDynamicVar(key: "surveyURL", defaultValue: "", abGroupType: .base)
    let surveyEnabled = BoolABDynamicVar(key: "surveyEnabled", defaultValue: false, abGroupType: .base)

    let freeBumpUpEnabled = BoolABDynamicVar(key: "freeBumpUpEnabled", defaultValue: false, abGroupType: .base)
    let pricedBumpUpEnabled = BoolABDynamicVar(key: "pricedBumpUpEnabled", defaultValue: false, abGroupType: .base)
    let newCarsMultiRequesterEnabled = BoolABDynamicVar(key: "newCarsMultiRequesterEnabled", defaultValue: false, abGroupType: .base)
    let inAppRatingIOS10 = BoolABDynamicVar(key: "20170711inAppRatingIOS10", defaultValue: false, abGroupType: .base)
    let userReviewsReportEnabled = BoolABDynamicVar(key: "20170823userReviewsReportEnabled", defaultValue: true, abGroupType: .base)
    let dynamicQuickAnswers = IntABDynamicVar(key: "20170816DynamicQuickAnswers", defaultValue: 0, abGroupType: .base)
    let appRatingDialogInactive = BoolABDynamicVar(key: "20170831AppRatingDialogInactive", defaultValue: false, abGroupType: .base)
    let locationDataSourceType = IntABDynamicVar(key: "20170830LocationDataSourceType", defaultValue: 0, abGroupType: .base)
    let defaultRadiusDistanceFeed = IntABDynamicVar(key: "20170922DefaultRadiusDistanceFeed", defaultValue: 0, abGroupType: .base)
    let searchAutocomplete = IntABDynamicVar(key: "20170914SearchAutocomplete", defaultValue: 0, abGroupType: .base)
    let realEstateEnabled = IntABDynamicVar(key: "20171228realEstateEnabled", defaultValue: 0, abGroupType: .base)
    let showPriceAfterSearchOrFilter = IntABDynamicVar(key: "20170928ShowPriceAfterSearchOrFilter", defaultValue: 0, abGroupType: .base)
    let requestsTimeOut = IntABDynamicVar(key: "20170929RequestTimeOut", defaultValue: 30, abGroupType: .base)
    let newBumpUpExplanation = IntABDynamicVar(key: "20171004NewBumpUpExplanation", defaultValue: 0, abGroupType: .base)
    let homeRelatedEnabled = IntABDynamicVar(key: "20171011HomeRelatedEnabled", defaultValue: 0, abGroupType: .base)
    let hideChatButtonOnFeaturedCells = IntABDynamicVar(key: "20171011ChatButtonOnFeaturedCells", defaultValue: 0, abGroupType: .base)
    let newItemPage = IntABDynamicVar(key: "20171027NewItemPage", defaultValue: 0, abGroupType: .base)
    let taxonomiesAndTaxonomyChildrenInFeed = IntABDynamicVar(key: "20171031TaxonomiesAndTaxonomyChildrenInFeed", defaultValue: 0, abGroupType: .base)
    let showPriceStepRealEstatePosting = IntABDynamicVar(key: "20171106RealEstatePostingOrder", defaultValue: 0, abGroupType: .base)
    let showClockInDirectAnswer = IntABDynamicVar(key: "20171031ShowClockInDirectAnswer", defaultValue: 0, abGroupType: .base)
    let bumpUpPriceDifferentiation = IntABDynamicVar(key: "20171114BumpUpPriceDifferentiation", defaultValue: 0, abGroupType: .base)
    let promoteBumpUpAfterSell = IntABDynamicVar(key: "20171127PromoteBumpUpAfterSell", defaultValue: 0, abGroupType: .base)
    let allowCallsForProfessionals = IntABDynamicVar(key: "20171228allowCallsForProfessionals", defaultValue: 0, abGroupType: .base)
    let moreInfoAFShOrDFP = IntABDynamicVar(key: "20171213MoreInfoAFShOrDFP", defaultValue: 0, abGroupType: .base)
    let showSecurityMeetingChatMessage = IntABDynamicVar(key: "20171219ShowSecurityMeetingChatMessage", defaultValue: 0, abGroupType: .base)
    let realEstateImprovements = IntABDynamicVar(key: "20180103RealEstateImprovements", defaultValue: 0, abGroupType: .base)
    let realEstatePromos = IntABDynamicVar(key: "20180108RealEstatePromos", defaultValue: 0, abGroupType: .base)
    let allowEmojisOnChat = IntABDynamicVar(key: "20180109AllowEmojisOnChat", defaultValue: 0, abGroupType: .base)
    let showAdsInFeedWithRatio = IntABDynamicVar(key: "20180111ShowAdsInFeedWithRatio", defaultValue: 0, abGroupType: .base)
    let removeCategoryWhenClosingPosting = IntABDynamicVar(key: "20180126RemoveCategoryWhenClosingPosting", defaultValue: 0, abGroupType: .base)
    let realEstateNewCopy = IntABDynamicVar(key: "20180126RealEstateNewCopy", defaultValue: 0, abGroupType: .realEstate)
    let dummyUsersInfoProfile = IntABDynamicVar(key: "20180130DummyUsersInfoProfile", defaultValue: 0, abGroupType: .retention)
    
    init() {
    }
    
    private var allVariables: [ABVariable] {
        var result = [ABVariable]()

        result.append(marketingPush)
        result.append(showNPSSurvey)
        result.append(surveyURL)
        result.append(surveyEnabled)
        result.append(freeBumpUpEnabled)
        result.append(pricedBumpUpEnabled)
        result.append(newCarsMultiRequesterEnabled)
        result.append(inAppRatingIOS10)
        result.append(userReviewsReportEnabled)
        result.append(dynamicQuickAnswers)
        result.append(appRatingDialogInactive)
        result.append(locationDataSourceType)
        result.append(defaultRadiusDistanceFeed)
        result.append(searchAutocomplete)
        result.append(realEstateEnabled)
        result.append(showPriceAfterSearchOrFilter)
        result.append(requestsTimeOut)
        result.append(newBumpUpExplanation)
        result.append(homeRelatedEnabled)
        result.append(hideChatButtonOnFeaturedCells)
        result.append(newItemPage)
        result.append(taxonomiesAndTaxonomyChildrenInFeed)
        result.append(showPriceStepRealEstatePosting)
        result.append(showClockInDirectAnswer)
        result.append(bumpUpPriceDifferentiation)
        result.append(promoteBumpUpAfterSell)
        result.append(allowCallsForProfessionals)
        result.append(moreInfoAFShOrDFP)
        result.append(showSecurityMeetingChatMessage)
        result.append(realEstateImprovements)
        result.append(realEstatePromos)
        result.append(allowEmojisOnChat)
        result.append(showAdsInFeedWithRatio)
        result.append(removeCategoryWhenClosingPosting)
        result.append(realEstateNewCopy)
        result.append(dummyUsersInfoProfile)
        
        return result
    }

    func registerVariables() {
        allVariables.forEach { $0.register() }
    }

    func variablesUpdated() {
        trackingData.value = allVariables.map { abVariable -> (String, ABGroupType) in
            return (abVariable.trackingData, abVariable.abGroupType)
        }
    }
}
