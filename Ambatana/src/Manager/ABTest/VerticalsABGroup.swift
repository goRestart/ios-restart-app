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
    let filterSearchCarSellerType: LeanplumABVariable<Int>
    let realEstateMap: LeanplumABVariable<Int>
    let showServicesFeatures: LeanplumABVariable<Int>
    let carExtraFieldsEnabled: LeanplumABVariable<Int>

    let group: ABGroup = .verticals
    var intVariables: [LeanplumABVariable<Int>] = []
    var stringVariables: [LeanplumABVariable<String>] = []
    var floatVariables: [LeanplumABVariable<Float>] = []
    var boolVariables: [LeanplumABVariable<Bool>] = []

    private init(searchCarsIntoNewBackend: LeanplumABVariable<Int>,
                 filterSearchCarSellerType: LeanplumABVariable<Int>,
                 realEstateMap: LeanplumABVariable<Int>,
                 showServicesFeatures: LeanplumABVariable<Int>,
                 carExtraFieldsEnabled: LeanplumABVariable<Int>) {
        self.searchCarsIntoNewBackend = searchCarsIntoNewBackend
        self.filterSearchCarSellerType = filterSearchCarSellerType
        self.realEstateMap = realEstateMap
        self.showServicesFeatures = showServicesFeatures
        self.carExtraFieldsEnabled = carExtraFieldsEnabled
        
        intVariables.append(contentsOf: [searchCarsIntoNewBackend,
                                         filterSearchCarSellerType,
                                         realEstateMap,
                                         showServicesFeatures,
                                         carExtraFieldsEnabled])
    }
    
    static func make() -> VerticalsABGroup {
        return VerticalsABGroup(searchCarsIntoNewBackend: verticalsIntFor(key: Keys.searchCarsIntoNewBackend),
                                filterSearchCarSellerType: verticalsIntFor(key: Keys.filterSearchCarSellerType),
                                realEstateMap: verticalsIntFor(key: Keys.realEstateMap),
                                showServicesFeatures: verticalsIntFor(key: Keys.showServicesFeatures),
                                carExtraFieldsEnabled: verticalsIntFor(key: Keys.carExtraFieldsEnabled))
    }
    
    private static func verticalsIntFor(key: String) -> LeanplumABVariable<Int> {
        return .makeInt(key: key, defaultValue: 0, groupType: .verticals)
    }
}

private struct Keys {
    static let searchCarsIntoNewBackend = "20180403searchCarsIntoNewBackend"
    static let filterSearchCarSellerType = "20180412filterSearchCarSellerType"
    static let realEstateMap = "20180427realEstateMap"
    static let showServicesFeatures = "20180518showServicesFeatures"
    static let carExtraFieldsEnabled = "20180628carExtraFieldsEnabled"
}
