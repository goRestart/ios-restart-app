import Foundation

struct SimilarQuery: Decodable, Equatable {
    public let query: String
    public let contextual: [String]
    public let jaccard: [String]
    
    public init(query: String, contextual: [String], jaccard: [String]) {
        self.query = query
        self.contextual = contextual
        self.jaccard = jaccard
    }
    
    public static func ==(lhs: SimilarQuery, rhs: SimilarQuery) -> Bool {
        return lhs.query == rhs.query &&
            lhs.contextual == rhs.contextual &&
            lhs.jaccard == rhs.jaccard
    }
}
