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
        static let iAmInterestedInFeed = "20180425iAmInterestedInFeed"
        static let highlightedIAmInterestedInFeed = "20180531HighlightedIAmInterestedInFeed"
        static let notificationSettings = "20180608NotificationSettings"
    }
    let dummyUsersInfoProfile: LeanplumABVariable<Int>
    let onboardingIncentivizePosting: LeanplumABVariable<Int>
    let iAmInterestedInFeed: LeanplumABVariable<Int>
    let highlightedIAmInterestedInFeed: LeanplumABVariable<Int>
    let notificationSettings: LeanplumABVariable<Int>
    
    let group: ABGroup = .retention
    var intVariables: [LeanplumABVariable<Int>] = []
    var stringVariables: [LeanplumABVariable<String>] = []
    var floatVariables: [LeanplumABVariable<Float>] = []
    var boolVariables: [LeanplumABVariable<Bool>] = []

    init(dummyUsersInfoProfile: LeanplumABVariable<Int>,
         onboardingIncentivizePosting: LeanplumABVariable<Int>,
         iAmInterestedInFeed: LeanplumABVariable<Int>,
         highlightedIAmInterestedInFeed: LeanplumABVariable<Int>,
         notificationSettings: LeanplumABVariable<Int>) {
        self.dummyUsersInfoProfile = dummyUsersInfoProfile
        self.onboardingIncentivizePosting = onboardingIncentivizePosting
        self.iAmInterestedInFeed = iAmInterestedInFeed
        self.highlightedIAmInterestedInFeed = highlightedIAmInterestedInFeed
        self.notificationSettings = notificationSettings

        intVariables.append(contentsOf: [dummyUsersInfoProfile,
                                        onboardingIncentivizePosting,
                                        iAmInterestedInFeed,
                                        highlightedIAmInterestedInFeed,
                                        notificationSettings])
    }

    static func make() -> RetentionABGroup {
        return RetentionABGroup(dummyUsersInfoProfile: .makeInt(key: Keys.dummyUsersInfoProfile,
                                                                defaultValue: 0,
                                                                groupType: .retention),
                                onboardingIncentivizePosting: .makeInt(key: Keys.onboardingIncentivizePosting,
                                                                       defaultValue: 0,
                                                                       groupType: .retention),
                                iAmInterestedInFeed: .makeInt(key: Keys.iAmInterestedInFeed,
                                                              defaultValue: 0,
                                                              groupType: .retention),
                                highlightedIAmInterestedInFeed: .makeInt(key: Keys.highlightedIAmInterestedInFeed,
                                                              defaultValue: 0,
                                                              groupType: .retention),
                                notificationSettings: .makeInt(key: Keys.notificationSettings,
                                                               defaultValue: 0,
                                                               groupType: .retention))
    }
}
