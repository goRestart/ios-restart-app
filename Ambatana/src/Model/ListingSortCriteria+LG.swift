import LGCoreKit
import LGComponents

extension ListingSortCriteria {
    static var defaultOption : ListingSortCriteria? {
        return nil
    }
    
    static var allValues: [ListingSortCriteria] {
        return [.creation, .distance, .priceAsc, .priceDesc]
    }
    
    var name : String {
        switch(self) {
        case .distance:
            return R.Strings.filtersSortClosest
        case .creation:
            return R.Strings.filtersSortNewest
        case .priceAsc:
            return R.Strings.filtersSortPriceAsc
        case .priceDesc:
            return R.Strings.filtersSortPriceDesc
        }
    }
    
    var trackValue: EventParameterSortBy {
        switch self {
        case .distance:
            return .distance
        case .creation:
            return .creationDate
        case .priceAsc:
            return .priceAsc
        case .priceDesc:
            return .priceDesc
        }
    }
}
