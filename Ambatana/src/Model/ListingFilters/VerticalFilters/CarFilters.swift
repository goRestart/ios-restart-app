
import LGCoreKit

struct CarFilters: VerticalFilterType {
    
    var sellerTypes: [UserType]
    var makeId: String?
    var makeName: String?
    var modelId: String?
    var modelName: String?
    var yearStart: Int?
    var yearEnd: Int?
    var bodyTypes: [CarBodyType]
    var driveTrainTypes: [CarDriveTrainType]
    var fuelTypes: [CarFuelType]
    var transmissionTypes: [CarTransmissionType]
    var mileageStart: Int?
    var mileageEnd: Int?
    var numberOfSeatsStart: Int?
    var numberOfSeatsEnd: Int?
    var mileageType: String? {
        guard mileageStart != nil || mileageEnd != nil else {
            return nil
        }
        
        return DistanceType.systemDistanceType().rawValue
    }
    
    var hasAnyAttributesSet: Bool {
        return checkIfAnyAttributesAreSet(forAttributes: [makeId, modelId,
                                                          yearStart, yearEnd,
                                                          mileageStart, mileageEnd,
                                                          numberOfSeatsStart, numberOfSeatsEnd,
                                                          bodyTypes, driveTrainTypes,
                                                          fuelTypes, transmissionTypes,
                                                          sellerTypes])
    }
    
    static func create() -> CarFilters {
        return CarFilters(sellerTypes: [],
                          makeId: nil,
                          makeName: nil,
                          modelId: nil,
                          modelName: nil,
                          yearStart: nil,
                          yearEnd: nil,
                          bodyTypes: [],
                          driveTrainTypes: [],
                          fuelTypes: [],
                          transmissionTypes: [],
                          mileageStart: nil,
                          mileageEnd: nil,
                          numberOfSeatsStart: nil,
                          numberOfSeatsEnd: nil)
    }
}


// MARK: Tracking

extension CarFilters {
    
    func createTrackingParams() -> [(EventParameterName, Any?)] {
        let bodyTypesString = bodyTypes.compactMap { $0.rawValue }.stringCommaSeparated
        let transmissionsString = transmissionTypes.compactMap { $0.rawValue }.stringCommaSeparated
        let fuelTypesString = fuelTypes.compactMap { $0.rawValue }.stringCommaSeparated
        let driveTrainsString = driveTrainTypes.compactMap { $0.rawValue }.stringCommaSeparated
        return [(.make, makeName),
                (.model, modelName),
                (.yearStart, yearStart),
                (.yearEnd, yearEnd),
                (.mileageFrom, mileageStart),
                (.mileageTo, mileageEnd),
                (.bodyType, bodyTypesString),
                (.transmission, transmissionsString),
                (.fuelType, fuelTypesString),
                (.drivetrain, driveTrainsString),
                (.seatsFrom, numberOfSeatsStart),
                (.seatsTo, numberOfSeatsEnd)]
    }
}


// MARK: Equatable implementation

extension CarFilters: Equatable {
    
    static func == (lhs: CarFilters, rhs: CarFilters) -> Bool {
        return lhs.makeId == rhs.makeId &&
            lhs.modelId == rhs.modelId &&
            lhs.yearStart == rhs.yearStart &&
            lhs.yearEnd == rhs.yearEnd &&
            lhs.bodyTypes == rhs.bodyTypes &&
            lhs.fuelTypes == rhs.fuelTypes &&
            lhs.transmissionTypes == rhs.transmissionTypes &&
            lhs.driveTrainTypes == rhs.driveTrainTypes &&
            lhs.mileageStart == rhs.mileageStart &&
            lhs.mileageEnd == rhs.mileageEnd &&
            lhs.numberOfSeatsStart == rhs.numberOfSeatsStart &&
            lhs.numberOfSeatsEnd == rhs.numberOfSeatsEnd
    }
}
