//
//  LGCarsMake.swift
//  LGCoreKit
//
//  Created by Dídac on 21/03/17.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Argo
import Curry
import Runes

struct LGCarsMake: CarsMake {
    var makeId: String
    var makeName: String
    var models: [CarsModel]

    init(makeId: String, makeName: String, models: [LGCarsModel]) {
        self.makeId = makeId
        self.makeName = makeName
        self.models = models
    }
}


extension LGCarsMake: Decodable {

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
    public static func decode(_ j: JSON) -> Decoded<LGCarsMake> {

        let result = curry(LGCarsMake.init)
            <^> j <| "id"
            <*> j <| "name"
            <*> j <|| "models"

        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "LGCarsMake parse error: \(error)")
        }
        return result
    }
}
