//
//  CoreReport.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 01/03/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

private let coreDomain = "com.letgo.ios.LGCoreKit"

// 100000..<300000
enum CoreReportNetworking: ReportType {
    case badRequest                                     // 140000
    case unauthorized(authLevel: AuthLevel)             // 1401XX
    case notFound                                       // 140400
    case conflict                                       // 140900
    case scammer                                        // 141800
    case unprocessableEntity                            // 142200
    case userNotVerified                                // 142400
    case internalServerError                            // 150000

    case invalidJWT(reason: CoreReportInvalidJWTReason) // 1600XX

    case other(httpCode: Int)                           // 2XXX00

    var domain: String {
        return coreDomain
    }
    var code: Int {
        switch self {
        case .badRequest:
            return 140000
        case let .unauthorized(authLevel):
            let baseCode = 140100
            switch authLevel {
            case .nonexistent:
                return baseCode
            case .installation:
                return baseCode + 1
            case .user:
                return baseCode + 2
        }
        case .notFound:
            return 140400
        case .conflict:
            return 140900
        case .scammer:
            return 141800
        case .unprocessableEntity:
            return 142200
        case .userNotVerified:
            return 142400
        case .internalServerError:
            return 150000
        case let .invalidJWT(reason):
            let baseCode = 160000
            switch reason {
            case .wrongFormat:
                return baseCode + 1
            case .unknownAuthLevel:
                return baseCode + 2
            }
        case let .other(code):
            return 200000 + code * 100
        }
    }

    init?(apiError: ApiError, currentAuthLevel: AuthLevel? = nil) {
        switch apiError {
        case .badRequest:
            self = .badRequest
        case .unauthorized where currentAuthLevel != nil:
            guard let authLevel = currentAuthLevel else { return nil }
            self = .unauthorized(authLevel: authLevel)
        case .scammer:
            self = .scammer
        case .notFound:
            self = .notFound
        case .conflict:
            self = .conflict
        case .internalServerError:
            self = .internalServerError
        case .unprocessableEntity:
            self = .unprocessableEntity
        case .userNotVerified:
            self = .userNotVerified
        case let .other(httpCode):
            self = .other(httpCode: httpCode)
        case  .network, .internalError, .notModified, .forbidden, .tooManyRequests, .unauthorized:
            return nil
        }
    }
}

enum CoreReportInvalidJWTReason {
    case wrongFormat
    case unknownAuthLevel
}

// 300000..<400000
enum CoreReportSession: Int, ReportType {
    case insufficientTokenLevel     = 300000
    case forcedSessionCleanup       = 300001

    var domain: String {
        return coreDomain
    }
    var code: Int {
        return rawValue
    }
}

// 400000..<500000
enum CoreReportRepository: Int, ReportType {
    case myUserInvalidObjectId      = 400000

    var domain: String {
        return coreDomain
    }
    var code: Int {
        return rawValue
    }
}

// 500000..<600000
enum CoreReportDataSource: ReportType {
    case parsing(entity: Entity)
    
    enum Entity: Int {
        case place = 1
        case places
        case placeDetails
        case carMakes
        case chatUnreadMessages
        case installation
        case ipLookup
        case listing
        case listings
        case product
        case car
        case realEstate
        case services
        case userListingRelation
        case listingStats
        case userListings
        case transaction
        case transactions
        case bumpeableListing
        case myUser
        case notifications
        case notificationSettings
        case searchAlerts
        case searchSuggestion
        case suggestiveSearch
        case stickers
        case user
        case users
        case userRelation
        case userRating
        case userRatings
        case relaxQuery
        case similarQuery
        case reputationActions
        case preSignedUploadUrl
        case imagesId
        case serviceType
        case report
        case availableFeaturePurchases

        
        var type: Any.Type {
            switch self {
            case .place, .placeDetails:
                return Place.self
            case .places:
                return [Place].self
            case .carMakes:
                return [ApiCarsMake].self
            case .chatUnreadMessages:
                return ChatUnreadMessages.self
            case .installation:
                return LGInstallationAPI.self
            case .ipLookup:
                return LGLocationCoordinates2D.self
            case .listing:
                return Listing.self
            case .listings:
                return [Listing].self
            case .product:
                return LGProduct.self
            case .car:
                return LGCar.self
            case .realEstate:
                return LGRealEstate.self
            case .services:
                return LGService.self
            case .userListingRelation:
                return LGUserListingRelation.self
            case .listingStats:
                return LGListingStats.self
            case .userListings:
                return [LGUserListing].self
            case .transaction:
                return LGTransaction.self
            case .transactions:
                return [LGTransaction].self
            case .bumpeableListing:
                return [LGBumpeableListing].self
            case .myUser:
                return LGMyUser.self
            case .notifications:
                return [LGNotification].self
            case .notificationSettings:
                return [LGNotificationSetting].self
            case .searchAlerts:
                return [LGSearchAlert].self
            case .searchSuggestion ,.imagesId:
                return [String].self
            case .suggestiveSearch:
                return [SuggestiveSearch].self
            case .stickers:
                return [LGSticker].self
            case .user:
                return LGUser.self
            case .users:
                return [LGUser].self
            case .userRelation:
                return LGUserUserRelation.self
            case .userRating:
                return LGUserRating.self
            case .userRatings:
                return [LGUserRating].self
            case .relaxQuery:
                return RelaxQuery.self
            case .similarQuery:
                return SimilarQuery.self
            case .reputationActions:
                return LGUserReputationAction.self
            case .preSignedUploadUrl:
                return LGPreSignedUploadUrl.self
            case .serviceType:
                return LGServiceType.self
            case .report:
                return LGReport.self
            case .availableFeaturePurchases:
                return LGAvailableFeaturePurchases.self
            }
        }
    }
    
    var domain: String {
        return coreDomain
    }
    var code: Int {
        let baseCode = 500000
        switch self {
        case .parsing(let entity):
            return baseCode + entity.rawValue
        }
    }
}

// 600000..<700000
enum CoreReportJSONSerialization: ReportType {
    case decoding

    var domain: String {
        return coreDomain
    }
    var code: Int {
        let baseCode = 600000
        switch self {
        case .decoding: return baseCode
        }
    }
}
