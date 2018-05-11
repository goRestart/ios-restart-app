extension ChatEventType: MockFactory {
    public static func makeMock() -> ChatEventType {
        switch Int.makeRandom(min: 0, max: 6) {
        case 0:
            return .interlocutorTypingStarted
        case 1:
            return .interlocutorTypingStopped
        case 2:
            return makeMockInterlocutorMessageSent()
        case 3:
            return .interlocutorReceptionConfirmed(messagesIds: [String].makeRandom())
        case 4:
            return .interlocutorReadConfirmed(messagesIds: [String].makeRandom())
        case 5:
            return .talkerUnauthenticated
        default:
            return .authenticationTokenExpired
        }
    }
    
    public static func makeMockInterlocutorMessageSent() -> ChatEventType {
        return .interlocutorMessageSent(messageId: String.makeRandom(),
                                        sentAt: Date.makeRandom(),
                                        content: MockChatMessageContent.makeMock())
    }
}
