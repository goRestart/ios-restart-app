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
    
    // Tracking
    var appsFlyerAPIKey: String { get { return "5EKnCjmwmNKjE2e7gYBo6T" } }
    var amplitudeAPIKey: String { get { return "6d37fbd6c25243c57676e6d4ce7948bf" } }
    var googleConversionTrackingId: String { get { return "949799886" } }
}
