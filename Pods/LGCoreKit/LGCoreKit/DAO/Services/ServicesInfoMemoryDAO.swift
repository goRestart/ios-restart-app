final class ServicesInfoMemoryDAO: ServicesInfoDAO, ServicesInfoRetrievable {

    private var serviceTypesList: [ServiceType] = []
    
    var isExpired: Bool {
        return false // The app won't be in memory for several days so technically it never expires
    }

    var servicesTypes: [ServiceType] {
        return serviceTypesList
    }
    
    private(set) var localeId: String?
    
    func save(servicesInfo: [ServiceType], localeId: String?) {
        serviceTypesList = servicesInfo
        self.localeId = localeId
    }
    
    func serviceSubtypes(forServiceTypeId serviceTypeId: String) -> [ServiceSubtype] {
        return serviceType(forServiceTypeId: serviceTypeId)?.subTypes ?? []
    }
    
    func serviceType(forServiceTypeId serviceTypeId: String) -> ServiceType? {
        return servicesTypes.first(where: { $0.id == serviceTypeId })
    }
    
    func serviceSubtype(forServiceSubtypeId serviceSubtypeId: String) -> ServiceSubtype? {
        return servicesTypes.flatMap({ $0.subTypes }).first(where: { $0.id == serviceSubtypeId })
    }
    
    func serviceAllSubtypesSorted() -> [ServiceSubtype] {
        let serviceSubtypes: [ServiceSubtype] = servicesTypes.flatMap({ $0.subTypes })
        return serviceSubtypes.sorted(by: { $0.isHighlighted && !$1.isHighlighted })
    }
    
    func clean() {
        serviceTypesList = []
    }    
}
