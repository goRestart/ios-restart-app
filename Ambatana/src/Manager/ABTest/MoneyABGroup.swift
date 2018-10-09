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
        static let multiDayBumpUp = "20180827MultiDayBumpUp"
        static let multiAdRequestInChatSectionForUS = "20180802MultiAdRequestInChatSectionForUS"
        static let multiAdRequestInChatSectionForTR = "20180802MultiAdRequestInChatSectionForTR"
        static let bumpPromoAfterSellNoLimit = "20180925BumpPromoAfterSellNoLimit"
        static let polymorphFeedAdsUSA = "20180828PolymorphFeedAdsUSA"
        static let showAdsInFeedWithRatio = "20180111ShowAdsInFeedWithRatio"
        static let googleUnifiedNativeAds = "20180928GoogleUnifiedNativeAds"
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
    let multiDayBumpUp: LeanplumABVariable<Int>
    let multiAdRequestInChatSectionForUS: LeanplumABVariable<Int>
    let multiAdRequestInChatSectionForTR: LeanplumABVariable<Int>
    let bumpPromoAfterSellNoLimit: LeanplumABVariable<Int>
    let polymorphFeedAdsUSA: LeanplumABVariable<Int>
    let showAdsInFeedWithRatio: LeanplumABVariable<Int>
    let googleUnifiedNativeAds: LeanplumABVariable<Int>

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
         multiAdRequestMoreInfo: LeanplumABVariable<Int>,
         multiDayBumpUp: LeanplumABVariable<Int>,
         multiAdRequestInChatSectionForUS: LeanplumABVariable<Int>,
         multiAdRequestInChatSectionForTR: LeanplumABVariable<Int>,
         bumpPromoAfterSellNoLimit: LeanplumABVariable<Int>,
         polymorphFeedAdsUSA: LeanplumABVariable<Int>,
         showAdsInFeedWithRatio: LeanplumABVariable<Int>,
         googleUnifiedNativeAds: LeanplumABVariable<Int>){
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
        self.multiDayBumpUp = multiDayBumpUp
        self.multiAdRequestInChatSectionForUS = multiAdRequestInChatSectionForUS
        self.multiAdRequestInChatSectionForTR = multiAdRequestInChatSectionForTR
        self.bumpPromoAfterSellNoLimit = bumpPromoAfterSellNoLimit
        self.polymorphFeedAdsUSA = polymorphFeedAdsUSA
        self.showAdsInFeedWithRatio = showAdsInFeedWithRatio
        self.googleUnifiedNativeAds = googleUnifiedNativeAds

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
                                         multiAdRequestMoreInfo,
                                         multiDayBumpUp,
                                         multiAdRequestInChatSectionForUS,
                                         multiAdRequestInChatSectionForTR,
                                         bumpPromoAfterSellNoLimit,
                                         polymorphFeedAdsUSA,
                                         showAdsInFeedWithRatio,
                                         googleUnifiedNativeAds])
        boolVariables.append(contentsOf: [showProTagUserProfile,
                                          showExactLocationForPros])
    }

    static func make() -> MoneyABGroup {
        return MoneyABGroup(copyForChatNowInTurkey: moneyIntFor(key: Keys.copyForChatNowInTurkey),
                            showProTagUserProfile: moneyBoolFor(key: Keys.showProTagUserProfile, value: false),
                            copyForChatNowInEnglish: moneyIntFor(key: Keys.copyForChatNowInEnglish),
                            showExactLocationForPros: moneyBoolFor(key: Keys.showExactLocationForPros, value: true),
                            copyForSellFasterNowInEnglish: moneyIntFor(key: Keys.copyForSellFasterNowInEnglish),
                            fullScreenAdsWhenBrowsingForUS: moneyIntFor(key: Keys.fullScreenAdsWhenBrowsingForUS),
                            preventMessagesFromFeedToProUsers: moneyIntFor(key: Keys.preventMessagesFromFeedToProUsers),
                            appInstallAdsInFeed: moneyIntFor(key: Keys.appInstallAdsInFeed),
                            alwaysShowBumpBannerWithLoading: moneyIntFor(key: Keys.alwaysShowBumpBannerWithLoading),
                            showSellFasterInProfileCells: moneyIntFor(key: Keys.showSellFasterInProfileCells),
                            bumpInEditCopys: moneyIntFor(key: Keys.bumpInEditCopys),
                            copyForSellFasterNowInTurkish: moneyIntFor(key: Keys.copyForSellFasterNowInTurkish),
                            multiAdRequestMoreInfo: moneyIntFor(key: Keys.multiAdRequestMoreInfo),
                            multiDayBumpUp: moneyIntFor(key: Keys.multiDayBumpUp),
                            multiAdRequestInChatSectionForUS: moneyIntFor(key: Keys.multiAdRequestInChatSectionForUS),
                            multiAdRequestInChatSectionForTR: moneyIntFor(key: Keys.multiAdRequestInChatSectionForTR),
                            bumpPromoAfterSellNoLimit: moneyIntFor(key: Keys.bumpPromoAfterSellNoLimit),
                            polymorphFeedAdsUSA: moneyIntFor(key: Keys.polymorphFeedAdsUSA),
                            showAdsInFeedWithRatio: moneyIntFor(key: Keys.showAdsInFeedWithRatio),
                            googleUnifiedNativeAds: moneyIntFor(key: Keys.googleUnifiedNativeAds)
        )
    }

    private static func moneyIntFor(key: String) -> LeanplumABVariable<Int> {
        return .makeInt(key: key, defaultValue: 0, groupType: .money)
    }

    private static func moneyBoolFor(key: String, value: Bool) -> LeanplumABVariable<Bool> {
        return .makeBool(key: key, defaultValue: value, groupType: .money)
    }
}

