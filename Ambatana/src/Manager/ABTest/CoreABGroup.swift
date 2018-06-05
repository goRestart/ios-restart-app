//
//  ABCore.swift
//  LetGo
//
//  Created by Facundo Menzella on 29/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

struct CoreABGroup: ABGroupType {
    private struct Keys {
        static let discardedProducts = "20180219DiscardedProducts"
        static let searchImprovements = "20180313SearchImprovements"
        static let machineLearningMVP = "20180312MachineLearningMVP"
        static let addPriceTitleDistanceToListings = "20180319AddPriceTitleDistanceToListings"
        static let relaxedSearch = "20180319RelaxedSearch"
    }
    
    let discardedProducts: LeanplumABVariable<Int>
    let searchImprovements: LeanplumABVariable<Int>
    let machineLearningMVP: LeanplumABVariable<Int>
    let addPriceTitleDistanceToListings: LeanplumABVariable<Int>
    let relaxedSearch: LeanplumABVariable<Int>

    let group: ABGroup = .retention
    var intVariables: [LeanplumABVariable<Int>] = []
    var stringVariables: [LeanplumABVariable<String>] = []
    var floatVariables: [LeanplumABVariable<Float>] = []
    var boolVariables: [LeanplumABVariable<Bool>] = []
    
    init(discardedProducts: LeanplumABVariable<Int>,
         searchImprovements: LeanplumABVariable<Int>,
         machineLearningMVP: LeanplumABVariable<Int>,
         addPriceTitleDistanceToListings: LeanplumABVariable<Int>,
         relaxedSearch: LeanplumABVariable<Int>) {
        self.discardedProducts = discardedProducts
        self.searchImprovements = searchImprovements
        self.machineLearningMVP = machineLearningMVP
        self.addPriceTitleDistanceToListings = addPriceTitleDistanceToListings
        self.relaxedSearch = relaxedSearch
        intVariables.append(contentsOf: [discardedProducts,
                                         searchImprovements,
                                         machineLearningMVP,
                                         addPriceTitleDistanceToListings,
                                         relaxedSearch])
    }
    
    static func make() -> CoreABGroup {
        return CoreABGroup(discardedProducts: .makeInt(key: Keys.discardedProducts,
                                                       defaultValue: 0,
                                                       groupType: .core),
                           searchImprovements: .makeInt(key: Keys.searchImprovements,
                                                        defaultValue: 0,
                                                        groupType: .core),
                           machineLearningMVP: .makeInt(key: Keys.machineLearningMVP,
                                                        defaultValue: 0,
                                                        groupType: .core),
                           addPriceTitleDistanceToListings: .makeInt(key: Keys.addPriceTitleDistanceToListings,
                                                                     defaultValue: 0,
                                                                     groupType: .core),
                           relaxedSearch: .makeInt(key: Keys.relaxedSearch,
                                                   defaultValue: 0,
                                                   groupType: .core))
    }
}
