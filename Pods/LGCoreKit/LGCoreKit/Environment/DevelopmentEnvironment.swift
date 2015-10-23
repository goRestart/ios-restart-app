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
    public let parseApplicationId = "3zW8RQIC7yEoG9WhWjNduehap6csBrHQ2whOebiz"
    public let parseClientId = "4dmYjzpoyMbAdDdmCTBG6s7TTHtNTAaQaJN6YOAk"

    // API
    public let apiBaseURL = "http://devel.api.letgo.com"
    public let apiClientId = "2_63roc3zwvhc0cgkkcs0wg0ogkwks0wcg8kgswcswsggg8ogokk"
    public let apiClientSecret = "64szvwjvm1wkwgogswsgccoco4ggckkwg444kswccg0404g040"
    
    // Images
    public let imagesBaseURL = "http://devel.cdn.letgo.com/images"  // @ahl: to be removed when full image URL is coming in the products response
    
    // Config
    public let configURL = "http://letgo-images-devel.s3.amazonaws.com/config/ios.json"
}