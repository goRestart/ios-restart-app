//
//  ProductionEnvironment.swift
//  LetGo
//
//  Created by AHL on 28/4/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import Foundation

public struct ProductionEnvironment: Environment {
    // Parse
    public let parseApplicationId = "fMjDVvxiMjuSxciNF67JrB9XQLm6mLuvQ2pjIniu"
    public let parseClientId = "VcGL3kgBEqleDz77pPEwd48SROpMu15XVosoqdbv"

    // API
    public let apiBaseURL = "https://letgo-a.akamaihd.net" //  old: "http://api.letgo.com"
    public let bouncerBaseURL = "https://bouncer.letgo.com/api"  // canary: "bouncer.canary.letgo.com"

    // Config
    public let configURL = "https://letgo-images.s3.amazonaws.com/config/ios.json"
}
