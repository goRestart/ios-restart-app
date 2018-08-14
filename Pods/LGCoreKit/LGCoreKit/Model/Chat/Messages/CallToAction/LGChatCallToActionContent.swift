
public protocol ChatCallToActionContent {
    var text: String { get }
    var deeplinkURL: URL? { get }
}

struct LGChatCallToActionContent: ChatCallToActionContent, Decodable, Equatable {
    let text: String
    let deeplinkURL: URL?


    init(text: String,
         deeplinkURL: URL?) {
        self.text = text
        self.deeplinkURL = deeplinkURL
    }

    /*
     "content": {
        "text": "Action",
        "deeplink": "letgo://users/dbc364b6-4e26-49dc-a015-dc7820262715",
        "link": ""  // only used by web
     }
     */

    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        text = try keyedContainer.decode(String.self, forKey: .text)
        if let deeplinkString = try keyedContainer.decodeIfPresent(String.self, forKey: .deeplink),
            let deeplinkURLValue = URL(string: deeplinkString) {
            deeplinkURL = deeplinkURLValue
        } else {
            deeplinkURL = nil
        }
    }

    enum CodingKeys: String, CodingKey {
        case text
        case deeplink
    }

    // MARK: Equatable

    static func ==(lhs: LGChatCallToActionContent, rhs: LGChatCallToActionContent) -> Bool {
        return lhs.text == rhs.text
            && lhs.deeplinkURL == rhs.deeplinkURL
    }
}
