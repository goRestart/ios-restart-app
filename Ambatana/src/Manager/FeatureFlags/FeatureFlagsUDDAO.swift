//
//  FeatureFlagsUDDAO.swift
//  LetGo
//
//  Created by Albert Hernández López on 08/06/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

final class FeatureFlagsUDDAO: FeatureFlagsDAO {
    static let userDefaultsKey = "FeatureFlags"
    
    fileprivate enum Key: String {
        case websocketChatEnabled = "websocketChatEnabled"
        case editLocationBubble = "editLocationBubble"
        case carsVerticalEnabled = "carsVerticalEnabled"
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
    
    func retrieveWebsocketChatEnabled() -> Bool? {
        return retrieve(key: .websocketChatEnabled)
    }
    
    func save(websocketChatEnabled: Bool) {
        save(key: .websocketChatEnabled, value: websocketChatEnabled)
        sync()
    }
    
    func retrieveEditLocationBubble() -> EditLocationBubble? {
        guard let rawValue: String = retrieve(key: .editLocationBubble) else { return nil }
        return EditLocationBubble(rawValue: rawValue)
    }
    
    func save(editLocationBubble: EditLocationBubble) {
        save(key: .editLocationBubble, value: editLocationBubble.rawValue)
        sync()
    }
    
    func retrieveCarsVerticalEnabled() -> Bool? {
        return retrieve(key: .carsVerticalEnabled)
    }
    
    func save(carsVerticalEnabled: Bool) {
        save(key: .carsVerticalEnabled, value: carsVerticalEnabled)
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
