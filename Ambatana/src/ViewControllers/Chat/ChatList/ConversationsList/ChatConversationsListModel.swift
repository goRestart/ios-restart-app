//
//  ChatConversationsListModel.swift
//  LetGo
//
//  Created by Nestor on 23/05/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit
import RxDataSources

// MARK: Section Model

struct ChatConversationsListSectionModel {
    typealias Item = ChatConversationsListItemModel
    
    var header: String
    var items: [Item]
    
    init(conversations: [ChatConversation], header: String) {
        items = conversations.map { ChatConversationsListItemModel(conversationCellData: ConversationCellData.make(from: $0)) }
        self.header = header
    }
}

extension ChatConversationsListSectionModel: AnimatableSectionModelType {
    typealias Identity = String
    
    var identity: String {
        return header
    }
    
    init(original: ChatConversationsListSectionModel, items: [Item]) {
        self = original
        self.items = items
    }
}

// MARK: Item Model

struct ChatConversationsListItemModel {
    let conversationCellData: ConversationCellData
}

extension ChatConversationsListItemModel: IdentifiableType, Equatable {
    typealias Identity = String
    
    var identity: Identity {
        return UUID().uuidString
    }
    
    static func ==(lhs: ChatConversationsListItemModel, rhs: ChatConversationsListItemModel) -> Bool {
        return lhs.conversationCellData == rhs.conversationCellData
    }
}
