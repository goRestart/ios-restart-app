struct VerticalsABGroup: ABGroupType {

    let carExtraFieldsEnabled: LeanplumABVariable<Int>
    let servicesUnifiedFilterScreen: LeanplumABVariable<Int>
    let servicesPaymentFrequency: LeanplumABVariable<Int>
    let jobsAndServicesEnabled: LeanplumABVariable<Int>
    let carPromoCells: LeanplumABVariable<Int>
    let servicesPromoCells: LeanplumABVariable<Int>
    let realEstatePromoCells: LeanplumABVariable<Int>
    let proUsersExtraImages: LeanplumABVariable<Int>
    let clickToTalk: LeanplumABVariable<Int>
    
    let group: ABGroup = .verticals
    var intVariables: [LeanplumABVariable<Int>] = []
    var stringVariables: [LeanplumABVariable<String>] = []
    var floatVariables: [LeanplumABVariable<Float>] = []
    var boolVariables: [LeanplumABVariable<Bool>] = []
    
    private init(carExtraFieldsEnabled: LeanplumABVariable<Int>,
                 servicesUnifiedFilterScreen: LeanplumABVariable<Int>,
                 servicesPaymentFrequency: LeanplumABVariable<Int>,
                 jobsAndServicesEnabled: LeanplumABVariable<Int>,
                 carPromoCells: LeanplumABVariable<Int>,
                 servicesPromoCells: LeanplumABVariable<Int>,
                 realEstatePromoCells: LeanplumABVariable<Int>,
                 proUsersExtraImages: LeanplumABVariable<Int>,
                 clickToTalk: LeanplumABVariable<Int>) {
        self.carExtraFieldsEnabled = carExtraFieldsEnabled
        self.servicesUnifiedFilterScreen = servicesUnifiedFilterScreen
        self.servicesPaymentFrequency = servicesPaymentFrequency
        self.jobsAndServicesEnabled = jobsAndServicesEnabled
        self.carPromoCells = carPromoCells
        self.servicesPromoCells = servicesPromoCells
        self.realEstatePromoCells = realEstatePromoCells
        self.proUsersExtraImages = proUsersExtraImages
        self.clickToTalk = clickToTalk
        intVariables.append(contentsOf: [carExtraFieldsEnabled,
                                         servicesUnifiedFilterScreen,
                                         servicesPaymentFrequency,
                                         jobsAndServicesEnabled,
                                         carPromoCells,
                                         servicesPromoCells,
                                         realEstatePromoCells,
                                         proUsersExtraImages,
                                         clickToTalk])
    }
    
    static func make() -> VerticalsABGroup {
        return VerticalsABGroup(carExtraFieldsEnabled: verticalsIntFor(key: Keys.carExtraFieldsEnabled),
                                servicesUnifiedFilterScreen: verticalsIntFor(key: Keys.servicesUnifiedFilterScreen),
                                servicesPaymentFrequency: verticalsIntFor(key: Keys.servicesPaymentFrequency),
                                jobsAndServicesEnabled: verticalsIntFor(key: Keys.jobsAndServicesEnabled),
                                carPromoCells: verticalsIntFor(key: Keys.carPromoCells),
                                servicesPromoCells: verticalsIntFor(key: Keys.servicesPromoCells),
                                realEstatePromoCells: verticalsIntFor(key: Keys.realEstatePromoCells),
                                proUsersExtraImages: verticalsIntFor(key: Keys.proUsersExtraImages),
                                clickToTalk:verticalsIntFor(key: Keys.clickToTalk))
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
    static let carPromoCells = "20182308carPromoCells"
    static let servicesPromoCells = "20182408servicesPromoCells"
    static let realEstatePromoCells = "20182708realEstatePromoCells"
    static let proUsersExtraImages = "20182808allow25ImagesForPros"
    static let clickToTalk = "20182708clickToTalk"
}
