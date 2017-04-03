//
//  LGCarsModel.swift
//  LGCoreKit
//
//  Created by Dídac on 21/03/17.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Argo
import Curry
import Runes

struct LGCarsModel: CarsModel {
    var modelId: String
    var modelName: String

    init(modelId: String, modelName: String) {
        self.modelId = modelId
        self.modelName = modelName
    }
}


extension LGCarsModel: Decodable {

    /*
     {
     "id": "b243756c-456b-4132-8a6f-c63758551f77",  // uuid4
     "name": "A3", // string
     }
     */
    public static func decode(_ j: JSON) -> Decoded<LGCarsModel> {

        let result = curry(LGCarsModel.init)
            <^> j <| "id"
            <*> j <| "name"

        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "LGCarsModel parse error: \(error)")
        }
        return result
    }
}
