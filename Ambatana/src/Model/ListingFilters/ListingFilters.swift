import LGComponents
import LGCoreKit

struct ListingFilters {
    
    var place: Place?
    var distanceRadius: Int?
    var distanceType: DistanceType
    var selectedCategories: [ListingCategory]
    var selectedTaxonomyChildren: [TaxonomyChild]
    var selectedTaxonomy: Taxonomy?
    var selectedWithin: ListingTimeCriteria
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

    init() {
        self.init(place: nil,
                  distanceRadius: SharedConstants.distanceSliderDefaultPosition,
                  distanceType: DistanceType.systemDistanceType(),
                  selectedCategories: [],
                  selectedTaxonomyChildren: [],
                  selectedTaxonomy: nil,
                  selectedWithin: ListingTimeCriteria.defaultOption,
                  selectedOrdering: ListingSortCriteria.defaultOption,
                  priceRange: .priceRange(min: nil, max: nil),
                  verticalFilters: VerticalFilters.create())
    }
    
    init(place: Place?,
         distanceRadius: Int,
         distanceType: DistanceType,
         selectedCategories: [ListingCategory],
         selectedTaxonomyChildren: [TaxonomyChild],
         selectedTaxonomy: Taxonomy?,
         selectedWithin: ListingTimeCriteria,
         selectedOrdering: ListingSortCriteria?,
         priceRange: FilterPriceRange,
         verticalFilters: VerticalFilters) {
        self.place = place
        self.distanceRadius = distanceRadius > 0 ? distanceRadius : nil
        self.distanceType = distanceType
        self.selectedCategories = selectedCategories
        self.selectedTaxonomyChildren = selectedTaxonomyChildren
        self.selectedTaxonomy = selectedTaxonomy
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
                              selectedTaxonomyChildren: selectedTaxonomyChildren,
                              selectedTaxonomy: selectedTaxonomy,
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
                              selectedTaxonomyChildren: selectedTaxonomyChildren,
                              selectedTaxonomy: selectedTaxonomy,
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
        if !selectedTaxonomyChildren.isEmpty { return false }
        if let _ = selectedTaxonomy { return false } //Default is nil
        if selectedWithin != ListingTimeCriteria.defaultOption { return false }
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
        guard a.selectedTaxonomyChildren.count == b.selectedTaxonomyChildren.count else { return false }
        for (index, element) in a.selectedTaxonomyChildren.enumerated() {
            guard element == b.selectedTaxonomyChildren[index] else { return false }
        }
        
        return a.place == b.place &&
            a.distanceRadius == b.distanceRadius &&
            a.distanceType == b.distanceType &&
            a.selectedCategories == b.selectedCategories &&
            a.selectedTaxonomy == b.selectedTaxonomy &&
            a.selectedWithin == b.selectedWithin &&
            a.selectedOrdering == b.selectedOrdering &&
            a.filterCoordinates == b.filterCoordinates &&
            a.priceRange == b.priceRange &&
            a.verticalFilters == b.verticalFilters
    }
}
