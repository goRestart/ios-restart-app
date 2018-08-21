struct VerticalsABGroup: ABGroupType {

    let carExtraFieldsEnabled: LeanplumABVariable<Int>
    let servicesUnifiedFilterScreen: LeanplumABVariable<Int>
    let servicesPaymentFrequency: LeanplumABVariable<Int>
    let jobsAndServicesEnabled: LeanplumABVariable<Int>
    
    let group: ABGroup = .verticals
    var intVariables: [LeanplumABVariable<Int>] = []
    var stringVariables: [LeanplumABVariable<String>] = []
    var floatVariables: [LeanplumABVariable<Float>] = []
    var boolVariables: [LeanplumABVariable<Bool>] = []

    private init(carExtraFieldsEnabled: LeanplumABVariable<Int>,
                 servicesUnifiedFilterScreen: LeanplumABVariable<Int>,
                 servicesPaymentFrequency: LeanplumABVariable<Int>,
                 jobsAndServicesEnabled: LeanplumABVariable<Int>) {
        self.carExtraFieldsEnabled = carExtraFieldsEnabled
        self.servicesUnifiedFilterScreen = servicesUnifiedFilterScreen
        self.servicesPaymentFrequency = servicesPaymentFrequency
        self.jobsAndServicesEnabled = jobsAndServicesEnabled

        intVariables.append(contentsOf: [carExtraFieldsEnabled,
                                         servicesUnifiedFilterScreen,
                                         servicesPaymentFrequency,
                                         jobsAndServicesEnabled])
    }
    
    static func make() -> VerticalsABGroup {
        return VerticalsABGroup(carExtraFieldsEnabled: verticalsIntFor(key: Keys.carExtraFieldsEnabled),
                                servicesUnifiedFilterScreen: verticalsIntFor(key: Keys.servicesUnifiedFilterScreen),
                                servicesPaymentFrequency: verticalsIntFor(key: Keys.servicesPaymentFrequency),
                                jobsAndServicesEnabled: verticalsIntFor(key: Keys.jobsAndServicesEnabled))
    }
    
    private static func verticalsIntFor(key: String) -> LeanplumABVariable<Int> {
        return .makeInt(key: key, defaultValue: 0, groupType: .verticals)
    }
}

private struct Keys {
    static let carExtraFieldsEnabled = "20180628carExtraFieldsEnabled"
    static let servicesUnifiedFilterScreen = "20180717servicesUnifiedFilterScreen"
    static let servicesPaymentFrequency = "20180730servicesPriceType"
    static let jobsAndServicesEnabled = "20180806jobsAndServicesEnabled"
}
