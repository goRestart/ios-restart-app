public struct MockChatCallToActionData: ChatCallToActionData {
    public var key: String?
    public var title: String
    public var text: String
    public var image: ChatCallToActionImage

    public init(key: String?,
                title: String,
                text: String,
                image: ChatCallToActionImage) {
        self.key = key
        self.title = title
        self.text = text
        self.image = image
    }

    init(from chatCallToActionData: ChatCallToActionData) {
        self.key = chatCallToActionData.key
        self.title = chatCallToActionData.title
        self.text = chatCallToActionData.text
        self.image = chatCallToActionData.image
    }

    public func makeDictionary() -> [String: Any] {
        var result = [String: Any]()
        result[MockChatCallToActionData.CodingKeys.key.rawValue] = key
        result[MockChatCallToActionData.CodingKeys.title.rawValue] = title
        result[MockChatCallToActionData.CodingKeys.text.rawValue] = text

        let image = MockChatCallToActionImage(url: self.image.url, position: self.image.position)
        result[MockChatCallToActionData.CodingKeys.image.rawValue] = image.makeDictionary()

        return result
    }

    private enum CodingKeys: String {
        case key
        case title
        case text
        case image
    }
}
