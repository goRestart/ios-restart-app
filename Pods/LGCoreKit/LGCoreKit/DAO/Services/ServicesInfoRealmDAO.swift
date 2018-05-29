import RealmSwift

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
    
    static let dataBaseName = "ServicesInfo"
    static let dataBaseExtension = "realm"
    
    private let dataBase: Realm
    
    var servicesTypes: [ServiceType] {
        let serviceTypes = dataBase.objects(RealmServiceType.self)
        let realmServiceTypesArray = Array(serviceTypes)
        return realmServiceTypesArray.map { convertToLGServiceType(serviceType: $0) }
    }
    
    // MARK: - Lifecycle
    
    init(realm: Realm) {
        self.dataBase = realm
    }
    
    convenience init?() {
        guard let cacheDirectoryPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory,
                                                                           .userDomainMask, true).first else { return nil }
        let cacheFilePath = cacheDirectoryPath + "/\(ServicesInfoRealmDAO.dataBaseName).\(ServicesInfoRealmDAO.dataBaseExtension)"
        
        do {
            let cacheFileUrl = URL(fileURLWithPath: cacheFilePath, isDirectory: false)
            let config = Realm.Configuration(fileURL: cacheFileUrl,
                                             readOnly: false,
                                             objectTypes: [RealmServiceType.self, RealmServiceSubtype.self])
            
            let dataBase = try Realm(configuration: config)
            self.init(realm: dataBase)
        } catch let error {
            logMessage(.verbose, type: CoreLoggingOptions.database, message: "Could not create Services Info DB: \(error)")
            return nil
        }
    }

    func save(servicesInfo serviceTypes: [ServiceType]) {
        clean()
        
        let realmArray = serviceTypes.map { convertToRealmServiceType(serviceType: $0) }
        let realmList = RealmHelper.convertArrayToRealmList(inputArray: realmArray)
        
        dataBase.cancelWriteTransactionsIfNeeded()
        do {
            try dataBase.write {
                dataBase.add(realmList)
            }
        } catch let error {
            logMessage(.verbose,
                       type: CoreLoggingOptions.database,
                       message: "Could not write in Services Info DB: \(error)")
        }
    }
    
    func serviceSubtypes(forServiceTypeId serviceTypeId: String) -> [ServiceSubtype] {
        guard let serviceType = serviceType(forServiceTypeId: serviceTypeId) else { return [] }
        return serviceType.subTypes
    }
    
    func serviceType(forServiceTypeId serviceTypeId: String) -> ServiceType? {
        let realmServiceTypes = dataBase.objects(RealmServiceType.self)
        let queryPredicate = NSPredicate(format: "typeId == '\(serviceTypeId)'")
        guard let realmServiceType = realmServiceTypes.filter(queryPredicate).first else { return nil }
        let serviceType = convertToLGServiceType(serviceType: realmServiceType)
        return serviceType
    }
    
    func serviceSubtype(forServiceSubtypeId serviceSubtypeId: String) -> ServiceSubtype? {
        let realmServiceSubtypes = dataBase.objects(RealmServiceSubtype.self)
        let queryPredicate = NSPredicate(format: "subtypeId == '\(serviceSubtypeId)'")
        guard let realmServiceSubtype = realmServiceSubtypes.filter(queryPredicate).first else { return nil }
        let serviceSubtype = convertToLGServiceSubtype(serviceSubtype: realmServiceSubtype)
        return serviceSubtype
    }
    
    func clean() {
        dataBase.cancelWriteTransactionsIfNeeded()
        do {
            try dataBase.write {
                dataBase.deleteAll()
            }
        } catch let error {
            logMessage(.verbose,
                       type: CoreLoggingOptions.database,
                       message: "Could not clean the Services Info DB: \(error)")
        }
    }
    
    func loadFirstRunCacheIfNeeded(jsonURL: URL) {
        guard dataBase.objects(RealmServiceType.self).isEmpty else { return }
        
        do {
            let data = try Data(contentsOf: jsonURL)
            let jsonServiceTypesList = try JSONSerialization.jsonObject(with: data, options: [])
            guard let serviceTypes = decoder(jsonServiceTypesList) else { return }
            save(servicesInfo: serviceTypes)
        } catch {
            logMessage(.verbose,
                       type: CoreLoggingOptions.database,
                       message: "Failed to create Services Info first run cache: \(error)")
        }
    }
}


// MARK:- Decoder
extension ServicesInfoRealmDAO {
    
    private func decoder(_ object: Any) -> [ServiceType]? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted) else { return nil }
        
        do {
            let serviceTypes = try JSONDecoder().decode(FailableDecodableArray<LGServiceType>.self, from: data)
            return serviceTypes.validElements
        } catch {
            logMessage(.debug, type: .parsing, message: "could not parse LGServiceTypes \(object)")
        }

        return nil
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
