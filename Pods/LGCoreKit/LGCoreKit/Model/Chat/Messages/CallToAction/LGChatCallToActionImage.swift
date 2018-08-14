
public enum ChatCallToActionImagePosition: String {
    case up
    case down
}

public protocol ChatCallToActionImage {
    var imageURL: URL? { get }
    var position: ChatCallToActionImagePosition { get }
}

struct LGChatCallToActionImage: ChatCallToActionImage, Decodable, Equatable {

    let imageURL: URL?
    let position: ChatCallToActionImagePosition

    init(imageURL: URL?,
         position: ChatCallToActionImagePosition) {
        self.imageURL = imageURL
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
        let imageURLString = try keyedContainer.decode(String.self, forKey: .url)
        imageURL = URL(string: imageURLString) ?? nil
        let positionValue = try keyedContainer.decode(String.self, forKey: .position)
        position = ChatCallToActionImagePosition(rawValue: positionValue) ?? .up
    }

    enum CodingKeys: String, CodingKey {
        case url
        case position
    }

    // MARK: Equatable

    static func ==(lhs: LGChatCallToActionImage, rhs: LGChatCallToActionImage) -> Bool {
        return lhs.imageURL == rhs.imageURL && lhs.position == rhs.position
    }
}
