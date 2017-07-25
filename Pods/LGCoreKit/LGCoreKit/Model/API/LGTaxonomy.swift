//
//  LGTaxonomy.swift
//  LGCoreKit
//
//  Created by Dídac on 17/07/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Argo
import Curry
import Runes

public struct LGTaxonomy: Taxonomy {
    public let name: String
    public let icon: URL?
    public let children: [TaxonomyChild]

    init(name: String, icon: String, children: [LGTaxonomyChild]) {
        self.name = name
        self.icon = URL(string: icon)
        self.children = children
    }
}

extension LGTaxonomy : Decodable {

    /**
     Expects a json in the form:
     {
        "name": "Electronics",
        "icon": "https://static.letgo.com/category-icons/electronics_title.png",
        "children": [
            {
                "id": 2,
                "type": "superkeyword",
                "name": "Phones",
                "highlight_order": 1,
                "highlight_icon": "https://static.letgo.com/category-icons/phones_superkw.png"
            },
            ...
        ]
     }
     **/


    public static func decode(_ j: JSON) -> Decoded<LGTaxonomy> {
        let result1 = curry(LGTaxonomy.init)
        let result2 = result1 <^> j <| "name"
        let result3 = result2 <*> j <| "icon"
        let result  = result3 <*> j <|| "children"
        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "LGTaxonomy parse error: \(error)")
        }
        return result
    }
}
