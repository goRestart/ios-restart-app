//
//  ABGroupType+AnalyticsABTestGroupIdentifier.swift
//  LetGo
//
//  Created by Albert Hernández López on 16/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGComponents

extension ABGroup {
    var analyticsGroupIdentifier: AnalyticsABTestGroupIdentifier {
        switch self {
        case .legacyABTests:
            return .legacy
        case .core:
            return .core
        case .verticals:
            return .verticals
        case .realEstate:
            return .realEstate
        case .money:
            return .money
        case .retention:
            return .retention
        case .chat:
            return .chat
        case .products:
            return .products
        case .users:
            return .users
        case .discovery:
            return .discovery
        }
    }
}
