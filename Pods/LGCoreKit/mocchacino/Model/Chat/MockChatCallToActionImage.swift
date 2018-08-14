public struct MockChatCallToActionImage: ChatCallToActionImage {
    public var imageURL: URL?
    public var position: ChatCallToActionImagePosition

    public init(imageURL: URL?,
                position: ChatCallToActionImagePosition) {
        self.imageURL = imageURL
        self.position = position
    }

    init(from chatCallToActionImage: ChatCallToActionImage) {
        self.imageURL = chatCallToActionImage.imageURL
        self.position = chatCallToActionImage.position
    }

    public func makeDictionary() -> [String: Any] {
        var result = [String: Any]()
        result[LGChatCallToActionImage.CodingKeys.url.rawValue] = imageURL
        result[LGChatCallToActionImage.CodingKeys.position.rawValue] = position.rawValue
        return result
    }
}
