public protocol ChatCarouselCardUser {
    var name: String { get }
    var imageURL: URL?  { get }
    var stars: Int { get }
    var deeplink: URL? { get }
}

struct LGChatCarouselCardUser: ChatCarouselCardUser, Decodable, Equatable {
    let name: String
    let imageURL: URL?
    let stars: Int
    let deeplink: URL?
    
    init(name: String,
         imageURL: URL?,
         stars: Int,
         deeplink: URL?) {
        self.name = name
        self.imageURL = imageURL
        self.stars = stars
        self.deeplink = deeplink
    }
    
    //  MARK: Decodable
    
    /*
     {
     "avatar_url": "http://...",
     "name": "Pepe",
     "stars": 5,
     "deeplink": "letgo://users/dbc364b6-4e26-49dc-a015-dc7820262715",
     "link": "http://..."
     },
     */
    
    init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        name = try keyedContainer.decode(String.self, forKey: .name)
        if let imageURLString = try keyedContainer.decodeIfPresent(String.self, forKey: .imageURL) {
            imageURL = URL(string: imageURLString) ?? nil
        } else {
            imageURL = nil
        }
        stars = try keyedContainer.decode(Int.self, forKey: .stars)
        if let deeplinkURLString = try keyedContainer.decodeIfPresent(String.self, forKey: .deeplink) {
            deeplink = URL(string: deeplinkURLString) ?? nil
        } else {
            deeplink = nil
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case imageURL = "avatar_url"
        case stars
        case deeplink
    }
    
    // MARK: Equatable
    
    static func ==(lhs: LGChatCarouselCardUser, rhs: LGChatCarouselCardUser) -> Bool {
        return lhs.name == rhs.name
            && lhs.imageURL == rhs.imageURL
            && lhs.stars == rhs.stars
            && lhs.deeplink == rhs.deeplink
    }
}
