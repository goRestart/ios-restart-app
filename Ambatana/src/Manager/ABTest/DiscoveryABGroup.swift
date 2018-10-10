import Foundation

struct DiscoveryABGroup: ABGroupType {
    private struct Keys {
        static let personalizedFeed = "20180509PersonalizedFeed"
        static let sectionedFeed = "20180828SectionedDiscoveryFeed"
        static let newSearchAPI = "20180927NewSearchAPI"
    }
    
    let personalizedFeed: LeanplumABVariable<Int>
    let sectionedFeed: LeanplumABVariable<Int>
    let newSearchAPI: LeanplumABVariable<Int>
    
    let group: ABGroup = .discovery
    var intVariables: [LeanplumABVariable<Int>] = []
    var stringVariables: [LeanplumABVariable<String>] = []
    var floatVariables: [LeanplumABVariable<Float>] = []
    var boolVariables: [LeanplumABVariable<Bool>] = []
    
    init(personalizedFeed: LeanplumABVariable<Int>,
         sectionedFeed: LeanplumABVariable<Int>,
         newSearchAPI: LeanplumABVariable<Int>) {
        self.personalizedFeed = personalizedFeed
        self.sectionedFeed = sectionedFeed
        self.newSearchAPI = newSearchAPI
        intVariables.append(contentsOf: [personalizedFeed,
                                         sectionedFeed,
                                         newSearchAPI])
    }
    
    static func make() -> DiscoveryABGroup {
        return DiscoveryABGroup(personalizedFeed: .makeInt(key: Keys.personalizedFeed,
                                                           defaultValue: 0,
                                                           groupType: .discovery),
                                sectionedFeed: .makeInt(key: Keys.sectionedFeed,
                                                        defaultValue: 0,
                                                        groupType: .discovery),
                                newSearchAPI: .makeInt(key: Keys.newSearchAPI,
                                                        defaultValue: 0,
                                                        groupType: .discovery)
        )
    }
}
