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
    
    // Push notifications
    var kahunaAPIKey: String { get }
    
    // App indexing
    var googleAppIndexingId: UInt { get }
    
    // Config
    var configFileName: String { get }

    // Adjust
    var adjustAppToken: String { get }
    var adjustEnvironment: String { get }

    // Twitter
    var twitterConsumerKey: String { get }
    var twitterConsumerSecret: String { get }

    // Taplytics
    var taplyticsApiKey: String { get }
}

extension AppEnvironment {
    var appStoreURL: NSURL? {
        return NSURL(string: String(format: Constants.appStoreURL, arguments: [appleAppId]))
    }
}
