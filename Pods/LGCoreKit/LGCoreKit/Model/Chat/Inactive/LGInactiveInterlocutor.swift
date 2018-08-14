//
//  LGInactiveInterlocutor.swift
//  LGCoreKit
//
//  Created by Dídac on 22/05/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

import Foundation

public protocol InactiveInterlocutor: BaseModel {
    var name: String { get }
    var avatar: File? { get }
    var status: UserStatus { get }
    var lastConnectedAt: Date? { get }
    var lastUpdatedAt: Date? { get }

    init(objectId: String?,
         name: String,
         avatar: File?,
         status: UserStatus,
         lastConnectedAt: Date?,
         lastUpdatedAt: Date?)
}


struct LGInactiveInterlocutor: InactiveInterlocutor, Decodable {
    let objectId: String?
    let name: String
    let avatar: File?
    let status: UserStatus
    let lastConnectedAt: Date?
    let lastUpdatedAt: Date?

    init(objectId: String?,
         name: String,
         avatar: File?,
         status: UserStatus,
         lastConnectedAt: Date?,
         lastUpdatedAt: Date?) {

        self.objectId = objectId
        self.name = name
        self.avatar = avatar
        self.status = status
        self.lastConnectedAt = lastConnectedAt
        self.lastUpdatedAt = lastUpdatedAt
    }

    fileprivate static func make(objectId: String?,
                                 name: String,
                                 avatar: LGFile?,
                                 status: UserStatus,
                                 lastConnectedAt: Date?,
                                 lastUpdatedAt: Date?) -> LGInactiveInterlocutor {

        return LGInactiveInterlocutor(objectId: objectId,
                                  name: name,
                                  avatar: avatar,
                                  status: status,
                                  lastConnectedAt: lastConnectedAt,
                                  lastUpdatedAt: lastUpdatedAt)
    }

    // MARK: Decodable

    /*
     {
     "id": [uuid|objectId]
     "name": [string|null],
     "avatar": [url|null],
     "status": [string|null],
     "type": [string|null],
     "last_connected_at": [Date|null],
     "last_updated_at": [Date|null],
     }
     */

    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        objectId = try keyedContainer.decode(String.self, forKey: .objectId)
        name = try keyedContainer.decodeIfPresent(String.self, forKey: .name) ?? ""
        if let avatarStringURL = try? keyedContainer.decode(String.self, forKey: .avatar) {
            avatar = LGFile(id: nil, urlString: avatarStringURL)
        } else {
            avatar = nil
        }
        status = try keyedContainer.decodeIfPresent(UserStatus.self, forKey: .status) ?? .active

        let lastConnectedAtValue = try keyedContainer.decodeIfPresent(TimeInterval.self, forKey: .lastConnectedAt)
        lastConnectedAt = Date.makeChatDate(millisecondsIntervalSince1970: lastConnectedAtValue)

        let lastUpdatedAtValue = try keyedContainer.decodeIfPresent(TimeInterval.self, forKey: .lastUpdatedAt)
        lastUpdatedAt = Date.makeChatDate(millisecondsIntervalSince1970: lastUpdatedAtValue)
    }

    enum CodingKeys: String, CodingKey {
        case objectId = "id"
        case name
        case avatar
        case status
        case lastConnectedAt = "last_connected_at"
        case lastUpdatedAt = "last_updated_at"
    }
}

