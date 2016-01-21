//
//  CanaryEnvironment.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 21/01/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

class CanaryEnvironment: Environment {
    // Parse (same as production)
    let parseApplicationId = "fMjDVvxiMjuSxciNF67JrB9XQLm6mLuvQ2pjIniu"
    let parseClientId = "VcGL3kgBEqleDz77pPEwd48SROpMu15XVosoqdbv"

    // API
    let apiBaseURL = "http://canary.api.letgo.com"
    let bouncerBaseURL = "http://bouncer.canary.letgo.com/api"

    // Config (same as production)
    let configURL = "https://letgo-images.s3.amazonaws.com/config/ios.json"
}
