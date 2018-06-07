public protocol ServicesInfoRepository: ServicesInfoRetrievable {
    func loadFirstRunCacheIfNeeded(jsonURL: URL)
    func refreshServicesFile()
    func retrieveServiceTypes() -> [ServiceType]
}
