//
//  LGSearchAlert.swift
//  LGCoreKit
//
//  Created by Raúl de Oñate Blanco on 09/04/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

public struct LGSearchAlert: SearchAlert, Decodable {
    public let objectId: String?
    public let query: String
    public let enabled: Bool
    public let createdAt: TimeInterval
    
    public init(objectId: String?, query: String, enabled: Bool, createdAt: TimeInterval) {
        self.objectId = objectId
        self.query = query
        self.enabled = enabled
        self.createdAt = createdAt
    }

    public func updating(enabled: Bool) -> LGSearchAlert {
        return LGSearchAlert(objectId: objectId, query: query, enabled: enabled, createdAt: createdAt)
    }
    // MARK: - Decodable
    
    /*
     {
     "user_search_alert_id" : "2a91920e-f204-4e18-a20a-5f5110644b21",
     "query" : "iphone",
     "enabled" : false,
     "created_at" : 1419984875118
     }
     */
    
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        objectId = try keyedContainer.decode(String.self, forKey: .id)
        query = try keyedContainer.decode(String.self, forKey: .query)
        enabled = try keyedContainer.decode(Bool.self, forKey: .enabled)
        createdAt = try keyedContainer.decode(TimeInterval.self, forKey: .createdAt)
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "user_search_alert_id"
        case query
        case enabled
        case createdAt = "created_at"
    }
}
