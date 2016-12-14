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

    private(set) var coreEnvironment: EnvironmentType

    var appEnvironment: AppEnvironmentType {
        switch coreEnvironment {
        case .Staging:
            return .Development
        case .Canary:
            return .Production
        case .Production:
            return .Production
        case .Escrow:   // TODO: Fix when merging w latest version
            return .Production
        }
    }

    init() {
        self.coreEnvironment = .Production
    #if GOD_MODE
        self.coreEnvironment = getCoreEnvironment()
        self.checkEnvironmentChange()
    #endif
    }

    func getCoreEnvironment() -> EnvironmentType {
        //First check xcode environment
        let envArgs = NSProcessInfo.processInfo().environment
        if envArgs["-environment-prod"] != nil {
            setSettingsEnvironment(.Production, key: EnvironmentsHelper.settingsEnvironmentKey)
            return .Production
        } else if envArgs["-environment-dev"] != nil {
            setSettingsEnvironment(.Staging, key: EnvironmentsHelper.settingsEnvironmentKey)
            return .Staging
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
        let userDefaults = NSUserDefaults()
        userDefaults.removeObjectForKey("Installation")
        userDefaults.removeObjectForKey("MyUser")
    #endif
        }
    }

    private func getSettingsEnvironment(key: String) -> EnvironmentType {
        let userDefaults = NSUserDefaults()
        guard let environmentString = userDefaults.stringForKey(key),
            environment = SettingsEnvironment(rawValue: environmentString) else { return .Production }
        switch environment {
        case .Production:
            return .Production
        case .Canary:
            return .Canary
        case .Staging:
            return .Staging
        }
    }

    private func setSettingsEnvironment(environment: EnvironmentType, key: String) {
        let userDefaults = NSUserDefaults()
        switch environment {
        case .Staging:
            userDefaults.setValue(SettingsEnvironment.Staging.rawValue, forKey: key)
        case .Canary:
            userDefaults.setValue(SettingsEnvironment.Canary.rawValue, forKey: key)
        case .Production:
            userDefaults.setValue(SettingsEnvironment.Production.rawValue, forKey: key)
        case .Escrow:   // TODO: Fix when merging w latest version
            break
        }
    }
}
