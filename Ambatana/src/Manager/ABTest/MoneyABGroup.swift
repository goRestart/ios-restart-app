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
        static let copyForChatNowInTurkey = "20180312CopyForChatNowInTurkey"
        static let showProTagUserProfile = "20180319ShowProTagUserProfile"
        static let copyForChatNowInEnglish = "20180403CopyForChatNowInEnglish"
        static let showExactLocationForPros = "20180413ShowExactLocationForPros"
        static let copyForSellFasterNowInEnglish = "20180420CopyForSellFasterNowInEnglish"
        static let fullScreenAdsWhenBrowsingForUS = "20180516FullScreenAdsWhenBrowsingForUS"
        static let preventMessagesFromFeedToProUsers = "20180710PreventMessagesFromFeedToProUsers"
        static let appInstallAdsInFeed = "20180628AppInstallAdsInFeed"
        static let alwaysShowBumpBannerWithLoading = "20180725AlwaysShowBumpBannerWithLoading"
        static let showSellFasterInProfileCells = "20180730ShowSellFasterInProfileCells"
        static let bumpInEditCopys = "20180806BumpInEditCopys"
        static let copyForSellFasterNowInTurkish = "20180810CopyForSellFasterNowInTurkish"
        static let multiAdRequestMoreInfo = "20180810MultiAdRequestMoreInfo"
    }
    let copyForChatNowInTurkey: LeanplumABVariable<Int>
    let showProTagUserProfile: LeanplumABVariable<Bool>
    let copyForChatNowInEnglish: LeanplumABVariable<Int>
    let showExactLocationForPros: LeanplumABVariable<Bool>
    let copyForSellFasterNowInEnglish: LeanplumABVariable<Int>
    let fullScreenAdsWhenBrowsingForUS: LeanplumABVariable<Int>
    let preventMessagesFromFeedToProUsers: LeanplumABVariable<Int>
    let appInstallAdsInFeed: LeanplumABVariable<Int>
    let alwaysShowBumpBannerWithLoading: LeanplumABVariable<Int>
    let showSellFasterInProfileCells: LeanplumABVariable<Int>
    let bumpInEditCopys: LeanplumABVariable<Int>
    let copyForSellFasterNowInTurkish: LeanplumABVariable<Int>
    let multiAdRequestMoreInfo: LeanplumABVariable<Int>

    let group: ABGroup = .money
    var intVariables: [LeanplumABVariable<Int>] = []
    var stringVariables: [LeanplumABVariable<String>] = []
    var floatVariables: [LeanplumABVariable<Float>] = []
    var boolVariables: [LeanplumABVariable<Bool>] = []

    init(copyForChatNowInTurkey: LeanplumABVariable<Int>,
         showProTagUserProfile: LeanplumABVariable<Bool>,
         copyForChatNowInEnglish: LeanplumABVariable<Int>,
         showExactLocationForPros: LeanplumABVariable<Bool>,
         copyForSellFasterNowInEnglish: LeanplumABVariable<Int>,
         fullScreenAdsWhenBrowsingForUS:LeanplumABVariable<Int>,
         preventMessagesFromFeedToProUsers:LeanplumABVariable<Int>,
         appInstallAdsInFeed:LeanplumABVariable<Int>,
         alwaysShowBumpBannerWithLoading: LeanplumABVariable<Int>,
         showSellFasterInProfileCells: LeanplumABVariable<Int>,
         bumpInEditCopys: LeanplumABVariable<Int>,
         copyForSellFasterNowInTurkish: LeanplumABVariable<Int>,
         multiAdRequestMoreInfo: LeanplumABVariable<Int>){
        self.copyForChatNowInTurkey = copyForChatNowInTurkey
        self.showProTagUserProfile = showProTagUserProfile
        self.copyForChatNowInEnglish = copyForChatNowInEnglish
        self.showExactLocationForPros = showExactLocationForPros
        self.copyForSellFasterNowInEnglish = copyForSellFasterNowInEnglish
        self.fullScreenAdsWhenBrowsingForUS = fullScreenAdsWhenBrowsingForUS
        self.preventMessagesFromFeedToProUsers = preventMessagesFromFeedToProUsers
        self.appInstallAdsInFeed = appInstallAdsInFeed
        self.alwaysShowBumpBannerWithLoading = alwaysShowBumpBannerWithLoading
        self.showSellFasterInProfileCells = showSellFasterInProfileCells
        self.bumpInEditCopys = bumpInEditCopys
        self.copyForSellFasterNowInTurkish = copyForSellFasterNowInTurkish
        self.multiAdRequestMoreInfo = multiAdRequestMoreInfo

        intVariables.append(contentsOf: [copyForChatNowInTurkey,
                                         copyForChatNowInEnglish,
                                         copyForSellFasterNowInEnglish,
                                         fullScreenAdsWhenBrowsingForUS,
                                         preventMessagesFromFeedToProUsers,
                                         appInstallAdsInFeed,
                                         alwaysShowBumpBannerWithLoading,
                                         showSellFasterInProfileCells,
                                         bumpInEditCopys,
                                         copyForSellFasterNowInTurkish,
                                         multiAdRequestMoreInfo])
        boolVariables.append(contentsOf: [showProTagUserProfile,
                                          showExactLocationForPros])
    }

    static func make() -> MoneyABGroup {
        return MoneyABGroup(copyForChatNowInTurkey: .makeInt(key: Keys.copyForChatNowInTurkey,
                                                             defaultValue: 0,
                                                             groupType: .money),
                            showProTagUserProfile:.makeBool(key: Keys.showProTagUserProfile,
                                                            defaultValue: false,
                                                            groupType: .money),
                            copyForChatNowInEnglish: .makeInt(key: Keys.copyForChatNowInEnglish,
                                                              defaultValue: 0,
                                                              groupType: .money),
                            showExactLocationForPros: .makeBool(key: Keys.showExactLocationForPros,
                                                                defaultValue: true,
                                                                groupType: .money),
                            copyForSellFasterNowInEnglish: .makeInt(key: Keys.copyForSellFasterNowInEnglish,
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
                                                          groupType: .money),
                            alwaysShowBumpBannerWithLoading: .makeInt(key: Keys.alwaysShowBumpBannerWithLoading,
                                                                      defaultValue: 0,
                                                                      groupType: .money),
                            showSellFasterInProfileCells: .makeInt(key: Keys.showSellFasterInProfileCells,
                                                                   defaultValue: 0,
                                                                   groupType: .money),
                            bumpInEditCopys: .makeInt(key: Keys.bumpInEditCopys,
                                                      defaultValue: 0,
                                                      groupType: .money),
                            copyForSellFasterNowInTurkish: .makeInt(key: Keys.copyForSellFasterNowInTurkish,
                                                                    defaultValue: 0,
                                                                    groupType: .money),
                            multiAdRequestMoreInfo: .makeInt(key: Keys.multiAdRequestMoreInfo,
                                                             defaultValue: 0,
                                                             groupType: .money)
        )
    }
}

