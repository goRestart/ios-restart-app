//
//  ProductionEnvironment.swift
//  LetGo
//
//  Created by AHL on 28/4/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

struct ProductionEnvironment: Environment {
    let apiBaseURL = "https://letgo-a.akamaihd.net"
    let bouncerBaseURL = "https://bouncer.letgo.com/api"
    let userRatingsBaseURL = "https://rating.letgo.com/api"
    let chatBaseURL = "https://chat.letgo.com"
    let webSocketURL = "wss://chat.letgo.com/socket"
    let notificationsBaseURL = "https://notifications.letgo.com/api"
    let passiveBuyersBaseURL = "https://passivebuyers.letgo.com/api"
    let paymentsBaseURL = "https://payment.letgo.com/payment"
    let suggestiveSearchBaseURL = "https://suggestivesearch.letgo.com"
}
