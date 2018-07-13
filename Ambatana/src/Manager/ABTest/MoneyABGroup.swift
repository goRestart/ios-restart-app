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
        static let noAdsInFeedForNewUsers = "20180212NoAdsInFeedForNewUsers"
        static let copyForChatNowInTurkey = "20180312CopyForChatNowInTurkey"
        static let showProTagUserProfile = "20180319ShowProTagUserProfile"
        static let feedAdsProviderForUS = "20180327FeedAdsProviderForUS"
        static let copyForChatNowInEnglish = "20180403CopyForChatNowInEnglish"
        static let feedAdsProviderForTR = "20180405FeedAdsProviderForTR"
        static let bumpUpBoost = "20180314bumpUpBoost"
        static let showExactLocationForPros = "20180413ShowExactLocationForPros"
        static let copyForSellFasterNowInEnglish = "20180420CopyForSellFasterNowInEnglish"
        static let googleAdxForTR = "20180511GoogleAdxForTR"
        static let fullScreenAdsWhenBrowsingForUS = "20180516FullScreenAdsWhenBrowsingForUS"
        static let preventMessagesFromFeedToProUsers = "20180710PreventMessagesFromFeedToProUsers"
        static let appInstallAdsInFeed = "20180628AppInstallAdsInFeed"
    }
    let noAdsInFeedForNewUsers: LeanplumABVariable<Int>
    let copyForChatNowInTurkey: LeanplumABVariable<Int>
    let showProTagUserProfile: LeanplumABVariable<Bool>
    let feedAdsProviderForUS: LeanplumABVariable<Int>
    let copyForChatNowInEnglish: LeanplumABVariable<Int>
    let feedAdsProviderForTR: LeanplumABVariable<Int>
    let bumpUpBoost: LeanplumABVariable<Int>
    let showExactLocationForPros: LeanplumABVariable<Bool>
    let copyForSellFasterNowInEnglish: LeanplumABVariable<Int>
    let googleAdxForTR: LeanplumABVariable<Int>
    let fullScreenAdsWhenBrowsingForUS: LeanplumABVariable<Int>
    let preventMessagesFromFeedToProUsers: LeanplumABVariable<Int>
    let appInstallAdsInFeed: LeanplumABVariable<Int>

    let group: ABGroup = .money
    var intVariables: [LeanplumABVariable<Int>] = []
    var stringVariables: [LeanplumABVariable<String>] = []
    var floatVariables: [LeanplumABVariable<Float>] = []
    var boolVariables: [LeanplumABVariable<Bool>] = []

    init(noAdsInFeedForNewUsers: LeanplumABVariable<Int>,
         copyForChatNowInTurkey: LeanplumABVariable<Int>,
         showProTagUserProfile: LeanplumABVariable<Bool>,
         feedAdsProviderForUS: LeanplumABVariable<Int>,
         copyForChatNowInEnglish: LeanplumABVariable<Int>,
         feedAdsProviderForTR: LeanplumABVariable<Int>,
         bumpUpBoost: LeanplumABVariable<Int>,
         showExactLocationForPros: LeanplumABVariable<Bool>,
         copyForSellFasterNowInEnglish: LeanplumABVariable<Int>,
         googleAdxForTR:LeanplumABVariable<Int>,
         fullScreenAdsWhenBrowsingForUS:LeanplumABVariable<Int>,
         preventMessagesFromFeedToProUsers:LeanplumABVariable<Int>,
         appInstallAdsInFeed:LeanplumABVariable<Int>){
        self.noAdsInFeedForNewUsers = noAdsInFeedForNewUsers
        self.copyForChatNowInTurkey = copyForChatNowInTurkey
        self.showProTagUserProfile = showProTagUserProfile
        self.feedAdsProviderForUS = feedAdsProviderForUS
        self.copyForChatNowInEnglish = copyForChatNowInEnglish
        self.feedAdsProviderForTR = feedAdsProviderForTR
        self.bumpUpBoost = bumpUpBoost
        self.showExactLocationForPros = showExactLocationForPros
        self.copyForSellFasterNowInEnglish = copyForSellFasterNowInEnglish
        self.googleAdxForTR = googleAdxForTR
        self.fullScreenAdsWhenBrowsingForUS = fullScreenAdsWhenBrowsingForUS
        self.preventMessagesFromFeedToProUsers = preventMessagesFromFeedToProUsers
        self.appInstallAdsInFeed = appInstallAdsInFeed

        intVariables.append(contentsOf: [noAdsInFeedForNewUsers,
                                         copyForChatNowInTurkey,
                                         feedAdsProviderForUS,
                                         copyForChatNowInEnglish,
                                         feedAdsProviderForTR,
                                         bumpUpBoost,
                                         copyForSellFasterNowInEnglish,
                                         googleAdxForTR,
                                         fullScreenAdsWhenBrowsingForUS,
                                         preventMessagesFromFeedToProUsers,
                                         appInstallAdsInFeed])
        boolVariables.append(contentsOf: [showProTagUserProfile,
                                          showExactLocationForPros])
    }

    static func make() -> MoneyABGroup {
        return MoneyABGroup(noAdsInFeedForNewUsers: .makeInt(key: Keys.noAdsInFeedForNewUsers,
                                                             defaultValue: 0,
                                                             groupType: .money),
                            copyForChatNowInTurkey: .makeInt(key: Keys.copyForChatNowInTurkey,
                                                             defaultValue: 0,
                                                             groupType: .money),
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
                                                                    groupType: .money),
                            googleAdxForTR: .makeInt(key: Keys.googleAdxForTR,
                                                           defaultValue: 0,
                                                           groupType: .money),
                            fullScreenAdsWhenBrowsingForUS: .makeInt(key: Keys.fullScreenAdsWhenBrowsingForUS,
                                                                     defaultValue: 0,
                                                                     groupType: .money),
                            preventMessagesFromFeedToProUsers: .makeInt(key: Keys.preventMessagesFromFeedToProUsers,
                                                                     defaultValue: 0,
                                                                     groupType: .money),
                            appInstallAdsInFeed: .makeInt(key: Keys.appInstallAdsInFeed,
                                                          defaultValue: 0,
                                                          groupType: .money))
    }
}
