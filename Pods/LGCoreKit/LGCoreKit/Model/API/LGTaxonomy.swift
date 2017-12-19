//
//  LGTaxonomy.swift
//  LGCoreKit
//
//  Created by Dídac on 17/07/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

public struct LGTaxonomy: Taxonomy, Decodable {
    public let name: String
    public let icon: URL?
    public let children: [TaxonomyChild]

    
    // MARK: - Lifecycle
    
    init(name: String,
         icon: String,
         children: [LGTaxonomyChild]) {
        self.name = name
        self.icon = URL(string: icon)
        self.children = children
    }
    
    
    // MARK: - Decodable
    
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
     */
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try keyedContainer.decode(String.self, forKey: .name)
        self.icon = try keyedContainer.decodeIfPresent(URL.self, forKey: .icon)
        self.children = try keyedContainer.decode([LGTaxonomyChild].self, forKey: .children)
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case icon
        case children
    }
}
