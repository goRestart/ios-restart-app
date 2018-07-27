import Foundation


public protocol ChatCallToAction: BaseModel {
    var key: String { get }
    var content: ChatCallToActionContent { get }
}

struct LGChatCallToAction: ChatCallToAction, Decodable, Equatable {

    let objectId: String?
    let key: String
    let content: ChatCallToActionContent

    init(objectId: String?, key: String, content: ChatCallToActionContent) {
        self.objectId = objectId
        self.key = key
        self.content = content
    }

    /*
     "cta": [
        {
            "id": "22222222-2222-2222-2222-222222222222",
            "key": "product_reposting#no",
            "content": {
                "text": "Action",
                "deeplink": "letgo://users/dbc364b6-4e26-49dc-a015-dc7820262715",
                "link": ""
            }
        }
     ]
     */

    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        objectId = try keyedContainer.decode(String.self, forKey: .id)
        key = try keyedContainer.decode(String.self, forKey: .key)
        let decodedContent = try keyedContainer.decode(LGChatCallToActionContent.self, forKey: .content)

        if let deeplinkURL = decodedContent.deeplinkURL {
            content = LGChatCallToActionContent(text: decodedContent.text, deeplinkURL: deeplinkURL)
        } else {
            throw DecodingError.valueNotFound(Int.self,
                                              DecodingError.Context(codingPath: [CodingKeys.content],
                                                                    debugDescription: "deeplink not found: \(decodedContent)"))
        }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case key
        case content
    }

    // MARK: Equatable

    static func ==(lhs: LGChatCallToAction, rhs: LGChatCallToAction) -> Bool {
        guard let lhLgContent = lhs.content as? LGChatCallToActionContent,
            let rhLgContent = rhs.content as? LGChatCallToActionContent else { return false }
        return lhs.objectId == rhs.objectId && lhs.key == rhs.key && lhLgContent == rhLgContent
    }
}

