//
//  RelaxQuery.swift
//  LGCoreKit
//
//  Created by Tomas Cobo on 14/03/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

struct RelaxQuery: Decodable, Equatable {
    
    public let query: String?
    public let relaxed: [String]?
    public let relaxedQuery: String?
    
    public init(query: String?, relaxed: [String]?, relaxedQuery: String?) {
        self.query = query
        self.relaxed = relaxed
        self.relaxedQuery = relaxedQuery
    }
    
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        query = try keyedContainer.decodeIfPresent(String.self, forKey: .query)
        relaxed = try keyedContainer.decodeIfPresent([String].self, forKey: .relaxed)
        relaxedQuery = try keyedContainer.decodeIfPresent(String.self, forKey: .relaxedQuery)
    }
    
    enum CodingKeys: String, CodingKey {
        case query
        case relaxed
        case relaxedQuery = "relaxed_query"
    }
    
    public static func ==(lhs: RelaxQuery, rhs: RelaxQuery) -> Bool {
        return lhs.query == rhs.query &&
            lhs.relaxed == rhs.relaxed &&
            lhs.relaxedQuery == rhs.relaxedQuery
    }
    
}
