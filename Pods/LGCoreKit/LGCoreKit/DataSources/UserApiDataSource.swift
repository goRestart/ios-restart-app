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

    func show(userId: String, includeAccounts: Bool, completion: UserDataSourceCompletion?) {
        let request = UserRouter.Show(userId: userId, includeAccounts: includeAccounts)
        apiClient.request(request, decoder: decoder, completion: completion)
    }

    func saveReport(reportedUserId: String, userId: String, parameters: [String: AnyObject],
        completion: UserDataSourceEmptyCompletion?) {
            let request = UserRouter.SaveReport(userId: userId, reportedUserId: reportedUserId, params: parameters)
        apiClient.request(request, completion: completion)
    }

    func indexBlocked(userId: String, completion: UsersDataSourceCompletion?) {
        let params: [String: AnyObject] = ["filter[link_name]": "blocked"]
        let request = UserRouter.IndexBlocked(userId: userId, params: params)
        apiClient.request(request, decoder: UserApiDataSource.decoderArray, completion: completion)
    }

    func retrieveRelation(userId: String, relatedUserId: String, completion: UserDataSourceUserRelationCompletion?) {
        let params: [String: AnyObject] = ["filter[user_to_id]": relatedUserId]
        let request = UserRouter.UserRelation(userId: userId, params: params)
        apiClient.request(request, decoder: UserApiDataSource.decoderUserRelation, completion: completion)
    }

    func blockUser(userId: String, relatedUserId: String, completion: UserDataSourceEmptyCompletion?) {
        let params: [String: AnyObject] = ["blocked": true]
        let request = UserRouter.BlockUser(userId: userId, userToId: relatedUserId, params: params)
        apiClient.request(request, completion: completion)
    }

    func unblockUser(userId: String, relatedUserId: String, completion: UserDataSourceEmptyCompletion?) {
        let params: [String: AnyObject] = ["blocked": false]
        let request = UserRouter.UnblockUser(userId: userId, userToId: relatedUserId, params: params)
        apiClient.request(request, completion: completion)
    }

    
    // MARK: - Private methods

    private static func decoderArray(object: AnyObject) -> [User]? {
        guard let theProduct : [LGUser] = decode(object) else { return nil }
        return theProduct.map{$0}
    }

    private func decoder(object: AnyObject) -> User? {
        let apiUser: LGUser? = decode(object)
        return apiUser
    }

    static func decoderUserRelation(object: AnyObject) -> UserUserRelation? {
        let relation: LGUserUserRelation? = LGUserUserRelation.decode(JSON(object))
        return relation
    }

}
