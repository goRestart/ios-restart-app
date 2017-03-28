import Result

open class MockOldChatRepository: OldChatRepository {
    public var indexResult: ChatsResult!
    public var retrieveResult: ChatResult!
    public var unreadMsgCountResult: Result<Int, RepositoryError>!
    public var sendMsgResult: MessageResult!
    public var archiveResult: Result<Void, RepositoryError>!


    // MARK: - Lifecycle

    required public init() {

    }


    // MARK: - OldChatRepository

    public func newChatWithProduct(_ product: Product) -> Chat? {
        var chat = MockChat.makeMock()
        chat.product = product
        return chat
    }

    public func index(_ type: ChatsType,
                      page: Int,
                      numResults: Int?,
                      completion: ChatsCompletion?) {
        delay(result: indexResult, completion: completion)
    }

    public func retrieveMessagesWithProduct(_ product: Product,
                                            buyer: User,
                                            page: Int,
                                            numResults: Int,
                                            completion: ChatCompletion?) {
        delay(result: retrieveResult, completion: completion)
    }

    public func retrieveMessagesWithProductId(_ productId: String,
                                              buyerId: String,
                                              page: Int,
                                              numResults: Int,
                                              completion: ChatCompletion?) {
        delay(result: retrieveResult, completion: completion)
    }

    public func retrieveMessagesWithConversationId(_ conversationId: String,
                                                   page: Int,
                                                   numResults: Int,
                                                   completion: ChatCompletion?) {
        delay(result: retrieveResult, completion: completion)
    }

    public func retrieveUnreadMessageCountWithCompletion(_ completion: ((Result<Int, RepositoryError>) -> Void)?) {
        delay(result: unreadMsgCountResult, completion: completion)
    }

    public func sendText(_ message: String,
                         product: Product,
                         recipient: User,
                         completion: MessageCompletion?) {
        delay(result: sendMsgResult, completion: completion)
    }

    public func sendOffer(_ message: String,
                          product: Product,
                          recipient: User,
                          completion: MessageCompletion?) {
        delay(result: sendMsgResult, completion: completion)
    }

    public func sendSticker(_ sticker: Sticker,
                            product: Product,
                            recipient: User,
                            completion: MessageCompletion?) {
        delay(result: sendMsgResult, completion: completion)
    }

    public func archiveChatsWithIds(_ ids: [String],
                                    completion: ((Result<Void, RepositoryError>) -> ())?) {
        delay(result: archiveResult, completion: completion)
    }

    public func unarchiveChatsWithIds(_ ids: [String],
                                      completion: ((Result<Void, RepositoryError>) -> ())?) {
        delay(result: archiveResult, completion: completion)
    }

    public func sendMessage(_ messageType: MessageType,
                            message: String,
                            product: Product,
                            recipient: User,
                            completion: MessageCompletion?) {
        delay(result: sendMsgResult, completion: completion)
    }
}
