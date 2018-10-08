import Foundation

struct RetentionABGroup: ABGroupType {
    private struct Keys {
        static let dummyUsersInfoProfile = "20180130DummyUsersInfoProfile"
        static let onboardingIncentivizePosting = "20180215OnboardingIncentivizePosting"
        static let searchAlertsInSearchSuggestions = "20180710SearchAlertsInSearchSuggestions"
        static let engagementBadging = "20180613EngagementBadging"
        static let searchAlertsDisableOldestIfMaximumReached = "201807SearchAlertsDisableOldestIfMaximumReached"
        static let randomImInterestedMessages = "20180817RandomImInterestedMessages"
        static let imInterestedInProfile = "20180828ImInterestedInProfile"
        static let shareAfterScreenshot = "20180905ShareAfterScreenshot"
        static let affiliationCampaign = "20181001Affiliation-1-49-0"
        static let imageSizesNotificationCenter = "20180928ImageSizesNotificationCenter"
        static let blockingSignUp = "20180919BlockingSignUp"
    }
    let dummyUsersInfoProfile: LeanplumABVariable<Int>
    let onboardingIncentivizePosting: LeanplumABVariable<Int>
    let searchAlertsInSearchSuggestions: LeanplumABVariable<Int>
    let engagementBadging: LeanplumABVariable<Int>
    let searchAlertsDisableOldestIfMaximumReached: LeanplumABVariable<Int>
    let randomImInterestedMessages: LeanplumABVariable<Int>
    let imInterestedInProfile: LeanplumABVariable<Int>
    let shareAfterScreenshot: LeanplumABVariable<Int>
    let affiliationCampaign: LeanplumABVariable<Int>
    let imageSizesNotificationCenter: LeanplumABVariable<Int>
    let blockingSignUp: LeanplumABVariable<Int>
    
    let group: ABGroup = .retention
    var intVariables: [LeanplumABVariable<Int>] = []
    var stringVariables: [LeanplumABVariable<String>] = []
    var floatVariables: [LeanplumABVariable<Float>] = []
    var boolVariables: [LeanplumABVariable<Bool>] = []

    init(dummyUsersInfoProfile: LeanplumABVariable<Int>,
         onboardingIncentivizePosting: LeanplumABVariable<Int>,
         searchAlertsInSearchSuggestions: LeanplumABVariable<Int>,
         engagementBadging: LeanplumABVariable<Int>,
         searchAlertsDisableOldestIfMaximumReached: LeanplumABVariable<Int>,
         randomImInterestedMessages: LeanplumABVariable<Int>,
         imInterestedInProfile: LeanplumABVariable<Int>,
         shareAfterScreenshot: LeanplumABVariable<Int>,
         affiliationCampaign: LeanplumABVariable<Int>,
         imageSizesNotificationCenter: LeanplumABVariable<Int>,
         blockingSignUp: LeanplumABVariable<Int>) {
        self.dummyUsersInfoProfile = dummyUsersInfoProfile
        self.onboardingIncentivizePosting = onboardingIncentivizePosting
        self.searchAlertsInSearchSuggestions = searchAlertsInSearchSuggestions
        self.engagementBadging = engagementBadging
        self.searchAlertsDisableOldestIfMaximumReached = searchAlertsDisableOldestIfMaximumReached
        self.randomImInterestedMessages = randomImInterestedMessages
        self.imInterestedInProfile = imInterestedInProfile
        self.shareAfterScreenshot = shareAfterScreenshot
        self.affiliationCampaign = affiliationCampaign
        self.imageSizesNotificationCenter = imageSizesNotificationCenter
        self.blockingSignUp = blockingSignUp

        intVariables.append(contentsOf: [dummyUsersInfoProfile,
                                        onboardingIncentivizePosting,
                                        searchAlertsInSearchSuggestions,
                                        engagementBadging,
                                        searchAlertsDisableOldestIfMaximumReached,
                                        randomImInterestedMessages,
                                        imInterestedInProfile,
                                        shareAfterScreenshot,
                                        affiliationCampaign,
                                        imageSizesNotificationCenter,
                                        blockingSignUp])
    }

    static func make() -> RetentionABGroup {
        return RetentionABGroup(dummyUsersInfoProfile: .makeInt(key: Keys.dummyUsersInfoProfile,
                                                                defaultValue: 0,
                                                                groupType: .retention),
                                onboardingIncentivizePosting: .makeInt(key: Keys.onboardingIncentivizePosting,
                                                                       defaultValue: 0,
                                                                       groupType: .retention),
                                searchAlertsInSearchSuggestions: .makeInt(key: Keys.searchAlertsInSearchSuggestions,
                                                                          defaultValue: 0,
                                                                          groupType: .retention),
                                engagementBadging: .makeInt(key: Keys.engagementBadging,
                                                            defaultValue: 0,
                                                            groupType: .retention),
                                searchAlertsDisableOldestIfMaximumReached: .makeInt(key: Keys.searchAlertsDisableOldestIfMaximumReached,
                                                                                    defaultValue: 0,
                                                                                    groupType: .retention),
                                randomImInterestedMessages: .makeInt(key: Keys.randomImInterestedMessages,
                                                                     defaultValue: 0,
                                                                     groupType: .retention),
                                imInterestedInProfile: .makeInt(key: Keys.imInterestedInProfile,
                                                                defaultValue: 0,
                                                                groupType: .retention),
                                shareAfterScreenshot: .makeInt(key: Keys.shareAfterScreenshot,
                                                               defaultValue: 0,
                                                               groupType: .retention),
                                affiliationCampaign: .makeInt(key: Keys.affiliationCampaign,
                                                              defaultValue: 0,
                                                              groupType: .retention),
                                imageSizesNotificationCenter: .makeInt(key: Keys.imageSizesNotificationCenter,
                                                                       defaultValue: 0,
                                                                       groupType: .retention),
                                blockingSignUp: .makeInt(key: Keys.blockingSignUp,
                                                         defaultValue: 0,
                                                         groupType: .retention))
    }
}
