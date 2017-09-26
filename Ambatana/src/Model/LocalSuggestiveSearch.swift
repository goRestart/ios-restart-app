//
//  LocalSuggestiveSearch.swift
//  LetGo
//
//  Created by Albert Hernández López on 26/09/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

final class LocalSuggestiveSearch: NSObject, SuggestiveSearch, NSCoding {
    private static let nameKey = "name"
    private static let categoryIdKey = "categoryId"
    
    let name: String
    let category: ListingCategory?

    
    // MARK: - Lifecycle
    
    init(name: String,
         category: ListingCategory?) {
        self.name = name
        self.category = category
    }
    
    
    // MARK: - NSCoding
    
    required init(coder decoder: NSCoder) {
        self.name = decoder.decodeObject(forKey: LocalSuggestiveSearch.nameKey) as? String ?? ""
        if let categoryId = decoder.decodeObject(forKey: LocalSuggestiveSearch.categoryIdKey) as? Int {
            self.category = ListingCategory(rawValue: categoryId)
        } else {
            self.category = nil
        }        
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: LocalSuggestiveSearch.nameKey)
        coder.encode(category?.rawValue, forKey: LocalSuggestiveSearch.categoryIdKey)
    }
}

