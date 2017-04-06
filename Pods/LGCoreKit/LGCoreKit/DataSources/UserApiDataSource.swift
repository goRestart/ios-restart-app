//
//  UserApiDataSource.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 3/2/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result
import Argo

final class UserApiDataSource: UserDataSource {
    
    let apiClient: ApiClient

    
    // MARK: - Lifecycle
    
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }

    func show(_ userId: String, completion: UserDataSourceCompletion?) {
        let request = UserRouter.show(userId: userId)
        apiClient.request(request, decoder: decoder, completion: completion)
    }

    func saveReport(_ reportedUserId: String, userId: String, parameters: [String: Any],
        completion: UserDataSourceEmptyCompletion?) {
            let request = UserRouter.saveReport(userId: userId, reportedUserId: reportedUserId, params: parameters)
        apiClient.request(request, completion: completion)
    }

    func indexBlocked(_ userId: String, completion: UsersDataSourceCompletion?) {
        let params: [String: Any] = ["filter[link_name]": "blocked"]
        let request = UserRouter.indexBlocked(userId: userId, params: params)
        apiClient.request(request, decoder: UserApiDataSource.decoderArray, completion: completion)
    }

    func retrieveRelation(_ userId: String, relatedUserId: String, completion: UserDataSourceUserRelationCompletion?) {
        let params: [String: Any] = ["filter[user_to_id]": relatedUserId]
        let request = UserRouter.userRelation(userId: userId, params: params)
        apiClient.request(request, decoder: UserApiDataSource.decoderUserRelation, completion: completion)
    }

    func blockUser(_ userId: String, relatedUserId: String, completion: UserDataSourceEmptyCompletion?) {
        let params: [String: Any] = ["blocked": true]
        let request = UserRouter.blockUser(userId: userId, userToId: relatedUserId, params: params)
        apiClient.request(request, completion: completion)
    }

    func unblockUser(_ userId: String, relatedUserId: String, completion: UserDataSourceEmptyCompletion?) {
        let params: [String: Any] = ["blocked": false]
        let request = UserRouter.unblockUser(userId: userId, userToId: relatedUserId, params: params)
        apiClient.request(request, completion: completion)
    }

    
    // MARK: - Private methods

    private static func decoderArray(_ object: Any) -> [User]? {
        guard let theProduct : [LGUser] = decode(object) else { return nil }
        return theProduct.map{$0}
    }

    private func decoder(_ object: Any) -> User? {
        let apiUser: LGUser? = decode(object)
        return apiUser
    }

    static func decoderUserRelation(_ object: Any) -> UserUserRelation? {
        let relation: LGUserUserRelation? = LGUserUserRelation.decode(JSON(object))
        return relation
    }

}
