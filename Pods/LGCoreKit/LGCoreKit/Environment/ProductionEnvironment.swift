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
    let commercializerBaseURL = "https://commercializer.letgo.com"
    let userRatingsBaseURL = "https://ratings.letgo.com/api" //TODO: Update when backend team publishes final url
    let webSocketURL = "ws://chat.letgo.com/socket"
}
