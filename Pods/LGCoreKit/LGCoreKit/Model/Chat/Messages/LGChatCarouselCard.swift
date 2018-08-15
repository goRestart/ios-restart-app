public enum ChatCarouselCardType: String, Decodable {
    case listing = "listing"
}

public protocol ChatCarouselCard {
    var type: ChatCarouselCardType { get }
    var actions: [ChatCallToAction] { get }
    var imageURL: URL? { get }
    var user: ChatCarouselCardUser? { get }
    var price: ListingPrice? { get }
    var currency: Currency? { get }
    var title: String? { get }
    var text: String? { get }
}

struct LGChatCarouselCard: ChatCarouselCard, Decodable, Equatable {
    let type: ChatCarouselCardType
    let actions: [ChatCallToAction]
    let imageURL: URL?
    let user: ChatCarouselCardUser?
    let price: ListingPrice?
    let currency: Currency?
    let title: String?
    let text: String?
    
    init(type: ChatCarouselCardType,
         actions: [ChatCallToAction],
         imageURL: URL?,
         user: ChatCarouselCardUser?,
         price: ListingPrice?,
         currency: Currency?,
         title: String?,
         text: String?) {
        self.type = type
        self.actions = actions
        self.imageURL = imageURL
        self.user = user
        self.price = price
        self.currency = currency
        self.title = title
        self.text = text
    }
    
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
     "price": {
         "amount" : 500,
         "currency": "USD",
         "price_flag": 1
     },
     "title": "Find other people who are changing the world like you!",
     "text": "Description"
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
            user = (try? keyedContainer.decodeIfPresent(LGChatCarouselCardUser.self, forKey: .user)) ?? nil
            title = (try? keyedContainer.decodeIfPresent(String.self, forKey: .title)) ?? nil
            text = (try? keyedContainer.decodeIfPresent(String.self, forKey: .text)) ?? nil
            if let priceContainer = try? keyedContainer.nestedContainer(keyedBy: PriceCodingKeyds.self, forKey: .price),
                let priceDecoded = try priceContainer.decodeIfPresent(Double.self, forKey: .amount),
                let currencyDecoded = try priceContainer.decodeIfPresent(String.self, forKey: .currency),
                let flag = try priceContainer.decodeIfPresent(ListingPriceFlag.self, forKey: .flag) {
                currency = Currency.currencyWithCode(currencyDecoded)
                price = ListingPrice.fromPrice(priceDecoded, andFlag: flag)
            } else {
                currency = nil
                price = nil
            }
        } else {
            throw DecodingError.typeMismatch(
                ChatCarouselCardType.self,
                DecodingError.Context(codingPath: [],
                                      debugDescription: "Could not parse a known ChatCarouselCardType type from \(decoder)"))
        }
    }
    
    enum PriceCodingKeyds: String, CodingKey {
        case amount
        case currency
        case flag = "price_flag"
    }
    
    enum ImageCodingKeys: String, CodingKey {
        case url
    }
    
    enum CodingKeys: String, CodingKey {
        case type
        case actions
        case image
        case user
        case price
        case title
        case text
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
            && lhs.price == rhs.price
            && lhs.title == rhs.title
            && lhs.text == rhs.text
    }
}
