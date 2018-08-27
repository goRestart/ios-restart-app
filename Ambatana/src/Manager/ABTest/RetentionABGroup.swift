//
//  ABRetention.swift
//  LetGo
//
//  Created by Facundo Menzella on 29/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

struct RetentionABGroup: ABGroupType {
    private struct Keys {
        static let dummyUsersInfoProfile = "20180130DummyUsersInfoProfile"
        static let onboardingIncentivizePosting = "20180215OnboardingIncentivizePosting"
        static let notificationSettings = "20180608NotificationSettings"
        static let searchAlertsInSearchSuggestions = "20180710SearchAlertsInSearchSuggestions"
        static let engagementBadging = "20180613EngagementBadging"
        static let searchAlertsDisableOldestIfMaximumReached = "201807SearchAlertsDisableOldestIfMaximumReached"
        static let notificationCenterRedesign = "20180731NotificationCenterRedesign"
        static let randomImInterestedMessages = "20180817RandomImInterestedMessages"
    }
    let dummyUsersInfoProfile: LeanplumABVariable<Int>
    let onboardingIncentivizePosting: LeanplumABVariable<Int>
    let notificationSettings: LeanplumABVariable<Int>
    let searchAlertsInSearchSuggestions: LeanplumABVariable<Int>
    let engagementBadging: LeanplumABVariable<Int>
    let searchAlertsDisableOldestIfMaximumReached: LeanplumABVariable<Int>
    let notificationCenterRedesign: LeanplumABVariable<Int>
    let randomImInterestedMessages: LeanplumABVariable<Int>
    
    let group: ABGroup = .retention
    var intVariables: [LeanplumABVariable<Int>] = []
    var stringVariables: [LeanplumABVariable<String>] = []
    var floatVariables: [LeanplumABVariable<Float>] = []
    var boolVariables: [LeanplumABVariable<Bool>] = []

    init(dummyUsersInfoProfile: LeanplumABVariable<Int>,
         onboardingIncentivizePosting: LeanplumABVariable<Int>,
         notificationSettings: LeanplumABVariable<Int>,
         searchAlertsInSearchSuggestions: LeanplumABVariable<Int>,
         engagementBadging: LeanplumABVariable<Int>,
         searchAlertsDisableOldestIfMaximumReached: LeanplumABVariable<Int>,
         notificationCenterRedesign: LeanplumABVariable<Int>,
         randomImInterestedMessages: LeanplumABVariable<Int>) {
        self.dummyUsersInfoProfile = dummyUsersInfoProfile
        self.onboardingIncentivizePosting = onboardingIncentivizePosting
        self.notificationSettings = notificationSettings
        self.searchAlertsInSearchSuggestions = searchAlertsInSearchSuggestions
        self.engagementBadging = engagementBadging
        self.searchAlertsDisableOldestIfMaximumReached = searchAlertsDisableOldestIfMaximumReached
        self.notificationCenterRedesign = notificationCenterRedesign
        self.randomImInterestedMessages = randomImInterestedMessages

        intVariables.append(contentsOf: [dummyUsersInfoProfile,
                                        onboardingIncentivizePosting,
                                        notificationSettings,
                                        searchAlertsInSearchSuggestions,
                                        engagementBadging,
                                        searchAlertsDisableOldestIfMaximumReached,
                                        notificationCenterRedesign,
                                        randomImInterestedMessages])
    }

    static func make() -> RetentionABGroup {
        return RetentionABGroup(dummyUsersInfoProfile: .makeInt(key: Keys.dummyUsersInfoProfile,
                                                                defaultValue: 0,
                                                                groupType: .retention),
                                onboardingIncentivizePosting: .makeInt(key: Keys.onboardingIncentivizePosting,
                                                                       defaultValue: 0,
                                                                       groupType: .retention),
                                notificationSettings: .makeInt(key: Keys.notificationSettings,
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
                                notificationCenterRedesign: .makeInt(key: Keys.notificationCenterRedesign,
                                                                     defaultValue: 0,
                                                                     groupType: .retention),
                                randomImInterestedMessages: .makeInt(key: Keys.randomImInterestedMessages,
                                                                     defaultValue: 0,
                                                                     groupType: .retention))
    }
}
