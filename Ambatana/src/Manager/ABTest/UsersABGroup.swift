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
        static let showPasswordlessLogin = "20180417ShowPasswordlessLogin"
        static let emergencyLocate = "20180425EmergencyLocate"
        static let offensiveReportAlert = "20180525OffensiveReportAlert"
        static let reportingFostaSesta = "20180627ReportingFostaSesta"
        static let community = "20180907Community"
        static let advancedReputationSystem11 = "20180828AdvancedReputationSystem11"
        static let advancedReputationSystem12 = "20180910AdvancedReputationSystem12"
    }

    let showPasswordlessLogin: LeanplumABVariable<Int>
    let emergencyLocate: LeanplumABVariable<Int>
    let offensiveReportAlert: LeanplumABVariable<Int>
    let reportingFostaSesta: LeanplumABVariable<Int>
    let community: LeanplumABVariable<Int>
    let advancedReputationSystem11: LeanplumABVariable<Int>
    let advancedReputationSystem12: LeanplumABVariable<Int>

    let group: ABGroup = .users
    var intVariables: [LeanplumABVariable<Int>] = []
    var stringVariables: [LeanplumABVariable<String>] = []
    var floatVariables: [LeanplumABVariable<Float>] = []
    var boolVariables: [LeanplumABVariable<Bool>] = []

    init(showPasswordlessLogin: LeanplumABVariable<Int>,
         emergencyLocate: LeanplumABVariable<Int>,
         offensiveReportAlert: LeanplumABVariable<Int>,
         reportingFostaSesta: LeanplumABVariable<Int>,
         community: LeanplumABVariable<Int>,
         advancedReputationSystem11: LeanplumABVariable<Int>,
         advancedReputationSystem12: LeanplumABVariable<Int>) {
        self.showPasswordlessLogin = showPasswordlessLogin
        self.emergencyLocate = emergencyLocate
        self.offensiveReportAlert = offensiveReportAlert
        self.reportingFostaSesta = reportingFostaSesta
        self.community = community
        self.advancedReputationSystem11 = advancedReputationSystem11
        self.advancedReputationSystem12 = advancedReputationSystem12
        intVariables.append(contentsOf: [showPasswordlessLogin,
                                         emergencyLocate,
                                         offensiveReportAlert,
                                         reportingFostaSesta,
                                         community,
                                         advancedReputationSystem11,
                                         advancedReputationSystem12])
    }

    static func make() -> UsersABGroup {
        return UsersABGroup(showPasswordlessLogin: .makeInt(key: Keys.showPasswordlessLogin,
                                                            defaultValue: 0,
                                                            groupType: .users),
                            emergencyLocate: .makeInt(key: Keys.emergencyLocate,
                                                      defaultValue: 0,
                                                      groupType: .users),
                            offensiveReportAlert: .makeInt(key: Keys.offensiveReportAlert,
                                                           defaultValue: 0,
                                                           groupType: .users),
                            reportingFostaSesta: .makeInt(key: Keys.reportingFostaSesta,
                                                          defaultValue: 0,
                                                          groupType: .users),
                            community: .makeInt(key: Keys.community,
                                                defaultValue: 0,
                                                groupType: .users),
                            advancedReputationSystem11: .makeInt(key: Keys.advancedReputationSystem11,
                                                                 defaultValue: 0,
                                                                 groupType: .users),
                            advancedReputationSystem12: .makeInt(key: Keys.advancedReputationSystem12,
                                                                 defaultValue: 0,
                                                                 groupType: .users)
        )
    }
}
