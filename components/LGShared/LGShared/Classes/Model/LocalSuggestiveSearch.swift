//
//  LocalSuggestiveSearch.swift
//  LetGo
//
//  Created by Albert Hernández López on 26/09/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
import SwiftyUserDefaults

final class LocalSuggestiveSearch: NSObject, NSCoding {
    private static let typeKey = "type"
    private static let typeValueTerm = 0
    private static let typeValueCategory = 1
    private static let typeValueTermWithCategory = 2
    private static let nameKey = "name"
    private static let categoryIdKey = "categoryId"
    
    let suggestiveSearch: SuggestiveSearch

    
    // MARK: - Lifecycle
    
    init(suggestiveSearch: SuggestiveSearch) {
        self.suggestiveSearch = suggestiveSearch
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let otherLocalSuggestiveSearch = object as? LocalSuggestiveSearch else { return false }
        return suggestiveSearch == otherLocalSuggestiveSearch.suggestiveSearch
    }
    
    
    // MARK: - NSCoding
    
    required init?(coder decoder: NSCoder) {
        let type = decoder.decodeInteger(forKey: LocalSuggestiveSearch.typeKey)
        switch type {
        case LocalSuggestiveSearch.typeValueTerm:
            guard let name = decoder.decodeObject(forKey: LocalSuggestiveSearch.nameKey) as? String else { return nil }
            self.suggestiveSearch = .term(name: name)
        case LocalSuggestiveSearch.typeValueCategory:
            let categoryId = decoder.decodeInteger(forKey: LocalSuggestiveSearch.categoryIdKey)
            guard let category = ListingCategory(rawValue: categoryId) else {
                return nil
            }
            self.suggestiveSearch = .category(category: category)
        case LocalSuggestiveSearch.typeValueTermWithCategory:
            let categoryId = decoder.decodeInteger(forKey: LocalSuggestiveSearch.categoryIdKey)
            guard let name = decoder.decodeObject(forKey: LocalSuggestiveSearch.nameKey) as? String,
                  let category = ListingCategory(rawValue: categoryId) else {
                    return nil
            }
            self.suggestiveSearch = .termWithCategory(name: name, category: category)
        default:
            return nil
        }
    }
    
    func encode(with coder: NSCoder) {
        switch suggestiveSearch {
        case let .term(name):
            coder.encode(LocalSuggestiveSearch.typeValueTerm, forKey: LocalSuggestiveSearch.typeKey)
            coder.encode(name, forKey: LocalSuggestiveSearch.nameKey)
        case let .category(category):
            coder.encode(LocalSuggestiveSearch.typeValueCategory, forKey: LocalSuggestiveSearch.typeKey)
            coder.encode(category.rawValue, forKey: LocalSuggestiveSearch.categoryIdKey)
        case let .termWithCategory(name, category):
            coder.encode(LocalSuggestiveSearch.typeValueTermWithCategory, forKey: LocalSuggestiveSearch.typeKey)
            coder.encode(name, forKey: LocalSuggestiveSearch.nameKey)
            coder.encode(category.rawValue, forKey: LocalSuggestiveSearch.categoryIdKey)
        }
    }
}


// MARK: - UserDefaults

extension UserDefaults {
    subscript(key: DefaultsKey<LocalSuggestiveSearch?>) -> LocalSuggestiveSearch? {
        get { return unarchive(key) }
        set { archive(key, newValue) }
    }
}
