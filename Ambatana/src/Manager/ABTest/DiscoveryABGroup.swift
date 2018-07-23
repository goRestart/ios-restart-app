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
        static let multiContact = "20180515MultiContact"
        static let emptySearchImprovements = "20180718EmptySearchImprovementsWithTracking"
    }
    
    let sectionedMainFeed: LeanplumABVariable<Int>
    let personalizedFeed: LeanplumABVariable<Int>
    let multiContact: LeanplumABVariable<Int>
    let emptySearchImprovements: LeanplumABVariable<Int>
    
    let group: ABGroup = .discovery
    var intVariables: [LeanplumABVariable<Int>] = []
    var stringVariables: [LeanplumABVariable<String>] = []
    var floatVariables: [LeanplumABVariable<Float>] = []
    var boolVariables: [LeanplumABVariable<Bool>] = []
    
    init(sectionedMainFeed: LeanplumABVariable<Int>,
         personalizedFeed: LeanplumABVariable<Int>,
         multiContact: LeanplumABVariable<Int>,
         emptySearchImprovements: LeanplumABVariable<Int>) {
        self.sectionedMainFeed = sectionedMainFeed
        self.personalizedFeed = personalizedFeed
        self.multiContact = multiContact
        self.emptySearchImprovements = emptySearchImprovements
        
        intVariables.append(contentsOf: [sectionedMainFeed,
                                         personalizedFeed,
                                         multiContact,
                                         emptySearchImprovements])
    }

    static func make() -> DiscoveryABGroup {
        return DiscoveryABGroup(sectionedMainFeed: .makeInt(key: Keys.sectionedMainFeed,
                                                            defaultValue: 0,
                                                            groupType: .discovery),
                                personalizedFeed: .makeInt(key: Keys.personalizedFeed,
                                                           defaultValue: 0,
                                                           groupType: .discovery),
                                multiContact: .makeInt(key: Keys.multiContact,
                                                       defaultValue: 0,
                                                       groupType: .discovery),
                                emptySearchImprovements: .makeInt(key: Keys.emptySearchImprovements,
                                                       defaultValue: 0,
                                                       groupType: .discovery))
    }
}
