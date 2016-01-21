//
//  DevelopmentEnvironment.swift
//  LetGo
//
//  Created by AHL on 28/4/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import Foundation

struct StagingEnvironment: Environment {
    // Parse
    let parseApplicationId = "RWaXNfBnphULM5paOjBXJVglOlCTxb4h7T2kyY3Z"
    let parseClientId = "sZI4kMi6fx2iQrSWtE3AKfMrgeYX0GwcbrSy6VRq"

    // API
    let apiBaseURL = "http://api.stg.letgo.com"
    let bouncerBaseURL = "http://bouncer.stg.letgo.com/api"

    // Config
    let configURL = "http://letgo-images-devel.s3.amazonaws.com/config/ios.json"
}
