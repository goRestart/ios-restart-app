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
    
    // Global iVars
    var objectId: String?
    
    var name: String?
    var type: String?
    
    init(name: String?, type: String?) {
        self.name = name
        self.type = type
    }
    
}

extension LGSuggestiveSearch : Decodable {
    
    static func newLGSuggestiveSearch(_ name: String?, type: String?)
        -> LGSuggestiveSearch {
            return LGSuggestiveSearch(name: name, type: type)
    }
    
    /**
     Expects a json in the form:
     
     {
     "items":[
     {
     "name":"door",
     "type":"suggestion",
     "attributes":{}
     },
     ...
     ],
     }
     */
    static func decode(_ j: JSON) -> Decoded<LGSuggestiveSearch> {
        let result1 = curry(LGSuggestiveSearch.newLGSuggestiveSearch)
        let result2 = result1 <^> j <|? "name"
        let result = result2 <*> j <|? "type"
        
        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "LGSuggestiveSearch parse error: \(error)")
        }
        
        return result
    }
    
}
