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
        get {
            if let appEnvironment = environment as? AppEnvironment {
                return appEnvironment.appleAppId
            }
            return ""
        }
    }
    var facebookAppId: String {
        get {
            if let appEnvironment = environment as? AppEnvironment {
                return appEnvironment.facebookAppId
            }
            return ""
        }
    }
    var appsFlyerAPIKey: String {
        get {
            if let appEnvironment = environment as? AppEnvironment {
                return appEnvironment.appsFlyerAPIKey
            }
            return ""
        }
    }
    var amplitudeAPIKey: String {
        get {
            if let appEnvironment = environment as? AppEnvironment {
                return appEnvironment.amplitudeAPIKey
            }
            return ""
        }
    }
    var googleConversionTrackingId: String {
        get {
            if let appEnvironment = environment as? AppEnvironment {
                return appEnvironment.googleConversionTrackingId
            }
            return ""
        }
    }

    var nanigansAppId: String {
        get {
            if let appEnvironment = environment as? AppEnvironment {
                return appEnvironment.nanigansAppId
            }
            return ""
        }
    }
    
    var urbanAirshipAPIKey: String {
        get {
            if let appEnvironment = environment as? AppEnvironment {
                return appEnvironment.urbanAirshipAPIKey
            }
            return ""
        }
    }

    var urbanAirshipAPISecret: String {
        get {
            if let appEnvironment = environment as? AppEnvironment {
                return appEnvironment.urbanAirshipAPISecret
            }
            return ""
        }
    }
}
