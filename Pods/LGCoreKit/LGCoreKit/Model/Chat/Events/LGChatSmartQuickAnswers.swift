import Foundation

public protocol ChatSmartQuickAnswers {
    var id: String { get }
    var conversationId: String { get }
    var talkerId: String { get }
    var messageId: String { get }
    var referralWord: String { get }
    var createdAt: Date { get }
    var answers: [ChatAnswer] { get }
}

struct LGChatSmartQuickAnswers: ChatSmartQuickAnswers, Decodable, Equatable {
    let id: String
    let conversationId: String
    let talkerId: String
    let messageId: String
    let referralWord: String
    let createdAt: Date
    let answers: [ChatAnswer]
    
    init(id: String,
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
    
    init(from smartQuickAnswer: ChatSmartQuickAnswers) {
        id = smartQuickAnswer.id
        conversationId = smartQuickAnswer.conversationId
        talkerId = smartQuickAnswer.talkerId
        messageId = smartQuickAnswer.messageId
        referralWord = smartQuickAnswer.referralWord
        createdAt = smartQuickAnswer.createdAt
        answers = smartQuickAnswer.answers
    }
    
    // MARK: Decodable
    
    /*{
     "id": [uuid],
     "conversation_id": [uuid],
     "talker_id": [uuid],
     "message_id": [uuid],
     "referral_word": [string],
     "created_at": [long],
     "answers": [array[ChatAnswer]]
     }*/
    
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        id = try keyedContainer.decode(String.self, forKey: .id)
        conversationId = try keyedContainer.decode(String.self, forKey: .conversationId)
        talkerId = try keyedContainer.decode(String.self, forKey: .talkerId)
        messageId = try keyedContainer.decode(String.self, forKey: .messageId)
        referralWord = try keyedContainer.decode(String.self, forKey: .referralWord)
        let createdAtVakue = try keyedContainer.decode(TimeInterval.self, forKey: .createdAt)
        createdAt = Date.makeChatDate(millisecondsIntervalSince1970: createdAtVakue) ?? Date()
        answers = try keyedContainer.decode([LGChatAnswer].self, forKey: .answers)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case conversationId = "conversation_id"
        case talkerId = "talker_id"
        case messageId = "message_id"
        case referralWord = "referral_word"
        case createdAt = "created_at"
        case answers
    }
    
    // MARK: Equatable
    
    static func ==(lhs: LGChatSmartQuickAnswers, rhs: LGChatSmartQuickAnswers) -> Bool {
        return lhs.id == rhs.id
            && lhs.conversationId == rhs.conversationId
            && lhs.talkerId == rhs.talkerId
            && lhs.messageId == rhs.messageId
            && lhs.referralWord == rhs.referralWord
            && lhs.createdAt == rhs.createdAt
            && lhs.answers.map { LGChatAnswer(from: $0) } == rhs.answers.map { LGChatAnswer(from: $0) }
    }
}
