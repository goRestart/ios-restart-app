//
//  LGCarsOthers.swift
//  LGCoreKit
//
//  Created by Dídac on 21/03/17.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Argo
import Curry
import Runes


struct LGCarsOthers: CarsOthers {
    var makeId: String
    var modelId: String

    init(makeId: String, modelId: String) {
        self.makeId = makeId
        self.modelId = modelId
    }
}


extension LGCarsOthers: Decodable {
    /*
     "others": {
        "make": "f762a529-6e99-4244-9568-e31b6705edb5",
        "model": "f762a529-6e99-4244-9568-e31b6705edb5"
     }
     */
    public static func decode(_ j: JSON) -> Decoded<LGCarsOthers> {

        let result = curry(LGCarsOthers.init)
            <^> j <| "make"
            <*> j <| "model"

        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "LGCarsOthers parse error: \(error)")
        }
        return result
    }
}
