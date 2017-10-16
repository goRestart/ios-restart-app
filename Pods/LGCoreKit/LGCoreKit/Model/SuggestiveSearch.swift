//
//  SuggestiveSearch.swift
//  LGCoreKit
//
//  Created by Raúl de Oñate Blanco on 12/07/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

public enum SuggestiveSearch: Equatable {
    case term(name: String)
    case category(category: ListingCategory)
    case termWithCategory(name: String, category: ListingCategory)
    
    public var name: String? {
        switch self {
        case let .term(name):
            return name
        case .category:
            return nil
        case let .termWithCategory(name, _):
            return name
        }
    }
    
    public var category: ListingCategory? {
        switch self {
        case .term:
            return nil
        case let .category(category):
            return category
        case let .termWithCategory(_, category):
            return category
        }
    }
    
    public static func ==(lhs: SuggestiveSearch, rhs: SuggestiveSearch) -> Bool {
        switch (lhs, rhs) {
        case (let .term(lName), let .term(rName)):
            return lName == rName
        case (let .category(lCategory), let .category(rCategory)):
            return lCategory == rCategory
        case (let .termWithCategory(lName, lCategory), let .termWithCategory(rName, rCategory)):
            return lName == rName && lCategory == rCategory
        default:
            return false
        }
    }
}
