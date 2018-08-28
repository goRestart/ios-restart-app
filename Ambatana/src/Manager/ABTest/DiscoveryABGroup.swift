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
        static let personalizedFeed = "20180509PersonalizedFeed"
        static let emptySearchImprovements = "20180718EmptySearchImprovementsWithTracking"
        static let sectionedFeed = "20180828SectionedDiscoveryFeed"
    }
    
    let personalizedFeed: LeanplumABVariable<Int>
    let emptySearchImprovements: LeanplumABVariable<Int>
    let sectionedFeed: LeanplumABVariable<Int>
    
    let group: ABGroup = .discovery
    var intVariables: [LeanplumABVariable<Int>] = []
    var stringVariables: [LeanplumABVariable<String>] = []
    var floatVariables: [LeanplumABVariable<Float>] = []
    var boolVariables: [LeanplumABVariable<Bool>] = []
    
    init(personalizedFeed: LeanplumABVariable<Int>,
         emptySearchImprovements: LeanplumABVariable<Int>,
         sectionedFeed: LeanplumABVariable<Int>) {
        self.personalizedFeed = personalizedFeed
        self.emptySearchImprovements = emptySearchImprovements
        self.sectionedFeed = sectionedFeed
        intVariables.append(contentsOf: [personalizedFeed,
                                         emptySearchImprovements,
                                         sectionedFeed])
    }
    
    static func make() -> DiscoveryABGroup {
        return DiscoveryABGroup(personalizedFeed: .makeInt(key: Keys.personalizedFeed,
                                                           defaultValue: 0,
                                                           groupType: .discovery),
                                emptySearchImprovements: .makeInt(key: Keys.emptySearchImprovements,
                                                       defaultValue: 0,
                                                       groupType: .discovery),
                                sectionedFeed: .makeInt(key: Keys.sectionedFeed,
                                                        defaultValue: 0,
                                                        groupType: .discovery)
        )
    }
}
