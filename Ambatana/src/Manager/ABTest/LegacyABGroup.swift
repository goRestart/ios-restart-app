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
        static let carsMultiReqEnabled = "newCarsMultiRequesterEnabled"
        static let inAppRatingIOS10 = "20170711inAppRatingIOS10"
        static let userReviewsReportEnabled = "20170823userReviewsReportEnabled"
        static let appRatingDialogInactive = "20170831AppRatingDialogInactive"
        static let locationDataSourceType = "20170830LocationDataSourceType"
        static let realEstateEnabled = "20171228realEstateEnabled"
        static let deckItemPage = "20180403NewItemPage"
        static let showAdsInFeedWithRatio = "20180111ShowAdsInFeedWithRatio"
    }
    
    let newCarsMultiRequesterEnabled: LeanplumABVariable<Bool>
    let inAppRatingIOS10: LeanplumABVariable<Bool>
    let userReviewsReportEnabled: LeanplumABVariable<Bool>
    let appRatingDialogInactive: LeanplumABVariable<Bool>
    let locationDataSourceType: LeanplumABVariable<Int>
    let realEstateEnabled: LeanplumABVariable<Int>
    let newItemPage: LeanplumABVariable<Int>
    let showAdsInFeedWithRatio: LeanplumABVariable<Int>
    
    
    let group: ABGroup = .legacyABTests
    var intVariables: [LeanplumABVariable<Int>] = []
    var stringVariables: [LeanplumABVariable<String>] = []
    var floatVariables: [LeanplumABVariable<Float>] = []
    var boolVariables: [LeanplumABVariable<Bool>] = []
    
    init(newCarsMultiRequesterEnabled: LeanplumABVariable<Bool>,
         inAppRatingIOS10: LeanplumABVariable<Bool>,
         userReviewsReportEnabled: LeanplumABVariable<Bool>,
         appRatingDialogInactive: LeanplumABVariable<Bool>,
         locationDataSourceType: LeanplumABVariable<Int>,
         realEstateEnabled: LeanplumABVariable<Int>,
         newItemPage: LeanplumABVariable<Int>,
         showAdsInFeedWithRatio: LeanplumABVariable<Int>) {
        self.newCarsMultiRequesterEnabled = newCarsMultiRequesterEnabled
        self.inAppRatingIOS10 = inAppRatingIOS10
        self.userReviewsReportEnabled = userReviewsReportEnabled
        self.appRatingDialogInactive = appRatingDialogInactive
        self.locationDataSourceType = locationDataSourceType
        self.realEstateEnabled = realEstateEnabled
        self.newItemPage = newItemPage
        self.showAdsInFeedWithRatio = showAdsInFeedWithRatio
        
        intVariables.append(contentsOf: [locationDataSourceType,
                                         realEstateEnabled,
                                         newItemPage,
                                         showAdsInFeedWithRatio])
        boolVariables.append(contentsOf: [newCarsMultiRequesterEnabled,
                                          inAppRatingIOS10,
                                          userReviewsReportEnabled,
                                          appRatingDialogInactive])
    }
    
    static func make() -> LegacyABGroup {
        return LegacyABGroup(newCarsMultiRequesterEnabled: .makeBool(key: Keys.carsMultiReqEnabled, defaultValue: false,  groupType: .legacyABTests),
                             inAppRatingIOS10: .makeBool(key: Keys.inAppRatingIOS10, defaultValue: false, groupType: .legacyABTests),
                             userReviewsReportEnabled: .makeBool(key: Keys.userReviewsReportEnabled, defaultValue: true, groupType: .legacyABTests),
                             appRatingDialogInactive: .makeBool(key: Keys.appRatingDialogInactive, defaultValue: false, groupType: .legacyABTests),
                             locationDataSourceType: .makeInt(key: Keys.locationDataSourceType, defaultValue: 0, groupType: .legacyABTests),
                             realEstateEnabled: .makeInt(key: Keys.realEstateEnabled, defaultValue: 0, groupType: .legacyABTests),
                             newItemPage: .makeInt(key: Keys.deckItemPage, defaultValue: 0, groupType: .legacyABTests),
                             showAdsInFeedWithRatio: .makeInt(key: Keys.showAdsInFeedWithRatio, defaultValue: 0, groupType: .legacyABTests))
    }
}
