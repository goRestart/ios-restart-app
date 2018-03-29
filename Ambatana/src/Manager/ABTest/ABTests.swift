//
//  ABTests.swift
//  LetGo
//
//  Created by Dídac on 12/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import RxSwift

protocol LeamplumSyncerType {
    func sync(variables: [ABRegistrable])
    func trackingData(variables: [ABTrackable]) -> [(String, ABGroupType)]
}

final class LeamplumSyncer: LeamplumSyncerType {
    func sync(variables: [ABRegistrable]) {
        variables.forEach { $0.register() }
    }

    func trackingData(variables: [ABTrackable]) -> [(String, ABGroupType)] {
        return mapTrackingData(variables)
    }

    private func mapTrackingData(_ array: [ABTrackable]) -> [(String, ABGroupType)] { return array.map { $0.tuple } }

}

class ABTests {
    private let syncer: LeamplumSyncerType
    let trackingData = Variable<[(String, ABGroupType)]?>(nil)

    // Not used in code, Just a helper for marketing team
    let marketingPush = LeanplumABVariable<Int>.makeInt(key: "marketingPush", defaultValue: 0, groupType: ABGroupType.legacyABTests)

    // Not an A/B just flags and variables for surveys
    let showNPSSurvey = LeanplumABVariable<Bool>.makeBool(key: "showNPSSurvey", defaultValue: false, groupType: .legacyABTests)
    let surveyURL = LeanplumABVariable<String>.makeString(key: "surveyURL", defaultValue: "", groupType: .legacyABTests)
    let surveyEnabled = LeanplumABVariable<Bool>.makeBool(key: "surveyEnabled", defaultValue: false, groupType: .legacyABTests)

    let freeBumpUpEnabled = LeanplumABVariable<Bool>.makeBool(key: "freeBumpUpEnabled", defaultValue: false, groupType: .legacyABTests)
    let pricedBumpUpEnabled = LeanplumABVariable<Bool>.makeBool(key: "pricedBumpUpEnabled", defaultValue: false, groupType: .legacyABTests)
    let newCarsMultiRequesterEnabled = LeanplumABVariable<Bool>.makeBool(key: "newCarsMultiRequesterEnabled", defaultValue: false,  groupType: ABGroupType.legacyABTests)
    let inAppRatingIOS10 = LeanplumABVariable<Bool>.makeBool(key: "20170711inAppRatingIOS10", defaultValue: false, groupType: .legacyABTests)
    let userReviewsReportEnabled = LeanplumABVariable<Bool>.makeBool(key: "20170823userReviewsReportEnabled", defaultValue: true, groupType: ABGroupType.legacyABTests)
    let dynamicQuickAnswers = LeanplumABVariable<Int>.makeInt(key: "20170816DynamicQuickAnswers", defaultValue: 0, groupType: .legacyABTests)
    let appRatingDialogInactive = LeanplumABVariable<Bool>.makeBool(key: "20170831AppRatingDialogInactive", defaultValue: false, groupType: ABGroupType.legacyABTests)
    let locationDataSourceType = LeanplumABVariable<Int>.makeInt(key: "20170830LocationDataSourceType", defaultValue: 0, groupType: .legacyABTests)
    let searchAutocomplete = LeanplumABVariable<Int>.makeInt(key: "20170914SearchAutocomplete", defaultValue: 0, groupType: .legacyABTests)
    let realEstateEnabled = LeanplumABVariable<Int>.makeInt(key: "20171228realEstateEnabled", defaultValue: 0, groupType: .legacyABTests)
    let requestsTimeOut = LeanplumABVariable<Int>.makeInt(key: "20170929RequestTimeOut", defaultValue: 30, groupType: .legacyABTests)
    let newItemPage = LeanplumABVariable<Int>.makeInt(key: "20171027NewItemPage", defaultValue: 0, groupType: .legacyABTests)
    let taxonomiesAndTaxonomyChildrenInFeed = LeanplumABVariable<Int>.makeInt(key: "20171031TaxonomiesAndTaxonomyChildrenInFeed", defaultValue: 0, groupType: ABGroupType.legacyABTests)
    let showClockInDirectAnswer = LeanplumABVariable<Int>.makeInt(key: "20171031ShowClockInDirectAnswer", defaultValue: 0, groupType: .legacyABTests)
    let allowCallsForProfessionals = LeanplumABVariable<Int>.makeInt(key: "20171228allowCallsForProfessionals", defaultValue: 0, groupType: ABGroupType.legacyABTests)
    let mostSearchedDemandedItems = LeanplumABVariable<Int>.makeInt(key: "20180104MostSearchedDemandedItems", defaultValue: 0, groupType: .retention)
    let showAdsInFeedWithRatio = LeanplumABVariable<Int>.makeInt(key: "20180111ShowAdsInFeedWithRatio", defaultValue: 0, groupType: .legacyABTests)
    let removeCategoryWhenClosingPosting = LeanplumABVariable<Int>.makeInt(key: "20180126RemoveCategoryWhenClosingPosting", defaultValue: 0, groupType: .legacyABTests)
    let realEstateNewCopy = LeanplumABVariable<Int>.makeInt(key: "20180126RealEstateNewCopy", defaultValue: 0, groupType: .realEstate)
    let dummyUsersInfoProfile = LeanplumABVariable<Int>.makeInt(key: "20180130DummyUsersInfoProfile", defaultValue: 0, groupType: .retention)
    let showInactiveConversations = LeanplumABVariable<Bool>.makeBool(key: "20180206ShowInactiveConversations", defaultValue: false, groupType: .chat)
    let increaseMinPriceBumps  = LeanplumABVariable<Int>.makeInt(key: "20180208IncreaseMinPriceBumps", defaultValue: 0, groupType: .money)
    let showSecurityMeetingChatMessage = LeanplumABVariable<Int>.makeInt(key: "20180207ShowSecurityMeetingChatMessage", defaultValue: 0, groupType: .chat)
    let noAdsInFeedForNewUsers = LeanplumABVariable<Int>.makeInt(key: "20180212NoAdsInFeedForNewUsers", defaultValue: 0, groupType: .money)
    let emojiSizeIncrement = LeanplumABVariable<Int>.makeInt(key: "20180212EmojiSizeIncrement", defaultValue: 0, groupType: .chat)
    let showBumpUpBannerOnNotValidatedListings = LeanplumABVariable<Int>.makeInt(key: "20180214showBumpUpBannerOnNotValidatedListings", defaultValue: 0, groupType: .money)
    let newUserProfileView = LeanplumABVariable<Int>.makeInt(key: "20180221NewUserProfileView", defaultValue: 0, groupType: .core)
    let turkeyBumpPriceVATAdaptation = LeanplumABVariable<Int>.makeInt(key: "20180221TurkeyBumpPriceVATAdaptation", defaultValue: 0, groupType: .money)
    let searchImprovements = LeanplumABVariable<Int>.makeInt(key: "20180313SearchImprovements", defaultValue: 0, groupType: .core)
    let showChatSafetyTips = LeanplumABVariable<Bool>.makeBool(key: "20180226ShowChatSafetyTips", defaultValue: false, groupType: .chat)
    let onboardingIncentivizePosting = LeanplumABVariable<Int>.makeInt(key: "20180215OnboardingIncentivizePosting", defaultValue: 0, groupType: .retention)
    let discardedProducts = LeanplumABVariable<Int>.makeInt(key: "20180219DiscardedProducts", defaultValue: 0, groupType: .core)
    let promoteBumpInEdit = LeanplumABVariable<Int>.makeInt(key: "20180227promoteBumpInEdit", defaultValue: 0, groupType: .money)
    let userIsTyping = LeanplumABVariable<Int>.makeInt(key: "20180305UserIsTyping", defaultValue: 0, groupType: .chat)
    let servicesCategoryEnabled = LeanplumABVariable<Int>.makeInt(key: "20180305ServicesCategoryEnabled", defaultValue: 0, groupType: .products)
    let copyForChatNowInTurkey = LeanplumABVariable<Int>.makeInt(key: "20180312CopyForChatNowInTurkey", defaultValue: 0, groupType: .money)
    let increaseNumberOfPictures = LeanplumABVariable<Int>.makeInt(key: "20180314IncreaseNumberOfPictures", defaultValue: 0, groupType: .realEstate)
    let machineLearningMVP = LeanplumABVariable<Int>.makeInt(key: "20180312MachineLearningMVP", defaultValue: 0, groupType: .core)
    let addPriceTitleDistanceToListings = LeanplumABVariable<Int>.makeInt(key: "20180319AddPriceTitleDistanceToListings", defaultValue: 0, groupType: .core)
    let markAllConversationsAsRead = LeanplumABVariable<Bool>.makeBool(key: "20180321MarkAllConversationsAsRead", defaultValue: false, groupType: .chat)
    let showProTagUserProfile = LeanplumABVariable<Bool>.makeBool(key: "20180319ShowProTagUserProfile", defaultValue: false, groupType: .money)
    let realEstateTutorial = LeanplumABVariable<Int>.makeInt(key: "20180309RealEstateTutorial", defaultValue: 0, groupType: .realEstate)
    let summaryAsFirstStep = LeanplumABVariable<Int>.makeInt(key: "20180320SummaryAsFirstStep", defaultValue: 0, groupType: .realEstate)
    let relaxedSearch = LeanplumABVariable<Int>.makeInt(key: "20180319RelaxedSearch", defaultValue: 0, groupType: .core)

    convenience init() {
        self.init(syncer: LeamplumSyncer())
    }

    init(syncer: LeamplumSyncerType) {
        self.syncer = syncer
    }

    private var intVariables: [LeanplumABVariable<Int>] {
        var result = [LeanplumABVariable<Int>]()

        result.append(marketingPush)
        result.append(dynamicQuickAnswers)
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
        result.append(increaseMinPriceBumps)
        result.append(showSecurityMeetingChatMessage)
        result.append(noAdsInFeedForNewUsers)
        result.append(emojiSizeIncrement)
        result.append(showBumpUpBannerOnNotValidatedListings)
        result.append(newUserProfileView)
        result.append(turkeyBumpPriceVATAdaptation)
        result.append(searchImprovements)
        result.append(onboardingIncentivizePosting)
        result.append(discardedProducts)
        result.append(promoteBumpInEdit)
        result.append(userIsTyping)
        result.append(servicesCategoryEnabled)
        result.append(copyForChatNowInTurkey)
        result.append(increaseNumberOfPictures)
        result.append(addPriceTitleDistanceToListings)
        result.append(realEstateTutorial)
        result.append(summaryAsFirstStep)
        result.append(relaxedSearch)
        result.append(machineLearningMVP)
        return result
    }

    private var boolVariables: [LeanplumABVariable<Bool>] {
        var result = [LeanplumABVariable<Bool>]()
        result.append(showNPSSurvey)
        result.append(surveyEnabled)
        result.append(freeBumpUpEnabled)
        result.append(pricedBumpUpEnabled)
        result.append(newCarsMultiRequesterEnabled)
        result.append(inAppRatingIOS10)
        result.append(userReviewsReportEnabled)
        result.append(appRatingDialogInactive)
        result.append(showInactiveConversations)
        result.append(showChatSafetyTips)
        result.append(markAllConversationsAsRead)
        result.append(showProTagUserProfile)
        result.append(showProTagUserProfile)
        return result
    }

    private var stringVariables: [LeanplumABVariable<String>] { return [surveyURL] }
    private var floatVariables: [LeanplumABVariable<Float>] { return [] }

    func registerVariables() {
        syncer.sync(variables: intVariables)
        syncer.sync(variables: boolVariables)
        syncer.sync(variables: floatVariables)
        syncer.sync(variables: stringVariables)
    }

    func variablesUpdated() {
        let uniquesInt = Array.init(Set<LeanplumABVariable<Int>>.init(intVariables))
        let uniquesFloat = Array.init(Set<LeanplumABVariable<Float>>.init(floatVariables))
        let uniquesBool = Array.init(Set<LeanplumABVariable<Bool>>.init(boolVariables))
        let uniquesString = Array.init(Set<LeanplumABVariable<String>>.init(stringVariables))

        var trackingData: [(String, ABGroupType)] = syncer.trackingData(variables: uniquesInt)
        trackingData.append(contentsOf: syncer.trackingData(variables: uniquesBool))
        trackingData.append(contentsOf: syncer.trackingData(variables: uniquesInt))
        trackingData.append(contentsOf: syncer.trackingData(variables: uniquesFloat))

        self.trackingData.value = trackingData
    }
}
