public struct MockChatCallToAction: ChatCallToAction {
    public var objectId: String?
    public var key: String
    public var content: ChatCallToActionContent

    public init(objectId: String?,
                key: String,
                content: ChatCallToActionContent) {

        self.objectId = objectId
        self.key = key
        self.content = content
    }

    init(from chatCallToAction: ChatCallToAction) {
        self.objectId = chatCallToAction.objectId
        self.key = chatCallToAction.key
        self.content = chatCallToAction.content
    }

    public func makeDictionary() -> [String: Any] {
        var result = [String: Any]()
        result[LGChatCallToAction.CodingKeys.id.rawValue] = objectId
        result[LGChatCallToAction.CodingKeys.key.rawValue] = key
        let content = MockChatCallToActionContent(text: self.content.text, deeplinkURL: self.content.deeplinkURL)
        result[LGChatCallToAction.CodingKeys.content.rawValue] = content.makeDictionary()
        return result
    }
}
