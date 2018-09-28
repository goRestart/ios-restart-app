protocol CarsInfoDAO {
    var isExpired: Bool { get }
    var carsMakesList: [CarsMake] { get }
    var countryCode: String? { get }
    func save(carsInfo: [CarsMakeWithModels], countryCode: String?)
    func modelsForMake(makeId: String) -> [CarsModel]
    func clean()
    func retrieveModelName(with makeId: String?, modelId: String?) -> String?
    func retrieveMakeName(with makeId: String?) -> String?
}
