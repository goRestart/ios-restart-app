public protocol ServicesInfoRepository {
    func loadFirstRunCacheIfNeeded(jsonURL: URL)
    func refreshServicesFile()
    func retrieveServiceTypes() -> [ServiceType]
}
