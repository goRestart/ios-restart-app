//
//  LGSuggestiveSearch.swift
//  LGCoreKit
//
//  Created by Raúl de Oñate Blanco on 12/07/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Argo
import Curry
import Runes

struct LGSuggestiveSearch: SuggestiveSearch {
    let name: String
    let category: ListingCategory?
    
    init(name: String, categoryId: Int?) {
        self.name = name
        if let categoryId = categoryId {
            self.category = ListingCategory(rawValue: categoryId)
        } else {
            self.category = nil
        }
    }
}

extension LGSuggestiveSearch : Decodable {
    
    /**
     Expects a json in the form:
     {
        "name": "iphone",
        "attributes": {
            "categoryId": 1,
            ...
        },
        ...
     }
     */
    static func decode(_ j: JSON) -> Decoded<LGSuggestiveSearch> {
        let result1 = curry(LGSuggestiveSearch.init)
        let result2 = result1 <^> j <| "name"
        let result  = result2 <*> j <|? ["attributes", "categoryId"]
        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "LGSuggestiveSearch parse error: \(error)")
        }
        return result
    }
}
