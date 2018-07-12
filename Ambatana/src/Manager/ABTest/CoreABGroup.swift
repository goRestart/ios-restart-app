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
        static let searchImprovements = "20180313SearchImprovements"
        static let addPriceTitleDistanceToListings = "20180319AddPriceTitleDistanceToListings"
        static let relaxedSearch = "20180319RelaxedSearch"
        static let emptyStateErrorResearchActive = "20180710EmptyStateErrorResearchActive"
    }

    let searchImprovements: LeanplumABVariable<Int>
    let addPriceTitleDistanceToListings: LeanplumABVariable<Int>
    let relaxedSearch: LeanplumABVariable<Int>
    let emptyStateErrorResearchActive: LeanplumABVariable<Bool>

    let group: ABGroup = .retention
    var intVariables: [LeanplumABVariable<Int>] = []
    var stringVariables: [LeanplumABVariable<String>] = []
    var floatVariables: [LeanplumABVariable<Float>] = []
    var boolVariables: [LeanplumABVariable<Bool>] = []
    
    init(searchImprovements: LeanplumABVariable<Int>,
         addPriceTitleDistanceToListings: LeanplumABVariable<Int>,
         relaxedSearch: LeanplumABVariable<Int>,
         emptyStateErrorResearchActive: LeanplumABVariable<Bool>
         ) {
        self.searchImprovements = searchImprovements
        self.addPriceTitleDistanceToListings = addPriceTitleDistanceToListings
        self.relaxedSearch = relaxedSearch
        self.emptyStateErrorResearchActive = emptyStateErrorResearchActive
        intVariables.append(contentsOf: [searchImprovements,
                                         addPriceTitleDistanceToListings,
                                         relaxedSearch
                                         ])
        boolVariables.append(contentsOf: [emptyStateErrorResearchActive])
    }
    
    static func make() -> CoreABGroup {
        return CoreABGroup(searchImprovements: .makeInt(key: Keys.searchImprovements,
                                                        defaultValue: 0,
                                                        groupType: .core),
                           addPriceTitleDistanceToListings: .makeInt(key: Keys.addPriceTitleDistanceToListings,
                                                                     defaultValue: 0,
                                                                     groupType: .core),
                           relaxedSearch: .makeInt(key: Keys.relaxedSearch,
                                                   defaultValue: 0,
                                                   groupType: .core),
                           emptyStateErrorResearchActive: .makeBool(key: Keys.emptyStateErrorResearchActive,
                                                                    defaultValue: false,
                                                                    groupType: .core)
        )
    }
}
