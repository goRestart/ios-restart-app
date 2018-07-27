import LGCoreKit
import LGComponents

enum ListingTimeFilter: Equatable {
    case day
    case week
    case month
    case all
    
    static var defaultOption : ListingTimeFilter {
        return .all
    }
    
    static var allValues: [ListingTimeFilter] = [.day, .week, .month, .all]

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
    
    var accessibilityId: Int {
        switch self {
        case .day:
            return 1
        case .week:
            return 2
        case .month:
            return 3
        case .all:
            return 4
        }
    }
    
    var listingTimeCriteria: ListingTimeCriteria {
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
