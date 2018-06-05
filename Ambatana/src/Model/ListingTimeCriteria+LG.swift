import LGCoreKit
import LGComponents

extension ListingTimeCriteria {
    static var defaultOption : ListingTimeCriteria {
        return .all
    }
    
    var name : String {
        switch(self) {
        case .day:
            return R.Strings.filtersWithinDay
        case .week:
            return R.Strings.filtersWithinWeek
        case .month:
            return R.Strings.filtersWithinMonth
        case .all:
            return R.Strings.filtersWithinAll
        }
    }
    
    static func allValues() -> [ListingTimeCriteria] { return [.day, .week, .month, .all] }

    var trackValue: EventParameterPostedWithin {
        switch self {
        case .day:
            return .day
        case .week:
            return .week
        case .month:
            return .month
        case .all:
            return .all
        }
    }
    
}
