extension RealEstatePropertyType: MockFactory {
    public static func makeMock() -> RealEstatePropertyType {
        let allValues: [RealEstatePropertyType] = [.apartment, .house, .room, .commercial, .other]
        return allValues.random()!
    }
}
