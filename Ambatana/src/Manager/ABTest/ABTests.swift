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
    func trackingData(variables: [ABTrackable]) -> [(String, ABGroup)]
}

final class LeamplumSyncer: LeamplumSyncerType {
    func sync(variables: [ABRegistrable]) {
        variables.forEach { $0.register() }
    }

    func trackingData(variables: [ABTrackable]) -> [(String, ABGroup)] {
        return mapTrackingData(variables)
    }

    private func mapTrackingData(_ array: [ABTrackable]) -> [(String, ABGroup)] { return array.map { $0.nameAndGroup } }
}

protocol ABGroupType {
    var group: ABGroup { get }
    var intVariables: [LeanplumABVariable<Int>] { get }
    var stringVariables: [LeanplumABVariable<String>] { get }
    var floatVariables: [LeanplumABVariable<Float>] { get }
    var boolVariables: [LeanplumABVariable<Bool>] { get }
}

class ABTests {
    private let syncer: LeamplumSyncerType
    let trackingData = Variable<[(String, ABGroup)]?>(nil)

    let legacy = LegacyABGroup.make()
    let realEstate = RealEstateABGroup.make()
    let verticals = VerticalsABGroup.make()
    let retention = RetentionABGroup.make()
    let money = MoneyABGroup.make()
    let chat = ChatABGroup.make()
    let core = CoreABGroup.make()
    let users = UsersABGroup.make()


    convenience init() {
        self.init(syncer: LeamplumSyncer())
    }

    init(syncer: LeamplumSyncerType) {
        self.syncer = syncer
    }

    private var intVariables: [LeanplumABVariable<Int>] {
        var result = [LeanplumABVariable<Int>]()

        result.append(contentsOf: legacy.intVariables)
        result.append(contentsOf: money.intVariables)
        result.append(contentsOf: retention.intVariables)
        result.append(contentsOf: realEstate.intVariables)
        result.append(contentsOf: verticals.intVariables)
        result.append(contentsOf: chat.intVariables)
        result.append(contentsOf: core.intVariables)
        result.append(contentsOf: users.intVariables)
        return result
    }

    private var boolVariables: [LeanplumABVariable<Bool>] {
        var result = [LeanplumABVariable<Bool>]()
        result.append(contentsOf: legacy.boolVariables)
        result.append(contentsOf: money.boolVariables)
        result.append(contentsOf: retention.boolVariables)
        result.append(contentsOf: realEstate.boolVariables)
        result.append(contentsOf: verticals.boolVariables)
        result.append(contentsOf: chat.boolVariables)
        result.append(contentsOf: core.boolVariables)
        result.append(contentsOf: users.boolVariables)
        return result
    }

    private var stringVariables: [LeanplumABVariable<String>] { return legacy.stringVariables }
    private var floatVariables: [LeanplumABVariable<Float>] { return [] }

    func registerVariables() {
        syncer.sync(variables: intVariables)
        syncer.sync(variables: boolVariables)
        syncer.sync(variables: floatVariables)
        syncer.sync(variables: stringVariables)
    }

    func variablesUpdated() {
        let uniquesInt = Array(Set<LeanplumABVariable<Int>>.init(intVariables))
        let uniquesFloat = Array(Set<LeanplumABVariable<Float>>.init(floatVariables))
        let uniquesBool = Array(Set<LeanplumABVariable<Bool>>.init(boolVariables))
        let uniquesString = Array(Set<LeanplumABVariable<String>>.init(stringVariables))

        var trackingData: [(String, ABGroup)] = syncer.trackingData(variables: uniquesString)
        trackingData.append(contentsOf: syncer.trackingData(variables: uniquesBool))
        trackingData.append(contentsOf: syncer.trackingData(variables: uniquesInt))
        trackingData.append(contentsOf: syncer.trackingData(variables: uniquesFloat))

        self.trackingData.value = trackingData
    }
}

extension ABTests {
    var advancedReputationSystem: LeanplumABVariable<Int> { return users.advancedReputationSystem }
}

extension ABTests {
    var discardedProducts: LeanplumABVariable<Int> { return core.discardedProducts }
    var newUserProfileView: LeanplumABVariable<Int> { return core.newUserProfileView }
    var searchImprovements: LeanplumABVariable<Int> { return core.searchImprovements }
    var servicesCategoryEnabled: LeanplumABVariable<Int> { return core.servicesCategoryEnabled }
    var machineLearningMVP: LeanplumABVariable<Int> { return core.machineLearningMVP }
    var addPriceTitleDistanceToListings: LeanplumABVariable<Int> { return core.addPriceTitleDistanceToListings }
    var relaxedSearch: LeanplumABVariable<Int> { return core.relaxedSearch }
}

extension ABTests {
    var showInactiveConversations: LeanplumABVariable<Bool> { return chat.showInactiveConversations }
    var showChatSafetyTips: LeanplumABVariable<Bool> { return chat.showChatSafetyTips }
    var userIsTyping: LeanplumABVariable<Int> { return chat.userIsTyping }
    var markAllConversationsAsRead: LeanplumABVariable<Bool> { return chat.markAllConversationsAsRead }
}

extension ABTests {
    var increaseMinPriceBumps: LeanplumABVariable<Int> { return money.increaseMinPriceBumps }
    var noAdsInFeedForNewUsers: LeanplumABVariable<Int> { return money.noAdsInFeedForNewUsers }
    var showBumpUpBannerOnNotValidatedListings: LeanplumABVariable<Int> { return money.showBumpUpBannerOnNotValidatedListings }
    var copyForChatNowInTurkey: LeanplumABVariable<Int> { return money.copyForChatNowInTurkey }
    var turkeyBumpPriceVATAdaptation: LeanplumABVariable<Int> { return money.turkeyBumpPriceVATAdaptation }
    var promoteBumpInEdit: LeanplumABVariable<Int> { return money.promoteBumpInEdit }
    var showProTagUserProfile: LeanplumABVariable<Bool> { return money.showProTagUserProfile }
    var feedAdsProviderForUS: LeanplumABVariable<Int> { return money.feedAdsProviderForUS }
    var copyForChatNowInEnglish: LeanplumABVariable<Int> { return money.copyForChatNowInEnglish }
    var feedAdsProviderForTR: LeanplumABVariable<Int> { return money.feedAdsProviderForTR }
    var bumpUpBoost: LeanplumABVariable<Int> { return money.bumpUpBoost }
}

extension ABTests {
    var dummyUsersInfoProfile: LeanplumABVariable<Int> { return retention.dummyUsersInfoProfile }
    var onboardingIncentivizePosting: LeanplumABVariable<Int> { return retention.onboardingIncentivizePosting }
}

extension ABTests {
    var realEstateNewCopy: LeanplumABVariable<Int> { return realEstate.realEstateNewCopy }
    var increaseNumberOfPictures: LeanplumABVariable<Int> { return realEstate.increaseNumberOfPictures }
    var realEstateTutorial: LeanplumABVariable<Int>{ return realEstate.realEstateTutorial }
    var summaryAsFirstStep: LeanplumABVariable<Int> { return realEstate.summaryAsFirstStep }
}

extension ABTests {
    var searchCarsIntoNewBackend: LeanplumABVariable<Int> { return verticals.searchCarsIntoNewBackend }
}

extension ABTests {
    var marketingPush: LeanplumABVariable<Int> { return legacy.marketingPush }
    // Not an A/B just flags and variables for surveys
    var showNPSSurvey: LeanplumABVariable<Bool> { return legacy.showNPSSurvey }
    var surveyURL: LeanplumABVariable<String> { return legacy.surveyURL }
    var surveyEnabled: LeanplumABVariable<Bool> { return legacy.surveyEnabled }
    var freeBumpUpEnabled: LeanplumABVariable<Bool> { return legacy.freeBumpUpEnabled }
    var pricedBumpUpEnabled: LeanplumABVariable<Bool> { return legacy.pricedBumpUpEnabled }
    var newCarsMultiRequesterEnabled: LeanplumABVariable<Bool> { return legacy.newCarsMultiRequesterEnabled }
    var inAppRatingIOS10: LeanplumABVariable<Bool> { return legacy.inAppRatingIOS10 }
    var userReviewsReportEnabled: LeanplumABVariable<Bool> { return legacy.userReviewsReportEnabled }
    var dynamicQuickAnswers: LeanplumABVariable<Int> { return legacy.dynamicQuickAnswers }
    var appRatingDialogInactive: LeanplumABVariable<Bool> { return legacy.appRatingDialogInactive }
    var locationDataSourceType: LeanplumABVariable<Int> { return legacy.locationDataSourceType }
    var searchAutocomplete: LeanplumABVariable<Int> { return legacy.searchAutocomplete }
    var realEstateEnabled: LeanplumABVariable<Int> { return legacy.realEstateEnabled }
    var requestsTimeOut: LeanplumABVariable<Int> { return legacy.requestsTimeOut }
    var deckItemPage: LeanplumABVariable<Int> { return legacy.newItemPage }
    var taxonomiesAndTaxonomyChildrenInFeed: LeanplumABVariable<Int> { return legacy.taxonomiesAndTaxonomyChildrenInFeed }
    var showClockInDirectAnswer: LeanplumABVariable<Int> { return legacy.showClockInDirectAnswer }
    var allowCallsForProfessionals: LeanplumABVariable<Int> { return legacy.allowCallsForProfessionals }
    var mostSearchedDemandedItems: LeanplumABVariable<Int> { return legacy.mostSearchedDemandedItems }
    var showAdsInFeedWithRatio: LeanplumABVariable<Int> { return legacy.showAdsInFeedWithRatio }
    var removeCategoryWhenClosingPosting: LeanplumABVariable<Int> { return legacy.removeCategoryWhenClosingPosting }
}
