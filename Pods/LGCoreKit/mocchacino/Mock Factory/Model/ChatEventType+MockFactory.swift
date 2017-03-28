extension ChatEventType: MockFactory {
    public static func makeMock() -> ChatEventType {
        switch Int.makeRandom(min: 0, max: 6) {
        case 0:
            return .interlocutorTypingStarted
        case 1:
            return .interlocutorTypingStopped
        case 2:
            return .interlocutorMessageSent(messageId: String.makeRandom(),
                                            sentAt: Date.makeRandom(),
                                            text: String.makeRandom(),
                                            type: ChatMessageType.makeMock())
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
}
