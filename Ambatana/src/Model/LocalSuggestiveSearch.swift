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
    
    var title: String {
        switch suggestiveSearch {
        case let .term(name):
            return name
        case let .category(category):
            return category.name
        case let .termWithCategory(name, _):
            return name
        }
    }
    
    var subtitle: String? {
        switch suggestiveSearch {
        case .term:
            return nil
        case .category:
            return "category"   // TODO: ¡¡¡localizable!!!
        case let .termWithCategory(_, category):
            return category.name
        }
    }
    
    let suggestiveSearch: SuggestiveSearch

    
    // MARK: - Lifecycle
    
    init(suggestiveSearch: SuggestiveSearch) {
        self.suggestiveSearch = suggestiveSearch
    }
    
    
    // MARK: - NSCoding
    
    required init?(coder decoder: NSCoder) {
        let type = decoder.decodeObject(forKey: LocalSuggestiveSearch.typeKey) as? Int ?? LocalSuggestiveSearch.typeValueTerm
        switch type {
        case LocalSuggestiveSearch.typeValueTerm:
            guard let name = decoder.decodeObject(forKey: LocalSuggestiveSearch.nameKey) as? String else { return nil }
            self.suggestiveSearch = .term(name: name)
        case LocalSuggestiveSearch.typeValueCategory:
            guard let categoryId = decoder.decodeObject(forKey: LocalSuggestiveSearch.categoryIdKey) as? Int,
                  let category = ListingCategory(rawValue: categoryId) else {
                return nil
            }
            self.suggestiveSearch = .category(category: category)
        case LocalSuggestiveSearch.typeValueTermWithCategory:
            guard let name = decoder.decodeObject(forKey: LocalSuggestiveSearch.nameKey) as? String,
                  let categoryId = decoder.decodeObject(forKey: LocalSuggestiveSearch.categoryIdKey) as? Int,
                  let category = ListingCategory(rawValue: categoryId)else {
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
