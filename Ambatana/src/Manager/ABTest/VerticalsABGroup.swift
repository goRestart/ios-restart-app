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
    let createUpdateIntoNewBackend: LeanplumABVariable<Int>

    let group: ABGroup = .verticals
    var intVariables: [LeanplumABVariable<Int>] = []
    var stringVariables: [LeanplumABVariable<String>] = []
    var floatVariables: [LeanplumABVariable<Float>] = []
    var boolVariables: [LeanplumABVariable<Bool>] = []

    private init(searchCarsIntoNewBackend: LeanplumABVariable<Int>,
         realEstatePromoCell: LeanplumABVariable<Int>,
         filterSearchCarSellerType: LeanplumABVariable<Int>,
         createUpdateIntoNewBackend: LeanplumABVariable<Int>) {
        self.searchCarsIntoNewBackend = searchCarsIntoNewBackend
        self.realEstatePromoCell = realEstatePromoCell
        self.filterSearchCarSellerType = filterSearchCarSellerType
        self.createUpdateIntoNewBackend = createUpdateIntoNewBackend
        intVariables.append(contentsOf: [searchCarsIntoNewBackend,
                                         realEstatePromoCell,
                                         filterSearchCarSellerType,
                                         createUpdateIntoNewBackend])
    }
    
    static func make() -> VerticalsABGroup {
        return VerticalsABGroup(searchCarsIntoNewBackend: verticalsIntFor(key: Keys.searchCarsIntoNewBackend),
                                realEstatePromoCell: verticalsIntFor(key: Keys.realEstatePromoCell),
                                filterSearchCarSellerType: verticalsIntFor(key: Keys.filterSearchCarSellerType),
                                createUpdateIntoNewBackend: verticalsIntFor(key: Keys.createUpdateIntoNewBackend))
    }
    
    private static func verticalsIntFor(key: String) -> LeanplumABVariable<Int> {
        return .makeInt(key: key, defaultValue: 0, groupType: .verticals)
    }
}

private struct Keys {
    static let searchCarsIntoNewBackend = "20180403searchCarsIntoNewBackend"
    static let realEstatePromoCell = "20180410realEstatePromoCell"
    static let filterSearchCarSellerType = "20180412filterSearchCarSellerType"
    static let createUpdateIntoNewBackend = "20180424createUpdateIntoNewBackend"
}
