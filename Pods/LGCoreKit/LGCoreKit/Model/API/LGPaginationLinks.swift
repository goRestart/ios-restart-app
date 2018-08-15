
public struct LGPaginationLinks: PaginationLinks {
    public let this: URL
    public let previous: URL?
    public let next: URL?
    
    public var isFirstPage: Bool {
        return previous == nil
    }
    
    public var isLastPage: Bool {
        return next == nil
    }
}

extension LGPaginationLinks: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case this = "self"
        case previous = "prev"
        case next = "next"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        this = try container.decode(URL.self, forKey: .this)
        previous = try container.decodeIfPresent(URL.self, forKey: .previous)
        next = try container.decodeIfPresent(URL.self, forKey: .next)
    }
}
