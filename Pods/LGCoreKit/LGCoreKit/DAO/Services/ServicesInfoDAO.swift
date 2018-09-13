protocol ServicesInfoDAO {
    var isExpired: Bool { get }
    var servicesTypes: [ServiceType] { get }
    var localeId: String? { get }
    func save(servicesInfo: [ServiceType], localeId: String?)
    func clean()
}

