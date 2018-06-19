struct RealEstateABGroup: ABGroupType {
    private struct Keys {
        static let realEstateNewCopy = "20180126RealEstateNewCopy"
        static let realEstateTutorial = "20180309RealEstateTutorial"
        static let summaryAsFirstStep = "20180320SummaryAsFirstStep"
    }
    let realEstateNewCopy: LeanplumABVariable<Int>
    let realEstateTutorial: LeanplumABVariable<Int>
    let summaryAsFirstStep: LeanplumABVariable<Int>

    let group: ABGroup = .realEstate
    var intVariables: [LeanplumABVariable<Int>] = []
    var stringVariables: [LeanplumABVariable<String>] = []
    var floatVariables: [LeanplumABVariable<Float>] = []
    var boolVariables: [LeanplumABVariable<Bool>] = []

    init(realEstateNewCopy: LeanplumABVariable<Int>,
         realEstateTutorial: LeanplumABVariable<Int>,
         summaryAsFirstStep: LeanplumABVariable<Int>) {
        self.realEstateNewCopy = realEstateNewCopy
        self.realEstateTutorial = realEstateTutorial
        self.summaryAsFirstStep = summaryAsFirstStep

        intVariables.append(contentsOf: [realEstateNewCopy, realEstateTutorial, summaryAsFirstStep])
    }

    static func make() -> RealEstateABGroup {
        return RealEstateABGroup(realEstateNewCopy: .makeInt(key: Keys.realEstateNewCopy,
                                                             defaultValue: 0,
                                                             groupType: .realEstate),
                                 realEstateTutorial: .makeInt(key: Keys.realEstateTutorial,
                                                              defaultValue: 0,
                                                              groupType: .realEstate),
                                 summaryAsFirstStep: .makeInt(key: Keys.summaryAsFirstStep,
                                                              defaultValue: 0,
                                                              groupType: .realEstate))
    }
}
