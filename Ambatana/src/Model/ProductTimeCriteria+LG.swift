//
//  ListingTimeCriteria+LG.swift
//  LetGo
//
//  Created by Eli Kohen on 23/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit

extension ListingTimeCriteria {
    static var defaultOption : ListingTimeCriteria {
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
    
    static func allValues() -> [ListingTimeCriteria] { return [.day, .week, .month, .all] }

}
