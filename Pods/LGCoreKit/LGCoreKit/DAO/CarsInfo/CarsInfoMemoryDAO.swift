class CarsInfoMemoryDAO: CarsInfoDAO {

    private var carsMakesWithModelsList: [CarsMakeWithModels] = []

    var carsMakesList: [CarsMake] {
        let carsMakes = carsMakesWithModelsList.map { LGCarsMake(makeId: $0.makeId, makeName: $0.makeName) }
        return carsMakes
    }
    
    private(set) var countryCode: String?
    
    let isExpired: Bool = false // The app won't be in memory for several days so technically it never expires

    func save(carsInfo: [CarsMakeWithModels], countryCode: String?) {
        carsMakesWithModelsList = carsInfo
        self.countryCode = countryCode
    }

    func modelsForMake(makeId: String) -> [CarsModel] {
        return carsMakesWithModelsList.first(where: { $0.makeId == makeId })?.models ?? []
    }

    func clean() {
        carsMakesWithModelsList = []
    }

    func retrieveMakeName(with makeId: String?) -> String? {
        return carsMakesWithModelsList.first(where: { $0.makeId == makeId })?.makeName
    }
    
    func retrieveModelName(with makeId: String?, modelId: String?) -> String? {
        guard let makeId = makeId else { return nil }
        guard let modelId = modelId else { return nil }
        let models = modelsForMake(makeId: makeId)
        return models.first(where: { $0.modelId == modelId })?.modelName
    }
}
