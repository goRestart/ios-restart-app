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
    let marketingPush = IntABDynamicVar(key: "marketingPush", defaultValue: 0, abGroupType: .legacyABTests)

    // Not an A/B just flags and variables for surveys
    let showNPSSurvey = BoolABDynamicVar(key: "showNPSSurvey", defaultValue: false, abGroupType: .legacyABTests)
    let surveyURL = StringABDynamicVar(key: "surveyURL", defaultValue: "", abGroupType: .legacyABTests)
    let surveyEnabled = BoolABDynamicVar(key: "surveyEnabled", defaultValue: false, abGroupType: .legacyABTests)

    let freeBumpUpEnabled = BoolABDynamicVar(key: "freeBumpUpEnabled", defaultValue: false, abGroupType: .legacyABTests)
    let pricedBumpUpEnabled = BoolABDynamicVar(key: "pricedBumpUpEnabled", defaultValue: false, abGroupType: .legacyABTests)
    let newCarsMultiRequesterEnabled = BoolABDynamicVar(key: "newCarsMultiRequesterEnabled", defaultValue: false, abGroupType: .legacyABTests)
    let inAppRatingIOS10 = BoolABDynamicVar(key: "20170711inAppRatingIOS10", defaultValue: false, abGroupType: .legacyABTests)
    let userReviewsReportEnabled = BoolABDynamicVar(key: "20170823userReviewsReportEnabled", defaultValue: true, abGroupType: .legacyABTests)
    let dynamicQuickAnswers = IntABDynamicVar(key: "20170816DynamicQuickAnswers", defaultValue: 0, abGroupType: .legacyABTests)
    let appRatingDialogInactive = BoolABDynamicVar(key: "20170831AppRatingDialogInactive", defaultValue: false, abGroupType: .legacyABTests)
    let locationDataSourceType = IntABDynamicVar(key: "20170830LocationDataSourceType", defaultValue: 0, abGroupType: .legacyABTests)
    let searchAutocomplete = IntABDynamicVar(key: "20170914SearchAutocomplete", defaultValue: 0, abGroupType: .legacyABTests)
    let realEstateEnabled = IntABDynamicVar(key: "20171228realEstateEnabled", defaultValue: 0, abGroupType: .legacyABTests)
    let requestsTimeOut = IntABDynamicVar(key: "20170929RequestTimeOut", defaultValue: 30, abGroupType: .legacyABTests)
    let homeRelatedEnabled = IntABDynamicVar(key: "20171011HomeRelatedEnabled", defaultValue: 0, abGroupType: .legacyABTests)
    let newItemPage = IntABDynamicVar(key: "20171027NewItemPage", defaultValue: 0, abGroupType: .legacyABTests)
    let taxonomiesAndTaxonomyChildrenInFeed = IntABDynamicVar(key: "20171031TaxonomiesAndTaxonomyChildrenInFeed", defaultValue: 0, abGroupType: .legacyABTests)
    let showPriceStepRealEstatePosting = IntABDynamicVar(key: "20171106RealEstatePostingOrder", defaultValue: 0, abGroupType: .legacyABTests)
    let showClockInDirectAnswer = IntABDynamicVar(key: "20171031ShowClockInDirectAnswer", defaultValue: 0, abGroupType: .legacyABTests)
    let allowCallsForProfessionals = IntABDynamicVar(key: "20171228allowCallsForProfessionals", defaultValue: 0, abGroupType: .legacyABTests)
    let realEstateImprovements = IntABDynamicVar(key: "20180103RealEstateImprovements", defaultValue: 0, abGroupType: .legacyABTests)
    let mostSearchedDemandedItems = IntABDynamicVar(key: "20180104MostSearchedDemandedItems", defaultValue: 0, abGroupType: .retention)
    let realEstatePromos = IntABDynamicVar(key: "20180108RealEstatePromos", defaultValue: 0, abGroupType: .legacyABTests)
    let showAdsInFeedWithRatio = IntABDynamicVar(key: "20180111ShowAdsInFeedWithRatio", defaultValue: 0, abGroupType: .legacyABTests)
    let removeCategoryWhenClosingPosting = IntABDynamicVar(key: "20180126RemoveCategoryWhenClosingPosting", defaultValue: 0, abGroupType: .legacyABTests)
    let realEstateNewCopy = IntABDynamicVar(key: "20180126RealEstateNewCopy", defaultValue: 0, abGroupType: .realEstate)
    let dummyUsersInfoProfile = IntABDynamicVar(key: "20180130DummyUsersInfoProfile", defaultValue: 0, abGroupType: .retention)
    let showInactiveConversations = BoolABDynamicVar(key: "20180206ShowInactiveConversations", defaultValue: false, abGroupType: .chat)
    let mainFeedAspectRatio = IntABDynamicVar(key: "20180208MainFeedAspectRatio", defaultValue: 0, abGroupType: .core)
    let increaseMinPriceBumps  = IntABDynamicVar(key: "20180208IncreaseMinPriceBumps", defaultValue: 0, abGroupType: .money)
    let showSecurityMeetingChatMessage = IntABDynamicVar(key: "20180207ShowSecurityMeetingChatMessage", defaultValue: 0, abGroupType: .chat)
    let noAdsInFeedForNewUsers = IntABDynamicVar(key: "20180212NoAdsInFeedForNewUsers", defaultValue: 0, abGroupType: .money)
    let emojiSizeIncrement = IntABDynamicVar(key: "20180212EmojiSizeIncrement", defaultValue: 0, abGroupType: .chat)
    let showBumpUpBannerOnNotValidatedListings = IntABDynamicVar(key: "20180214showBumpUpBannerOnNotValidatedListings", defaultValue: 0, abGroupType: .money)
    let newUserProfileView = IntABDynamicVar(key: "20180221NewUserProfileView", defaultValue: 0, abGroupType: .core)
    let turkeyBumpPriceVATAdaptation = IntABDynamicVar(key: "20180221TurkeyBumpPriceVATAdaptation", defaultValue: 0, abGroupType: .money)
    let searchImprovements = IntABDynamicVar(key: "20180313SearchImprovements", defaultValue: 0, abGroupType: .core)
    let showChatSafetyTips = BoolABDynamicVar(key: "20180226ShowChatSafetyTips", defaultValue: false, abGroupType: .chat)
    let onboardingIncentivizePosting = IntABDynamicVar(key: "20180215OnboardingIncentivizePosting", defaultValue: 0, abGroupType: .retention)
    let discardedProducts = IntABDynamicVar(key: "20180219DiscardedProducts", defaultValue: 0, abGroupType: .core)
    let promoteBumpInEdit = IntABDynamicVar(key: "20180227promoteBumpInEdit", defaultValue: 0, abGroupType: .money)
    let userIsTyping = IntABDynamicVar(key: "20180305UserIsTyping", defaultValue: 0, abGroupType: .chat)
    let servicesCategoryEnabled = IntABDynamicVar(key: "20180305ServicesCategoryEnabled", defaultValue: 0, abGroupType: .products)
    let copyForChatNowInTurkey = IntABDynamicVar(key: "20180312CopyForChatNowInTurkey", defaultValue: 0, abGroupType: .money)
    

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
        result.append(searchAutocomplete)
        result.append(realEstateEnabled)
        result.append(requestsTimeOut)
        result.append(homeRelatedEnabled)
        result.append(newItemPage)
        result.append(taxonomiesAndTaxonomyChildrenInFeed)
        result.append(showPriceStepRealEstatePosting)
        result.append(showClockInDirectAnswer)
        result.append(allowCallsForProfessionals)
        result.append(realEstateImprovements)
        result.append(mostSearchedDemandedItems)
        result.append(realEstatePromos)
        result.append(showAdsInFeedWithRatio)
        result.append(removeCategoryWhenClosingPosting)
        result.append(realEstateNewCopy)
        result.append(dummyUsersInfoProfile)
        result.append(showInactiveConversations)
        result.append(mainFeedAspectRatio)
        result.append(increaseMinPriceBumps)
        result.append(showSecurityMeetingChatMessage)
        result.append(noAdsInFeedForNewUsers)
        result.append(emojiSizeIncrement)
        result.append(showBumpUpBannerOnNotValidatedListings)
        result.append(newUserProfileView)
        result.append(turkeyBumpPriceVATAdaptation)
        result.append(searchImprovements)
        result.append(showChatSafetyTips)
        result.append(onboardingIncentivizePosting)
        result.append(discardedProducts)
        result.append(promoteBumpInEdit)
        result.append(userIsTyping)
        result.append(servicesCategoryEnabled)
        result.append(copyForChatNowInTurkey)
        
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
