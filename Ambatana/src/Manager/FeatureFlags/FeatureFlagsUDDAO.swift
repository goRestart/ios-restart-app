//
//  FeatureFlagsUDDAO.swift
//  LetGo
//
//  Created by Albert Hernández López on 08/06/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit

final class FeatureFlagsUDDAO: FeatureFlagsDAO {
    static let userDefaultsKey = "FeatureFlags"
    
    fileprivate enum Key: String {
        case newUserProfileEnabled = "newUserProfileEnabled"
        case emergencyLocate = "emergencyLocate"
        case community = "community"
        case advancedReputationSystem12 = "advancedReputationSystem12"
        case mutePushNotifications = "mutePushNotifications"
        case mutePushNotificationsStartHour = "mutePushNotificationsStartHour"
        case mutePushNotificationsEndHour = "mutePushNotificationsEndHour"
    }

    fileprivate var dictionary: [String: Any]
    fileprivate let userDefaults: UserDefaults
    
    // MARK: - Lifecycle
    
    convenience init() {
        self.init(userDefaults: UserDefaults.letgo)
    }
    
    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
        self.dictionary = FeatureFlagsUDDAO.fetch(userDefaults: userDefaults) ?? [:]
    }
    
    
    // MARK: - FeatureFlagsDAO

    func retrieveEmergencyLocate() -> EmergencyLocate? {
        guard let rawValue: String = retrieve(key: .emergencyLocate) else { return nil }
        return EmergencyLocate(rawValue: rawValue)
    }

    func save(emergencyLocate: EmergencyLocate) {
        save(key: .emergencyLocate, value: emergencyLocate.rawValue)
        sync()
    }

    func retrieveCommunity() -> ShowCommunity? {
        guard let rawValue: String = retrieve(key: .community) else { return nil }
        return ShowCommunity(rawValue: rawValue)
    }

    func save(community: ShowCommunity) {
        save(key: .community, value: community.rawValue)
        sync()
    }

    func retrieveAdvancedReputationSystem12() -> AdvancedReputationSystem12? {
        guard let rawValue: String = retrieve(key: .advancedReputationSystem12) else { return nil }
        return AdvancedReputationSystem12(rawValue: rawValue)
    }

    func save(advancedReputationSystem12: AdvancedReputationSystem12) {
        save(key: .advancedReputationSystem12, value: advancedReputationSystem12.rawValue)
        sync()
    }

    func retrieveMutePushNotifications() -> (MutePushNotifications, hourStart: Int, hourEnd: Int)? {
        guard
            let rawValue: String = retrieve(key: .mutePushNotifications),
            let start: Int = retrieve(key: .mutePushNotificationsStartHour),
            let end: Int = retrieve(key: .mutePushNotificationsEndHour),
            let mutePushNotifications = MutePushNotifications(rawValue: rawValue)
            else {
                return nil
        }
        return (mutePushNotifications, hourStart: start, hourEnd: end)
    }

    func save(mutePushNotifications: MutePushNotifications, hourStart: Int, hourEnd: Int) {
        save(key: .mutePushNotifications, value: mutePushNotifications.rawValue)
        save(key: .mutePushNotificationsStartHour, value: hourStart)
        save(key: .mutePushNotificationsEndHour, value: hourEnd)
        sync()
    }
}


// MARK: - Private methods

fileprivate extension FeatureFlagsUDDAO {
    static func fetch(userDefaults: UserDefaults) -> [String: Any]? {
        return userDefaults.dictionary(forKey: FeatureFlagsUDDAO.userDefaultsKey)
    }

    func retrieve<T>(key: Key) -> T? {
        return dictionary[key.rawValue] as? T
    }

    func save<T>(key: Key, value: T) {
        dictionary[key.rawValue] = value
    }

    func sync() {
        userDefaults.setValue(dictionary, forKey: FeatureFlagsUDDAO.userDefaultsKey)
    }
}
