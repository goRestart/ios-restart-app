//
//  LGNotification.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 25/04/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

public protocol NotificationModel: BaseModel {
    var createdAt: Date { get }
    var isRead: Bool { get }
    var campaignType: String? { get }
    var modules: NotificationModular { get }
}

struct LGNotification: NotificationModel, Decodable {
    let objectId: String?
    let createdAt: Date
    let isRead: Bool
    let campaignType: String?
    let modules: NotificationModular
    
    // MARK: - Decodable
    
    /*
     {
         "campaign_type": "Like/Follow/Sold",
         "uuid": "73aedba9-11db-3207-bb47-26812bfe8e71",
         "created_at": 1461569433,
         "is_read": false,
         "data" : {... type concrete data ...}
     }
     */
    
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        objectId = try keyedContainer.decodeIfPresent(String.self, forKey: .objectId)
        let createdAtTimestamp = try keyedContainer.decode(TimeInterval.self, forKey: .createdAt)
        createdAt = Date(timeIntervalSince1970: createdAtTimestamp.epochInSeconds())
        isRead = try keyedContainer.decode(Bool.self, forKey: .isRead)
        campaignType = try keyedContainer.decodeIfPresent(String.self, forKey: .campaignType)
        modules = try keyedContainer.decode(LGNotificationModular.self, forKey: .modules)
    }
    
    enum CodingKeys: String, CodingKey {
        case objectId = "uuid"
        case createdAt = "created_at"
        case isRead = "is_read"
        case campaignType = "campaign_type"
        case modules = "data"
    }
}
