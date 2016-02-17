//
//  ProductionEnvironment.swift
//  LetGo
//
//  Created by AHL on 28/4/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import Foundation

struct ProductionEnvironment: Environment {
    // API
    let apiBaseURL = "https://letgo-a.akamaihd.net"
    let bouncerBaseURL = "https://bouncer.letgo.com/api"

    // Config
    let configURL = "https://letgo-images.s3.amazonaws.com/config/ios.json"
}
