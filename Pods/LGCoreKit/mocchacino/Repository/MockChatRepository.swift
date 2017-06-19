import RxSwift

open class MockChatRepository: ChatRepository {
    public var indexMessagesResult: ChatMessagesResult!
    public var indexConversationsResult: ChatConversationsResult!
    public var showConversationResult: ChatConversationResult!
    public var commandResult: ChatCommandResult!
    public var unreadMessagesResult: ChatUnreadMessagesResult!

    public let chatStatusPublishSubject = PublishSubject<WSChatStatus>()
    public let chatEventsPublishSubject = PublishSubject<ChatEvent>()


    // MARK: - Lifecycle

    required public init() {
        
    }


    // MARK: - ChatRepository

    public var chatStatus: Observable<WSChatStatus> {
        return chatStatusPublishSubject.asObservable()
    }

    public var chatEvents: Observable<ChatEvent> {
        return chatEventsPublishSubject.asObservable()
    }

    public func createNewMessage(_ talkerId: String,
                                 text: String,
                                 type: ChatMessageType) -> ChatMessage {
        return MockChatMessage(objectId: String.makeRandom(),
                               talkerId: talkerId,
                               text: text,
                               sentAt: nil,
                               receivedAt: nil,
                               readAt: nil,
                               type: type,
                               warnings: [])
    }

    public func indexMessages(_ conversationId: String,
                              numResults: Int,
                              offset: Int,
                              completion: ChatMessagesCompletion?) {
        delay(result: indexMessagesResult, completion: completion)
    }

    public func indexMessagesNewerThan(_ messageId: String,
                                       conversationId: String,
                                       completion: ChatMessagesCompletion?) {
        delay(result: indexMessagesResult, completion: completion)
    }

    public func indexMessagesOlderThan(_ messageId: String,
                                       conversationId: String,
                                       numResults: Int,
                                       completion: ChatMessagesCompletion?) {
        delay(result: indexMessagesResult, completion: completion)
    }

    public func indexConversations(_ numResults: Int,
                                   offset: Int,
                                   filter: WebSocketConversationFilter,
                                   completion: ChatConversationsCompletion?) {
        delay(result: indexConversationsResult, completion: completion)
    }

    public func showConversation(_ conversationId: String,
                                 completion: ChatConversationCompletion?) {
        delay(result: showConversationResult, completion: completion)
    }

    public func showConversation(_ sellerId: String,
                                 productId: String,
                                 completion: ChatConversationCompletion?) {
        delay(result: showConversationResult, completion: completion)
    }

    public func typingStarted(_ conversationId: String) {
    }

    public func typingStopped(_ conversationId: String) {
    }

    public func sendMessage(_ conversationId: String,
                            messageId: String,
                            type: ChatMessageType,
                            text: String,
                            completion: ChatCommandCompletion?) {
        delay(result: commandResult, completion: completion)
    }

    public func confirmRead(_ conversationId: String,
                            messageIds: [String],
                            completion: ChatCommandCompletion?) {
        delay(result: commandResult, completion: completion)
    }

    public func archiveConversations(_ conversationIds: [String],
                                     completion: ChatCommandCompletion?) {
        delay(result: commandResult, completion: completion)
    }

    public func confirmReception(_ conversationId: String,
                                 messageIds: [String],
                                 completion: ChatCommandCompletion?) {
        delay(result: commandResult, completion: completion)
    }

    public func unarchiveConversations(_ conversationIds: [String],
                                       completion: ChatCommandCompletion?) {
        delay(result: commandResult, completion: completion)
    }

    public func chatUnreadMessagesCount(_ completion: ChatUnreadMessagesCompletion?) {
        delay(result: unreadMessagesResult, completion: completion)
    }

    public func chatEventsIn(_ conversationId: String) -> Observable<ChatEvent> {
        return chatEvents.filter { $0.conversationId == conversationId }.asObservable()
    }
}
