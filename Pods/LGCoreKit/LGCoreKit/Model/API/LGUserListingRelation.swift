//
//  LGUserListingRelation.swift
//  LGCoreKit
//
//  Created by Dídac on 21/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

public struct LGUserListingRelation: UserListingRelation, Decodable {
    public var isFavorited: Bool
    public var isReported: Bool

    // MARK: Decodable

    /**
     Expects a json in the form:
     {
     "is_reported": false,
     "is_favorited": false
     }
     */

    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        isFavorited = try keyedContainer.decode(Bool.self, forKey: .isFavorited)
        isReported = try keyedContainer.decode(Bool.self, forKey: .isReported)
    }

    enum CodingKeys: String, CodingKey {
        case isFavorited = "is_favorited"
        case isReported = "is_reported"
    }
}

