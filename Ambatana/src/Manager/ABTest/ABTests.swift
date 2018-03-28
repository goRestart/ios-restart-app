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
    let newItemPage = IntABDynamicVar(key: "20171027NewItemPage", defaultValue: 0, abGroupType: .legacyABTests)
    let taxonomiesAndTaxonomyChildrenInFeed = IntABDynamicVar(key: "20171031TaxonomiesAndTaxonomyChildrenInFeed", defaultValue: 0, abGroupType: .legacyABTests)
    let showClockInDirectAnswer = IntABDynamicVar(key: "20171031ShowClockInDirectAnswer", defaultValue: 0, abGroupType: .legacyABTests)
    let allowCallsForProfessionals = IntABDynamicVar(key: "20171228allowCallsForProfessionals", defaultValue: 0, abGroupType: .legacyABTests)
    let mostSearchedDemandedItems = IntABDynamicVar(key: "20180104MostSearchedDemandedItems", defaultValue: 0, abGroupType: .retention)
    let showAdsInFeedWithRatio = IntABDynamicVar(key: "20180111ShowAdsInFeedWithRatio", defaultValue: 0, abGroupType: .legacyABTests)
    let removeCategoryWhenClosingPosting = IntABDynamicVar(key: "20180126RemoveCategoryWhenClosingPosting", defaultValue: 0, abGroupType: .legacyABTests)
    let realEstateNewCopy = IntABDynamicVar(key: "20180126RealEstateNewCopy", defaultValue: 0, abGroupType: .realEstate)
    let dummyUsersInfoProfile = IntABDynamicVar(key: "20180130DummyUsersInfoProfile", defaultValue: 0, abGroupType: .retention)
    let showInactiveConversations = BoolABDynamicVar(key: "20180206ShowInactiveConversations", defaultValue: false, abGroupType: .chat)
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
    let increaseNumberOfPictures = IntABDynamicVar(key: "20180314IncreaseNumberOfPictures", defaultValue: 0, abGroupType: .realEstate)
    let machineLearningMVP = IntABDynamicVar(key: "20180312MachineLearningMVP", defaultValue: 0, abGroupType: .core)
    let chatNorris = IntABDynamicVar(key: "20180319ChatNorris", defaultValue: 0, abGroupType: .chat)
    let addPriceTitleDistanceToListings = IntABDynamicVar(key: "20180319AddPriceTitleDistanceToListings", defaultValue: 0, abGroupType: .core)
    let markAllConversationsAsRead = BoolABDynamicVar(key: "20180321MarkAllConversationsAsRead", defaultValue: false, abGroupType: .chat)
    let showProTagUserProfile = BoolABDynamicVar(key: "20180319ShowProTagUserProfile", defaultValue: false, abGroupType: .money)
    let realEstateTutorial = IntABDynamicVar(key: "20180309RealEstateTutorial", defaultValue: 0, abGroupType: .realEstate)
    let summaryAsFirstStep = IntABDynamicVar(key: "20180320SummaryAsFirstStep", defaultValue: 0, abGroupType: .realEstate)
    let relaxedSearch = IntABDynamicVar(key: "20180319RelaxedSearch", defaultValue: 0, abGroupType: .core)

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
        result.append(newItemPage)
        result.append(taxonomiesAndTaxonomyChildrenInFeed)
        result.append(showClockInDirectAnswer)
        result.append(allowCallsForProfessionals)
        result.append(mostSearchedDemandedItems)
        result.append(showAdsInFeedWithRatio)
        result.append(removeCategoryWhenClosingPosting)
        result.append(realEstateNewCopy)
        result.append(dummyUsersInfoProfile)
        result.append(showInactiveConversations)
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
        result.append(increaseNumberOfPictures)
        result.append(chatNorris)
        result.append(addPriceTitleDistanceToListings)
        result.append(markAllConversationsAsRead)
        result.append(showProTagUserProfile)
        result.append(realEstateTutorial)
        result.append(summaryAsFirstStep)
        result.append(relaxedSearch)
        result.append(machineLearningMVP)
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
