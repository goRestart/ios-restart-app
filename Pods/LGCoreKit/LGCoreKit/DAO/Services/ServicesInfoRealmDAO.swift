import RealmSwift

@objcMembers class RealmServicesInfo: Object {
    dynamic var localeId: String? = nil
    dynamic var updatedAt: Date = Date()
    dynamic var services = List<RealmServiceType>()
}

@objcMembers class RealmServiceType: Object {
    dynamic var typeId: String = ""
    dynamic var typeName: String = ""
    let subtypes = List<RealmServiceSubtype>()
}

@objcMembers class RealmServiceSubtype: Object {
    dynamic var subtypeId: String = ""
    dynamic var subtypeName: String = ""
    dynamic var subtypeIsHighlighted: Bool = false
}

final class ServicesInfoRealmDAO: ServicesInfoDAO, ServicesInfoRetrievable {
    
    static let expirationThresholdDays = 15
    
    static let dataBaseName = "ServicesInfo"
    static let dataBaseExtension = "realm"
    private static let schemaVersion: UInt64 = 1
    
    static func cacheFilePath() -> String {
        guard let cacheDirectoryPath =
            NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else { return "" }
        let cacheFilePath = cacheDirectoryPath + "/\(ServicesInfoRealmDAO.dataBaseName).\(ServicesInfoRealmDAO.dataBaseExtension)"
        return cacheFilePath
    }
    
    private let dataBase: Realm
    private let expirationThreshold: Days
    
    var isExpired: Bool {
        guard let updatedAt = realmServicesInfo?.updatedAt else { return true }
        return updatedAt.isOlderThan(days: expirationThreshold)
    }
    
    var servicesTypes: [ServiceType] {
        guard let servicesList = realmServicesInfo?.services else {
            return []
        }
        let services = Array(servicesList)
        return services.map { convertToLGServiceType(serviceType: $0) }
    }
    
    var localeId: String? {
        return realmServicesInfo?.localeId
    }

    private var realmServicesInfo: RealmServicesInfo? {
        return dataBase.objects(RealmServicesInfo.self).first
    }
    
    // MARK: - Lifecycle
    
    init(realm: Realm, expirationThreshold: Days = CarsInfoRealmDAO.expirationThresholdDays) {
        self.dataBase = realm
        self.expirationThreshold = expirationThreshold
    }
    
    convenience init?(cacheFilePath: String = cacheFilePath()) {
        guard !cacheFilePath.isEmpty else { return nil }
        do {
            let cacheFileUrl = URL(fileURLWithPath: cacheFilePath, isDirectory: false)
            let config = Realm.Configuration(fileURL: cacheFileUrl,
                                             readOnly: false,
                                             schemaVersion: ServicesInfoRealmDAO.schemaVersion,
                                             deleteRealmIfMigrationNeeded: true,
                                             objectTypes: [RealmServicesInfo.self, RealmServiceType.self, RealmServiceSubtype.self])
            let dataBase = try Realm(configuration: config)
            self.init(realm: dataBase)
        } catch let error {
            logMessage(.verbose, type: CoreLoggingOptions.database, message: "Could not create Services Info DB: \(error)")
            return nil
        }
    }

    func save(servicesInfo serviceTypes: [ServiceType], localeId: String?) {
        clean()
        
        let realmArray = serviceTypes.map { convertToRealmServiceType(serviceType: $0) }
        let realmList = RealmHelper.convertArrayToRealmList(inputArray: realmArray)
        
        let servicesInfo = RealmServicesInfo()
        servicesInfo.services = realmList
        servicesInfo.localeId = localeId
        servicesInfo.updatedAt = Date()
        
        dataBase.cancelWriteTransactionsIfNeeded()
        do {
            try dataBase.write {
                dataBase.add(servicesInfo)
            }
        } catch let error {
            logMessage(.verbose, type: CoreLoggingOptions.database, message: "Could not write in Services Info DB: \(error)")
        }
    }
    
    func serviceSubtypes(forServiceTypeId serviceTypeId: String) -> [ServiceSubtype] {
        guard let serviceType = serviceType(forServiceTypeId: serviceTypeId) else { return [] }
        return serviceType.subTypes
    }
    
    func serviceType(forServiceTypeId serviceTypeId: String) -> ServiceType? {
        return servicesTypes.first(where: { $0.id == serviceTypeId })
    }
    
    func serviceSubtype(forServiceSubtypeId serviceSubtypeId: String) -> ServiceSubtype? {
        return servicesTypes
            .first(where: { $0.subTypes.contains{ $0.id == serviceSubtypeId } })?
            .subTypes
            .first(where: { $0.id == serviceSubtypeId })
    }
    
    func serviceAllSubtypesSorted() -> [ServiceSubtype] {
        return servicesTypes.flatMap{ $0.subTypes }.sorted(by: { $0.isHighlighted && !$1.isHighlighted })
    }
    
    func clean() {
        dataBase.cancelWriteTransactionsIfNeeded()
        do {
            try dataBase.write {
                dataBase.deleteAll()
            }
        } catch let error {
            logMessage(.verbose, type: CoreLoggingOptions.database, message: "Could not clean the Services Info DB: \(error)")
        }
    }
}


// MARK:- Convert LG > Realm
extension ServicesInfoRealmDAO {
    
    private func convertToRealmServiceType(serviceType: ServiceType) -> RealmServiceType {
        let resultServiceType = RealmServiceType()
        resultServiceType.typeId = serviceType.id
        resultServiceType.typeName = serviceType.name
        
        let realmServiceSubtypesArray = serviceType.subTypes.map({ convertToRealmServiceSubtype(serviceSubtype: $0) })
        resultServiceType.subtypes.append(objectsIn: realmServiceSubtypesArray)
        
        return resultServiceType
    }
    
    private func convertToRealmServiceSubtype(serviceSubtype: ServiceSubtype) -> RealmServiceSubtype {
        let resultServiceSubtype = RealmServiceSubtype()
        resultServiceSubtype.subtypeId = serviceSubtype.id
        resultServiceSubtype.subtypeName = serviceSubtype.name
        resultServiceSubtype.subtypeIsHighlighted = serviceSubtype.isHighlighted
        
        return resultServiceSubtype
    }
}


// MARK:- Convert Realm > LG
extension ServicesInfoRealmDAO {
    
    private func convertToLGServiceType(serviceType: RealmServiceType) -> LGServiceType {
        let resultServiceType = LGServiceType(id: serviceType.typeId,
                                              name: serviceType.typeName,
                                              subtypes: serviceType.subtypes.map({ convertToLGServiceSubtype(serviceSubtype: $0) }))
        return resultServiceType
    }
    
    private func convertToLGServiceSubtype(serviceSubtype: RealmServiceSubtype) -> LGServiceSubtype {
        let resultServiceSubtype = LGServiceSubtype(id: serviceSubtype.subtypeId,
                                                    name: serviceSubtype.subtypeName,
                                                    isHighlighted: serviceSubtype.subtypeIsHighlighted)
        return resultServiceSubtype
    }
}
