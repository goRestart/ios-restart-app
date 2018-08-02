public struct MockChatSmartQuickAnswers: ChatSmartQuickAnswers, Equatable {
    public var id: String
    public var conversationId: String
    public var talkerId: String
    public var messageId: String
    public var referralWord: String
    public var createdAt: Date
    public var answers: [ChatAnswer]
    
    public init(id: String,
         conversationId: String,
         talkerId: String,
         messageId: String,
         referralWord: String,
         createdAt: Date,
         answers: [ChatAnswer]) {
        self.id = id
        self.conversationId = conversationId
        self.talkerId = talkerId
        self.messageId = messageId
        self.referralWord = referralWord
        self.createdAt = createdAt
        self.answers = answers
    }
    
    public init(from smartQuickAnswer: ChatSmartQuickAnswers) {
        id = smartQuickAnswer.id
        conversationId = smartQuickAnswer.conversationId
        talkerId = smartQuickAnswer.talkerId
        messageId = smartQuickAnswer.messageId
        referralWord = smartQuickAnswer.referralWord
        createdAt = smartQuickAnswer.createdAt
        answers = smartQuickAnswer.answers
    }
    
    public static func ==(lhs: MockChatSmartQuickAnswers, rhs: MockChatSmartQuickAnswers) -> Bool {
        return lhs.id == rhs.id
            && lhs.conversationId == rhs.conversationId
            && lhs.talkerId == rhs.talkerId
            && lhs.messageId == rhs.messageId
            && lhs.referralWord == rhs.referralWord
            && lhs.createdAt == rhs.createdAt
            && lhs.answers.map { LGChatAnswer(from: $0) } == rhs.answers.map { LGChatAnswer(from: $0) }
    }
    
    public func makeDictionary() -> [String: Any] {
        var data = [String: Any]()
        data[LGChatSmartQuickAnswers.CodingKeys.id.rawValue] = id
        data[LGChatSmartQuickAnswers.CodingKeys.conversationId.rawValue] = conversationId
        data[LGChatSmartQuickAnswers.CodingKeys.talkerId.rawValue] = talkerId
        data[LGChatSmartQuickAnswers.CodingKeys.messageId.rawValue] = messageId
        data[LGChatSmartQuickAnswers.CodingKeys.referralWord.rawValue] = referralWord
        data[LGChatSmartQuickAnswers.CodingKeys.createdAt.rawValue] = createdAt.millisecondsSince1970()
        data[LGChatSmartQuickAnswers.CodingKeys.answers.rawValue] = answers.map { MockChatAnswer(from: $0).makeDictionary() }
        return data
    }
}
