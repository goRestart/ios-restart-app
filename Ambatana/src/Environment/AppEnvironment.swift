//
//  AppEnvironment.swift
//  LetGo
//
//  Created by Albert Hernández López on 07/05/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

protocol AppEnvironment: Environment {
    // General
    var appleAppId: String { get }
    var facebookAppId: String { get }

    // Tracking
    var appsFlyerAPIKey: String { get }
    var amplitudeAPIKey: String { get }
    var googleConversionPrimaryTrackingId: String { get }
    var googleConversionSecondaryTrackingId: String { get }
    var nanigansAppId: String { get }
    
    // Push notifications
    var kahunaAPIKey: String { get }
    
    // New relic
    var newRelicToken: String { get }
}
