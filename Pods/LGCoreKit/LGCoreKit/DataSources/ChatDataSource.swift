//
//  ChatDataSource.swift
//  Pods
//
//  Created by Dídac on 11/01/16.
//
//

import Result

typealias ChatDataSourceRetrieveChatsCompletion = Result<[Chat], ApiError> -> Void
typealias ChatDataSourceRetrieveChatCompletion = Result<Chat, ApiError> -> Void
typealias ChatDataSourceSendMessageCompletion = Result<Void, ApiError> -> Void
typealias ChatDataSourceUnreadCountCompletion = Result<Int, ApiError> -> Void
typealias ChatDataSourceArchiveChatCompletion = Result<Void, ApiError> -> Void

protocol ChatDataSource {

    /**
    Retrieve the chats list for the current user for the given page and type filter
    The request will be paginated with 20 results per page
    
    - parameter type:       Type of the chats to filter by (selling, buying, archived...)
    - parameter page:       Page you want to retrieve, starting in 0
    - parameter numResults: total number of results to retrieve per page
    - parameter completion: Completion closure to execute when the opeartion finishes
    */
    func index(type: ChatsType, page: Int, numResults: Int?, completion: ChatDataSourceRetrieveChatsCompletion?)
    
    /**
    Retrieves an specific chat
    
    parameter productId: the id of the product related to the chat we want to retrieve
    parameter buyerId: the id of the buyer related to the chat we want to retrieve
    parameter offset: the offset for the messages list
    parameter numResults: the num of messages we want to retrieve
    parameter completion: the completion closure
    */
    func retrieveMessagesWithProductId(productId: String, buyerId: String, offset: Int, numResults: Int?,
        completion: ChatDataSourceRetrieveChatCompletion?)

    /**
    Retrieves an specific chat

    parameter conversationId: the id of the specific chat we want to retrieve
    parameter offset: the offset for the messages list
    parameter numResults: the num of messages we want to retrieve
    parameter completion: the completion closure
    */
    func retrieveMessagesWithConversationId(conversationId: String, offset: Int, numResults: Int?,
        completion: ChatDataSourceRetrieveChatCompletion?)

    /**
    Sends a message to a user about a specific product

    parameter recipientUserId: the id of the user who will receive the message
    parameter recipientUserId: the id of the product related to the message
    parameter message: the content of the message
    parameter type: the type of message (text or offer)
    parameter completion: the completion closure
    */
    func sendMessageTo(recipientUserId: String, productId: String, message: String, type: MessageType,
        completion: ChatDataSourceSendMessageCompletion?)

    /**
    Retrieves the number of unread messages for the user

    parameter completion: the completion closure
    */
    func fetchUnreadCount(completion: ChatDataSourceUnreadCountCompletion?)

    /**
    Archives an specific chat (chat is not deleted)

    parameter chatId: the id of the specific chat we want to archive
    parameter completion: the completion closure
    */
    func archiveChatWithId(chatId: String, completion: ChatDataSourceArchiveChatCompletion?)

}
