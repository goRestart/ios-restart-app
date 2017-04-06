//
//  ChatRelatedItemState.swift
//  LetGo
//
//  Created by Juan Iglesias on 06/04/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

enum ChatRelatedItemsState: Equatable {
    case loading
    case visible(productId: String)
    case hidden
    
    var isVisible: Bool {
        switch self {
        case .visible:
            return true
        case .hidden, .loading:
            return false
        }
    }
}

func ==(a: ChatRelatedItemsState, b: ChatRelatedItemsState) -> Bool {
    switch (a, b) {
    case (.visible(let prodA), .visible(let prodB)) where prodA == prodB: return true
    case (.hidden, .hidden): return true
    case (.loading, .loading): return true
    default: return false
    }
}
