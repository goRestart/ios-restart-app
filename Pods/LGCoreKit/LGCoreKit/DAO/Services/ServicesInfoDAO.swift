protocol ServicesInfoDAO {
    var  servicesTypes: [ServiceType] { get }
    func save(servicesInfo: [ServiceType])
    func clean()
    func loadFirstRunCacheIfNeeded(jsonURL: URL)
}

