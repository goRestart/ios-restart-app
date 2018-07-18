
import LGCoreKit

struct RealEstateFilters: VerticalFilterType {
    
    var propertyType: RealEstatePropertyType?
    var offerTypes: [RealEstateOfferType]
    var numberOfBedrooms: NumberOfBedrooms?
    var numberOfBathrooms: NumberOfBathrooms?
    var numberOfRooms: NumberOfRooms?
    var sizeRange: SizeRange

    var hasAnyAttributesSet: Bool {
        return checkIfAnyAttributesAreSet(forAttributes: [offerTypes, propertyType,
                                                          numberOfBathrooms, numberOfBedrooms, numberOfRooms],
                                          initialValue: sizeRange != SizeRange(min: nil, max: nil))
    }
    
    static func create() -> RealEstateFilters {
        return RealEstateFilters(propertyType: nil,
                                 offerTypes: [],
                                 numberOfBedrooms: nil,
                                 numberOfBathrooms: nil,
                                 numberOfRooms: nil,
                                 sizeRange: SizeRange(min: nil, max: nil))
    }
}


// MARK: Tracking

extension RealEstateFilters {
    
    func createTrackingParams() -> [(EventParameterName, Any?)] {
        let offerTypesString = offerTypes.compactMap { $0.rawValue }.stringCommaSeparated
        
        return [(.offerType, offerTypesString),
                (.propertyType, propertyType?.rawValue),
                (.bedrooms, numberOfBedrooms?.trackingString),
                (.bathrooms, numberOfBathrooms?.trackingString),
                (.rooms, numberOfRooms?.trackingString),
                (.sizeSqrMetersMin, realEstateSizeRangeMinTrackingValue()),
                (.sizeSqrMetersMax, realEstateSizeRangeMaxTrackingValue())]
    }
    
    private func realEstateSizeRangeMinTrackingValue() -> String? {
        guard let minSize = sizeRange.min else { return nil }
        return String(minSize)
    }
    
    private func realEstateSizeRangeMaxTrackingValue() -> String? {
        guard let maxSize = sizeRange.max else { return nil }
        return String(maxSize)
    }
}


// MARK: Equatable implementation

extension RealEstateFilters: Equatable {
    
    static func == (lhs: RealEstateFilters, rhs: RealEstateFilters) -> Bool {
        return lhs.propertyType == rhs.propertyType &&
            lhs.offerTypes == rhs.offerTypes &&
            lhs.numberOfBedrooms == rhs.numberOfBedrooms &&
            lhs.numberOfBathrooms == rhs.numberOfBathrooms &&
            lhs.sizeRange == rhs.sizeRange &&
            lhs.numberOfRooms == rhs.numberOfRooms
    }
}
