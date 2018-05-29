public protocol ServicesInfoRetrievable {
    func serviceSubtypes(forServiceTypeId serviceTypeId: String) -> [ServiceSubtype]
    func serviceType(forServiceTypeId serviceTypeId: String) -> ServiceType?
    func serviceSubtype(forServiceSubtypeId serviceSubtypeId: String) -> ServiceSubtype?
}
