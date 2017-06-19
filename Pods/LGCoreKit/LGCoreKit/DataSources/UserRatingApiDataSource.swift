//
//  UserRatingApiDataSource.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 14/07/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation
import Argo


class UserRatingApiDataSource: UserRatingDataSource {

    let apiClient: ApiClient

    private let userFilter = "filter[user_rated_id]"
    private let typeFilter = "filter[type]"
    private let userFromFilter = "filter[user_id]"
    private let productFilter = "filter[product_id]"

    // MARK: - Lifecycle

    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }

    func index(_ userId: String, offset: Int, limit: Int, completion: UserRatingsDataSourceCompletion?) {
        var params: [String: Any] = [:]
        params["offset"] = offset
        params["limit"] = limit
        params[userFilter] = userId
        let request = UserRatingRouter.index(params: params)
        apiClient.request(request, decoder: UserRatingApiDataSource.decoderArray, completion: completion)
    }

    func show(_ ratingId: String, completion: UserRatingDataSourceCompletion?) {
        let request = UserRatingRouter.show(objectId: ratingId)
        apiClient.request(request, decoder: UserRatingApiDataSource.decoder, completion: completion)
    }

    func show(_ userId: String, userFromId: String, type: UserRatingType, completion: UserRatingDataSourceCompletion?) {
        var params: [String: Any] = [:]
        params[userFilter] = userId
        params[userFromFilter] = userFromId
        params[typeFilter] = type.apiValue
        switch type {
        case .conversation:
            break
        case let .buyer(productId):
            params[productFilter] = productId
        case let .seller(productId):
            params[productFilter] = productId
        }
        let request = UserRatingRouter.index(params: params)
        // UserRating with same (userId, userFromId, type) is unique so result should have one (or zero) results
        apiClient.request(request, decoder: UserRatingApiDataSource.decoderArray) { result in
            switch result {
            case let .failure(error):
                completion?(UserRatingDataSourceResult(error: error))
            case let .success(ratingArray):
                guard let rating = ratingArray.first else {
                    completion?(UserRatingDataSourceResult(error: .notFound))
                    return
                }
                completion?(UserRatingDataSourceResult(rating))
            }
        }
    }

    func create(_ userId: String, userFromId: String, value: Int, comment: String?, type: UserRatingType, completion: UserRatingDataSourceCompletion?) {
        let data = UserRatingApiDataSource.encodeUserRatingParams(userId: userId, userFromId: userFromId,
                                                                  value: value, comment: comment, type: type)
        let request = UserRatingRouter.create(params: data)
        apiClient.request(request, decoder: UserRatingApiDataSource.decoder, completion: completion)
    }

    func update(_ ratingId: String, value: Int?, comment: String?, completion: UserRatingDataSourceCompletion?) {
        let data = UserRatingApiDataSource.encodeUserRatingParams(userId: nil, userFromId: nil,
                                                                  value: value, comment: comment, type: nil)
        let request = UserRatingRouter.update(objectId: ratingId, params: data)
        apiClient.request(request, decoder: UserRatingApiDataSource.decoder, completion: completion)
    }

    func report(_ ratingId: String, completion: UserRatingDataSourceCompletion?) {
        let request = UserRatingRouter.report(objectId: ratingId)
        apiClient.request(request, decoder: UserRatingApiDataSource.decoder, completion: completion)
    }


    // MARK: - Decoder

    private static func decoderArray(_ object: Any) -> [UserRating]? {
        // Ignore ratings that can't be decoded
        guard let ratings = Array<LGUserRating>.filteredDecode(JSON(object)).value else { return nil }
        return ratings.map{ $0 }
    }

    private static func decoder(_ object: Any) -> UserRating? {
        guard let userRating : LGUserRating = decode(object) else { return nil }
        return userRating
    }

    // MARK: - Encoder

    private static func encodeUserRatingParams(userId: String?, userFromId: String?, value: Int?,
                                                   comment: String?, type: UserRatingType?) -> [String : Any] {
        var result: [String : Any] = [:]
        result["type"] = type?.apiValue
        result["user_id"] = userFromId
        result["user_rated_id"] = userId
        result["value"] = value
        var attributes: [String : Any] = [:]
        attributes["product_id"] = type?.productId
        attributes["comment"] = comment
        if !attributes.isEmpty {
            result["attributes"] = attributes
        }
        return result
    }
}


private extension UserRatingType {
    var productId: String? {
        switch self {
        case .conversation:
            return nil
        case let .seller(productId):
            return productId
        case let .buyer(productId):
            return productId
        }
    }
}
