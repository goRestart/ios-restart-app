public enum ChatCarouselCardType: String, Decodable {
    case listing = "listing"
}

public protocol ChatCarouselCard {
    var type: ChatCarouselCardType { get }
    var actions: [ChatCallToAction] { get }
    var product: ChatCarouselProduct? { get }
    var user: ChatCarouselCardUser? { get }
    var imageURL: URL? { get }
    var title: String? { get }
    var text: String? { get }
    var deeplinkURL: URL? { get }
    var trackingKey: String? { get }
}

enum PriceCodingKeys: String, CodingKey {
    case amount
    case currency
    case flag = "price_flag"
}

public struct ChatCarouselProduct: Decodable, Equatable {
    public let id: String
    public let price: ListingPrice
    public let currency: Currency?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        
        let priceContainer = try container.nestedContainer(keyedBy: PriceCodingKeys.self, forKey: .price)
        let priceDecoded = try priceContainer.decodeIfPresent(Double.self, forKey: .amount)

        let flag = try priceContainer.decodeIfPresent(ListingPriceFlag.self, forKey: .flag)

        let currencyCode = try priceContainer.decode(String.self, forKey: .currency)
        
        currency = Currency.currencyWithCode(currencyCode)
        price = ListingPrice.fromPrice(priceDecoded, andFlag: flag)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case price
    }
}

struct LGChatCarouselCard: ChatCarouselCard, Decodable, Equatable {
    
    let type: ChatCarouselCardType
    let actions: [ChatCallToAction]
    let product: ChatCarouselProduct?
    let user: ChatCarouselCardUser?
    let imageURL: URL?
    let title: String?
    let text: String?
    let deeplinkURL: URL?
    let trackingKey: String?
    
    //  MARK: Decodable
    
    /*
     {
     "type": "listing",
     "actions": [{
     "id": "11111111-1111-1111-1111-111111111111",
     "key": "track_call_to_action",
     "content": {
     "text": "Text 1",
     "deeplink": "letgo://users/dbc364b6-4e26-49dc-a015-dc7820262715",
     "link": "http://..."
     }
     }],
     "image": {
     "url" : "https://img.letgo.com/images/27/db/06/4a/27db064a33b1025c66465fb69e0f06e0.jpeg?impolicy=img_600"
     },
     "user": {
     "avatar_url": "http://...",
     "name": "Pepe",
     "stars": 5,
     "deeplink": "letgo://users/dbc364b6-4e26-49dc-a015-dc7820262715",
     "link": "http://..."
     },
     "product": {
     "id": "11111111-1111-1111-1111-111111111111"
     "price": {
     "amount" : 500,
     "currency": "USD",
     "price_flag": 1
     },
     },
     "title": "Find other people who are changing the world like you!",
     "text": "Description",
     "deeplink": "letgo://users/dbc364b6-4e26-49dc-a015-dc7820262715",
     "key": "card tracking key"
     }
     */
    
    init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        type = try keyedContainer.decode(ChatCarouselCardType.self, forKey: .type)
        if case type = ChatCarouselCardType.listing {
            actions = try keyedContainer.decode([LGChatCallToAction].self, forKey: .actions)
            let imageContainer = try keyedContainer.nestedContainer(keyedBy: ImageCodingKeys.self,
                                                                    forKey: .image)
            let imageURLString = try imageContainer.decode(String.self, forKey: .url)
            imageURL = URL(string: imageURLString) ?? nil
            if let deeplinkURLString = try keyedContainer.decodeIfPresent(String.self, forKey: .deeplink) {
                deeplinkURL = URL(string: deeplinkURLString) ?? nil
            } else {
                deeplinkURL = nil
            }
            
            trackingKey =  (try? keyedContainer.decodeIfPresent(String.self, forKey: .key)) ?? nil
            product = try keyedContainer.decodeIfPresent(ChatCarouselProduct.self, forKey: .product)
            user = (try? keyedContainer.decodeIfPresent(LGChatCarouselCardUser.self, forKey: .user)) ?? nil
            title = (try? keyedContainer.decodeIfPresent(String.self, forKey: .title)) ?? nil
            text = (try? keyedContainer.decodeIfPresent(String.self, forKey: .text)) ?? nil
        } else {
            throw DecodingError.typeMismatch(
                ChatCarouselCardType.self,
                DecodingError.Context(codingPath: [],
                                      debugDescription: "Could not parse a known ChatCarouselCardType type from \(decoder)"))
        }
    }
    
    enum ImageCodingKeys: String, CodingKey {
        case url
    }
    
    enum CodingKeys: String, CodingKey {
        case type
        case actions
        case image
        case user
        case product
        case price
        case title
        case text
        case deeplink
        case key
    }
    
    // MARK: Equatable
    
    static func ==(lhs: LGChatCarouselCard, rhs: LGChatCarouselCard) -> Bool {
        let lhsLGActions = lhs.actions.map { $0 as? LGChatCallToAction }
        let rhsLGActions = rhs.actions.map { $0 as? LGChatCallToAction }
        let lhsLGChatCarouselCardUser = lhs.user as? LGChatCarouselCard
        let rhsLGChatCarouselCardUser = rhs.user as? LGChatCarouselCard
        return lhs.type == rhs.type
            && lhsLGActions == rhsLGActions
            && lhs.imageURL == rhs.imageURL
            && lhsLGChatCarouselCardUser == rhsLGChatCarouselCardUser
            && lhs.product == rhs.product
            && lhs.title == rhs.title
            && lhs.text == rhs.text
    }
}
