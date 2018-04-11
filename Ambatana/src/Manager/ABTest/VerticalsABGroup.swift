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
        static let realEstatePromoCell = "20180410realEstatePromoCell"
    }
    let searchCarsIntoNewBackend: LeanplumABVariable<Int>
    let realEstatePromoCell: LeanplumABVariable<Int>

    let group: ABGroup = .verticals
    var intVariables: [LeanplumABVariable<Int>] = []
    var stringVariables: [LeanplumABVariable<String>] = []
    var floatVariables: [LeanplumABVariable<Float>] = []
    var boolVariables: [LeanplumABVariable<Bool>] = []

    init(searchCarsIntoNewBackend: LeanplumABVariable<Int>,
         realEstatePromoCell: LeanplumABVariable<Int>) {
        self.searchCarsIntoNewBackend = searchCarsIntoNewBackend
        self.realEstatePromoCell = realEstatePromoCell

        intVariables.append(contentsOf: [searchCarsIntoNewBackend, realEstatePromoCell])
    }

    static func make() -> VerticalsABGroup {
        return VerticalsABGroup(searchCarsIntoNewBackend: .makeInt(key: Keys.searchCarsIntoNewBackend,
                                                             defaultValue: 0,
                                                             groupType: .verticals),
                                realEstatePromoCell: .makeInt(key: Keys.realEstatePromoCell, defaultValue: 0, groupType: .verticals))
    }
}
