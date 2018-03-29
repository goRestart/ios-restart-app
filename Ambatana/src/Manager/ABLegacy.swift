//
//  ABLegacy.swift
//  LetGo
//
//  Created by Facundo Menzella on 29/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

struct LegacyGroup: ABGroupType {
    private struct Keys {
        static let marketingPush = "marketingPush"
        static let showNPSSurvey = "showNPSSurvey"
        static let surveyURL = "surveyURL"
        static let surveyEnabled = "surveyEnabled"
        static let freeBumpUpEnabled = "freeBumpUpEnabled"
        static let pricedBumpUpEnabled = "pricedBumpUpEnabled"
        static let carsMultiReqEnabled = "newCarsMultiRequesterEnabled"
        static let inAppRatingIOS10 = "20170711inAppRatingIOS10"
        static let userReviewsReportEnabled = "20170823userReviewsReportEnabled"
        static let dynamicQuickAnswers = "20170816DynamicQuickAnswers"
        static let appRatingDialogInactive = "20170831AppRatingDialogInactive"
        static let locationDataSourceType = "20170830LocationDataSourceType"
        static let searchAutocomplete = "20170914SearchAutocomplete"
        static let realEstateEnabled = "20171228realEstateEnabled"
        static let requestTimeOut = "20170929RequestTimeOut"
        static let newItemPage = "20171027NewItemPage"
        static let taxonomiesAndTaxonomyChildrenInFeed = "20171031TaxonomiesAndTaxonomyChildrenInFeed"
        static let showClockInDirectAnswer = "20171031ShowClockInDirectAnswer"
        static let allowCallsForProfessionals = "20171228allowCallsForProfessionals"
        static let mostSearchedDemandedItems = "20180104MostSearchedDemandedItems"
        static let showAdsInFeedWithRatio = "20180111ShowAdsInFeedWithRatio"
        static let removeCategoryWhenClosingPosting = "20180126RemoveCategoryWhenClosingPosting"
    }


    let group: ABGroup = .legacyABTests
    var intVariables: [LeanplumABVariable<Int>] = []
    var stringVariables: [LeanplumABVariable<String>] = []
    var floatVariables: [LeanplumABVariable<Float>] = []
    var boolVariables: [LeanplumABVariable<Bool>] = []

    init(marketingPush: LeanplumABVariable<Int>,
         showNPSSurvey: LeanplumABVariable<Bool>,
         surveyURL: LeanplumABVariable<String>,
         surveyEnabled: LeanplumABVariable<Bool>,
         freeBumpUpEnabled: LeanplumABVariable<Bool>,
         pricedBumpUpEnabled: LeanplumABVariable<Bool>,
         newCarsMultiRequesterEnabled: LeanplumABVariable<Bool>,
         inAppRatingIOS10: LeanplumABVariable<Bool>,
         userReviewsReportEnabled: LeanplumABVariable<Bool>,
         dynamicQuickAnswers: LeanplumABVariable<Int>,
         appRatingDialogInactive: LeanplumABVariable<Bool>,
         locationDataSourceType: LeanplumABVariable<Int>,
         searchAutocomplete: LeanplumABVariable<Int>,
         realEstateEnabled: LeanplumABVariable<Int>,
         requestsTimeOut: LeanplumABVariable<Int>,
         newItemPage: LeanplumABVariable<Int>,
         taxonomiesAndTaxonomyChildrenInFeed: LeanplumABVariable<Int>,
         showClockInDirectAnswer: LeanplumABVariable<Int>,
         allowCallsForProfessionals: LeanplumABVariable<Int>,
         mostSearchedDemandedItems: LeanplumABVariable<Int>,
         showAdsInFeedWithRatio: LeanplumABVariable<Int>,
         removeCategoryWhenClosingPosting: LeanplumABVariable<Int>) {
        intVariables.append(contentsOf: [marketingPush, dynamicQuickAnswers, locationDataSourceType, searchAutocomplete,
                                        realEstateEnabled, requestsTimeOut, newItemPage, taxonomiesAndTaxonomyChildrenInFeed,
                                        showClockInDirectAnswer, allowCallsForProfessionals, mostSearchedDemandedItems,
                                        showAdsInFeedWithRatio, removeCategoryWhenClosingPosting])
        boolVariables.append(contentsOf: [showNPSSurvey, surveyEnabled, freeBumpUpEnabled,
                                          pricedBumpUpEnabled, newCarsMultiRequesterEnabled, inAppRatingIOS10,
                                          userReviewsReportEnabled, appRatingDialogInactive])
        stringVariables.append(surveyURL)

    }

    static func make() -> LegacyGroup {
        return LegacyGroup(marketingPush: .makeInt(key: Keys.marketingPush, defaultValue: 0, groupType: .legacyABTests),
                           showNPSSurvey: .makeBool(key: Keys.showNPSSurvey, defaultValue: false, groupType: .legacyABTests),
                           surveyURL: .makeString(key: Keys.surveyURL, defaultValue: "", groupType: .legacyABTests),
                           surveyEnabled: .makeBool(key: Keys.surveyEnabled, defaultValue: false, groupType: .legacyABTests),
                           freeBumpUpEnabled: .makeBool(key: Keys.freeBumpUpEnabled, defaultValue: false, groupType: .legacyABTests),
                           pricedBumpUpEnabled: .makeBool(key: Keys.pricedBumpUpEnabled, defaultValue: false, groupType: .legacyABTests),
                           newCarsMultiRequesterEnabled: .makeBool(key: Keys.carsMultiReqEnabled, defaultValue: false,  groupType: .legacyABTests),
                           inAppRatingIOS10: .makeBool(key: Keys.inAppRatingIOS10, defaultValue: false, groupType: .legacyABTests),
                           userReviewsReportEnabled: .makeBool(key: Keys.userReviewsReportEnabled, defaultValue: true, groupType: .legacyABTests),
                           dynamicQuickAnswers: .makeInt(key: Keys.dynamicQuickAnswers, defaultValue: 0, groupType: .legacyABTests),
                           appRatingDialogInactive: .makeBool(key: Keys.appRatingDialogInactive, defaultValue: false, groupType: .legacyABTests),
                           locationDataSourceType: .makeInt(key: Keys.locationDataSourceType, defaultValue: 0, groupType: .legacyABTests),
                           searchAutocomplete: .makeInt(key: Keys.searchAutocomplete, defaultValue: 0, groupType: .legacyABTests),
                           realEstateEnabled: .makeInt(key: Keys.realEstateEnabled, defaultValue: 0, groupType: .legacyABTests),
                           requestsTimeOut: .makeInt(key: Keys.requestTimeOut, defaultValue: 30, groupType: .legacyABTests),
                           newItemPage: .makeInt(key: Keys.newItemPage, defaultValue: 0, groupType: .legacyABTests),
                           taxonomiesAndTaxonomyChildrenInFeed: .makeInt(key: Keys.taxonomiesAndTaxonomyChildrenInFeed, defaultValue: 0, groupType: .legacyABTests),
                           showClockInDirectAnswer: .makeInt(key: Keys.showClockInDirectAnswer, defaultValue: 0, groupType: .legacyABTests),
                           allowCallsForProfessionals:  .makeInt(key: Keys.allowCallsForProfessionals, defaultValue: 0, groupType: .legacyABTests),
                           mostSearchedDemandedItems: .makeInt(key: Keys.mostSearchedDemandedItems, defaultValue: 0, groupType: .retention), showAdsInFeedWithRatio: .makeInt(key: Keys.showAdsInFeedWithRatio, defaultValue: 0, groupType: .legacyABTests),
                           removeCategoryWhenClosingPosting: .makeInt(key: Keys.removeCategoryWhenClosingPosting, defaultValue: 0, groupType: .legacyABTests))



    }

    init(marketingPush: LeanplumABVariable<Int>, showNPSSurvey: LeanplumABVariable<Bool>,
         surveyURL: LeanplumABVariable<String>, surveyEnabled: LeanplumABVariable<Bool>) {

    }
}
