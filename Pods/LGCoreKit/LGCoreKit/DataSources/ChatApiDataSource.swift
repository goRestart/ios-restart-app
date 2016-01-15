//
//  ChatApiDataSource.swift
//  Pods
//
//  Created by Dídac on 11/01/16.
//
//

import Argo
import Result

class ChatApiDataSource: ChatDataSource {

    static let sharedInstance = ChatApiDataSource()

    func retrieveChats(completion: ChatDataSourceRetrieveChatsCompletion?) {
        var parameters: [String : AnyObject] = [:]
        parameters["num_results"] = 1000
        let request = ChatRouter.Index(params: parameters)
        ApiClient.request(request, decoder: chatsDecoder, completion: completion)
    }

    func retrieveChatWithProductId(productId: String, buyerId: String,
        completion: ChatDataSourceRetrieveChatCompletion?) {

        var parameters: [String : AnyObject] = [:]
        parameters["buyer"] = buyerId
        parameters["productId"] = productId
        parameters["num_results"] = 1000

        let request = ChatRouter.Show(objectId: productId, params: parameters)
        ApiClient.request(request, decoder: chatDecoder, completion: completion)
    }

    func sendMessageTo(recipientUserId: String, productId: String, message: String, type: MessageType,
        completion: ChatDataSourceSendMessageCompletion?) {

            var parameters: [String : AnyObject] = [:]
            parameters["userTo"] = recipientUserId
            parameters["type"] = type.rawValue
            parameters["content"] = message

            let request = ChatRouter.CreateMessage(objectId: productId, params: parameters)
            // ⚠️ TODO: API should respond with the message
            ApiClient.request(request, completion: completion)
    }

    func fetchUnreadCount(completion: ChatDataSourceUnreadCountCompletion?) {
        let request = ChatRouter.UnreadCount
        ApiClient.request(request, decoder: unreadCountDecoder, completion: completion)
    }

    func archiveChatWithId(chatId: String, completion: ChatDataSourceArchiveChatCompletion?) {
        let request = ChatRouter.Archive(objectId: chatId)
        ApiClient.request(request, completion: completion)
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