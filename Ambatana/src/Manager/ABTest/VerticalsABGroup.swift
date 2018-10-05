struct VerticalsABGroup: ABGroupType {

    let servicesPaymentFrequency: LeanplumABVariable<Int>
    let jobsAndServicesEnabled: LeanplumABVariable<Int>
    let carPromoCells: LeanplumABVariable<Int>
    let servicesPromoCells: LeanplumABVariable<Int>
    let realEstatePromoCells: LeanplumABVariable<Int>
    let proUsersExtraImages: LeanplumABVariable<Int>
    let clickToTalk: LeanplumABVariable<Int>
    let boostSmokeTest: LeanplumABVariable<Int>
    
    let group: ABGroup = .verticals
    var intVariables: [LeanplumABVariable<Int>] = []
    var stringVariables: [LeanplumABVariable<String>] = []
    var floatVariables: [LeanplumABVariable<Float>] = []
    var boolVariables: [LeanplumABVariable<Bool>] = []
    
    private init(servicesPaymentFrequency: LeanplumABVariable<Int>,
                 jobsAndServicesEnabled: LeanplumABVariable<Int>,
                 carPromoCells: LeanplumABVariable<Int>,
                 servicesPromoCells: LeanplumABVariable<Int>,
                 realEstatePromoCells: LeanplumABVariable<Int>,
                 proUsersExtraImages: LeanplumABVariable<Int>,
                 clickToTalk: LeanplumABVariable<Int>,
                 boostSmokeTest: LeanplumABVariable<Int>) {
        self.servicesPaymentFrequency = servicesPaymentFrequency
        self.jobsAndServicesEnabled = jobsAndServicesEnabled
        self.carPromoCells = carPromoCells
        self.servicesPromoCells = servicesPromoCells
        self.realEstatePromoCells = realEstatePromoCells
        self.proUsersExtraImages = proUsersExtraImages
        self.clickToTalk = clickToTalk
        self.boostSmokeTest = boostSmokeTest
        intVariables.append(contentsOf: [servicesPaymentFrequency,
                                         jobsAndServicesEnabled,
                                         carPromoCells,
                                         servicesPromoCells,
                                         realEstatePromoCells,
                                         proUsersExtraImages,
                                         clickToTalk,
                                         boostSmokeTest])
    }
    
    static func make() -> VerticalsABGroup {
        return VerticalsABGroup(servicesPaymentFrequency: verticalsIntFor(key: Keys.servicesPaymentFrequency),
                                jobsAndServicesEnabled: verticalsIntFor(key: Keys.jobsAndServicesEnabled),
                                carPromoCells: verticalsIntFor(key: Keys.carPromoCells),
                                servicesPromoCells: verticalsIntFor(key: Keys.servicesPromoCells),
                                realEstatePromoCells: verticalsIntFor(key: Keys.realEstatePromoCells),
                                proUsersExtraImages: verticalsIntFor(key: Keys.proUsersExtraImages),
                                clickToTalk:verticalsIntFor(key: Keys.clickToTalk),
                                boostSmokeTest:verticalsIntFor(key: Keys.boostSmokeTest))
    }
    
    private static func verticalsIntFor(key: String) -> LeanplumABVariable<Int> {
        return .makeInt(key: key, defaultValue: 0, groupType: .verticals)
    }
}

private struct Keys {
    static let servicesPaymentFrequency = "20180730servicesPriceType"
    static let jobsAndServicesEnabled = "20180806jobsAndServicesEnabled"
    static let carPromoCells = "20182308carPromoCells"
    static let servicesPromoCells = "20182408servicesPromoCells"
    static let realEstatePromoCells = "20182708realEstatePromoCells"
    static let proUsersExtraImages = "20182808allow25ImagesForPros"
    static let clickToTalk = "20182708clickToTalk"
    static let boostSmokeTest = "20180110boostSmokeTest"
}
