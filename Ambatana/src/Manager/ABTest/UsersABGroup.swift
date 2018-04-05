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
        static let advancedReputationSystem = "20180328AdvancedReputationSystem"
    }
    let advancedReputationSystem: LeanplumABVariable<Int>

    let group: ABGroup = .users
    var intVariables: [LeanplumABVariable<Int>] = []
    var stringVariables: [LeanplumABVariable<String>] = []
    var floatVariables: [LeanplumABVariable<Float>] = []
    var boolVariables: [LeanplumABVariable<Bool>] = []

    init(advancedReputationSystem: LeanplumABVariable<Int>) {
        self.advancedReputationSystem = advancedReputationSystem
        intVariables.append(contentsOf: [advancedReputationSystem])
    }

    static func make() -> UsersABGroup {
        return UsersABGroup(advancedReputationSystem: .makeInt(key: Keys.advancedReputationSystem,
                                                               defaultValue: 0,
                                                               groupType: .users))
    }
}
