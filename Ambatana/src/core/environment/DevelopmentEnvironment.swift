//
//  DevelopmentEnvironment.swift
//  LetGo
//
//  Created by AHL on 28/4/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import Foundation

public struct DevelopmentEnvironment: Environment {
    public let parseApplicationId: String = "3zW8RQIC7yEoG9WhWjNduehap6csBrHQ2whOebiz"
    public let parseClientId: String = "4dmYjzpoyMbAdDdmCTBG6s7TTHtNTAaQaJN6YOAk"
    public let apiBaseURL: String = "http://vps122602.ovh.net"     // old DEV
//    let apiBaseURL: String = "http://devel.api.letgo.com"     // new DEV (requires OAuth)
}