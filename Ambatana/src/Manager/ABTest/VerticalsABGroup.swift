//
//  RealEstateABGroup.swift
//  LetGo
//
//  Created by Facundo Menzella on 29/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

struct VerticalsABGroup: ABGroupType {

    let searchCarsIntoNewBackend: LeanplumABVariable<Int>
    let realEstatePromoCell: LeanplumABVariable<Int>
    let filterSearchCarSellerType: LeanplumABVariable<Int>

    let group: ABGroup = .verticals
    var intVariables: [LeanplumABVariable<Int>] = []
    var stringVariables: [LeanplumABVariable<String>] = []
    var floatVariables: [LeanplumABVariable<Float>] = []
    var boolVariables: [LeanplumABVariable<Bool>] = []

    private init(searchCarsIntoNewBackend: LeanplumABVariable<Int>,
         realEstatePromoCell: LeanplumABVariable<Int>,
         filterSearchCarSellerType: LeanplumABVariable<Int>) {
        self.searchCarsIntoNewBackend = searchCarsIntoNewBackend
        self.realEstatePromoCell = realEstatePromoCell
        self.filterSearchCarSellerType = filterSearchCarSellerType

        intVariables.append(contentsOf: [searchCarsIntoNewBackend, realEstatePromoCell, filterSearchCarSellerType])
    }

    static func make() -> VerticalsABGroup {
        return VerticalsABGroup(searchCarsIntoNewBackend: .makeInt(key: Keys.searchCarsIntoNewBackend,
                                                             defaultValue: 0,
                                                             groupType: .verticals),
                                realEstatePromoCell: .makeInt(key: Keys.realEstatePromoCell, defaultValue: 0, groupType: .verticals),
                                filterSearchCarSellerType: .makeInt(key: Keys.filterSearchCarSellerType,
                                                                    defaultValue: 0,
                                                                    groupType: .verticals))
    }
}

private struct Keys {
    static let searchCarsIntoNewBackend = "20180403searchCarsIntoNewBackend"
    static let realEstatePromoCell = "20180410realEstatePromoCell"
    static let filterSearchCarSellerType = "20180412filterSearchCarSellerType"
}
