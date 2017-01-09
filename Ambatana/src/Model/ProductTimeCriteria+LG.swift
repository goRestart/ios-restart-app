//
//  ProductTimeCriteria+LG.swift
//  LetGo
//
//  Created by Eli Kohen on 23/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit

extension ProductTimeCriteria {
    static var defaultOption : ProductTimeCriteria {
        return .all
    }
    
    var name : String {
        switch(self) {
        case .day:
            return LGLocalizedString.filtersWithinDay
        case .week:
            return LGLocalizedString.filtersWithinWeek
        case .month:
            return LGLocalizedString.filtersWithinMonth
        case .all:
            return LGLocalizedString.filtersWithinAll
        }
    }
    
    static func allValues() -> [ProductTimeCriteria] { return [.day, .week, .month, .Aall] }

}
