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
//    public let apiBaseURL: String = "http://3rdparty.ambatana.com"     // old PROD
    public let apiBaseURL = "http://api.letgo.com"             // new PROD
    public let apiClientId = "2_4iqtxcwybj8k08o8ssw4wkc0c408o8o4g8go8ogok0ss4g48oo"
    public let apiClientSecret = "4hbpw71kl8u80sw8gww44gs0ww8c44kc4wwssw0k08sw4k4ssc"
    
    // Images
    public let imagesBaseURL = "http://api.letgo.com"  // @ahl: to be removed when full image URL is coming in the products response
}