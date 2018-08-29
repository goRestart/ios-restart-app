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
        case advancedReputationSystem11 = "advancedReputationSystem11"
    }

    fileprivate var dictionary: [String: Any]
    fileprivate let userDefaults: UserDefaults
    
    // MARK: - Lifecycle
    
    convenience init() {
        self.init(userDefaults: UserDefaults.standard)
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

    func retrieveAdvancedReputationSystem11() -> AdvancedReputationSystem11? {
        guard let rawValue: String = retrieve(key: .advancedReputationSystem11) else { return nil }
        return AdvancedReputationSystem11(rawValue: rawValue)
    }

    func save(advancedReputationSystem11: AdvancedReputationSystem11) {
        save(key: .advancedReputationSystem11, value: advancedReputationSystem11.rawValue)
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
