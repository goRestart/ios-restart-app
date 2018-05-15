import RxSwift

open class MockChatRepository: InternalChatRepository {

    public var indexMessagesResult: ChatMessagesResult!
    public var indexConversationsResult: ChatConversationsResult!
    public var showConversationResult: ChatConversationResult!
    public var sendMessageCommandResult: ChatCommandResult!
    public var archiveCommandResult: ChatCommandResult!
    public var unarchiveCommandResult: ChatCommandResult!
    public var confirmReadCommandResult: ChatCommandResult!
    public var confirmReceptionCommandResult: ChatCommandResult!
    public var unreadMessagesResult: ChatUnreadMessagesResult!
    public var fetchInactiveConversationsCountResult: ChatCountResult!
    public var fetchInactiveConversationsResult: ChatInactiveConversationsResult!
    public var markConversationAsReadResult: ChatCommandResult!
    
    public let chatStatusPublishSubject = PublishSubject<WSChatStatus>()
    public let chatEventsPublishSubject = PublishSubject<ChatEvent>()
    
    // MARK: - Lifecycle
    
    required public init() {
        
    }
    
    public func cleanInactiveConversations() {
        inactiveConversations.value.removeAll()
    }
    
    public func clean() {
        cleanInactiveConversations()
    }
    
    
    // MARK: - ChatRepository
    
    public var chatStatus: Observable<WSChatStatus> {
        return chatStatusPublishSubject.asObservable()
    }
    
    public var chatEvents: Observable<ChatEvent> {
        return chatEventsPublishSubject.asObservable()
    }
    
    public let allConversations = CollectionVariable<ChatConversation>([])
    public let sellingConversations = CollectionVariable<ChatConversation>([])
    public let buyingConversations = CollectionVariable<ChatConversation>([])
    public let inactiveConversations = Variable<[ChatInactiveConversation]>([])
    public let inactiveConversationsCount = Variable<Int?>(nil)
    public let conversationsLock: NSLock = NSLock()
    
    public func createNewMessage(_ talkerId: String,
                                 text: String?,
                                 type: ChatMessageType) -> ChatMessage {
        return MockChatMessage(objectId: String.makeRandom(),
                               talkerId: talkerId,
                               sentAt: nil,
                               receivedAt: nil,
                               readAt: nil,
                               warnings: [],
                               content: MockChatMessageContent(type: type,
                                                               defaultText: String.makeRandom(),
                                                               text: text),
                               assistantMeeting: nil)
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
    
    public func internalIndexConversations(_ numResults: Int,
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
                                 listingId: String,
                                 completion: ChatConversationCompletion?) {
        delay(result: showConversationResult, completion: completion)
    }
    
    public func fetchInactiveConversationsCount(completion: ChatCountCompletion?) {
        delay(result: fetchInactiveConversationsCountResult, completion: completion)
    }
    
    public func fetchInactiveConversations(limit: Int, offset: Int, completion: ChatInactiveConversationsCompletion?) {
        delay(result: fetchInactiveConversationsResult, completion: completion)
    }
    
    public func typingStarted(_ conversationId: String) {
    }
    
    public func typingStopped(_ conversationId: String) {
    }
    
    public func internalSendMessage(_ conversationId: String,
                                    messageId: String,
                                    type: WebSocketSendMessageType,
                                    text: String,
                                    answerKey: String?,
                                    completion: ChatCommandCompletion?) {
        delay(result: sendMessageCommandResult, completion: completion)
    }
    
    public func internalConfirmRead(_ conversationId: String,
                                    messageIds: [String],
                                    completion: ChatCommandCompletion?) {
        delay(result: confirmReadCommandResult, completion: completion)
    }
    
    public func internalArchiveConversations(_ conversationIds: [String],
                                             completion: ChatCommandCompletion?) {
        delay(result: archiveCommandResult, completion: completion)
    }
    
    public func internalArchiveInactiveConversations(_ conversationIds: [String],
                                                     completion: ChatCommandCompletion?) {
        delay(result: archiveCommandResult, completion: completion)
    }
    
    func internalMarkAllConversationsAsRead(completion: ChatCommandCompletion?) {
        delay(result: markConversationAsReadResult, completion: completion)
    }
    
    public func confirmReception(_ conversationId: String,
                                 messageIds: [String],
                                 completion: ChatCommandCompletion?) {
        delay(result: confirmReceptionCommandResult, completion: completion)
    }
    
    public func internalUnarchiveConversation(_ conversationId: String,
                                              completion: ChatCommandCompletion?) {
        delay(result: unarchiveCommandResult, completion: completion)
    }
    
    public func markAllConversationsAsRead(completion: ChatCommandCompletion?) {
        delay(result: markConversationAsReadResult, completion: completion)
    }
    
    public func chatUnreadMessagesCount(_ completion: ChatUnreadMessagesCompletion?) {
        delay(result: unreadMessagesResult, completion: completion)
    }
    
    public func chatEventsIn(_ conversationId: String) -> Observable<ChatEvent> {
        return chatEvents.filter { $0.conversationId == conversationId }.asObservable()
    }
}

