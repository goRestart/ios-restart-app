//
//  MoneyABGroup.swift
//  LetGo
//
//  Created by Facundo Menzella on 29/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

struct MoneyABGroup: ABGroupType {
    private struct Keys {
        static let increaseMinPriceBumps = "20180208IncreaseMinPriceBumps"
        static let noAdsInFeedForNewUsers = "20180212NoAdsInFeedForNewUsers"
        static let showBumpUpBannerOnNotValidatedListings = "20180214showBumpUpBannerOnNotValidatedListings"
        static let copyForChatNowInTurkey = "20180312CopyForChatNowInTurkey"
        static let turkeyBumpPriceVATAdaptation = "20180221TurkeyBumpPriceVATAdaptation"
        static let promoteBumpInEdit = "20180227promoteBumpInEdit"
        static let showProTagUserProfile = "20180319ShowProTagUserProfile"
        static let feedAdsProviderForUS = "20180327FeedAdsProviderForUS"
        static let feedAdsProviderForTR = "20180405FeedAdsProviderForTR"
    }
    let increaseMinPriceBumps: LeanplumABVariable<Int>
    let noAdsInFeedForNewUsers: LeanplumABVariable<Int>
    let showBumpUpBannerOnNotValidatedListings: LeanplumABVariable<Int>
    let copyForChatNowInTurkey: LeanplumABVariable<Int>
    let turkeyBumpPriceVATAdaptation: LeanplumABVariable<Int>
    let promoteBumpInEdit: LeanplumABVariable<Int>
    let showProTagUserProfile: LeanplumABVariable<Bool>
    let feedAdsProviderForUS: LeanplumABVariable<Int>
    let feedAdsProviderForTR: LeanplumABVariable<Int>

    let group: ABGroup = .money
    var intVariables: [LeanplumABVariable<Int>] = []
    var stringVariables: [LeanplumABVariable<String>] = []
    var floatVariables: [LeanplumABVariable<Float>] = []
    var boolVariables: [LeanplumABVariable<Bool>] = []

    init(increaseMinPriceBumps: LeanplumABVariable<Int>,
         noAdsInFeedForNewUsers: LeanplumABVariable<Int>,
         showBumpUpBannerOnNotValidatedListings: LeanplumABVariable<Int>,
         copyForChatNowInTurkey: LeanplumABVariable<Int>,
         turkeyBumpPriceVATAdaptation: LeanplumABVariable<Int>,
         promoteBumpInEdit: LeanplumABVariable<Int>,
         showProTagUserProfile: LeanplumABVariable<Bool>,
         feedAdsProviderForUS: LeanplumABVariable<Int>,
         feedAdsProviderForTR: LeanplumABVariable<Int>) {
        self.increaseMinPriceBumps = increaseMinPriceBumps
        self.noAdsInFeedForNewUsers = noAdsInFeedForNewUsers
        self.showBumpUpBannerOnNotValidatedListings = showBumpUpBannerOnNotValidatedListings
        self.copyForChatNowInTurkey = copyForChatNowInTurkey
        self.turkeyBumpPriceVATAdaptation = turkeyBumpPriceVATAdaptation
        self.promoteBumpInEdit = promoteBumpInEdit
        self.showProTagUserProfile = showProTagUserProfile
        self.feedAdsProviderForUS = feedAdsProviderForUS
        self.feedAdsProviderForTR = feedAdsProviderForTR

        intVariables.append(contentsOf: [increaseMinPriceBumps,
                                         noAdsInFeedForNewUsers,
                                         showBumpUpBannerOnNotValidatedListings,
                                         copyForChatNowInTurkey,
                                         turkeyBumpPriceVATAdaptation,
                                         promoteBumpInEdit,
                                         feedAdsProviderForUS,
                                         feedAdsProviderForTR])
        boolVariables.append(showProTagUserProfile)
    }

    static func make() -> MoneyABGroup {
        return MoneyABGroup(increaseMinPriceBumps: .makeInt(key: Keys.increaseMinPriceBumps,
                                                            defaultValue: 0,
                                                            groupType: .money),
                            noAdsInFeedForNewUsers: .makeInt(key: Keys.noAdsInFeedForNewUsers,
                                                             defaultValue: 0,
                                                             groupType: .money),
                            showBumpUpBannerOnNotValidatedListings: .makeInt(key: Keys.showBumpUpBannerOnNotValidatedListings,
                                                                             defaultValue: 0,
                                                                             groupType: .money),
                            copyForChatNowInTurkey: .makeInt(key: Keys.copyForChatNowInTurkey,
                                                             defaultValue: 0,
                                                             groupType: .money),
                            turkeyBumpPriceVATAdaptation: .makeInt(key: Keys.turkeyBumpPriceVATAdaptation,
                                                                   defaultValue: 0, groupType: .money),
                            promoteBumpInEdit: .makeInt(key: Keys.promoteBumpInEdit, defaultValue: 0,
                                                        groupType: .money),
                            showProTagUserProfile:.makeBool(key: Keys.showProTagUserProfile,
                                                            defaultValue: false,
                                                            groupType: .money),
                            feedAdsProviderForUS: .makeInt(key: Keys.feedAdsProviderForUS,
                                                           defaultValue: 0,
                                                           groupType: .money),
                            feedAdsProviderForTR: .makeInt(key: Keys.feedAdsProviderForTR,
                                                           defaultValue: 0,
                                                           groupType: .money))
    }
}
