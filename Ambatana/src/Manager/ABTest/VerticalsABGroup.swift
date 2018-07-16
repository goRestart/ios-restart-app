struct VerticalsABGroup: ABGroupType {

    let searchCarsIntoNewBackend: LeanplumABVariable<Int>
    let realEstateMap: LeanplumABVariable<Int>
    let showServicesFeatures: LeanplumABVariable<Int>
    let carExtraFieldsEnabled: LeanplumABVariable<Int>
    let realEstateMapTooltip: LeanplumABVariable<Int>

    let group: ABGroup = .verticals
    var intVariables: [LeanplumABVariable<Int>] = []
    var stringVariables: [LeanplumABVariable<String>] = []
    var floatVariables: [LeanplumABVariable<Float>] = []
    var boolVariables: [LeanplumABVariable<Bool>] = []

    private init(searchCarsIntoNewBackend: LeanplumABVariable<Int>,
                 realEstateMap: LeanplumABVariable<Int>,
                 showServicesFeatures: LeanplumABVariable<Int>,
                 carExtraFieldsEnabled: LeanplumABVariable<Int>,
                 realEstateMapTooltip: LeanplumABVariable<Int>) {
        self.searchCarsIntoNewBackend = searchCarsIntoNewBackend
        self.realEstateMap = realEstateMap
        self.showServicesFeatures = showServicesFeatures
        self.carExtraFieldsEnabled = carExtraFieldsEnabled
        self.realEstateMapTooltip = realEstateMapTooltip
        
        intVariables.append(contentsOf: [searchCarsIntoNewBackend,
                                         realEstateMap,
                                         showServicesFeatures,
                                         carExtraFieldsEnabled,
                                         realEstateMapTooltip])
    }
    
    static func make() -> VerticalsABGroup {
        return VerticalsABGroup(searchCarsIntoNewBackend: verticalsIntFor(key: Keys.searchCarsIntoNewBackend),
                                realEstateMap: verticalsIntFor(key: Keys.realEstateMap),
                                showServicesFeatures: verticalsIntFor(key: Keys.showServicesFeatures),
                                carExtraFieldsEnabled: verticalsIntFor(key: Keys.carExtraFieldsEnabled),
                                realEstateMapTooltip: verticalsIntFor(key: Keys.realEstateMapTooltip))
    }
    
    private static func verticalsIntFor(key: String) -> LeanplumABVariable<Int> {
        return .makeInt(key: key, defaultValue: 0, groupType: .verticals)
    }
}

private struct Keys {
    static let searchCarsIntoNewBackend = "20180403searchCarsIntoNewBackend"
    static let realEstateMap = "20180427realEstateMap"
    static let showServicesFeatures = "20180518showServicesFeatures"
    static let carExtraFieldsEnabled = "20180628carExtraFieldsEnabled"
    static let realEstateMapTooltip = "20180703realEstateMapTooltip"
}
