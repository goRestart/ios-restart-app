//
//  SearchType.swift
//  LetGo
//
//  Created by Eli Kohen on 16/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

enum SearchType {
    case user(query: String)
    case trending(query: String)
    case lastSearch(query: String)
    case collection(type: CollectionCellType, query: String)

    var text: String {
        switch self {
        case let .user(query):
            return query
        case let .trending(query):
            return query
        case let .lastSearch(query):
            return query
        case let .collection(type, _):
            return type.title
        }
    }

    var query: String {
        switch self {
        case let .user(query):
            return query
        case let .trending(query):
            return query
        case let .lastSearch(query):
            return query
        case let .collection(_ , query):
            return query
        }
    }

    var isTrending: Bool {
        switch self {
        case .user, .collection, .lastSearch:
            return false
        case .trending:
            return true
        }
    }

    var isCollection: Bool {
        switch self {
        case .user, .trending, .lastSearch:
            return false
        case .collection:
            return true
        }
    }
    
    var isLastSearch: Bool {
        switch self {
        case .user, .trending, .collection:
            return false
        case .lastSearch:
            return true
        }
    }
}
