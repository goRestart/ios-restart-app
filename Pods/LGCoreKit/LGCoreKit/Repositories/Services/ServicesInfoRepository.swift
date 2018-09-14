public protocol ServicesInfoRepository: ServicesInfoRetrievable {
    func loadFirstRunCacheIfNeeded(jsonURL: URL)
    func retrieveServiceTypes() -> [ServiceType]
}
