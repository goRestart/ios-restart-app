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
        static let searchAlerts = "20180418SearchAlerts"
        static let highlightedIAmInterestedInFeed = "20180531HighlightedIAmInterestedInFeed"
    }
    let dummyUsersInfoProfile: LeanplumABVariable<Int>
    let onboardingIncentivizePosting: LeanplumABVariable<Int>
    let iAmInterestedInFeed: LeanplumABVariable<Int>
    let searchAlerts: LeanplumABVariable<Int>
    let highlightedIAmInterestedInFeed: LeanplumABVariable<Int>
    
    let group: ABGroup = .retention
    var intVariables: [LeanplumABVariable<Int>] = []
    var stringVariables: [LeanplumABVariable<String>] = []
    var floatVariables: [LeanplumABVariable<Float>] = []
    var boolVariables: [LeanplumABVariable<Bool>] = []

    init(dummyUsersInfoProfile: LeanplumABVariable<Int>,
         onboardingIncentivizePosting: LeanplumABVariable<Int>,
         iAmInterestedInFeed: LeanplumABVariable<Int>,
         searchAlerts: LeanplumABVariable<Int>,
         highlightedIAmInterestedInFeed: LeanplumABVariable<Int>) {
        self.dummyUsersInfoProfile = dummyUsersInfoProfile
        self.onboardingIncentivizePosting = onboardingIncentivizePosting
        self.iAmInterestedInFeed = iAmInterestedInFeed
        self.searchAlerts = searchAlerts
        self.highlightedIAmInterestedInFeed = highlightedIAmInterestedInFeed

        intVariables.append(contentsOf: [dummyUsersInfoProfile,
                                        onboardingIncentivizePosting,
                                        iAmInterestedInFeed,
                                        searchAlerts,
                                        highlightedIAmInterestedInFeed])
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
                                searchAlerts: .makeInt(key: Keys.searchAlerts,
                                                       defaultValue: 0,
                                                       groupType: .retention),
                                highlightedIAmInterestedInFeed: .makeInt(key: Keys.highlightedIAmInterestedInFeed,
                                                              defaultValue: 0,
                                                              groupType: .retention))
    }
}
