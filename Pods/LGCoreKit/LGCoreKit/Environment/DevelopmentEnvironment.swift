//
//  DevelopmentEnvironment.swift
//  LetGo
//
//  Created by AHL on 28/4/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import Foundation

public struct DevelopmentEnvironment: Environment {
    // Parse
    public let parseApplicationId = "RWaXNfBnphULM5paOjBXJVglOlCTxb4h7T2kyY3Z"// old_dev: "3zW8RQIC7yEoG9WhWjNduehap6csBrHQ2whOebiz"
    public let parseClientId = "sZI4kMi6fx2iQrSWtE3AKfMrgeYX0GwcbrSy6VRq"// old_dev: "4dmYjzpoyMbAdDdmCTBG6s7TTHtNTAaQaJN6YOAk"

    // API
    public let apiBaseURL = "http://api.stg.letgo.com"  // old_dev: "http://devel.api.letgo.com"
    public let bouncerBaseURL = "http://bouncer.stg.letgo.com/api"

    // Config
    public let configURL = "http://letgo-images-devel.s3.amazonaws.com/config/ios.json"
}
