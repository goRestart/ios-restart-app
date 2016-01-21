//
//  DevelopmentEnvironment+AppEnvironment.swift
//  LetGo
//
//  Created by Albert Hernández López on 07/05/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import Adjust

class DevelopmentEnvironment: AppEnvironment {
    // General
    var appleAppId: String { get { return "986339882" } }
    var facebookAppId: String { get { return "924384130976182" } }
    
    // Tracking
    var appsFlyerAPIKey: String { get { return "5EKnCjmwmNKjE2e7gYBo6T" } }
    var amplitudeAPIKey: String { get { return "1c32ba5ed444237608436bad4f310307" } }
    var gcPrimaryTrackingId: String { get { return "947998763" } }
    var gcSecondaryTrackingId: String { get { return "952362970" } }
    var nanigansAppId: String { get { return "298434" } }
    
    // Push notifications
    var urbanAirshipAPIKey: String { get { return "psjAmPh7RD-qPQXMykcPXQ" } }
    var urbanAirshipAPISecret: String { get { return "GfoA9hGdSOC0_JyFWqmGdQ" } }
    
    var kahunaAPIKey: String { get { return "9188e3c6b7cf47acb94a10ab027a08f3" } }
    
    // New relic
    var newRelicToken: String { get { return "AA448d0966d24653a9a1c92e2d37f86ef5ec61cc7c" } }
    
    // App indexing
    var googleAppIndexingId: UInt { get { return 986339882} }

    // Config
    var configFileName: String { get { return "ios-devel" } }
    
    // AB Testing
    var optimizelyAPIKey: String { get { return "AANI18IBpYo0Me6aWVN88XVYBszyWl3f~3728230154" } }

    // Adjust
    var adjustAppToken: String { get { return "ddy5ww1scx6o" } }
    var adjustEnvironment: String { get { return ADJEnvironmentSandbox } }
}
