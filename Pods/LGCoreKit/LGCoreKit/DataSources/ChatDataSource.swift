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
    Retrieves the chat list for the current user
    
    parameter completion: the completion closure
    */
    func retrieveChats(completion: ChatDataSourceRetrieveChatsCompletion?)

    /**
    Retrieves an specific chat
    
    parameter chatId: the id of the specific chat we want to retrieve
    parameter completion: the completion closure
    */
    func retrieveChatWithProductId(productId: String, buyerId: String, completion: ChatDataSourceRetrieveChatCompletion?)

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
