import RealmSwift

@objcMembers class RealmCarsInfo: Object {
    dynamic var countryCode: String? = nil
    dynamic var updatedAt: Date = Date()
    dynamic var carMakes = List<RealmCarsMakeWithModels>()
}

@objcMembers class RealmCarsMakeWithModels: Object {
    dynamic var makeId: String = CarAttributes.emptyMake
    dynamic var makeName: String = CarAttributes.emptyMake
    let models = List<RealmCarsModel>()
}

@objcMembers class RealmCarsModel: Object {
    dynamic var modelId: String = CarAttributes.emptyModel
    dynamic var modelName: String = CarAttributes.emptyModel
}

typealias Days = Int

class CarsInfoRealmDAO: CarsInfoDAO {
    
    static let expirationThresholdDays = 15

    static let dataBaseName = "CarsInfo"
    static let dataBaseExtension = "realm"
    private static let schemaVersion: UInt64 = 1
    
    static func cacheFilePath() -> String {
        guard let cacheDirectoryPath =
            NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else { return "" }
        let cacheFilePath = cacheDirectoryPath + "/\(CarsInfoRealmDAO.dataBaseName).\(CarsInfoRealmDAO.dataBaseExtension)"
        return cacheFilePath
    }

    private let dataBase: Realm
    private let expirationThreshold: Days
    
    var isExpired: Bool {
        guard let updatedAt = realmCarsInfo?.updatedAt else { return true }
        return updatedAt.isOlderThan(days: expirationThreshold)
    }

    var carsMakesList: [CarsMake] {
        guard let carMakesList = realmCarsInfo?.carMakes else {
            return []
        }
        let rmCarsMakesArray = Array(carMakesList)
        return rmCarsMakesArray.map { convertToLGCarsMake(carsMake: $0) }
    }
    
    var countryCode: String? {
        return realmCarsInfo?.countryCode
    }
    
    private var realmCarsInfo: RealmCarsInfo? {
        return dataBase.objects(RealmCarsInfo.self).first
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
                                             schemaVersion: CarsInfoRealmDAO.schemaVersion,
                                             deleteRealmIfMigrationNeeded: true,
                                             objectTypes: [RealmCarsInfo.self, RealmCarsMakeWithModels.self, RealmCarsModel.self])
            let dataBase = try Realm(configuration: config)
            self.init(realm: dataBase)
        } catch let error {
            logMessage(.verbose, type: CoreLoggingOptions.database, message: "Could not create Cars Info DB: \(error)")
            return nil
        }
    }


    // MARK: - Public methods

    func save(carsInfo: [CarsMakeWithModels], countryCode: String?) {
        clean()

        let realmArray = carsInfo.map { convertToRealmCarsMake(carsMake: $0) }
        let realmList = RealmHelper.convertArrayToRealmList(inputArray: realmArray)
        
        let realmCarsInfo = RealmCarsInfo()
        realmCarsInfo.carMakes = realmList
        realmCarsInfo.countryCode = countryCode
        realmCarsInfo.updatedAt = Date()

        dataBase.cancelWriteTransactionsIfNeeded()
        do {
            try dataBase.write {
                dataBase.add(realmCarsInfo)
            }
        } catch let error {
            logMessage(.verbose, type: CoreLoggingOptions.database, message: "Could not write in Cars Info DB: \(error)")
        }
    }
    
    func modelsForMake(makeId: String) -> [CarsModel] {
        guard let carMake = carMake(withMakeId: makeId) else { return [] }
        return RealmHelper.convertRealmListToArray(realmList: carMake.models).map { convertToLGCarsModel(carsModel: $0) }
    }

    func clean() {
        dataBase.cancelWriteTransactionsIfNeeded()
        do {
            try dataBase.write {
                dataBase.deleteAll()
            }
        } catch let error {
            logMessage(.verbose, type: CoreLoggingOptions.database, message: "Could not clean the Cars Info DB: \(error)")
        }
    }

    func retrieveMakeName(with makeId: String?) -> String? {
        guard let makeId = makeId else { return nil }
        return carMake(withMakeId: makeId)?.makeName
    }
    
    func retrieveModelName(with makeId: String?, modelId: String?) -> String? {
        guard let makeId = makeId, let modelId = modelId else { return nil }
        let models = modelsForMake(makeId: makeId)
        return models.first(where: { $0.modelId == modelId })?.modelName
    }
    

    // MARK: - Private Methods

    private func carMake(withMakeId makeId: String) -> RealmCarsMakeWithModels? {
        guard let carMakes = realmCarsInfo?.carMakes else { return nil }
        return RealmHelper.convertRealmListToArray(realmList: carMakes).first(where: { $0.makeId == makeId })
    }

    
    // MARK: > LG to Realm

    private func convertToRealmCarsMake(carsMake: CarsMakeWithModels) -> RealmCarsMakeWithModels {
        let resultMake = RealmCarsMakeWithModels()
        resultMake.makeId = carsMake.makeId
        resultMake.makeName = carsMake.makeName

        let realmModelsArray = carsMake.models.map { convertToRealmCarsModel(carsModel: $0) }
        resultMake.models.append(objectsIn: realmModelsArray)

        return resultMake
    }

    private func convertToRealmCarsModel(carsModel: CarsModel) -> RealmCarsModel {
        let resultModel = RealmCarsModel()
        resultModel.modelId = carsModel.modelId
        resultModel.modelName = carsModel.modelName
        return resultModel
    }


    // MARK: > Realm to LG

    private func convertToLGCarsMake(carsMake: RealmCarsMakeWithModels) -> LGCarsMake {
        let resultMake = LGCarsMake(makeId: carsMake.makeId, makeName: carsMake.makeName)
        return resultMake
    }

    private func convertToLGCarsModel(carsModel: RealmCarsModel) -> LGCarsModel {
        let resultModel = LGCarsModel(modelId: carsModel.modelId, modelName: carsModel.modelName)
        return resultModel
    }
}
