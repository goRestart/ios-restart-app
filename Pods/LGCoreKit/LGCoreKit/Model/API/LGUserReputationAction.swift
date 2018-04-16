//
//  LGUserReputationItem.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 10/4/18.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

import Foundation

struct LGUserReputationAction: UserReputationAction, Decodable {
    let id: String
    let type: UserReputationActionType
    let points: Int
    let createdAt: Date?

    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        let createdAtString = try keyedContainer.decode(String.self, forKey: .createdAt)
        let typeString = try keyedContainer.decode(String.self, forKey: .name)
        id = try keyedContainer.decode(String.self, forKey: .id)
        type = UserReputationActionType(rawValue: typeString) ?? .unknown
        points = try keyedContainer.decode(Int.self, forKey: .points)
        createdAt = LGDateFormatter().date(from: createdAtString)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case points
        case createdAt = "created_at"
    }
}
