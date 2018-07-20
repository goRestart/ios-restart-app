public struct MockChatCallToActionImage: ChatCallToActionImage {
    public var url: String
    public var position: ChatCallToActionImagePosition

    public init(url: String,
                position: ChatCallToActionImagePosition) {
        self.url = url
        self.position = position
    }

    init(from chatCallToActionImage: ChatCallToActionImage) {
        self.url = chatCallToActionImage.url
        self.position = chatCallToActionImage.position
    }

    public func makeDictionary() -> [String: Any] {
        var result = [String: Any]()
        result[LGChatCallToActionImage.CodingKeys.url.rawValue] = url
        result[LGChatCallToActionImage.CodingKeys.position.rawValue] = position.rawValue
        return result
    }
}
