import LGComponents
import LGCoreKit

struct SizeRange: Equatable {
    let min: Int?
    let max: Int?
}

func ==(lhs: SizeRange, rhs: SizeRange) -> Bool {
    return lhs.min == rhs.min && lhs.max == rhs.max
}

enum FilterPriceRange: Equatable {
    case freePrice
    case priceRange(min: Int?, max: Int?)

    var min: Int? {
        switch self {
        case .freePrice:
            return nil
        case let .priceRange(min: minPrice, max: _):
            return minPrice
        }
    }

    var max: Int? {
        switch self {
        case .freePrice:
            return nil
        case let .priceRange(min: _, max: maxPrice):
            return maxPrice
        }
    }

    var free: Bool {
        switch self {
        case .freePrice:
            return true
        case .priceRange:
            return false
        }
    }
}

func ==(a: FilterPriceRange, b: FilterPriceRange) -> Bool {
    switch (a, b) {
    case (let .priceRange(minA, maxA), let .priceRange(minB, maxB)) where minA == minB && maxA == maxB : return true
    case (.freePrice, .freePrice): return true
    default: return false
    }
}

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

    var carSellerTypes: [UserType]
    var carMakeId: String?
    var carMakeName: String?
    var carModelId: String?
    var carModelName: String?
    var carYearStart: Int?
    var carYearEnd: Int?
    var carBodyTypes: [CarBodyType]
    var carDriveTrainTypes: [CarDriveTrainType]
    var carFuelTypes: [CarFuelType]
    var carTransmissionTypes: [CarTransmissionType]
    var carMileageStart: Int?
    var carMileageEnd: Int?
    var carNumberOfSeatsStart: Int?
    var carNumberOfSeatsEnd: Int?
    var carMileageType: String? {
        guard carMileageStart != nil || carMileageEnd != nil else {
            return nil
        }
        
        return DistanceType.systemDistanceType().rawValue
    }
    
    var realEstatePropertyType: RealEstatePropertyType?
    var realEstateOfferTypes: [RealEstateOfferType]
    var realEstateNumberOfBedrooms: NumberOfBedrooms?
    var realEstateNumberOfBathrooms: NumberOfBathrooms?
    var realEstateNumberOfRooms: NumberOfRooms?
    var realEstateSizeRange: SizeRange
    
    var servicesType: ServiceType?
    var servicesSubtypes: [ServiceSubtype]?
    
    var noFilterCategoryApplied: Bool {
        return selectedCategories.isEmpty
    }

    init() {
        self.init(
            place: nil,
            distanceRadius: SharedConstants.distanceSliderDefaultPosition,
            distanceType: DistanceType.systemDistanceType(),
            selectedCategories: [],
            selectedTaxonomyChildren: [],
            selectedTaxonomy: nil,
            selectedWithin: ListingTimeCriteria.defaultOption,
            selectedOrdering: ListingSortCriteria.defaultOption,
            priceRange: .priceRange(min: nil, max: nil),
            carSellerTypes: [],
            carMakeId: nil,
            carMakeName: nil,
            carModelId: nil,
            carModelName: nil,
            carYearStart: nil,
            carYearEnd: nil,
            carBodyTypes: [],
            carFuelTypes: [],
            carTransmissionTypes: [],
            carDriveTrainTypes: [],
            carMileageStart: nil,
            carMileageEnd: nil,
            carNumberOfSeatsStart: nil,
            carNumberOfSeatsEnd: nil,
            realEstatePropertyType: nil,
            realEstateOfferType: [],
            realEstateNumberOfBedrooms: nil,
            realEstateNumberOfBathrooms: nil,
            realEstateNumberOfRooms: nil,
            realEstateSizeRange: SizeRange(min: nil, max: nil),
            servicesType: nil,
            servicesSubtypes: nil
        )
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
         carSellerTypes: [UserType],
         carMakeId: String?,
         carMakeName: String?,
         carModelId: String?,
         carModelName: String?,
         carYearStart: Int?,
         carYearEnd: Int?,
         carBodyTypes: [CarBodyType],
         carFuelTypes: [CarFuelType],
         carTransmissionTypes: [CarTransmissionType],
         carDriveTrainTypes: [CarDriveTrainType],
         carMileageStart: Int?,
         carMileageEnd: Int?,
         carNumberOfSeatsStart: Int?,
         carNumberOfSeatsEnd: Int?,
         realEstatePropertyType: RealEstatePropertyType?,
         realEstateOfferType: [RealEstateOfferType],
         realEstateNumberOfBedrooms: NumberOfBedrooms?,
         realEstateNumberOfBathrooms: NumberOfBathrooms?,
         realEstateNumberOfRooms: NumberOfRooms?,
         realEstateSizeRange: SizeRange,
         servicesType: ServiceType?,
         servicesSubtypes: [ServiceSubtype]?) {
        self.place = place
        self.distanceRadius = distanceRadius > 0 ? distanceRadius : nil
        self.distanceType = distanceType
        self.selectedCategories = selectedCategories
        self.selectedTaxonomyChildren = selectedTaxonomyChildren
        self.selectedTaxonomy = selectedTaxonomy
        self.selectedWithin = selectedWithin
        self.selectedOrdering = selectedOrdering
        self.priceRange = priceRange
        self.carSellerTypes = carSellerTypes
        self.carMakeId = carMakeId
        self.carMakeName = carMakeName
        self.carModelId = carModelId
        self.carModelName = carModelName
        self.carYearStart = carYearStart
        self.carYearEnd = carYearEnd
        self.carBodyTypes = carBodyTypes
        self.carFuelTypes = carFuelTypes
        self.carDriveTrainTypes = carDriveTrainTypes
        self.carTransmissionTypes = carTransmissionTypes
        self.carMileageStart = carMileageStart
        self.carMileageEnd = carMileageEnd
        self.carNumberOfSeatsStart = carNumberOfSeatsStart
        self.carNumberOfSeatsEnd = carNumberOfSeatsEnd
        self.realEstatePropertyType = realEstatePropertyType
        self.realEstateOfferTypes = realEstateOfferType
        self.realEstateNumberOfBedrooms = realEstateNumberOfBedrooms
        self.realEstateNumberOfBathrooms = realEstateNumberOfBathrooms
        self.realEstateNumberOfRooms = realEstateNumberOfRooms
        self.realEstateSizeRange = realEstateSizeRange
        self.servicesType = servicesType
        self.servicesSubtypes = servicesSubtypes
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
                              carSellerTypes: carSellerTypes,
                              carMakeId: carMakeId,
                              carMakeName: carMakeName,
                              carModelId: carModelId,
                              carModelName: carModelName,
                              carYearStart: carYearStart,
                              carYearEnd: carYearEnd,
                              carBodyTypes: carBodyTypes,
                              carFuelTypes: carFuelTypes,
                              carTransmissionTypes: carTransmissionTypes,
                              carDriveTrainTypes: carDriveTrainTypes,
                              carMileageStart: carMileageStart,
                              carMileageEnd: carMileageEnd,
                              carNumberOfSeatsStart: carNumberOfSeatsStart,
                              carNumberOfSeatsEnd: carNumberOfSeatsEnd,
                              realEstatePropertyType: realEstatePropertyType,
                              realEstateOfferType: realEstateOfferTypes,
                              realEstateNumberOfBedrooms: realEstateNumberOfBedrooms,
                              realEstateNumberOfBathrooms: realEstateNumberOfBathrooms,
                              realEstateNumberOfRooms: realEstateNumberOfRooms,
                              realEstateSizeRange: realEstateSizeRange,
                              servicesType: servicesType,
                              servicesSubtypes: servicesSubtypes)
    }
    
    func resetingRealEstateAttributes() -> ListingFilters {
        return ListingFilters(place: place,
                              distanceRadius: distanceRadius ?? SharedConstants.distanceSliderDefaultPosition,
                              distanceType: distanceType,
                              selectedCategories: selectedCategories,
                              selectedTaxonomyChildren: selectedTaxonomyChildren,
                              selectedTaxonomy: selectedTaxonomy,
                              selectedWithin: selectedWithin,
                              selectedOrdering: selectedOrdering,
                              priceRange: priceRange,
                              carSellerTypes: carSellerTypes,
                              carMakeId: carMakeId,
                              carMakeName: carMakeName,
                              carModelId: carModelId,
                              carModelName: carModelName,
                              carYearStart: carYearStart,
                              carYearEnd: carYearEnd,
                              carBodyTypes: carBodyTypes,
                              carFuelTypes: carFuelTypes,
                              carTransmissionTypes: carTransmissionTypes,
                              carDriveTrainTypes: carDriveTrainTypes,
                              carMileageStart: carMileageStart,
                              carMileageEnd: carMileageEnd,
                              carNumberOfSeatsStart: carNumberOfSeatsStart,
                              carNumberOfSeatsEnd: carNumberOfSeatsEnd,
                              realEstatePropertyType: nil,
                              realEstateOfferType: [],
                              realEstateNumberOfBedrooms: nil,
                              realEstateNumberOfBathrooms: nil,
                              realEstateNumberOfRooms: nil,
                              realEstateSizeRange: SizeRange(min: nil, max: nil),
                              servicesType: servicesType,
                              servicesSubtypes: servicesSubtypes)
    }
    
    func resetingCarAttributes() -> ListingFilters {
        return ListingFilters(place: place,
                              distanceRadius: distanceRadius ?? SharedConstants.distanceSliderDefaultPosition,
                              distanceType: distanceType,
                              selectedCategories: selectedCategories,
                              selectedTaxonomyChildren: selectedTaxonomyChildren,
                              selectedTaxonomy: selectedTaxonomy,
                              selectedWithin: selectedWithin,
                              selectedOrdering: selectedOrdering,
                              priceRange: priceRange,
                              carSellerTypes: [],
                              carMakeId: nil,
                              carMakeName: nil,
                              carModelId: nil,
                              carModelName: nil,
                              carYearStart: nil,
                              carYearEnd: nil,
                              carBodyTypes: [],
                              carFuelTypes: [],
                              carTransmissionTypes: [],
                              carDriveTrainTypes: [],
                              carMileageStart: nil,
                              carMileageEnd: nil,
                              carNumberOfSeatsStart: nil,
                              carNumberOfSeatsEnd: nil,
                              realEstatePropertyType: realEstatePropertyType,
                              realEstateOfferType: realEstateOfferTypes,
                              realEstateNumberOfBedrooms: realEstateNumberOfBedrooms,
                              realEstateNumberOfBathrooms: realEstateNumberOfBathrooms,
                              realEstateNumberOfRooms: realEstateNumberOfRooms,
                              realEstateSizeRange: realEstateSizeRange,
                              servicesType: servicesType,
                              servicesSubtypes: servicesSubtypes)
    }
    
    func resetingServicesAttributes() -> ListingFilters {
        return ListingFilters(place: place,
                              distanceRadius: distanceRadius ?? SharedConstants.distanceSliderDefaultPosition,
                              distanceType: distanceType,
                              selectedCategories: selectedCategories,
                              selectedTaxonomyChildren: selectedTaxonomyChildren,
                              selectedTaxonomy: selectedTaxonomy,
                              selectedWithin: selectedWithin,
                              selectedOrdering: selectedOrdering,
                              priceRange: priceRange,
                              carSellerTypes: carSellerTypes,
                              carMakeId: carMakeId,
                              carMakeName: carMakeName,
                              carModelId: carModelId,
                              carModelName: carModelName,
                              carYearStart: carYearStart,
                              carYearEnd: carYearEnd,
                              carBodyTypes: carBodyTypes,
                              carFuelTypes: carFuelTypes,
                              carTransmissionTypes: carTransmissionTypes,
                              carDriveTrainTypes: carDriveTrainTypes,
                              carMileageStart: carMileageStart,
                              carMileageEnd: carMileageEnd,
                              carNumberOfSeatsStart: carNumberOfSeatsStart,
                              carNumberOfSeatsEnd: carNumberOfSeatsEnd,
                              realEstatePropertyType: realEstatePropertyType,
                              realEstateOfferType: realEstateOfferTypes,
                              realEstateNumberOfBedrooms: realEstateNumberOfBedrooms,
                              realEstateNumberOfBathrooms: realEstateNumberOfBathrooms,
                              realEstateNumberOfRooms: realEstateNumberOfRooms,
                              realEstateSizeRange: realEstateSizeRange,
                              servicesType: nil,
                              servicesSubtypes: nil)
    }

    mutating func toggleCategory(_ category: ListingCategory) {
        if let categoryIndex = indexForCategory(category) {
            // DESELECT
            selectedCategories.remove(at: categoryIndex)
        } else {
            // SELECT
            selectedCategories = [category]
        }
    }
    
    func hasSelectedCategory(_ category: ListingCategory) -> Bool {
        return indexForCategory(category) != nil
    }
    
    var hasAnyRealEstateAttributes: Bool {
        return checkIfAnyAttributesAreSet(forAttributes: [realEstateOfferTypes, realEstatePropertyType,
                                                          realEstateNumberOfBathrooms, realEstateNumberOfBedrooms, realEstateNumberOfRooms],
                                          initialValue: realEstateSizeRange != SizeRange(min: nil, max: nil))
    }
    
    var hasAnyCarAttributes: Bool {
        return checkIfAnyAttributesAreSet(forAttributes: [carMakeId, carModelId,
                                                          carYearStart, carYearEnd,
                                                          carMileageStart, carMileageEnd,
                                                          carNumberOfSeatsStart, carNumberOfSeatsEnd,
                                                          carBodyTypes, carDriveTrainTypes,
                                                          carFuelTypes, carTransmissionTypes,
                                                          carSellerTypes])
    }
    
    var hasAnyServicesAttributes: Bool {
        return checkIfAnyAttributesAreSet(forAttributes: [servicesType, servicesSubtypes])
    }
    
    func checkIfAnyAttributesAreSet(forAttributes attributes: [Any?],
                                    initialValue: Bool = false) -> Bool {
        return attributes.reduce(initialValue, { (res, next) -> Bool in
            guard let next = next else {
                return res
            }
            
            if let nextArray = next as? [Any] {
                return nextArray.count > 0 ? true : res
            }
            return true
        })
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
        if hasAnyCarAttributes { return false }
        if hasAnyRealEstateAttributes { return false }
        if hasAnyServicesAttributes { return false }
        return true
    }
    
    private func indexForCategory(_ category: ListingCategory) -> Int? {
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
            a.carMakeId == b.carMakeId &&
            a.carModelId == b.carModelId &&
            a.carYearStart == b.carYearStart &&
            a.carYearEnd == b.carYearEnd &&
            a.carBodyTypes == b.carBodyTypes &&
            a.carFuelTypes == b.carFuelTypes &&
            a.carTransmissionTypes == b.carTransmissionTypes &&
            a.carDriveTrainTypes == b.carDriveTrainTypes &&
            a.carMileageStart == b.carMileageStart &&
            a.carMileageEnd == b.carMileageEnd &&
            a.carNumberOfSeatsStart == b.carNumberOfSeatsStart &&
            a.carNumberOfSeatsEnd == b.carNumberOfSeatsEnd &&
            a.realEstatePropertyType == b.realEstatePropertyType &&
            a.realEstateOfferTypes == b.realEstateOfferTypes &&
            a.realEstateNumberOfBedrooms == b.realEstateNumberOfBedrooms &&
            a.realEstateNumberOfBathrooms == b.realEstateNumberOfBathrooms &&
            a.realEstateSizeRange == b.realEstateSizeRange &&
            a.realEstateNumberOfRooms == b.realEstateNumberOfRooms &&
            a.servicesType?.id == b.servicesType?.id &&
            a.servicesSubtypes?.count == b.servicesSubtypes?.count
    }
}
