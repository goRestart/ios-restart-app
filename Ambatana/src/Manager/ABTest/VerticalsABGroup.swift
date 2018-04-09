//
//  RealEstateABGroup.swift
//  LetGo
//
//  Created by Facundo Menzella on 29/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

struct VerticalsABGroup: ABGroupType {
    private struct Keys {
        static let searchCarsIntoNewBackend = "20180403searchCarsIntoNewBackend"
    }
    let searchCarsIntoNewBackend: LeanplumABVariable<Int>

    let group: ABGroup = .verticals
    var intVariables: [LeanplumABVariable<Int>] = []
    var stringVariables: [LeanplumABVariable<String>] = []
    var floatVariables: [LeanplumABVariable<Float>] = []
    var boolVariables: [LeanplumABVariable<Bool>] = []

    init(searchCarsIntoNewBackend: LeanplumABVariable<Int>) {
        self.searchCarsIntoNewBackend = searchCarsIntoNewBackend

        intVariables.append(contentsOf: [searchCarsIntoNewBackend])
    }

    static func make() -> VerticalsABGroup {
        return VerticalsABGroup(searchCarsIntoNewBackend: .makeInt(key: Keys.searchCarsIntoNewBackend,
                                                             defaultValue: 0,
                                                             groupType: .verticals))
    }
}
