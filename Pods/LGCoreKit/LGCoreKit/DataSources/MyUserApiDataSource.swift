//
//  MyUserApiDataSource.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 03/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Result

class MyUserApiDataSource: MyUserDataSource {
    let apiClient: ApiClient
    
    
    // MARK: - Lifecycle
    
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    
    // MARK: - MyUserDataSource

    func show(_ myUserId: String, completion: MyUserApiCompletion?) {
        let request = MyUserRouter.show(myUserId: myUserId)
        apiClient.request(request, decoder: MyUserApiDataSource.decoder, completion: completion)
    }

    func createWithEmail(_ email: String, password: String, name: String, newsletter: Bool?, location: LGLocation?,
                         postalAddress: PostalAddress?, localeIdentifier: String,
                         completion: MyUserApiCompletion?) {
        var data: [String: Any] = [:]
        data[LGMyUser.CodingKeys.email.rawValue] = email
        data[LGMyUser.CodingKeys.password.rawValue] = password
        data[LGMyUser.CodingKeys.name.rawValue] = name
        data[LGMyUser.CodingKeys.latitude.rawValue] = location?.coordinate.latitude
        data[LGMyUser.CodingKeys.longitude.rawValue] = location?.coordinate.longitude
        data[LGMyUser.CodingKeys.locationType.rawValue] = location?.type.rawValue
        data[LGMyUser.CodingKeys.zipCode.rawValue] = postalAddress?.zipCode
        data[LGMyUser.CodingKeys.address.rawValue] = postalAddress?.address
        data[LGMyUser.CodingKeys.city.rawValue] = postalAddress?.city
        data[LGMyUser.CodingKeys.countryCode.rawValue] = postalAddress?.countryCode
        if let newsletter = newsletter {
            data[LGMyUser.CodingKeys.newsletter.rawValue] = newsletter
        }
        data[LGMyUser.CodingKeys.localeIdentifier.rawValue] = localeIdentifier

        let request = MyUserRouter.create(params: data)
        apiClient.request(request, decoder: MyUserApiDataSource.decoder, completion: completion)
    }

    func update(_ myUserId: String, params: [String : Any], completion: MyUserApiCompletion?) {
        let request = MyUserRouter.update(myUserId: myUserId, params: params)
        apiClient.request(request, decoder: MyUserApiDataSource.decoder, completion: completion)
    }

    func uploadAvatar(_ avatar: Data, myUserId: String, progressBlock: ((Int) -> ())?, completion: MyUserApiCompletion?) {
        var data: [String: Any] = [:]
        data[LGMyUser.CodingKeys.avatar.rawValue] = avatar

        let request = MyUserRouter.updateAvatar(myUserId: myUserId, params: data)

        apiClient.upload(request, decoder: MyUserApiDataSource.decoder, multipart: { multipartFormData in
                multipartFormData.append(avatar, withName: "avatar", fileName: "avatar.jpg", mimeType: "image/jpg")
            }, completion: completion) { progress in
                let percentProgress: Int
                if progress.totalUnitCount > 0 {
                    percentProgress = Int(progress.completedUnitCount*100/progress.totalUnitCount)
                } else {
                    percentProgress = 0
                }
                progressBlock?(percentProgress)
        }
    }

    func resetPassword(_ userId: String, params: [String: Any], token: String,
        completion: MyUserApiCompletion?) {
            let request = MyUserRouter.resetPassword(myUserId: userId, params: params, token: token)
            apiClient.request(request, decoder: MyUserApiDataSource.decoder, completion: completion)
    }

    func linkAccount(_ userId: String, provider: LinkAccountProvider, completion: ((Result<Void, ApiError>) -> ())?) {
        var params: [String: Any] = [:]
        params["provider"] = provider.accountProvider.rawValue 
        params["credentials"] = provider.credentials 
        let request = MyUserRouter.linkAccount(myUserId: userId, params: params)
        apiClient.request(request, completion: completion)
    }

    func retrieveUserReputationActions(_ userId: String, completion: UserDataSourceReputationCompletion?) {
        let request = MyUserRouter.showReputationActions(myUserId: userId)
        apiClient.request(request, decoder: MyUserApiDataSource.decoderReputationActions, completion: completion)
    }

    func requestSMSCode(_ userId: String, phonePrefix: String, phone: String, completion: MyUserApiVoidCompletion?) {
        var params: [String: Any] = [:]
        params["prefix"] = phonePrefix
        params["telephone"] = phone
        let request = MyUserRouter.requestSMSCode(myUserId: userId, params: params)
        apiClient.request(request, completion: completion)
    }

    func validateSMSCode(_ userId: String, code: String, completion: MyUserApiVoidCompletion?) {
        var params: [String: Any] = [:]
        params["code"] = code
        let request = MyUserRouter.validateSMSCode(myUserId: userId, params: params)
        apiClient.request(request, completion: completion)
    }
    
    func notifyReferral(inviterId: String, myUserId: String, completion: @escaping DataSourceCompletion<Void>) {
        let userIdKey = "user_id"
        let params: [String : Any] = [userIdKey : inviterId]
        let request = MyUserRouter.notifyReferral(myUserId: myUserId, params: params)
        apiClient.request(request, completion: completion)
    }

    // MARK: - Private methods

    /**
    Decodes an object to a `MyUser` object.
    - parameter object: The object.
    - returns: A `MyUser` object.
    */
    
    private static func decoder(_ object: Any) -> MyUser? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted) else { return nil }
        do {
            let myUser = try LGMyUser.decode(jsonData: data)
            return myUser
        } catch {
            logAndReportParseError(object: object, entity: .myUser,
                                   comment: "could not parse LGMyUser")
        }
        return nil
    }

    private static func decoderReputationActions(_ object: Any) -> [UserReputationAction]? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted) else { return nil }

        do {
            let actions = try JSONDecoder().decode(FailableDecodableArray<LGUserReputationAction>.self, from: data)
            return actions.validElements
        } catch {
            logAndReportParseError(object: object, entity: .reputationActions,
                                   comment: "could not parse [LGUserReputationAction]")
        }
        return nil
    }
}

// MARK: - AddAccount provider

private extension LinkAccountProvider {
    var credentials: String {
        switch self {
        case .email(let email):
            return email
        case .facebook(let facebookToken):
            return facebookToken
        case .google(let googleToken):
            return googleToken
        }
    }
}
