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
        return conversationCellData.conversationId ?? ""
    }
    
    static func ==(lhs: ChatConversationsListItemModel, rhs: ChatConversationsListItemModel) -> Bool {
        return lhs.conversationCellData == rhs.conversationCellData
    }
}

// MARK: Helpers

extension ConversationCellData {
    static func make(from conversation: ChatConversation) -> ConversationCellData {
        return ConversationCellData(status: conversation.conversationCellStatus,
                                    conversationId: conversation.objectId,
                                    userId: conversation.interlocutor?.objectId,
                                    userName: conversation.interlocutor?.name ?? "",
                                    userImageUrl: conversation.interlocutor?.avatar?.fileURL,
                                    userImagePlaceholder: LetgoAvatar.avatarWithID(conversation.interlocutor?.objectId,
                                                                                   name: conversation.interlocutor?.name),
                                    userType: conversation.interlocutor?.userType,
                                    amISelling: conversation.amISelling,
                                    listingId: conversation.listing?.objectId,
                                    listingName: conversation.listing?.name ?? "",
                                    listingImageUrl: conversation.listing?.image?.fileURL,
                                    unreadCount: conversation.unreadMessageCount,
                                    messageDate: conversation.lastMessageSentAt,
                                    isTyping: conversation.interlocutorIsTyping.value)
    }
    
    static func ==(lhs: ConversationCellData, rhs: ConversationCellData) -> Bool {
        return lhs.status == rhs.status
            && lhs.conversationId == rhs.conversationId
            && lhs.userId == rhs.userId
            && lhs.userName == rhs.userName
            && lhs.userImageUrl == rhs.userImageUrl
            && lhs.userImagePlaceholder == rhs.userImagePlaceholder
            && lhs.userType == rhs.userType
            && lhs.amISelling == rhs.amISelling
            && lhs.listingId == rhs.listingId
            && lhs.listingName == rhs.listingName
            && lhs.listingImageUrl == rhs.listingImageUrl
            && lhs.unreadCount == rhs.unreadCount
            && lhs.messageDate == rhs.messageDate
            && lhs.isTyping == rhs.isTyping
    }
}
