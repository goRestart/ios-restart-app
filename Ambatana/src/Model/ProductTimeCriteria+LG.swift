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
        return .All
    }
    
    var name : String {
        switch(self) {
        case .Day:
            return LGLocalizedString.filtersWithinDay
        case .Week:
            return LGLocalizedString.filtersWithinWeek
        case .Month:
            return LGLocalizedString.filtersWithinMonth
        case .All:
            return LGLocalizedString.filtersWithinAll
        }
    }
    
    static func allValues() -> [ProductTimeCriteria] { return [.Day, .Week, .Month, .All] }

}
