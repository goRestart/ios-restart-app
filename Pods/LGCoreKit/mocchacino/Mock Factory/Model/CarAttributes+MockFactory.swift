extension CarAttributes: MockFactory {
    public static func makeMock() -> CarAttributes {
        let hasMake = Bool.makeRandom()
        let hasModel = Bool.makeRandom()
        return CarAttributes(make: hasMake ? String.makeRandom() : nil,
                             modelId: hasModel ? String.makeRandom() : nil,
                             model: hasModel ? String.makeRandom() : nil,
                             year: Int?.makeRandom(),
                             mileage: Int.makeRandom(),
                             mileageType: .km,
                             bodyType: .coupe,
                             transmission: .automatic,
                             fuelType: .diesel,
                             driveTrain: .fwd,
                             seats: Int.makeRandom())
    }
}
