//
//  LegacyABGroup.swift
//  LetGo
//
//  Created by Facundo Menzella on 29/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

struct LegacyABGroup: ABGroupType {
    private struct Keys {
        static let marketingPush = "marketingPush"
        static let surveyURL = "surveyURL"
        static let surveyEnabled = "surveyEnabled"
        static let freeBumpUpEnabled = "freeBumpUpEnabled"
        static let pricedBumpUpEnabled = "pricedBumpUpEnabled"
        static let carsMultiReqEnabled = "newCarsMultiRequesterEnabled"
        static let inAppRatingIOS10 = "20170711inAppRatingIOS10"
        static let userReviewsReportEnabled = "20170823userReviewsReportEnabled"
        static let appRatingDialogInactive = "20170831AppRatingDialogInactive"
        static let locationDataSourceType = "20170830LocationDataSourceType"
        static let realEstateEnabled = "20171228realEstateEnabled"
        static let requestTimeOut = "20170929RequestTimeOut"
        static let deckItemPage = "20180403NewItemPage"
        static let taxonomiesAndTaxonomyChildrenInFeed = "20171031TaxonomiesAndTaxonomyChildrenInFeed"
        static let showClockInDirectAnswer = "20171031ShowClockInDirectAnswer"
        static let showAdsInFeedWithRatio = "20180111ShowAdsInFeedWithRatio"
    }
    
    let marketingPush: LeanplumABVariable<Int>
    // Not an A/B just flags and variables for surveys
    let surveyURL: LeanplumABVariable<String>
    let surveyEnabled: LeanplumABVariable<Bool>
    let freeBumpUpEnabled: LeanplumABVariable<Bool>
    let pricedBumpUpEnabled: LeanplumABVariable<Bool>
    let newCarsMultiRequesterEnabled: LeanplumABVariable<Bool>
    let inAppRatingIOS10: LeanplumABVariable<Bool>
    let userReviewsReportEnabled: LeanplumABVariable<Bool>
    let appRatingDialogInactive: LeanplumABVariable<Bool>
    let locationDataSourceType: LeanplumABVariable<Int>
    let realEstateEnabled: LeanplumABVariable<Int>
    let requestsTimeOut: LeanplumABVariable<Int>
    let newItemPage: LeanplumABVariable<Int>
    let taxonomiesAndTaxonomyChildrenInFeed: LeanplumABVariable<Int>
    let showClockInDirectAnswer: LeanplumABVariable<Int>
    let showAdsInFeedWithRatio: LeanplumABVariable<Int>
    
    
    let group: ABGroup = .legacyABTests
    var intVariables: [LeanplumABVariable<Int>] = []
    var stringVariables: [LeanplumABVariable<String>] = []
    var floatVariables: [LeanplumABVariable<Float>] = []
    var boolVariables: [LeanplumABVariable<Bool>] = []
    
    init(marketingPush: LeanplumABVariable<Int>,
         surveyURL: LeanplumABVariable<String>,
         surveyEnabled: LeanplumABVariable<Bool>,
         freeBumpUpEnabled: LeanplumABVariable<Bool>,
         pricedBumpUpEnabled: LeanplumABVariable<Bool>,
         newCarsMultiRequesterEnabled: LeanplumABVariable<Bool>,
         inAppRatingIOS10: LeanplumABVariable<Bool>,
         userReviewsReportEnabled: LeanplumABVariable<Bool>,
         appRatingDialogInactive: LeanplumABVariable<Bool>,
         locationDataSourceType: LeanplumABVariable<Int>,
         realEstateEnabled: LeanplumABVariable<Int>,
         requestsTimeOut: LeanplumABVariable<Int>,
         newItemPage: LeanplumABVariable<Int>,
         taxonomiesAndTaxonomyChildrenInFeed: LeanplumABVariable<Int>,
         showClockInDirectAnswer: LeanplumABVariable<Int>,
         showAdsInFeedWithRatio: LeanplumABVariable<Int>) {
        
        self.marketingPush = marketingPush
        self.surveyURL = surveyURL
        self.surveyEnabled = surveyEnabled
        self.freeBumpUpEnabled = freeBumpUpEnabled
        self.pricedBumpUpEnabled = pricedBumpUpEnabled
        self.newCarsMultiRequesterEnabled = newCarsMultiRequesterEnabled
        self.inAppRatingIOS10 = inAppRatingIOS10
        self.userReviewsReportEnabled = userReviewsReportEnabled
        self.appRatingDialogInactive = appRatingDialogInactive
        self.locationDataSourceType = locationDataSourceType
        self.realEstateEnabled = realEstateEnabled
        self.requestsTimeOut = requestsTimeOut
        self.newItemPage = newItemPage
        self.taxonomiesAndTaxonomyChildrenInFeed = taxonomiesAndTaxonomyChildrenInFeed
        self.showClockInDirectAnswer = showClockInDirectAnswer
        self.showAdsInFeedWithRatio = showAdsInFeedWithRatio
        
        intVariables.append(contentsOf: [marketingPush,
                                         locationDataSourceType,
                                         realEstateEnabled,
                                         requestsTimeOut,
                                         newItemPage,
                                         taxonomiesAndTaxonomyChildrenInFeed,
                                         showClockInDirectAnswer,
                                         showAdsInFeedWithRatio])
        boolVariables.append(contentsOf: [surveyEnabled, freeBumpUpEnabled,
                                          pricedBumpUpEnabled, newCarsMultiRequesterEnabled, inAppRatingIOS10,
                                          userReviewsReportEnabled, appRatingDialogInactive])
        stringVariables.append(surveyURL)
        
    }
    
    static func make() -> LegacyABGroup {
        return LegacyABGroup(marketingPush: .makeInt(key: Keys.marketingPush, defaultValue: 0, groupType: .legacyABTests),
                             surveyURL: .makeString(key: Keys.surveyURL, defaultValue: "", groupType: .legacyABTests),
                             surveyEnabled: .makeBool(key: Keys.surveyEnabled, defaultValue: false, groupType: .legacyABTests),
                             freeBumpUpEnabled: .makeBool(key: Keys.freeBumpUpEnabled, defaultValue: false, groupType: .legacyABTests),
                             pricedBumpUpEnabled: .makeBool(key: Keys.pricedBumpUpEnabled, defaultValue: false, groupType: .legacyABTests),
                             newCarsMultiRequesterEnabled: .makeBool(key: Keys.carsMultiReqEnabled, defaultValue: false,  groupType: .legacyABTests),
                             inAppRatingIOS10: .makeBool(key: Keys.inAppRatingIOS10, defaultValue: false, groupType: .legacyABTests),
                             userReviewsReportEnabled: .makeBool(key: Keys.userReviewsReportEnabled, defaultValue: true, groupType: .legacyABTests),
                             appRatingDialogInactive: .makeBool(key: Keys.appRatingDialogInactive, defaultValue: false, groupType: .legacyABTests),
                             locationDataSourceType: .makeInt(key: Keys.locationDataSourceType, defaultValue: 0, groupType: .legacyABTests),
                             realEstateEnabled: .makeInt(key: Keys.realEstateEnabled, defaultValue: 0, groupType: .legacyABTests),
                             requestsTimeOut: .makeInt(key: Keys.requestTimeOut, defaultValue: 30, groupType: .legacyABTests),
                             newItemPage: .makeInt(key: Keys.deckItemPage, defaultValue: 0, groupType: .legacyABTests),
                             taxonomiesAndTaxonomyChildrenInFeed: .makeInt(key: Keys.taxonomiesAndTaxonomyChildrenInFeed, defaultValue: 0, groupType: .legacyABTests),
                             showClockInDirectAnswer: .makeInt(key: Keys.showClockInDirectAnswer, defaultValue: 0, groupType: .legacyABTests),
                             showAdsInFeedWithRatio: .makeInt(key: Keys.showAdsInFeedWithRatio, defaultValue: 0, groupType: .legacyABTests))
    }
}
