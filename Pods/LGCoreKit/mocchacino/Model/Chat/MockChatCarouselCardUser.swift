@testable import LGCoreKit

public struct MockChatCarouselCardUser: ChatCarouselCardUser {
    public var name: String
    public var imageURL: URL?
    public var stars: Int
    public var deeplink: URL?
    
    public init(name: String,
                imageURL: URL?,
                stars: Int,
                deeplink: URL?) {
        self.name = name
        self.imageURL = imageURL
        self.stars = stars
        self.deeplink = deeplink
    }
    
    init(from chatCarouselCardUser: ChatCarouselCardUser) {
        self.name = chatCarouselCardUser.name
        self.imageURL = chatCarouselCardUser.imageURL
        self.stars = chatCarouselCardUser.stars
        self.deeplink = chatCarouselCardUser.deeplink
    }

    public func makeDictionary() -> [String: Any] {
        var result = [String: Any]()
        result[LGChatCarouselCardUser.CodingKeys.name.rawValue] = name
        result[LGChatCarouselCardUser.CodingKeys.imageURL.rawValue] = imageURL
        result[LGChatCarouselCardUser.CodingKeys.stars.rawValue] = stars
        result[LGChatCarouselCardUser.CodingKeys.deeplink.rawValue] = deeplink
        return result
    }
}
