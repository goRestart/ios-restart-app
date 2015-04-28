//
//  ProductionEnvironment.swift
//  LetGo
//
//  Created by AHL on 28/4/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import Foundation

public struct ProductionEnvironment: Environment {
    public let parseApplicationId: String = "fMjDVvxiMjuSxciNF67JrB9XQLm6mLuvQ2pjIniu"
    public let parseClientId: String = "VcGL3kgBEqleDz77pPEwd48SROpMu15XVosoqdbv"
    public let apiBaseURL: String = "http://3rdparty.ambatana.com"     // old PROD
//    let apiBaseURL: String = "http://api.letgo.com"             // new PROD
}