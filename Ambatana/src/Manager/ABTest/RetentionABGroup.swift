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
    }
    let dummyUsersInfoProfile: LeanplumABVariable<Int>
    let onboardingIncentivizePosting: LeanplumABVariable<Int>

    let group: ABGroup = .retention
    var intVariables: [LeanplumABVariable<Int>] = []
    var stringVariables: [LeanplumABVariable<String>] = []
    var floatVariables: [LeanplumABVariable<Float>] = []
    var boolVariables: [LeanplumABVariable<Bool>] = []

    init(dummyUsersInfoProfile: LeanplumABVariable<Int>,
         onboardingIncentivizePosting: LeanplumABVariable<Int>) {
        self.dummyUsersInfoProfile = dummyUsersInfoProfile
        self.onboardingIncentivizePosting = onboardingIncentivizePosting

        intVariables.append(contentsOf: [dummyUsersInfoProfile, onboardingIncentivizePosting])
    }

    static func make() -> RetentionABGroup {
        return RetentionABGroup(dummyUsersInfoProfile: .makeInt(key: Keys.dummyUsersInfoProfile,
                                                                defaultValue: 0,
                                                                groupType: .retention),
                                onboardingIncentivizePosting: .makeInt(key: Keys.onboardingIncentivizePosting,
                                                                       defaultValue: 0,
                                                                       groupType: .retention))
    }
}
