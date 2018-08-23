
import LGCoreKit

struct ServicesFilters: VerticalFilterType {
    
    var type: ServiceType?
    var subtypes: [ServiceSubtype]?
    var listingTypes: [ServiceListingType]
    
    var hasAnyAttributesSet: Bool {
        return checkIfAnyAttributesAreSet(forAttributes: [type, subtypes, listingTypes])
    }

    static func create() -> ServicesFilters {
        return ServicesFilters(type: nil,
                               subtypes: nil,
                               listingTypes: [])
    }
}


// MARK: Tracking

extension ServicesFilters {
    
    func createTrackingParams() -> [(EventParameterName, Any?)] {
        let listingTypesString = listingTypes.compactMap { $0.rawValue }.stringCommaSeparated

        return [(.serviceSubtype, subtypes?.trackingValue),
                (.serviceType, type?.id),
                (.serviceListingType, listingTypesString)]
    }
}


// MARK: Equatable implementation

extension ServicesFilters: Equatable {
    
    static func == (lhs: ServicesFilters, rhs: ServicesFilters) -> Bool {
        return lhs.type?.id == rhs.type?.id &&
            lhs.subtypes?.count == rhs.subtypes?.count &&
            lhs.listingTypes.count == rhs.listingTypes.count
    }
}


extension ServicesFilters {
    var selectedSubtypeIds: [String]? {
        return subtypes?.compactMap({ $0.id })
    }
}
