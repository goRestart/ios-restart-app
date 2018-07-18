
struct VerticalFilters: VerticalFilterType {

    var cars: CarFilters
    var services: ServicesFilters
    var realEstate: RealEstateFilters
        
    private var allVerticals: [VerticalFilterType] {
        let allVerticals: [VerticalFilterType?] = [cars, services, realEstate]
        return allVerticals.compactMap({ $0 })
    }
    
    var hasAnyAttributesSet: Bool {
        return allVerticals.reduce(false, { (res, next) -> Bool in
            if next.hasAnyAttributesSet { return true }
            return res
        })
    }
    
    func createTrackingParams() -> [(EventParameterName, Any?)] {
        return allVerticals.reduce([], { (res, next) -> [(EventParameterName, Any?)] in
            return res + next.createTrackingParams()
        })
    }
    
    static func create() -> VerticalFilters {
        return VerticalFilters(cars: CarFilters.create(),
                               services: ServicesFilters.create(),
                               realEstate: RealEstateFilters.create())
    }
}


// MARK: Equatable implementation

extension VerticalFilters: Equatable {
    
    static func == (lhs: VerticalFilters, rhs: VerticalFilters) -> Bool {
        return lhs.cars == rhs.cars &&
            lhs.services == rhs.services &&
            lhs.realEstate == rhs.realEstate
    }
}
