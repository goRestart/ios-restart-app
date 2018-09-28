public struct MockChatMessageSystem: ChatMessageSystem, Equatable {
    public var localizedKey: String
    public var localizedText: String
    public var severity: ChatMessageSystemSeverity

    public func makeDictionary() -> [String: Any] {
        var result = [String: Any]()
        result[LGChatMessageContent.CodingKeys.localizedKey.rawValue] = localizedKey
        result[LGChatMessageContent.CodingKeys.localizedText.rawValue] = localizedText
        result[LGChatMessageContent.CodingKeys.severity.rawValue] = severity.rawValue
        return result
    }
}
