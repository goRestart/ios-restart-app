//
//  DevelopmentEnvironment.swift
//  LetGo
//
//  Created by AHL on 28/4/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

struct StagingEnvironment: Environment {
    let apiBaseURL = "http://api.stg.letgo.com"
    let bouncerBaseURL = "http://bouncer.stg.letgo.com/api"
    let commercializerBaseURL = "http://commercializer.stg.letgo.com"
    let userRatingsBaseURL = "http://rating.stg.letgo.com/api"
    let chatBaseURL = "https://chat.stg.letgo.com"
    let webSocketURL = "wss://chat.stg.letgo.com/socket"
    let notificationsBaseURL = "http://notifications.stg.letgo.com/api"
    let passiveBuyersBaseURL = "http://passivebuyers.stg.letgo.com/api"
}
