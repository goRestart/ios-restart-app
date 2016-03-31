//
//  CanaryEnvironment.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 21/01/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

class CanaryEnvironment: Environment {
    // API
    let apiBaseURL = "http://canary.api.letgo.com"
    let bouncerBaseURL = "http://bouncer.canary.letgo.com/api"
    let commercializerBaseURL = "http://commercializer.canary.letgo.com"
    let webSocketURL = "ws://chat.letgo.com/socket"
    
    // Config (same as production)
    let configURL = "https://letgo-images.s3.amazonaws.com/config/ios.json"
}
