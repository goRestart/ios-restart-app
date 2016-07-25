//
//  DevelopmentEnvironment.swift
//  LetGo
//
//  Created by AHL on 28/4/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import Foundation

struct StagingEnvironment: Environment {
    // API
    let apiBaseURL = "http://api.stg.letgo.com"
    let bouncerBaseURL = "http://bouncer.stg.letgo.com/api"
    let commercializerBaseURL = "http://commercializer.stg.letgo.com"
    let userRatingsBaseURL = "http://rating.stg.letgo.aws/api"
    let webSocketURL = "ws://chat.stg.letgo.com/socket"
}
