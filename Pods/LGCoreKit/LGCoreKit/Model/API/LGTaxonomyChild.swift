//
//  LGTaxonomyChild.swift
//  LGCoreKit
//
//  Created by Dídac on 17/07/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Argo
import Curry
import Runes

public struct LGTaxonomyChild: TaxonomyChild {
    public let id: Int
    public let type: TaxonomyChildType
    public let name: String
    public let highlightOrder: Int?
    public let highlightIcon: URL?
    public let image: URL?

    init(id: Int, type: String, name: String, highlightOrder: Int?, highlightIcon: String?, image: String?) {
        self.id = id
        self.type = TaxonomyChildType(rawValue: type) ?? .superKeyword
        self.name = name
        self.highlightOrder = highlightOrder
        if let icon = highlightIcon {
            self.highlightIcon = URL(string: icon)
        } else {
            self.highlightIcon = nil
        }
        if let actualImage = image {
            self.image = URL(string: actualImage)
        } else {
            self.image = nil
        }
    }
}

extension LGTaxonomyChild : Decodable {

    /**
     Expects a json in the form:
     {
        "id": 2,
        "type": "superkeyword",
        "name": "Phones",
        "highlight_order": 1,
        "highlight_icon": "https://static.letgo.com/category-icons/phones_superkw.png",
        "image": "https://static.letgo.com/superkeyword_images/Tools&Machinery.jpg"
     }
 
    or 
 
    {
        "id": 9,
        "type": "category",
        "name": "Cars & Trucks",
        "highlight_order": 2,
        "highlight_icon": "https://static.letgo.com/category-icons/cars_and_trucks_superkw.png",
        "image": "https://static.letgo.com/superkeyword_images/Tools&Machinery.jpg"
    }
     **/


    public static func decode(_ j: JSON) -> Decoded<LGTaxonomyChild> {
        let result1 = curry(LGTaxonomyChild.init)
        let result2 = result1 <^> j <| "id"
        let result3 = result2 <*> j <| "type"
        let result4 = result3 <*> j <| "name"
        let result5 = result4 <*> j <|? "highlight_order"
        let result6 = result5 <*> j <|? "highlight_icon"
        let result  = result6 <*> j <|? "image"
        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "LGTaxonomyChild parse error: \(error)")
        }
        return result
    }
}
