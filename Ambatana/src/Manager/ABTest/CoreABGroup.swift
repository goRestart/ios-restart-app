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
        static let relaxedSearch = "20180319RelaxedSearch"
        static let cachedFeed = "20180809CachedFeed"

    }
    let searchImprovements: LeanplumABVariable<Int>
    let relaxedSearch: LeanplumABVariable<Int>
    let cachedFeed: LeanplumABVariable<Int>

    let group: ABGroup = .retention
    var intVariables: [LeanplumABVariable<Int>] = []
    var stringVariables: [LeanplumABVariable<String>] = []
    var floatVariables: [LeanplumABVariable<Float>] = []
    var boolVariables: [LeanplumABVariable<Bool>] = []
    
    init(searchImprovements: LeanplumABVariable<Int>,
         relaxedSearch: LeanplumABVariable<Int>,
         cachedFeed: LeanplumABVariable<Int>) {
        self.searchImprovements = searchImprovements
        self.relaxedSearch = relaxedSearch
        self.cachedFeed = cachedFeed
        intVariables.append(contentsOf: [searchImprovements,
                                         relaxedSearch,
                                         cachedFeed])
    }
    
    static func make() -> CoreABGroup {
        return CoreABGroup(searchImprovements: .makeInt(key: Keys.searchImprovements,
                                                        defaultValue: 0,
                                                        groupType: .core),
                           relaxedSearch: .makeInt(key: Keys.relaxedSearch,
                                                   defaultValue: 0,
                                                   groupType: .core),
                           cachedFeed: .makeInt(key: Keys.cachedFeed,
                                                defaultValue: 0,
                                                groupType: .core))
    }
}
