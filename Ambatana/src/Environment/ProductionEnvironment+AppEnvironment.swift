//
//  ProductionEnvironment+AppEnvironment.swift
//  LetGo
//
//  Created by Albert Hernández López on 07/05/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

extension ProductionEnvironment: AppEnvironment {
    // General
    var appleAppId: String { get { return "986339882" } }
    var facebookAppId: String { get { return "699538486794082" } }
    
    // Tracking
    var appsFlyerAPIKey: String { get { return "5EKnCjmwmNKjE2e7gYBo6T" } }
    var amplitudeAPIKey: String { get { return "6d37fbd6c25243c57676e6d4ce7948bf" } }
    var googleConversionTrackingId: String { get { return "947998763" } }
    var nanigansAppId: String { get { return "298434" } }
    
    var urbanAirshipAPIKey: String { get { return "554gl4nfTgGQKYpZN_m5aQ"} }
    var urbanAirshipAPISecret: String { get { return "13N1n6bTRuqGsAev6eWDSA"} }
}
