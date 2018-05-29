open class MockServicesInfoRepository: ServicesInfoRepository, ServicesInfoRetrievable {
    public var serviceTypesRetrieved: [ServiceType] = []
    public var serviceSubtipedRetrieved: [ServiceSubtype] = []
    
    // MARK: - Lifecycle
    
    required public init() {}
    
    public func loadFirstRunCacheIfNeeded(jsonURL: URL) { }
    
    public func refreshServicesFile() { }
    
    public func retrieveServiceTypes() -> [ServiceType] { return serviceTypesRetrieved }
    
    public func serviceSubtypes(forServiceTypeId serviceTypeId: String) -> [ServiceSubtype] {
        return []
    }
    
    public func serviceType(forServiceTypeId serviceTypeId: String) -> ServiceType? {
        return MockServiceType.makeMock()
    }
    
    public func serviceSubtype(forServiceSubtypeId serviceSubtypeId: String) -> ServiceSubtype? {
        return MockServiceSubtype.makeMock()
    }
    
}
