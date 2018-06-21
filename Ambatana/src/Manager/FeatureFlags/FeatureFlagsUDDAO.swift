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
        case advancedReputationSystemEnabled = "advancedReputationSystemEnabled"
        case emergencyLocate = "emergencyLocate"
        case chatConversationsListWithoutTabs = "chatConversationsListWithoutTabs"
    }

    fileprivate var dictionary: [String: Any]
    fileprivate let userDefaults: UserDefaults
    fileprivate var networkDAO: NetworkDAO
    
    // MARK: - Lifecycle
    
    convenience init() {
        self.init(userDefaults: UserDefaults.standard, networkDAO: NetworkDefaultsDAO())
    }
    
    init(userDefaults: UserDefaults, networkDAO: NetworkDAO) {
        self.userDefaults = userDefaults
        self.networkDAO = networkDAO
        self.dictionary = FeatureFlagsUDDAO.fetch(userDefaults: userDefaults) ?? [:]
    }
    
    
    // MARK: - FeatureFlagsDAO

    func retrieveTimeoutForRequests() -> TimeInterval? {
        return networkDAO.timeoutIntervalForRequests
    }

    func save(timeoutForRequests: TimeInterval) {
        networkDAO.timeoutIntervalForRequests = timeoutForRequests
    }

    func retrieveAdvanceReputationSystem() -> AdvancedReputationSystem? {
        guard let rawValue: String = retrieve(key: .advancedReputationSystemEnabled) else { return nil }
        return AdvancedReputationSystem(rawValue: rawValue)
    }

    func save(advanceReputationSystem: AdvancedReputationSystem) {
        save(key: .advancedReputationSystemEnabled, value: advanceReputationSystem.rawValue)
        sync()
    }

    func retrieveEmergencyLocate() -> EmergencyLocate? {
        guard let rawValue: String = retrieve(key: .emergencyLocate) else { return nil }
        return EmergencyLocate(rawValue: rawValue)
    }

    func save(emergencyLocate: EmergencyLocate) {
        save(key: .emergencyLocate, value: emergencyLocate.rawValue)
        sync()
    }

    func retrieveChatConversationsListWithoutTabs() -> ChatConversationsListWithoutTabs? {
        guard let rawValue: String = retrieve(key: .chatConversationsListWithoutTabs) else { return nil }
        return ChatConversationsListWithoutTabs(rawValue: rawValue)
    }
    
    func save(chatConversationsListWithoutTabs: ChatConversationsListWithoutTabs) {
        save(key: .chatConversationsListWithoutTabs, value: chatConversationsListWithoutTabs.rawValue)
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
