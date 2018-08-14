@testable import LGCoreKit

public struct MockChatCarouselCard: ChatCarouselCard {
    public var type: ChatCarouselCardType
    public var actions: [ChatCallToAction]
    public var imageURL: URL?
    public var user: ChatCarouselCardUser?
    public var price: ListingPrice?
    public var currency: Currency?
    public var title: String?
    public var text: String?
    
    public init(type: ChatCarouselCardType,
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
    
    init(from chatCarouselCard: ChatCarouselCard) {
        self.type = chatCarouselCard.type
        self.actions = chatCarouselCard.actions
        self.imageURL = chatCarouselCard.imageURL
        self.user = chatCarouselCard.user
        self.price = chatCarouselCard.price
        self.currency = chatCarouselCard.currency
        self.title = chatCarouselCard.title
        self.text = chatCarouselCard.text
    }
    
    public func makeDictionary() -> [String: Any] {
        var result = [String: Any]()
        result[LGChatCarouselCard.CodingKeys.type.rawValue] = type
        result[LGChatCarouselCard.CodingKeys.actions.rawValue] = actions.map { MockChatCallToAction(from: $0).makeDictionary() }
        result[LGChatCarouselCard.CodingKeys.image.rawValue] = imageURL
        result[LGChatCarouselCard.CodingKeys.user.rawValue] = user
        result[LGChatCarouselCard.CodingKeys.price.rawValue] = ["amount" : price?.value ?? 0,
                                                                "currency": currency?.code ?? "USD",
                                                                "price_flag": price?.priceFlag.rawValue ?? "1"]
        result[LGChatCarouselCard.CodingKeys.title.rawValue] = title
        result[LGChatCarouselCard.CodingKeys.text.rawValue] = text
        return result
    }
}
