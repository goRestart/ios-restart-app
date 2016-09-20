//
//  SearchType.swift
//  LetGo
//
//  Created by Eli Kohen on 16/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

enum SearchType {
    case User(query: String)
    case Trending(query: String)
    case Collection(type: CollectionCellType)

    var text: String {
        switch self {
        case let .User(query):
            return query
        case let .Trending(query):
            return query
        case let .Collection(type):
            return type.title
        }
    }

    var query: String {
        switch self {
        case let .User(query):
            return query
        case let .Trending(query):
            return query
        case let .Collection(type):
            return type.searchTextUS
        }
    }

    var isTrending: Bool {
        switch self {
        case .User, .Collection:
            return false
        case .Trending:
            return true
        }
    }

    var isCollection: Bool {
        switch self {
        case .User, .Trending:
            return false
        case .Collection:
            return true
        }
    }
}
