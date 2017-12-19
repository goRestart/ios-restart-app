//
//  LGUserUserRelation.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 10/02/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

struct LGUserUserRelation: UserUserRelation, Decodable {
    var isBlocked: Bool
    var isBlockedBy: Bool

    static func decodeFrom(data: Data) throws -> LGUserUserRelation {
        let decoder = JSONDecoder()
        if let elements = try? decoder.decode([LGUserUserRelation].self, from: data), let first = elements.first {
            return elements.reduce(first, { (previous, next) -> LGUserUserRelation in
                var element = previous
                element.isBlocked = next.isBlocked
                element.isBlockedBy = next.isBlockedBy
                return element
            })
        } else {
            return try decoder.decode(LGUserUserRelation.self, from: data)
        }
    }

    // MARK: Decodable

    /**
     Expects a json in the form:

     {
     "blocked": false,
     "blocked_by": false
     }
     */

    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        isBlocked = try keyedContainer.decode(Bool.self, forKey: .isBlocked)
        isBlockedBy = try keyedContainer.decode(Bool.self, forKey: .isBlockedBy)
    }

    enum CodingKeys: String, CodingKey {
        case isBlocked = "blocked"
        case isBlockedBy = "blocked_by"
    }

}

