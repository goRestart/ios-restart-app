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
    case Selling
    case Buying
    case Archived
    case All

    var apiValue: String {
        switch self {
        case .Selling: return "as_seller"
        case .Buying: return "as_buyer"
        case .Archived: return "archived"
        case .All: return "default"
        }
    }
}


class ChatApiDataSource: ChatDataSource {
    let apiClient: ApiClient


    // MARK: - Lifecycle

    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }


    // MARK: - ChatDataSource
    func index(type: ChatsType, page: Int, numResults: Int?, completion: ChatDataSourceRetrieveChatsCompletion?) {
        var parameters: [String: AnyObject] = ["filter" : type.apiValue, "page" : page]
        if let number = numResults {
            parameters["num_results"] = number
        }
        let request = ChatRouter.Index(params: parameters)
        apiClient.request(request, decoder: chatsDecoder, completion: completion)
    }

    func retrieveMessagesWithProductId(productId: String, buyerId: String, offset: Int, numResults: Int?,
        completion: ChatDataSourceRetrieveChatCompletion?) {

            var parameters: [String : AnyObject] = [:]
            parameters["buyer"] = buyerId
            parameters["productId"] = productId
            parameters["offset"] = offset
            parameters["num_results"] = numResults

            let request = ChatRouter.Show(objectId: productId, params: parameters)
            apiClient.request(request, decoder: chatDecoder, completion: completion)
    }

    func sendMessageTo(recipientUserId: String, productId: String, message: String, type: MessageType,
        completion: ChatDataSourceSendMessageCompletion?) {

            var parameters: [String : AnyObject] = [:]
            parameters["userTo"] = recipientUserId
            parameters["type"] = type.rawValue
            parameters["content"] = message

            let request = ChatRouter.CreateMessage(objectId: productId, params: parameters)
            // ⚠️ TODO: API should respond with the message
            apiClient.request(request, completion: completion)
    }

    func fetchUnreadCount(completion: ChatDataSourceUnreadCountCompletion?) {
        let request = ChatRouter.UnreadCount
        apiClient.request(request, decoder: unreadCountDecoder, completion: completion)
    }

    func archiveChatWithId(chatId: String, completion: ChatDataSourceArchiveChatCompletion?) {
        let request = ChatRouter.Archive(objectId: chatId)
        apiClient.request(request, completion: completion)
    }


    // MARK: - Private methods

    /**
    Decodes an object to a `[Chat]` object.
    - parameter object: The object.
    - returns: A `[Chat]` object.
    */
    private func chatsDecoder(object: AnyObject) -> [Chat]? {
        guard let chats : [LGChat] = decode(object) else { return nil }
        return chats.map{$0}
    }

    /**
    Decodes an object to a `Chat` object.
    - parameter object: The object.
    - returns: A `Chat` object.
    */
    private func chatDecoder(object: AnyObject) -> Chat? {
        guard let apiChat: LGChat = decode(object) else { return nil }
        return apiChat
    }

    /**
    Decodes an object to an Int
    - parameter object: The object.
    - returns: An Int with the num of unread messages
    */
    private func unreadCountDecoder(object: AnyObject) -> Int? {
        let count: Int? = JSON.parse(object) <| "count"
        return count
    }
}
