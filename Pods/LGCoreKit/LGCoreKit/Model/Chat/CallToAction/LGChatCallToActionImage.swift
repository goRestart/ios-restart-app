
public enum ChatCallToActionImagePosition: String {
    case up
    case down
}

public protocol ChatCallToActionImage {
    var url: String { get }
    var position: ChatCallToActionImagePosition { get }
}

struct LGChatCallToActionImage: ChatCallToActionImage, Decodable, Equatable {

    let url: String
    let position: ChatCallToActionImagePosition

    init(url: String, position: ChatCallToActionImagePosition) {
        self.url = url
        self.position = position
    }

    /*
     "image": {
        "url": "http://kfdjjdfñk",
        "position": "[up|down]"
     }
     */

    init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        url = try keyedContainer.decode(String.self, forKey: .url)
        let positionValue = try keyedContainer.decode(String.self, forKey: .position)
        position = ChatCallToActionImagePosition(rawValue: positionValue) ?? .up
    }

    enum CodingKeys: String, CodingKey {
        case url
        case position
    }

    // MARK: Equatable

    static func ==(lhs: LGChatCallToActionImage, rhs: LGChatCallToActionImage) -> Bool {
        return lhs.url == rhs.url && lhs.position == rhs.position
    }
}
