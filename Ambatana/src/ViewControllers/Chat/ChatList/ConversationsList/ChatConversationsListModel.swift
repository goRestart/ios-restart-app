//
//  ChatConversationsListModel.swift
//  LetGo
//
//  Created by Nestor on 23/05/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit
import RxDataSources
import GoogleMobileAds

// MARK: Section Model

struct ChatConversationsListSectionModel {
    typealias Item = ChatConversationsListItemModel
    
    var header: String
    var items: [Item] = []
    
    init(conversations: [ChatConversation], header: String) {
        items = conversations.map { .conversationCellData(conversationCellData: ConversationCellData.make(from: $0)) }
        self.header = header
    }
    
    init(conversations: [ChatConversation], header: String, adData: ConversationAdCellData?) {
        items = conversations.map { .conversationCellData(conversationCellData: ConversationCellData.make(from: $0)) }
        if let adData = adData, conversations.count > 0 {
            if items.count > adData.position {
                items.insert(.adCellData(conversationAdCellData: adData), at: adData.position)
            } else {
                items.append(.adCellData(conversationAdCellData: adData))
            }
        }
        self.header = header
    }
    
    mutating func addAd(adData: ConversationAdCellData) {
        if items.count > 0 {
            if items.count > adData.position {
                items.insert(.adCellData(conversationAdCellData: adData), at: adData.position)
            } else {
                items.append(.adCellData(conversationAdCellData: adData))
            }
        }
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

enum ChatConversationsListItemModel {
    case conversationCellData(conversationCellData: ConversationCellData)
    case adCellData(conversationAdCellData: ConversationAdCellData)
}

extension ChatConversationsListItemModel: IdentifiableType, Equatable {
    typealias Identity = String
    
    var identity: Identity {
        switch self {
        case .conversationCellData(let conversationCellData):
            return conversationCellData.conversationId ?? ""
        case .adCellData(let adCellData):
            return adCellData.adUnitId
        }
    }
    
    static func ==(lhs: ChatConversationsListItemModel, rhs: ChatConversationsListItemModel) -> Bool {
        switch lhs {
            case .conversationCellData(let lhsConversationCellData):
                switch rhs {
                case .conversationCellData(let rhsConversationCellData):
                    return lhsConversationCellData == rhsConversationCellData
                default:
                    return false
                }
        default:
            return false
        }

    }
}
