//
//  ApiCarsMake.swift
//  LGCoreKit
//
//  Created by Dídac on 21/03/17.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Argo
import Curry
import Runes

struct ApiCarsMake: CarsMakeWithModels {
    var makeId: String
    var makeName: String
    var models: [CarsModel]

    init(makeId: String, makeName: String, models: [ApiCarsModel]) {
        self.makeId = makeId
        self.makeName = makeName
        self.models = models
    }
}


extension ApiCarsMake: Decodable {

    /*
     {
     "id": "f762a529-6e99-4244-9568-e31b6705edb5", // uuid4
     "name": "Audi", // string
     "models": [
        {
            "id": "b243756c-456b-4132-8a6f-c63758551f77",  // uuid4
            "name": "A3", // string
        },
        ...
     ]
     }
     */
    public static func decode(_ j: JSON) -> Decoded<ApiCarsMake> {
        let result1 = curry(ApiCarsMake.init)
        let result2 = result1 <^> j <| "id"
        let result3 = result2 <*> j <| "name"
        let result  = result3 <*> j <|| "models"
        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "ApiCarsMake parse error: \(error)")
        }
        return result
    }
}
