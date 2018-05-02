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
        static let showProTagUserProfile = "20180319ShowProTagUserProfile"
        static let feedAdsProviderForUS = "20180327FeedAdsProviderForUS"
        static let copyForChatNowInEnglish = "20180403CopyForChatNowInEnglish"
        static let feedAdsProviderForTR = "20180405FeedAdsProviderForTR"
        static let bumpUpBoost = "20180314bumpUpBoost"
        static let showExactLocationForPros = "20180413ShowExactLocationForPros"
        static let copyForSellFasterNowInEnglish = "20180420CopyForSellFasterNowInEnglish"
    }
    let increaseMinPriceBumps: LeanplumABVariable<Int>
    let noAdsInFeedForNewUsers: LeanplumABVariable<Int>
    let showBumpUpBannerOnNotValidatedListings: LeanplumABVariable<Int>
    let copyForChatNowInTurkey: LeanplumABVariable<Int>
    let turkeyBumpPriceVATAdaptation: LeanplumABVariable<Int>
    let showProTagUserProfile: LeanplumABVariable<Bool>
    let feedAdsProviderForUS: LeanplumABVariable<Int>
    let copyForChatNowInEnglish: LeanplumABVariable<Int>
    let feedAdsProviderForTR: LeanplumABVariable<Int>
    let bumpUpBoost: LeanplumABVariable<Int>
    let showExactLocationForPros: LeanplumABVariable<Bool>
    let copyForSellFasterNowInEnglish: LeanplumABVariable<Int>

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
         showProTagUserProfile: LeanplumABVariable<Bool>,
         feedAdsProviderForUS: LeanplumABVariable<Int>,
         copyForChatNowInEnglish: LeanplumABVariable<Int>,
         feedAdsProviderForTR: LeanplumABVariable<Int>,
         bumpUpBoost: LeanplumABVariable<Int>,
         showExactLocationForPros: LeanplumABVariable<Bool>,
         copyForSellFasterNowInEnglish: LeanplumABVariable<Int>){
        self.increaseMinPriceBumps = increaseMinPriceBumps
        self.noAdsInFeedForNewUsers = noAdsInFeedForNewUsers
        self.showBumpUpBannerOnNotValidatedListings = showBumpUpBannerOnNotValidatedListings
        self.copyForChatNowInTurkey = copyForChatNowInTurkey
        self.turkeyBumpPriceVATAdaptation = turkeyBumpPriceVATAdaptation
        self.showProTagUserProfile = showProTagUserProfile
        self.feedAdsProviderForUS = feedAdsProviderForUS
        self.copyForChatNowInEnglish = copyForChatNowInEnglish
        self.feedAdsProviderForTR = feedAdsProviderForTR
        self.bumpUpBoost = bumpUpBoost
        self.showExactLocationForPros = showExactLocationForPros
        self.copyForSellFasterNowInEnglish = copyForSellFasterNowInEnglish

        intVariables.append(contentsOf: [increaseMinPriceBumps,
                                         noAdsInFeedForNewUsers,
                                         showBumpUpBannerOnNotValidatedListings,
                                         copyForChatNowInTurkey,
                                         turkeyBumpPriceVATAdaptation,
                                         feedAdsProviderForUS,
                                         copyForChatNowInEnglish,
                                         feedAdsProviderForTR,
                                         bumpUpBoost,
                                         copyForSellFasterNowInEnglish])
        boolVariables.append(contentsOf: [showProTagUserProfile,
                                          showExactLocationForPros])
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
                            showProTagUserProfile:.makeBool(key: Keys.showProTagUserProfile,
                                                            defaultValue: false,
                                                            groupType: .money),
                            feedAdsProviderForUS: .makeInt(key: Keys.feedAdsProviderForUS,
                                                           defaultValue: 0,
                                                           groupType: .money),
                            copyForChatNowInEnglish: .makeInt(key: Keys.copyForChatNowInEnglish,
                                                              defaultValue: 0,
                                                              groupType: .money),
                            feedAdsProviderForTR: .makeInt(key: Keys.feedAdsProviderForTR,
                                                              defaultValue: 0,
                                                              groupType: .money),
                            bumpUpBoost: .makeInt(key: Keys.bumpUpBoost,
                                                           defaultValue: 0,
                                                           groupType: .money),
                            showExactLocationForPros: .makeBool(key: Keys.showExactLocationForPros,
                                                                defaultValue: true,
                                                                groupType: .money),
                            copyForSellFasterNowInEnglish: .makeInt(key: Keys.copyForSellFasterNowInEnglish,
                                                                    defaultValue: 0,
                                                                    groupType: .money))
        
    }
}
