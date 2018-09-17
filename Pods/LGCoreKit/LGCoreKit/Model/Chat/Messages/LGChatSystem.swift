public enum ChatMessageSystemSeverity: String, Decodable {
    case info
}

public protocol ChatMessageSystem {
    var localizedKey: String { get }
    var localizedText: String { get }
    var severity: ChatMessageSystemSeverity { get }
}

public struct LGChatMessageSystem: ChatMessageSystem, Equatable {
    public let localizedKey: String
    public let localizedText: String
    public let severity: ChatMessageSystemSeverity
}
