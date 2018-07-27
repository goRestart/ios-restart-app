struct VerticalsABGroup: ABGroupType {

    let showServicesFeatures: LeanplumABVariable<Int>
    let carExtraFieldsEnabled: LeanplumABVariable<Int>
    let realEstateMapTooltip: LeanplumABVariable<Int>
    let servicesUnifiedFilterScreen: LeanplumABVariable<Int>

    let group: ABGroup = .verticals
    var intVariables: [LeanplumABVariable<Int>] = []
    var stringVariables: [LeanplumABVariable<String>] = []
    var floatVariables: [LeanplumABVariable<Float>] = []
    var boolVariables: [LeanplumABVariable<Bool>] = []

    private init(showServicesFeatures: LeanplumABVariable<Int>,
                 carExtraFieldsEnabled: LeanplumABVariable<Int>,
                 realEstateMapTooltip: LeanplumABVariable<Int>,
                 servicesUnifiedFilterScreen: LeanplumABVariable<Int>) {
        self.showServicesFeatures = showServicesFeatures
        self.carExtraFieldsEnabled = carExtraFieldsEnabled
        self.realEstateMapTooltip = realEstateMapTooltip
        self.servicesUnifiedFilterScreen = servicesUnifiedFilterScreen
        
        intVariables.append(contentsOf: [showServicesFeatures,
                                         carExtraFieldsEnabled,
                                         realEstateMapTooltip,
                                         servicesUnifiedFilterScreen])
    }
    
    static func make() -> VerticalsABGroup {
        return VerticalsABGroup(showServicesFeatures: verticalsIntFor(key: Keys.showServicesFeatures),
                                carExtraFieldsEnabled: verticalsIntFor(key: Keys.carExtraFieldsEnabled),
                                realEstateMapTooltip: verticalsIntFor(key: Keys.realEstateMapTooltip),
                                servicesUnifiedFilterScreen: verticalsIntFor(key: Keys.servicesUnifiedFilterScreen))
    }
    
    private static func verticalsIntFor(key: String) -> LeanplumABVariable<Int> {
        return .makeInt(key: key, defaultValue: 0, groupType: .verticals)
    }
}

private struct Keys {
    static let showServicesFeatures = "20180518showServicesFeatures"
    static let carExtraFieldsEnabled = "20180628carExtraFieldsEnabled"
    static let realEstateMapTooltip = "20180703realEstateMapTooltip"
    static let servicesUnifiedFilterScreen = "20180717servicesUnifiedFilterScreen"
}
