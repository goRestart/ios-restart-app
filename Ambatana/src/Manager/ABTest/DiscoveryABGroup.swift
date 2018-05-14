//
//  DiscoveryABGroup.swift
//  LetGo
//
//  Created by Haiyan Ma on 08/05/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

struct DiscoveryABGroup: ABGroupType {
    private struct Keys {
        static let personalizedFeed = "20180509PersonalizedFeed"
    }
    let personalizedFeed: LeanplumABVariable<Int>
    
    let group: ABGroup = .discovery
    var intVariables: [LeanplumABVariable<Int>] = []
    var stringVariables: [LeanplumABVariable<String>] = []
    var floatVariables: [LeanplumABVariable<Float>] = []
    var boolVariables: [LeanplumABVariable<Bool>] = []
    
    init(personalizedFeed: LeanplumABVariable<Int>) {
        self.personalizedFeed = personalizedFeed
        intVariables.append(contentsOf: [personalizedFeed])
    }
    
    static func make() -> DiscoveryABGroup {
        return DiscoveryABGroup(personalizedFeed: .makeInt(key: Keys.personalizedFeed,
                                                            defaultValue: 0,
                                                            groupType: .discovery))
    }
}
