
import LGCoreKit

struct ServicesFilters: VerticalFilterType {
    
    var type: ServiceType?
    var subtypes: [ServiceSubtype]?
    
    var hasAnyAttributesSet: Bool {
        return checkIfAnyAttributesAreSet(forAttributes: [type, subtypes])
    }

    static func create() -> ServicesFilters {
        return ServicesFilters(type: nil,
                               subtypes: nil)
    }
}


// MARK: Tracking

extension ServicesFilters {
    
    func createTrackingParams() -> [(EventParameterName, Any?)] {
        return [(.serviceSubtype, subtypes?.trackingValue),
                (.serviceType, type?.id)]
    }
}


// MARK: Equatable implementation

extension ServicesFilters: Equatable {
    
    static func == (lhs: ServicesFilters, rhs: ServicesFilters) -> Bool {
        return lhs.type?.id == rhs.type?.id &&
            lhs.subtypes?.count == rhs.subtypes?.count
    }
}


extension ServicesFilters {
    var selectedSubtypeIds: [String]? {
        return subtypes?.compactMap({ $0.id })
    }
}
