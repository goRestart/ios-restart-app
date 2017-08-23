//
//  ChatRepository.swift
//  LGCoreKit
//
//  Created by Dídac on 12/01/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result

public typealias ChatsResult = Result<[Chat], RepositoryError>
public typealias ChatsCompletion = (ChatsResult) -> Void

public typealias ChatResult = Result<Chat, RepositoryError>
public typealias ChatCompletion = (ChatResult) -> Void

public typealias MessageResult = Result<Message, RepositoryError>
public typealias MessageCompletion = (MessageResult) -> Void


public protocol OldChatRepository {


    // MARK: Public methods

    /**
     Factory method. Will build a new chat from the provided listing. Will use myUser as 'userFrom'.

     - returns: Chat in case myUser and listing.user have values. nil otherwise
     */
    func newChatWithListing(_ listing: Listing) -> Chat?


    // MARK: Index methods

    /**
     Retrieves chats of the current user filtered by ChatsType
     The request is paginated with 20 results per page

     - parameter type: Chat type to filter the results
     - parameter page: Page you want to retrieve (starting in 0)
     - parameter numResults: Number of results per page, if nil the API will use the default value
     - parameter completion: Closure to execute when the operation finishes
     */
    func index(_ type: ChatsType, page: Int, numResults: Int?, completion: ChatsCompletion?)


    // MARK: Show Methods

    /**
     Retrieves a chat for the given listing and buyer.

     - parameter listing: The listing.
     - parameter buyer: The buyer.
     - parameter completion: The completion closure.
     */
    func retrieveMessagesWithListing(_ listing: Listing, buyer: User, page: Int, numResults: Int,
                                            completion: ChatCompletion?)

    func retrieveMessagesWithListingId(_ listingId: String, buyerId: String, page: Int, numResults: Int,
                                              completion: ChatCompletion?)

    func retrieveMessagesWithConversationId(_ conversationId: String, page: Int, numResults: Int,
                                                   completion: ChatCompletion?)

    /**
     Retrieves the unread message count.

     - parameter completion: The completion closure.
     */
    func retrieveUnreadMessageCountWithCompletion(_ completion: ((Result<Int, RepositoryError>) -> Void)?)


    // MARK: Post methods

    /**
     Sends a text message to given recipient for the given listing.

     - parameter message: The message.
     - parameter listing: The listing.
     - parameter recipient: The recipient user.
     - parameter completion: The completion closure.
     */
    func sendText(_ message: String, listing: Listing, recipient: User, completion: MessageCompletion?)
    func sendText(_ message: String, listingId: String, recipientId: String, completion: MessageCompletion?)

    /**
     Sends an offer to given recipient for the given listing.

     - parameter message: The message.
     - parameter listing: The listing.
     - parameter recipient: The recipient user.
     - parameter completion: The completion closure.
     */
    func sendOffer(_ message: String, listing: Listing, recipient: User, completion: MessageCompletion?)
    func sendOffer(_ message: String, listingId: String, recipientId: String, completion: MessageCompletion?)

    /**
     Sends a sticker to given recipient for the given listing.

     - parameter sticker: The sticker object to send.
     - parameter listing: The listing.
     - parameter recipient: The recipient user.
     - parameter completion: The completion closure.
     */
    func sendSticker(_ sticker: Sticker, listing: Listing, recipient: User, completion: MessageCompletion?)
    func sendSticker(_ sticker: Sticker, listingId: String, recipientId: String, completion: MessageCompletion?)

    /**
     Archives a bunch of chats for the current user

     - parameter ids: The chats to be archived
     - parameter completion: The completion closure.
     */
    func archiveChatsWithIds(_ ids: [String], completion: ((Result<Void, RepositoryError>) -> ())?)


    // MARK: - Put methods

    /**
     Unarchives a bunch of chats for the current user

     - parameter ids: The chats to be archived
     - parameter completion: The completion closure.
     */
    func unarchiveChatsWithIds(_ ids: [String], completion: ((Result<Void, RepositoryError>) -> ())?)


    // MARK: - Private methods

    /**
     Sends a message to given recipient for the given listing.

     - parameter messageType: The message type.
     - parameter message: The message.
     - parameter listingId: The listingId.
     - parameter recipientId: The recipient user id.
     - parameter completion: The completion closure.
     */
    func sendMessage(_ messageType: MessageType, message: String, listingId: String, recipientId: String,
                     completion: MessageCompletion?)
}
