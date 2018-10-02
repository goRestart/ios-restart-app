//
//  UserApiDataSource.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 3/2/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result

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

    func indexBlocked(_ userId: String, limit: Int, offset: Int, completion: UsersDataSourceCompletion?) {
        let params: [String: Any] = ["filter[link_name]": "blocked",
                                     "offset": offset,
                                     "limit": limit]
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

    func requestVerification(params: [String: Any], completion: DataSourceCompletion<Void>?) {
        let request = UserRouter.createVerificationRequest(params: params)
        apiClient.request(request, completion: completion)
    }

    func readVerificationRequests(requestedUserId: String, myUserId: String, completion: DataSourceCompletion<[UserVerificationRequest]>?) {
        let params: [String: Any] = ["filter[requester]": myUserId, "filter[requested]": requestedUserId]
        let request = UserRouter.verificationRequests(params: params)
        apiClient.request(request, decoder: UserApiDataSource.decoderVerificationRequests, completion: completion)
    }

    // MARK: - Private methods

    private static func decoderArray(_ object: Any) -> [User]? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted) else { return nil }
        do {
            let users = try JSONDecoder().decode(FailableDecodableArray<LGUser>.self, from: data)
            return users.validElements
        } catch {
            logAndReportParseError(object: object, entity: .users,
                                   comment: "could not parse [LGUser]")
        }
        return nil

    }

    private func decoder(_ object: Any) -> User? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted) else { return nil }
        do {
            let user = try LGUser.decode(jsonData: data)
            return user
        } catch {
            logAndReportParseError(object: object, entity: .user,
                                   comment: "could not parse LGUser")
        }
        return nil
    }

    static func decoderUserRelation(_ object: Any) -> UserUserRelation? {
        if let json = object as? [[String: Any]] {
            return LGUserUserRelation.decodeFrom(jsonArray: json)
        } else {
            guard let data = try? JSONSerialization.data(withJSONObject: object,
                                                         options: .prettyPrinted) else {
                                                            logAndReportParseError(object: object, entity: .userRelation,
                                                                                   comment: "could not parse LGUserUserRelation")
                                                            return nil
            }
            return LGUserUserRelation.decodeFrom(jsonData: data)
        }
    }

    private static func decoderVerificationRequests(_ object: Any) -> [UserVerificationRequest]? {

        guard let dict = object as? [String : Any] else { return nil }
        guard let itemsArray = dict["data"] as? [[String : Any]] else { return nil }
        guard let data = try? JSONSerialization.data(withJSONObject: itemsArray, options: .prettyPrinted) else { return nil }

        do {
            let verificationRequests = try JSONDecoder().decode(FailableDecodableArray<LGUserVerificationRequest>.self,
                                                                from: data)
            return verificationRequests.validElements

        } catch {
            logAndReportParseError(object: object, entity: .verificationRequests,
                                   comment: "could not parse [LGUserVerificationRequest]")
        }
        return nil
    }
}
