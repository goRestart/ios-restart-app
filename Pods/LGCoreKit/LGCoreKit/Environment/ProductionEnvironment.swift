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
    let userRatingsBaseURL = "https://rating.letgo.com/api"
    let chatBaseURL = "https://chat.letgo.com"
    let webSocketURL = "wss://chat.letgo.com/socket"
}
