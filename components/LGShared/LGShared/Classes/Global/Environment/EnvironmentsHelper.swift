//
//  EnvironmentsHelper.swift
//  LetGo
//
//  Created by Eli Kohen on 22/01/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

class EnvironmentsHelper {

    private static let settingsEnvironmentKey = "SettingsBundleEnvironment"
    private static let lastEnvironmentKey = "SettingsBundleLastEnvironment"

    private enum SettingsEnvironment: String {
        case production = "Production"
        case staging = "Staging"
        case canary = "Canary"
        case escrow = "Escrow"
    }

    private(set) var coreEnvironment: EnvironmentType = .production

    var appEnvironment: AppEnvironmentType {
        switch coreEnvironment {
        case .staging:
            return .development
        case .canary:
            return .production
        case .production:
            return .production
        case .escrow:
            return .escrow
        }
    }

    init() {
    #if GOD_MODE
        self.coreEnvironment = getCoreEnvironment()
    #endif
        self.checkEnvironmentChange()
    }

    func getCoreEnvironment() -> EnvironmentType {
        //First check xcode environment
        let envArgs = ProcessInfo.processInfo.environment
        if envArgs["-environment-prod"] != nil {
            setSettingsEnvironment(.production, key: EnvironmentsHelper.settingsEnvironmentKey)
            return .production
        } else if envArgs["-environment-dev"] != nil {
            setSettingsEnvironment(.staging, key: EnvironmentsHelper.settingsEnvironmentKey)
            return .staging
        } else if envArgs["-environment-escrow"] != nil {
            setSettingsEnvironment(.escrow, key: EnvironmentsHelper.settingsEnvironmentKey)
            return .escrow
        }

        //Last check settings
        return getSettingsEnvironment(EnvironmentsHelper.settingsEnvironmentKey)
    }

    private func checkEnvironmentChange() {
        let lastEnvironment = getSettingsEnvironment(EnvironmentsHelper.lastEnvironmentKey)
        if lastEnvironment.rawValue != coreEnvironment.rawValue {
            setSettingsEnvironment(coreEnvironment, key: EnvironmentsHelper.lastEnvironmentKey)

    #if GOD_MODE
        /*There was a change, delete corekit installation and myUser to force cleanup and recreation double wrapped 
        under compiler directive to avoid this code to be executed on production */
        let userDefaults = UserDefaults()
        userDefaults.removeObject(forKey: "Installation")
        userDefaults.removeObject(forKey: "MyUser")
    #endif
        }
    }

    private func getSettingsEnvironment(_ key: String) -> EnvironmentType {
        let userDefaults = UserDefaults()
        guard let environmentString = userDefaults.string(forKey: key),
            let environment = SettingsEnvironment(rawValue: environmentString) else { return .production }
        switch environment {
        case .production:
            return .production
        case .canary:
            return .canary
        case .staging:
            return .staging
        case .escrow:
            return .escrow
        }
    }

    private func setSettingsEnvironment(_ environment: EnvironmentType, key: String) {
        let userDefaults = UserDefaults()
        switch environment {
        case .staging:
            userDefaults.setValue(SettingsEnvironment.staging.rawValue, forKey: key)
        case .canary:
            userDefaults.setValue(SettingsEnvironment.canary.rawValue, forKey: key)
        case .production:
            userDefaults.setValue(SettingsEnvironment.production.rawValue, forKey: key)
        case .escrow:
            userDefaults.setValue(SettingsEnvironment.escrow.rawValue, forKey: key)
        }
    }
}
