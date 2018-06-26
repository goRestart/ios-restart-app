public struct CarAttributes: Equatable, Decodable {
    public let make: String?
    public let makeId: String?
    public let model: String?
    public let modelId: String?
    public let year: Int?
    public let mileage: Int?
    public let mileageType: DistanceType?
    public let bodyType: CarBodyType?
    public let transmission: CarTransmissionType?
    public let fuelType: CarFuelType?
    public let driveTrain: CarDriveTrainType?
    public let seats: Int?
    
    public static let emptyMake = ""
    public static let emptyModel = ""
    public static let emptyYear = 0
    
    public init(makeId: String? = nil, make: String? = nil, modelId: String? = nil, model: String? = nil, year: Int? = nil,
                mileage: Int? = nil, mileageType: DistanceType? = nil, bodyType: CarBodyType? = nil,
                transmission: CarTransmissionType? = nil, fuelType: CarFuelType? = nil, driveTrain: CarDriveTrainType? = nil,
                seats: Int? = nil) {
        self.makeId = makeId
        self.make = make
        self.modelId = modelId
        self.model = model
        self.year = year
        self.mileage = mileage
        self.mileageType = mileageType
        self.bodyType = bodyType
        self.transmission = transmission
        self.fuelType = fuelType
        self.driveTrain = driveTrain
        self.seats = seats
    }
    
    public init(from decoder: Decoder) throws {
        let keyedContainerProductsApi = try decoder.container(keyedBy: CodingKeysProductsApi.self)
        let keyedContainerCarsApi = try decoder.container(keyedBy: CodingKeysCarsApi.self)
        
        if let makeIdValue = try keyedContainerProductsApi.decodeIfPresent(String.self, forKey: .make) {
            makeId = makeIdValue
        } else {
            makeId = try keyedContainerCarsApi.decodeIfPresent(String.self, forKey: .makeId)
        }
        make = nil
        if let modelIdValue = try keyedContainerProductsApi.decodeIfPresent(String.self, forKey: .model) {
            modelId = modelIdValue
        } else {
            modelId = try keyedContainerCarsApi.decodeIfPresent(String.self, forKey: .modelId)
        }
        model = nil
        year = try keyedContainerCarsApi.decodeIfPresent(Int.self, forKey: .year)
        
        mileage = try keyedContainerCarsApi.decodeIfPresent(Int.self, forKey: .mileage)
        mileageType = try keyedContainerCarsApi.decodeIfPresent(DistanceType.self, forKey: .mileageType)
        bodyType = try keyedContainerCarsApi.decodeIfPresent(CarBodyType.self, forKey: .bodyType)
        transmission = try keyedContainerCarsApi.decodeIfPresent(CarTransmissionType.self, forKey: .transmission)
        fuelType = try keyedContainerCarsApi.decodeIfPresent(CarFuelType.self, forKey: .fuelType)
        driveTrain = try keyedContainerCarsApi.decodeIfPresent(CarDriveTrainType.self, forKey: .driveTrain)
        seats = try keyedContainerCarsApi.decodeIfPresent(Int.self, forKey: .seats)
    }
    
    private enum CodingKeysProductsApi: String, CodingKey {
        case make, model, year
    }
    private enum CodingKeysCarsApi: String, CodingKey {
        case makeId, modelId, year, mileage, mileageType, bodyType, transmission, fuelType, seats
        case driveTrain = "drivetrain"
    }
}

public extension CarAttributes {
    public var isMakeEmpty: Bool {
        guard let make = make else { return false }
        return make == CarAttributes.emptyMake
    }
    
    public var isModelEmpty: Bool {
        guard let model = model else { return false }
        return model == CarAttributes.emptyModel
    }
    
    public var isYearEmpty: Bool {
        guard let year = year  else { return false }
        return year == CarAttributes.emptyYear
    }
    
    public var isAllExtraFieldsEmpty: Bool {
        let allValues: [Any?] =  [mileage, mileageType, bodyType, transmission, fuelType, driveTrain, seats]
        return allValues.filter { $0 != nil }.isEmpty
    }
    
    public func updating(makeId: String? = nil, make: String? = nil, modelId: String? = nil, model: String? = nil, year: Int? = nil,
                         mileage: Int? = nil, mileageType: DistanceType? = nil, bodyType: CarBodyType? = nil,
                         transmission: CarTransmissionType? = nil, fuelType: CarFuelType? = nil, driveTrain: CarDriveTrainType? = nil,
                         seats: Int? = nil) -> CarAttributes {
        
        return CarAttributes(makeId: makeId ?? self.makeId,
                             make: make ?? self.make,
                             modelId: modelId ?? self.modelId,
                             model: model ?? self.model,
                             year: year ?? self.year,
                             mileage: mileage ?? self.mileage,
                             mileageType: mileageType ?? self.mileageType,
                             bodyType: bodyType ?? self.bodyType,
                             transmission: transmission ?? self.transmission,
                             fuelType: fuelType ?? self.fuelType,
                             driveTrain: driveTrain ?? self.driveTrain,
                             seats: seats ?? self.seats)
    }
    
    public static func emptyCarAttributes() -> CarAttributes {
        return CarAttributes(makeId: CarAttributes.emptyMake,
                             make: CarAttributes.emptyMake,
                             modelId: CarAttributes.emptyModel,
                             model: CarAttributes.emptyModel,
                             year: CarAttributes.emptyYear)
    }
}

public func ==(lhs: CarAttributes, rhs: CarAttributes) -> Bool {
    return lhs.make == rhs.make && lhs.makeId == rhs.makeId &&
        lhs.model == rhs.model && lhs.modelId == rhs.modelId &&
        lhs.year == rhs.year &&
        lhs.mileage == rhs.mileage &&
        lhs.mileageType == rhs.mileageType &&
        lhs.bodyType == rhs.bodyType &&
        lhs.transmission == rhs.transmission &&
        lhs.fuelType == rhs.fuelType &&
        lhs.driveTrain == rhs.driveTrain &&
        lhs.seats == rhs.seats
}

