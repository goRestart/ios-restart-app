struct RealEstateABGroup: ABGroupType {
    private struct Keys {
        static let realEstateNewCopy = "20180126RealEstateNewCopy"

    }
    
    let realEstateNewCopy: LeanplumABVariable<Int>

    let group: ABGroup = .realEstate
    var intVariables: [LeanplumABVariable<Int>] = []
    var stringVariables: [LeanplumABVariable<String>] = []
    var floatVariables: [LeanplumABVariable<Float>] = []
    var boolVariables: [LeanplumABVariable<Bool>] = []

    init(realEstateNewCopy: LeanplumABVariable<Int>) {
        self.realEstateNewCopy = realEstateNewCopy

        intVariables.append(contentsOf: [realEstateNewCopy])
    }

    static func make() -> RealEstateABGroup {
        return RealEstateABGroup(realEstateNewCopy: .makeInt(key: Keys.realEstateNewCopy,
                                                             defaultValue: 0,
                                                             groupType: .realEstate))
    }
}
