public struct MockChatCarouselCard: ChatCarouselCard {
    public var type: ChatCarouselCardType
    public var actions: [ChatCallToAction]
    public var imageURL: URL?
    public var deeplinkURL: URL?
    public var trackingKey: String?
    public var user: ChatCarouselCardUser?
    public var price: ListingPrice?
    public var currency: Currency?
    public var title: String?
    public var text: String?
    
    public init(type: ChatCarouselCardType,
                actions: [ChatCallToAction],
                imageURL: URL?,
                deeplinkURL: URL?,
                trackingKey: String?,
                user: ChatCarouselCardUser?,
                price: ListingPrice?,
                currency: Currency?,
                title: String?,
                text: String?) {
        self.type = type
        self.actions = actions
        self.imageURL = imageURL
        self.deeplinkURL = deeplinkURL
        self.trackingKey = trackingKey
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
        self.deeplinkURL = chatCarouselCard.deeplinkURL
        self.trackingKey = chatCarouselCard.trackingKey
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
        result[LGChatCarouselCard.CodingKeys.image.rawValue] = [LGChatCarouselCard.ImageCodingKeys.url.rawValue: imageURL?.absoluteString]
        result[LGChatCarouselCard.CodingKeys.user.rawValue] = user
        result[LGChatCarouselCard.CodingKeys.price.rawValue] = [LGChatCarouselCard.PriceCodingKeys.amount.rawValue: price?.value ?? 0,
                                                                LGChatCarouselCard.PriceCodingKeys.currency.rawValue: currency?.code ?? "USD",
                                                                LGChatCarouselCard.PriceCodingKeys.flag.rawValue: price?.priceFlag.rawValue ?? "1"]
        result[LGChatCarouselCard.CodingKeys.title.rawValue] = title
        result[LGChatCarouselCard.CodingKeys.text.rawValue] = text
        result[LGChatCarouselCard.CodingKeys.deeplink.rawValue] = deeplinkURL?.absoluteString
        result[LGChatCarouselCard.CodingKeys.key.rawValue] = trackingKey
        return result
    }
}
