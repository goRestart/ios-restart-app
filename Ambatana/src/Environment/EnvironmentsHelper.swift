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
        case Production = "Production"
        case Staging = "Staging"
        case Canary = "Canary"
    }

    static func appEnvironment() -> AppEnvironmentType {
    #if GOD_MODE
        let coreEnv = coreEnvironment()
        switch coreEnv {
        case .Staging:
            return .Development
        case .Canary:
            return .Production
        case .Production:
            return .Production
        }
    #else
        return .Production
    #endif
    }

    static func coreEnvironment() -> EnvironmentType {
    #if GOD_MODE
        //First check environment
        let envArgs = NSProcessInfo.processInfo().environment
        if envArgs["-environment-prod"] != nil {
            setSettingsEnvironment(.Production)
            return .Production
        } else if envArgs["-environment-dev"] != nil {
            setSettingsEnvironment(.Staging)
            return .Staging
        }

        //Last check settings
        let userDefaults = NSUserDefaults()
        guard let environmentString = userDefaults.stringForKey(settingsEnvironmentKey),
            environment = SettingsEnvironment(rawValue: environmentString) else { return .Production }
        switch environment {
        case .Production:
            return .Production
        case .Canary:
            return .Canary
        case .Staging:
            return .Staging
        }
    #else
        return .Production
    #endif
    }

    private static func setSettingsEnvironment(environment: EnvironmentType) {
        let userDefaults = NSUserDefaults()
        switch environment {
        case .Staging:
            userDefaults.setValue(SettingsEnvironment.Staging.rawValue, forKey: settingsEnvironmentKey)
        case .Canary:
            userDefaults.setValue(SettingsEnvironment.Canary.rawValue, forKey: settingsEnvironmentKey)
        case .Production:
            userDefaults.setValue(SettingsEnvironment.Production.rawValue, forKey: settingsEnvironmentKey)
        }
    }
}
