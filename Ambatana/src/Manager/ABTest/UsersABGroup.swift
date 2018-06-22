//
//  UsersABGroup.swift
//  LetGo
//
//  Created by Facundo Menzella on 05/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

struct UsersABGroup: ABGroupType {
    private struct Keys {
        static let advancedReputationSystem = "20180621AdvancedReputationSystem"
        static let showPasswordlessLogin = "20180417ShowPasswordlessLogin"
        static let emergencyLocate = "20180425EmergencyLocate"
        static let offensiveReportAlert = "20180525OffensiveReportAlert"
    }
    let advancedReputationSystem: LeanplumABVariable<Int>
    let showPasswordlessLogin: LeanplumABVariable<Int>
    let emergencyLocate: LeanplumABVariable<Int>
    let offensiveReportAlert: LeanplumABVariable<Int>

    let group: ABGroup = .users
    var intVariables: [LeanplumABVariable<Int>] = []
    var stringVariables: [LeanplumABVariable<String>] = []
    var floatVariables: [LeanplumABVariable<Float>] = []
    var boolVariables: [LeanplumABVariable<Bool>] = []

    init(advancedReputationSystem: LeanplumABVariable<Int>,
         showPasswordlessLogin: LeanplumABVariable<Int>,
         emergencyLocate: LeanplumABVariable<Int>,
         offensiveReportAlert: LeanplumABVariable<Int>) {
        self.advancedReputationSystem = advancedReputationSystem
        self.showPasswordlessLogin = showPasswordlessLogin
        self.emergencyLocate = emergencyLocate
        self.offensiveReportAlert = offensiveReportAlert
        intVariables.append(contentsOf: [advancedReputationSystem,
                                         showPasswordlessLogin,
                                         emergencyLocate,
                                         offensiveReportAlert])
    }

    static func make() -> UsersABGroup {
        return UsersABGroup(advancedReputationSystem: .makeInt(key: Keys.advancedReputationSystem,
                                                               defaultValue: 0,
                                                               groupType: .users),
                            showPasswordlessLogin: .makeInt(key: Keys.showPasswordlessLogin,
                                                            defaultValue: 0,
                                                            groupType: .users),
                            emergencyLocate: .makeInt(key: Keys.emergencyLocate,
                                                      defaultValue: 0,
                                                      groupType: .users),
                            offensiveReportAlert: .makeInt(key: Keys.offensiveReportAlert,
                                                           defaultValue: 0,
                                                           groupType: .users)
        )
    }
}
