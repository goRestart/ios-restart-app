import LGComponents
import LGCoreKit

struct ListingFilters {
    
    var place: Place?
    var distanceRadius: Int?
    var distanceType: DistanceType
    var selectedCategories: [ListingCategory]
    var selectedWithin: ListingTimeFilter
    var selectedOrdering: ListingSortCriteria?
    var filterCoordinates: LGLocationCoordinates2D? {
        return place?.location
    }
    var priceRange: FilterPriceRange
    
    var verticalFilters: VerticalFilters
    
    var noFilterCategoryApplied: Bool {
        return selectedCategories.isEmpty
    }
    
    var hasAnyRealEstateAttributes: Bool {
        return verticalFilters.realEstate.hasAnyAttributesSet
    }
    
    var hasAnyServicesAttributes: Bool {
        return verticalFilters.services.hasAnyAttributesSet
    }
    
    var hasAnyCarAttributes: Bool {
        return verticalFilters.cars.hasAnyAttributesSet
    }
    
    var hasOnlyPlace: Bool {
        if let _ = distanceRadius { return false }
        if !selectedCategories.isEmpty { return false }
        if selectedWithin != ListingTimeFilter.defaultOption { return false }
        if selectedOrdering != ListingSortCriteria.defaultOption { return false }
        if priceRange != .priceRange(min: nil, max: nil) { return false }
        if verticalFilters.hasAnyAttributesSet { return false }
        if let _ = place { return true }
        return false
    }

    init() {
        self.init(place: nil,
                  distanceRadius: SharedConstants.distanceSliderDefaultPosition,
                  distanceType: DistanceType.systemDistanceType(),
                  selectedCategories: [],
                  selectedWithin: ListingTimeFilter.defaultOption,
                  selectedOrdering: ListingSortCriteria.defaultOption,
                  priceRange: .priceRange(min: nil, max: nil),
                  verticalFilters: VerticalFilters.create())
    }
    
    init(categoriesString: String?,
         distanceRadiusString: String?,
         sortCriteriaString: String?,
         priceFlagString: String?,
         minPriceString: String?,
         maxPriceString: String?) {
        let categories: [ListingCategory]
        if let categoriesString = categoriesString {
            categories = ListingCategory.categoriesFromString(categoriesString)
        } else {
            categories = []
        }
        
        let distanceRadius: Int
        if let distanceRadiusString = distanceRadiusString, let distanceRadiusInt = Int(distanceRadiusString) {
            distanceRadius = distanceRadiusInt
        } else {
            distanceRadius = SharedConstants.distanceSliderDefaultPosition
        }

        let sortCriteria: ListingSortCriteria?
        if let sortCriteriaString = sortCriteriaString,
            let deepLinkSortCriteria = DeepLinkSortCriteria.init(rawValue: sortCriteriaString) {
            sortCriteria = ListingSortCriteria.init(rawValue: deepLinkSortCriteria.intValue)
        } else {
            sortCriteria = ListingSortCriteria.defaultOption
        }
        
        let priceFlag: FilterPriceRange
        if let priceFlagString = priceFlagString,
            let priceFlagInt = Int(priceFlagString),
            let deepLinkPriceFlag = DeepLinkPriceFlag.init(rawValue: priceFlagInt),
            deepLinkPriceFlag.isFree {
            priceFlag = .freePrice
        } else {
            let minPrice: Int?
            if let minPriceString = minPriceString {
                minPrice = Int(minPriceString)
            } else {
                minPrice = nil
            }
            let maxPrice: Int?
            if let maxPriceString = maxPriceString {
                maxPrice = Int(maxPriceString)
            } else {
                maxPrice = nil
            }
            priceFlag = .priceRange(min: minPrice, max: maxPrice)
        }

        self.init(place: nil,
                  distanceRadius: distanceRadius,
                  distanceType: DistanceType.systemDistanceType(),
                  selectedCategories: categories,
                  selectedWithin: ListingTimeFilter.defaultOption,
                  selectedOrdering: sortCriteria,
                  priceRange: priceFlag,
                  verticalFilters: VerticalFilters.create())
    }
    
    init(place: Place?,
         distanceRadius: Int,
         distanceType: DistanceType,
         selectedCategories: [ListingCategory],
         selectedWithin: ListingTimeFilter,
         selectedOrdering: ListingSortCriteria?,
         priceRange: FilterPriceRange,
         verticalFilters: VerticalFilters) {
        self.place = place
        self.distanceRadius = distanceRadius > 0 ? distanceRadius : nil
        self.distanceType = distanceType
        self.selectedCategories = selectedCategories
        self.selectedWithin = selectedWithin
        self.selectedOrdering = selectedOrdering
        self.priceRange = priceRange
        self.verticalFilters = verticalFilters
    }
    
    func updating(selectedCategories: [ListingCategory]) -> ListingFilters {
        return ListingFilters(place: place,
                              distanceRadius: distanceRadius ?? SharedConstants.distanceSliderDefaultPosition,
                              distanceType: distanceType,
                              selectedCategories: selectedCategories,
                              selectedWithin: selectedWithin,
                              selectedOrdering: selectedOrdering,
                              priceRange: priceRange,
                              verticalFilters: verticalFilters)
    }
    
    func resetVerticalAttributes() -> ListingFilters {
        return ListingFilters(place: place,
                              distanceRadius: distanceRadius ?? SharedConstants.distanceSliderDefaultPosition,
                              distanceType: distanceType,
                              selectedCategories: selectedCategories,
                              selectedWithin: selectedWithin,
                              selectedOrdering: selectedOrdering,
                              priceRange: priceRange,
                              verticalFilters: VerticalFilters.create())
    }
  
    mutating func toggleCategory(_ category: ListingCategory) {
        if let categoryIndex = index(for: category) {
            // DESELECT
            selectedCategories.remove(at: categoryIndex)
        } else {
            // SELECT
            selectedCategories = [category]
        }
    }
    
    func hasSelectedCategory(_ category: ListingCategory) -> Bool {
        return index(for: category) != nil
    }

    func isDefault() -> Bool {
        if let _ = place { return false } //Default is nil
        if let _ = distanceRadius { return false } //Default is nil
        if !selectedCategories.isEmpty { return false }
        if selectedWithin != ListingTimeFilter.defaultOption { return false }
        if selectedOrdering != ListingSortCriteria.defaultOption { return false }
        if priceRange != .priceRange(min: nil, max: nil) { return false }
        if verticalFilters.hasAnyAttributesSet { return false }
        return true
    }
    
    private func index(for category: ListingCategory) -> Int? {
        return selectedCategories.index(where: { $0 == category })
    }
}

extension Place: Equatable {
    public static func == (a: Place, b: Place) -> Bool {
        return a.name == b.name &&
        a.postalAddress == b.postalAddress &&
        a.location == b.location &&
        a.placeResumedData == b.placeResumedData
    }
}

extension ListingFilters: Equatable {
    static func ==(a: ListingFilters, b: ListingFilters) -> Bool {
        return a.place == b.place &&
            a.distanceRadius == b.distanceRadius &&
            a.distanceType == b.distanceType &&
            a.selectedCategories == b.selectedCategories &&
            a.selectedWithin == b.selectedWithin &&
            a.selectedOrdering == b.selectedOrdering &&
            a.filterCoordinates == b.filterCoordinates &&
            a.priceRange == b.priceRange &&
            a.verticalFilters == b.verticalFilters
    }
}
