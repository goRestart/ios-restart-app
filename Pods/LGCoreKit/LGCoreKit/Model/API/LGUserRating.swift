//
//  LGUserRating.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 14/07/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo
import Curry
import Runes

struct LGUserRating: UserRating {
    let objectId: String?
    let userToId: String
    let userFrom: User
    let type: UserRatingType
    let value: Int
    let comment: String?
    let status: UserRatingStatus
    let createdAt: Date
    let updatedAt: Date

    init(objectId: String, userToId: String, userFrom: LGUser, type: UserRatingType, value: Int, comment: String?,
         status: UserRatingStatus, createdAt: Date, updatedAt: Date) {
        self.objectId = objectId
        self.userToId = userToId
        self.userFrom = userFrom
        self.type = type
        self.value = value
        self.comment = comment
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension LGUserRating: Decodable {

    /**
     From: https://ambatana.atlassian.net/wiki/display/BAPI/User+Rating+Endpoints+and+Model

     {
         "uuid": string (UserRating Uuid, i.e -"42f93d94-7026-4f24-98b7-c73415695ebf"),
         "user_to_id": string (UserRating userToId, i.e -"044adf68-9e6e-49ae-849a-c3dfa4901172"),
         "user_from": {
             "id": string ("b088284d-40a9-4b9a-ad61-63df56d9e961"),
             "name": string ("Jaime Torres"),
             "avatar_url": string|null,
             "zip_code": string ("08039"),
             "country_code": string ("ES"),
             "city": string ("Barcelona"),
             "banned": bool (false),
             "status": string ("active")
         }
         "product_id": string | null (UserRating productId, i.e -"42f93d94-7026-4f24-98b7-c73415695ebf"),
         "type": int (UserRating type, i.e - 1),
         "value": int (UserRating value, i.e. - 5),
         "comment": string | null (UserRating comment, i.e - "feo"),
         "status": int (UserRating status, i.e - 2),
         "created_at": DateTime (UserRating createdAt, i.e - "2016-07-12T18:27:51+0200"),
         "updated_at": DateTime (UserRating updatedAt, i.e - "2016-07-12T18:27:51+0200")
     }
     */
    static func decode(_ j: JSON) -> Decoded<LGUserRating> {
        let result1 = curry(LGUserRating.init)
            <^> j <| "uuid"
            <*> j <| "user_to_id"
            <*> j <| "user_from"
            <*> UserRatingType.decode(j)
            <*> j <| "value"
        let result = result1
            <*> j <|? "comment"
            <*> j <| "status"
            <*> j <| "created_at"
            <*> j <| "updated_at"

        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.Parsing, message: "LGUserRating parse error: \(error)")
        }

        return result
    }
}

extension UserRatingStatus: Decodable {}

extension UserRatingType: Decodable {
    public static func decode(_ j: JSON) -> Decoded<UserRatingType> {
        let decodedType: Decoded<UserRatingApiType> = j <| "type"
        guard let type = decodedType.value else { return Decoded<UserRatingType>.fromOptional(nil) }

        let result: Decoded<UserRatingType>
        switch type {
        case .conversation:
            result = Decoded<UserRatingType>.fromOptional(.conversation)
        case .seller:
            result = curry(UserRatingType.seller)
                <^> j <| "product_id"
        case .buyer:
            result = curry(UserRatingType.buyer)
                <^> j <| "product_id"
        }

        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.Parsing, message: "UserRatingType parse error: \(error)")
        }
        return result
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
        }
    }

    var apiValue: Int {
        return apiType.rawValue
    }
}

private enum UserRatingApiType: Int {
    case conversation = 1
    case seller = 2
    case buyer = 3
}

extension UserRatingApiType: Decodable {}
