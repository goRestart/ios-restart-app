import Foundation

struct CoreABGroup: ABGroupType {
    private struct Keys {
        static let searchImprovements = "20180313SearchImprovements"
        static let relaxedSearch = "20180319RelaxedSearch"
        static let muteNotifications = "20180906MutePushNotifications"
        static let muteNotificationsStartHour = "20180906MutePushNotificationsHourStart"
        static let muteNotificationsEndHour = "20180906MutePushNotificationsHourEnd"
        static let facebookUnavailable = "20181001FacebookUnavailable"
    }
    let searchImprovements: LeanplumABVariable<Int>
    let relaxedSearch: LeanplumABVariable<Int>
    let mutePushNotifications: LeanplumABVariable<Int>
    let mutePushNotificationsStartHour: LeanplumABVariable<Int>
    let mutePushNotificationsEndHour: LeanplumABVariable<Int>
    let facebookUnavailable: LeanplumABVariable<Bool>

    let group: ABGroup = .core
    var intVariables: [LeanplumABVariable<Int>] = []
    var stringVariables: [LeanplumABVariable<String>] = []
    var floatVariables: [LeanplumABVariable<Float>] = []
    var boolVariables: [LeanplumABVariable<Bool>] = []
    
    init(searchImprovements: LeanplumABVariable<Int>,
         relaxedSearch: LeanplumABVariable<Int>,
         mutePushNotifications: LeanplumABVariable<Int>,
         mutePushNotificationsStartHour: LeanplumABVariable<Int>,
         mutePushNotificationsEndHour: LeanplumABVariable<Int>,
         facebookUnavailable: LeanplumABVariable<Bool>) {
        self.searchImprovements = searchImprovements
        self.relaxedSearch = relaxedSearch
        self.mutePushNotifications = mutePushNotifications
        self.mutePushNotificationsStartHour = mutePushNotificationsStartHour
        self.mutePushNotificationsEndHour = mutePushNotificationsEndHour
        self.facebookUnavailable = facebookUnavailable
        intVariables.append(contentsOf: [
            searchImprovements,
            relaxedSearch,
            mutePushNotifications,
            mutePushNotificationsStartHour,
            mutePushNotificationsEndHour
            ])
        boolVariables.append(contentsOf:[
            facebookUnavailable
            ])
    }
    
    static func make() -> CoreABGroup {
        return CoreABGroup(searchImprovements: coreIntFor(key: Keys.searchImprovements),
                           relaxedSearch: coreIntFor(key: Keys.relaxedSearch),
                           mutePushNotifications: coreIntFor(key: Keys.muteNotifications),
                           mutePushNotificationsStartHour: coreIntFor(key: Keys.muteNotificationsStartHour, value: 23),
                           mutePushNotificationsEndHour: coreIntFor(key: Keys.muteNotificationsEndHour, value: 6),
                           facebookUnavailable: coreBoolFor(key: Keys.facebookUnavailable, value: false)
        )
    }

    private static func coreIntFor(key: String, value: Int = 0) -> LeanplumABVariable<Int> {
        return .makeInt(key: key, defaultValue: value, groupType: .core)
    }
    
    private static func coreBoolFor(key: String, value: Int = 0) -> LeanplumABVariable<Bool> {
        return .makeBool(key: key, defaultValue: value, groupType: .core)
    }
}
