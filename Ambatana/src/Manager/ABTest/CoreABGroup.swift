//
//  ABCore.swift
//  LetGo
//
//  Created by Facundo Menzella on 29/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

struct CoreABGroup: ABGroupType {
    private struct Keys {
        static let searchImprovements = "20180313SearchImprovements"
        static let relaxedSearch = "20180319RelaxedSearch"
        static let muteNotifications = "20180906MutePushNotifications"
        static let muteNotificationsStartHour = "20180906MutePushNotificationsHourStart"
        static let muteNotificationsEndHour = "20180906MutePushNotificationsHourEnd"
    }
    let searchImprovements: LeanplumABVariable<Int>
    let relaxedSearch: LeanplumABVariable<Int>
    let mutePushNotifications: LeanplumABVariable<Int>
    let mutePushNotificationsStartHour: LeanplumABVariable<Int>
    let mutePushNotificationsEndHour: LeanplumABVariable<Int>

    let group: ABGroup = .retention
    var intVariables: [LeanplumABVariable<Int>] = []
    var stringVariables: [LeanplumABVariable<String>] = []
    var floatVariables: [LeanplumABVariable<Float>] = []
    var boolVariables: [LeanplumABVariable<Bool>] = []
    
    init(searchImprovements: LeanplumABVariable<Int>,
         relaxedSearch: LeanplumABVariable<Int>,
         mutePushNotifications: LeanplumABVariable<Int>,
         mutePushNotificationsStartHour: LeanplumABVariable<Int>,
         mutePushNotificationsEndHour: LeanplumABVariable<Int>) {
        self.searchImprovements = searchImprovements
        self.relaxedSearch = relaxedSearch
        self.mutePushNotifications = mutePushNotifications
        self.mutePushNotificationsStartHour = mutePushNotificationsStartHour
        self.mutePushNotificationsEndHour = mutePushNotificationsEndHour
        intVariables.append(contentsOf: [
            searchImprovements,
            relaxedSearch,
            mutePushNotifications,
            mutePushNotificationsStartHour,
            mutePushNotificationsEndHour
            ])
    }
    
    static func make() -> CoreABGroup {
        return CoreABGroup(searchImprovements: .makeInt(key: Keys.searchImprovements,
                                                        defaultValue: 0,
                                                        groupType: .core),
                           relaxedSearch: .makeInt(key: Keys.relaxedSearch,
                                                   defaultValue: 0,
                                                   groupType: .core),
                           mutePushNotifications: .makeInt(key: Keys.muteNotifications,
                                                           defaultValue: 0,
                                                           groupType: .core),
                           mutePushNotificationsStartHour: .makeInt(key: Keys.muteNotificationsStartHour,
                                                                    defaultValue: 23,
                                                                    groupType: .core),
                           mutePushNotificationsEndHour: .makeInt(key: Keys.muteNotificationsEndHour,
                                                                  defaultValue: 6,
                                                                    groupType: .core))
    }
}
