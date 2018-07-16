public enum CarBodyType: String, Decodable {
    case coupe, sedan, hybrid, hatchback, convertible, wagon, minivan, suv, truck, others
}

public enum CarDriveTrainType: String, Decodable {
    case awd, fwd, rwd
    case fourWd = "4wd"
}

public enum CarFuelType: String, Decodable {
    case diesel, electric, flex, gas, hybrid
}

public enum CarTransmissionType: String, Decodable {
    case automatic, manual
}
