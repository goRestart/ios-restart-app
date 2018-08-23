//
//  LGUserRating.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 14/07/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

struct LGUserRating: UserRating, Decodable {
    let objectId: String?
    let userToId: String
    let userFrom: UserListing
    let listingId: String?
    let type: UserRatingType
    let value: Int
    let comment: String?
    let status: UserRatingStatus
    let createdAt: Date
    let updatedAt: Date
    
    
    // MARK: - Decodable
    
    /**
     Expects a json in the form:
     {
         "uuid": "42f93d94-7026-4f24-98b7-c73415695ebf",
         "user_to_id": "044adf68-9e6e-49ae-849a-c3dfa4901172",
         "user_from":{
             "id": "b088284d-40a9-4b9a-ad61-63df56d9e961",
             "name": "Jaime Torres",
             "avatar_url": null,
             "zip_code": "08039",
             "country_code": "ES",
             "city": "Barcelona",
             "banned": false,
             "status": "active"
         },
         "type": 1,
         "value": 5,
         "comment": "feo",
         "status": 1,
         "created_at": "2016-07-12T18:27:51+0200",
         "updated_at": "2016-07-12T18:27:51+0200"
     }
     */
    init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.objectId = try keyedContainer.decodeIfPresent(String.self, forKey: .id)
        self.userToId = try keyedContainer.decode(String.self, forKey: .userToId)
        self.userFrom = try keyedContainer.decode(LGUserListing.self, forKey: .userFrom)
        self.listingId = try keyedContainer.decode(String?.self, forKey: .listingId)
        let typeValue = try keyedContainer.decode(Int.self, forKey: .type)
        switch typeValue {
        case UserRatingApiType.conversation.rawValue:
            self.type = .conversation
        case UserRatingApiType.seller.rawValue:
            self.type = .seller
        case UserRatingApiType.buyer.rawValue:
            self.type = .buyer
        case UserRatingApiType.report.rawValue:
            self.type = .report
        default:
            throw DecodingError.valueNotFound(Int.self, DecodingError.Context(codingPath: [CodingKeys.type],
                                                                              debugDescription: "\(typeValue)"))
        }
        self.value = try keyedContainer.decode(Int.self, forKey: .value)
        self.comment = try keyedContainer.decode(String?.self, forKey: .comment)
        
        let statusValue = try keyedContainer.decode(Int.self, forKey: .status)
        if let status = UserRatingStatus(rawValue: statusValue) {
            self.status = status
        } else {
            throw DecodingError.valueNotFound(Int.self, DecodingError.Context(codingPath: [CodingKeys.status],
                                                                              debugDescription: "\(statusValue)"))
        }
        let dateFormatter = LGDateFormatter()
        let createdAtString = try keyedContainer.decode(String.self, forKey: .createdAt)
        if let createdAt = dateFormatter.date(from: createdAtString) {
            self.createdAt = createdAt
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [CodingKeys.createdAt],
                                                                    debugDescription: "\(createdAtString)"))
        }
        let updatedAtString = try keyedContainer.decode(String.self, forKey: .updatedAt)
        if let updatedAt = dateFormatter.date(from: updatedAtString) {
            self.updatedAt = updatedAt
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [CodingKeys.updatedAt],
                                                                    debugDescription: "\(updatedAtString)"))
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id         = "uuid"
        case userToId   = "user_to_id"
        case userFrom   = "user_from"
        case listingId  = "product_id"
        case type       = "type"
        case value      = "value"
        case comment    = "comment"
        case status     = "status"
        case createdAt  = "created_at"
        case updatedAt  = "updated_at"
    }
}

extension UserRatingType {
    private var apiType: UserRatingApiType {
        switch self {
        case .conversation:
            return .conversation
        case .seller:
            return .seller
        case .buyer:
            return .buyer
        case .report:
            return .report
        }
    }

    var apiValue: Int {
        return apiType.rawValue
    }
}

private enum UserRatingApiType: Int {
    case conversation = 1 // [DEPRECATED] do not use to create new ratings
    case seller = 2
    case buyer = 3
    case report = 4
}
