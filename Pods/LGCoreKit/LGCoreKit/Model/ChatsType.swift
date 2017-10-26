//
//  ChatsType.swift
//  Pods
//
//  Created by Dídac on 11/01/16.
//
//

import Argo
import Result

public enum ChatsType {
    case selling
    case buying
    case archived
    case all

    var apiValue: String {
        switch self {
        case .selling: return "as_seller"
        case .buying: return "as_buyer"
        case .archived: return "archived"
        case .all: return "default"
        }
    }
}


