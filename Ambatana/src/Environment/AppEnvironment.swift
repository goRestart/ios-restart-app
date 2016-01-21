//
//  AppEnvironment.swift
//  LetGo
//
//  Created by Albert Hernández López on 07/05/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

protocol AppEnvironment {
    // General
    var appleAppId: String { get }
    var facebookAppId: String { get }

    // Tracking
    var appsFlyerAPIKey: String { get }
    var amplitudeAPIKey: String { get }
    var gcPrimaryTrackingId: String { get }
    var gcSecondaryTrackingId: String { get }
    var nanigansAppId: String { get }
    
    // Push notifications
    var kahunaAPIKey: String { get }
    
    // New relic
    var newRelicToken: String { get }
    
    // App indexing
    var googleAppIndexingId: UInt { get }
    
    // Config
    var configFileName: String { get }
    
    // AB Testing
    var optimizelyAPIKey: String { get }

    // Adjust
    var adjustAppToken: String { get }
    var adjustEnvironment: String { get }
}

extension AppEnvironment {
    var appStoreURL: NSURL? {
        return NSURL(string: String(format: Constants.appStoreURL, arguments: [appleAppId]))
    }
}
