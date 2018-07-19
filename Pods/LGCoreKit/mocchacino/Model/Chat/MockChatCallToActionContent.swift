public struct MockChatCallToActionContent: ChatCallToActionContent {
    public var text: String
    public var deeplinkURL: URL?

    public init(text: String,
                deeplinkURL: URL?) {

        self.text = text
        self.deeplinkURL = deeplinkURL
    }

    init(from chatCallToActionContent: ChatCallToActionContent) {
        self.text = chatCallToActionContent.text
        self.deeplinkURL = chatCallToActionContent.deeplinkURL
    }

    public func makeDictionary() -> [String: Any] {
        var result = [String: Any]()
        result[LGChatCallToActionContent.CodingKeys.text.rawValue] = text
        result[LGChatCallToActionContent.CodingKeys.deeplink.rawValue] = deeplinkURL?.absoluteString
        return result
    }
}
