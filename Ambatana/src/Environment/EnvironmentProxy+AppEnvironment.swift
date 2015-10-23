//
//  EnvironmentProxy+AppEnvironment.swift
//  LetGo
//
//  Created by Albert Hernández López on 07/05/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

extension EnvironmentProxy: AppEnvironment {

    // MARK: - AppEnvironment
    
    var appleAppId: String {
        if let appEnvironment = environment as? AppEnvironment {
            return appEnvironment.appleAppId
        }
        return ""
    }
    var facebookAppId: String {
        if let appEnvironment = environment as? AppEnvironment {
            return appEnvironment.facebookAppId
        }
        return ""
    }
    var appsFlyerAPIKey: String {
        if let appEnvironment = environment as? AppEnvironment {
            return appEnvironment.appsFlyerAPIKey
        }
        return ""
    }
    var amplitudeAPIKey: String {
        if let appEnvironment = environment as? AppEnvironment {
            return appEnvironment.amplitudeAPIKey
        }
        return ""
    }
    var googleConversionTrackingId: String {
        if let appEnvironment = environment as? AppEnvironment {
            return appEnvironment.googleConversionTrackingId
        }
        return ""
    }

    var nanigansAppId: String {
        if let appEnvironment = environment as? AppEnvironment {
            return appEnvironment.nanigansAppId
        }
        return ""
    }
    
    var kahunaAPIKey: String {
        if let appEnvironment = environment as? AppEnvironment {
            return appEnvironment.kahunaAPIKey
        }
        return ""
    }
    
    var newRelicToken: String {
        if let appEnvironment = environment as? AppEnvironment {
            return appEnvironment.newRelicToken
        }
        return ""
    }
    
    var googleAppIndexingId: UInt {
        if let appEnvironment = environment as? AppEnvironment {
            return appEnvironment.googleAppIndexingId
        }
        return 0

    var configFileName: String {
        if let appEnvironment = environment as? AppEnvironment {
            return appEnvironment.configFileName
        }
        return ""
    }
}
