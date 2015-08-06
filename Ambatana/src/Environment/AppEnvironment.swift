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

    // Tracking
    var appsFlyerAPIKey: String { get }
    var amplitudeAPIKey: String { get }
    var googleConversionTrackingId: String { get }
    
    var urbanAirshipAPIKey: String { get }
    var urbanAirshipAPISecret: String { get }
}
