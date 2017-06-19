extension CarAttributes: MockFactory {
    public static func makeMock() -> CarAttributes {
        let hasMake = Bool.makeRandom()
        let hasModel = Bool.makeRandom()
        return CarAttributes(makeId: hasMake ? String.makeRandom() : nil,
                             make: hasMake ? String.makeRandom() : nil,
                             modelId: hasModel ? String.makeRandom() : nil,
                             model: hasModel ? String.makeRandom() : nil,
                             year: Int?.makeRandom())
    }
}
