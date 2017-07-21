//
//  FeatureFlagsHelpers.swift
//  LetGo
//
//  Created by Juan Iglesias on 21/07/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation

extension AddSuperKeywordsOnFeed {

    var isActive: Bool {
        switch self {
        case .control, .baseline:
            return false
        case .active:
            return true
        }
    }
}
