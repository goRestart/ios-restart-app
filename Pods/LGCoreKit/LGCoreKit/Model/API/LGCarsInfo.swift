//
//  LGCarsInfo.swift
//  LGCoreKit
//
//  Created by Dídac on 21/03/17.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Argo
import Curry
import Runes


struct LGCarsInfo: CarsInfo {
    var makesList: [CarsMake]
    var others: CarsOthers

    init(makesList: [LGCarsMake], others: LGCarsOthers) {
        self.makesList = makesList
        self.others = others
    }
}


extension LGCarsInfo: Decodable {

    /*
     {
     "list": [
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
        },
     ...
     ],
     "others": {
     "make": "f762a529-6e99-4244-9568-e31b6705edb5",
     "model": "f762a529-6e99-4244-9568-e31b6705edb5"
     }
     }
     */
    public static func decode(_ j: JSON) -> Decoded<LGCarsInfo> {

        let result = curry(LGCarsInfo.init)
            <^> j <|| "list"
            <*> j <| "others"

        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "LGCarsInfo parse error: \(error)")
        }
        return result
    }
}
