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

    func index(userId: String, offset: Int, limit: Int, completion: UserRatingsDataSourceCompletion?) {
        var params: [String: AnyObject] = [:]
        params["offset"] = offset
        params["limit"] = limit
        params[userFilter] = userId
        let request = UserRatingRouter.Index(params: params)
        apiClient.request(request, decoder: UserRatingApiDataSource.decoderArray, completion: completion)
    }

    func show(ratingId: String, completion: UserRatingDataSourceCompletion?) {
        let request = UserRatingRouter.Show(objectId: ratingId)
        apiClient.request(request, decoder: UserRatingApiDataSource.decoder, completion: completion)
    }

    func show(userId: String, userFromId: String, type: UserRatingType, completion: UserRatingDataSourceCompletion?) {
        var params: [String: AnyObject] = [:]
        params[userFilter] = userId
        params[userFromFilter] = userFromId
        params[typeFilter] = type.apiValue
        switch type {
        case .Conversation:
            break
        case let .Buyer(productId):
            params[productFilter] = productId
        case let .Seller(productId):
            params[productFilter] = productId
        }
        let request = UserRatingRouter.Index(params: params)
        // UserRating with same (userId, userFromId, type) is unique so result should have one (or zero) results
        apiClient.request(request, decoder: UserRatingApiDataSource.decoderArray) { result in
            switch result {
            case let .Failure(error):
                completion?(UserRatingDataSourceResult(error: error))
            case let .Success(ratingArray):
                guard let rating = ratingArray.first else {
                    completion?(UserRatingDataSourceResult(error: .NotFound))
                    return
                }
                completion?(UserRatingDataSourceResult(rating))
            }
        }
    }

    func create(userId: String, userFromId: String, value: Int, comment: String?, type: UserRatingType, completion: UserRatingDataSourceCompletion?) {
        let data = UserRatingApiDataSource.encodeUserRatingParams(userId: userId, userFromId: userFromId,
                                                                  value: value, comment: comment, type: type)
        let request = UserRatingRouter.Create(params: data)
        apiClient.request(request, decoder: UserRatingApiDataSource.decoder, completion: completion)
    }

    func update(ratingId: String, value: Int?, comment: String?, completion: UserRatingDataSourceCompletion?) {
        let data = UserRatingApiDataSource.encodeUserRatingParams(userId: nil, userFromId: nil,
                                                                  value: value, comment: comment, type: nil)
        let request = UserRatingRouter.Update(objectId: ratingId, params: data)
        apiClient.request(request, decoder: UserRatingApiDataSource.decoder, completion: completion)
    }

    func report(ratingId: String, completion: UserRatingDataSourceEmptyCompletion?) {
        let request = UserRatingRouter.Report(objectId: ratingId)
        apiClient.request(request, completion: completion)
    }


    // MARK: - Decoder

    private static func decoderArray(object: AnyObject) -> [UserRating]? {
        guard let ratings : [LGUserRating] = decode(object) else { return nil }
        return ratings.map{$0}
    }

    private static func decoder(object: AnyObject) -> UserRating? {
        guard let userRating : LGUserRating = decode(object) else { return nil }
        return userRating
    }

    // MARK: - Encoder

    private static func encodeUserRatingParams(userId userId: String?, userFromId: String?, value: Int?,
                                                     comment: String?, type: UserRatingType?) -> [String : AnyObject] {
        var result: [String : AnyObject] = [:]
        result["type"] = type?.apiValue
        result["user_id"] = userFromId
        result["user_rated_id"] = userId
        result["value"] = value
        var attributes: [String : AnyObject] = [:]
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
        case .Conversation:
            return nil
        case let .Seller(productId):
            return productId
        case let .Buyer(productId):
            return productId
        }
    }
}
