//
//  ChatApiDataSource.swift
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


class ChatApiDataSource: OldChatDataSource {
    let apiClient: ApiClient


    // MARK: - Lifecycle

    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }


    // MARK: - ChatDataSource
    func index(_ type: ChatsType, page: Int, numResults: Int?, completion: ChatDataSourceRetrieveChatsCompletion?) {
        var parameters: [String: Any] = ["filter" : type.apiValue, "page" : page]
        if let number = numResults {
            parameters["num_results"] = number
        }
        let request = OldChatRouter.index(params: parameters)
        apiClient.request(request, decoder: chatsDecoder, completion: completion)
    }

    func retrieveMessagesWithProductId(_ productId: String, buyerId: String, offset: Int, numResults: Int?,
        completion: ChatDataSourceRetrieveChatCompletion?) {

            var parameters: [String : Any] = [:]
            parameters["buyer"] = buyerId
            parameters["productId"] = productId
            parameters["offset"] = offset
            parameters["num_results"] = numResults

            let request = OldChatRouter.show(objectId: productId, params: parameters)
            apiClient.request(request, decoder: chatDecoder, completion: completion)
    }

    func retrieveMessagesWithConversationId(_ conversationId: String, offset: Int, numResults: Int?,
        completion: ChatDataSourceRetrieveChatCompletion?) {

            var parameters: [String : Any] = [:]
            parameters["offset"] = offset
            parameters["num_results"] = numResults

            let request = OldChatRouter.showConversation(objectId: conversationId, params: parameters)
            apiClient.request(request, decoder: chatDecoder, completion: completion)
    }
    
    func sendMessageTo(_ recipientUserId: String, productId: String, message: String, type: MessageType,
        completion: ChatDataSourceSendMessageCompletion?) {

            var parameters: [String : Any] = [:]
            parameters["userTo"] = recipientUserId
            parameters["type"] = type.rawValue
            parameters["content"] = message

            let request = OldChatRouter.createMessage(objectId: productId, params: parameters)
            apiClient.request(request, completion: completion)
    }

    func fetchUnreadCount(_ completion: ChatDataSourceUnreadCountCompletion?) {
        let request = OldChatRouter.unreadCount
        apiClient.request(request, decoder: unreadCountDecoder, completion: completion)
    }

    func archiveChatsWithIds(_ chatIds: [String], completion: ChatDataSourceArchiveChatCompletion?) {
        var parameters: [String : Any] = [:]
        parameters["conversationUuids"] = chatIds
        let request = OldChatRouter.archive(params: parameters)
        apiClient.request(request, completion: completion)
    }

    func unarchiveChatsWithIds(_ chatIds: [String], completion: ChatDataSourceArchiveChatCompletion?) {
        var parameters: [String : Any] = [:]
        parameters["conversationUuids"] = chatIds
        let request = OldChatRouter.unarchive(params: parameters)
        apiClient.request(request, completion: completion)
    }


    // MARK: - Private methods

    /**
    Decodes an object to a `[Chat]` object.
    - parameter object: The object.
    - returns: A `[Chat]` object.
    */
    private func chatsDecoder(_ object: Any) -> [Chat]? {
        guard let chats : [LGChat] = decode(object) else { return nil }
        return chats.map{$0}
    }

    /**
    Decodes an object to a `Chat` object.
    - parameter object: The object.
    - returns: A `Chat` object.
    */
    private func chatDecoder(_ object: Any) -> Chat? {
        guard let apiChat: LGChat = decode(object) else { return nil }
        return apiChat
    }

    /**
    Decodes an object to an Int
    - parameter object: The object.
    - returns: An Int with the num of unread messages
    */
    private func unreadCountDecoder(_ object: Any) -> Int? {
        let count: Decoded<Int> = JSON(object) <| "count"
        return count.value
    }
}
