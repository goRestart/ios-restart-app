public struct MockSticker: Sticker {
    public var url: String
    public var name: String
    public var type: StickerType

    public func encode() -> [String : Any] {
        return ["url": url,
                "name": name,
                "type": type.rawValue]
    }

    public static func decode(_ dictionary: [String : Any]) -> MockSticker? {
        guard let url = dictionary["url"] as? String,
            let name = dictionary["name"] as? String,
            let typeRawValue = dictionary["type"] as? String,
            let type = StickerType(rawValue: typeRawValue) else { return nil }

        return MockSticker(url: url,
                           name: name,
                           type: type)
    }
}
