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
    
    // Push notifications
    var kahunaAPIKey: String { get }
    
    // App indexing
    var googleAppIndexingId: UInt { get }

    // Google login
    var googleServerClientID: String { get }

    // Config
    var configFileName: String { get }

    // Twitter
    var twitterConsumerKey: String { get }
    var twitterConsumerSecret: String { get }

    // Leanplum
    var leanplumAppId: String { get }
    var leanplumEnvKey: String { get }

    // Config
    var configURL: String { get }
}
