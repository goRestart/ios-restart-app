//
//  DiscoveryABGroup.swift
//  LetGo
//
//  Created by Facundo Menzella on 11/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

struct DiscoveryABGroup: ABGroupType {
    private struct Keys {
        static let sectionedMainFeed = "20180411SectionedMainFeed"
        static let personalizedFeed = "20180509PersonalizedFeed"
        static let searchBoxImprovements = "20180511SearchBoxImprovements"
    }
    
    let sectionedMainFeed: LeanplumABVariable<Int>
    let personalizedFeed: LeanplumABVariable<Int>
    let searchBoxImprovements: LeanplumABVariable<Int>
    let group: ABGroup = .discovery
    var intVariables: [LeanplumABVariable<Int>] = []
    var stringVariables: [LeanplumABVariable<String>] = []
    var floatVariables: [LeanplumABVariable<Float>] = []
    var boolVariables: [LeanplumABVariable<Bool>] = []
    
    init(personalizedFeed: LeanplumABVariable<Int>,
         searchBoxImprovements: LeanplumABVariable<Int>,
         sectionedMainFeed: LeanplumABVariable<Int>) {
        self.personalizedFeed = personalizedFeed
        self.searchBoxImprovements = searchBoxImprovements
        intVariables.append(contentsOf: [personalizedFeed, searchBoxImprovements])
        
        self.sectionedMainFeed = sectionedMainFeed
        intVariables.append(contentsOf: [sectionedMainFeed])
    }

    static func make() -> DiscoveryABGroup {
        return DiscoveryABGroup(personalizedFeed: .makeInt(key: Keys.personalizedFeed,
                                                           defaultValue: 0,
                                                           groupType: .discovery),
                                searchBoxImprovements: .makeInt(key: Keys.searchBoxImprovements,
                                                                defaultValue: 0,
                                                                groupType: .discovery),
                                sectionedMainFeed: .makeInt(key: Keys.sectionedMainFeed,
                                                            defaultValue: 0, groupType: .discovery))
    }
}
