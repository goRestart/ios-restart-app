//
//  MyUserApiDataSource.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 03/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Argo
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
        let JSONKeys = LGMyUser.ApiMyUserKeys()

        var data: [String: Any] = [:]
        data[JSONKeys.email] = email
        data[JSONKeys.password] = password
        data[JSONKeys.name] = name
        data[JSONKeys.latitude] = location?.coordinate.latitude
        data[JSONKeys.longitude] = location?.coordinate.longitude
        data[JSONKeys.locationType] = location?.type?.rawValue
        data[JSONKeys.zipCode] = postalAddress?.zipCode
        data[JSONKeys.address] = postalAddress?.address
        data[JSONKeys.city] = postalAddress?.city
        data[JSONKeys.countryCode] = postalAddress?.countryCode
        if let newsletter = newsletter {
            data[JSONKeys.newsletter] = newsletter 
        }
        data[JSONKeys.localeIdentifier] = localeIdentifier 

        let request = MyUserRouter.create(params: data)
        apiClient.request(request, decoder: MyUserApiDataSource.decoder, completion: completion)
    }

    func update(_ myUserId: String, params: [String : Any], completion: MyUserApiCompletion?) {
        let request = MyUserRouter.update(myUserId: myUserId, params: params)
        apiClient.request(request, decoder: MyUserApiDataSource.decoder, completion: completion)
    }

    func uploadAvatar(_ avatar: Data, myUserId: String, progressBlock: ((Int) -> ())?, completion: MyUserApiCompletion?) {

        let JSONKeys = LGMyUser.ApiMyUserKeys()

        var data: [String: Any] = [:]
        data[JSONKeys.avatar] = avatar 

        let request = MyUserRouter.updateAvatar(myUserId: myUserId, params: data)

        apiClient.upload(request, decoder: MyUserApiDataSource.decoder, multipart: { multipartFormData in
                multipartFormData.append(avatar, withName: "avatar", fileName: "avatar.jpg", mimeType: "image/jpg")
            }, completion: completion) { progress in
                let p = progress.completedUnitCount*100/progress.totalUnitCount
                progressBlock?(Int(p))
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

    
    // MARK: - Private methods

    /**
    Decodes an object to a `MyUser` object.
    - parameter object: The object.
    - returns: A `MyUser` object.
    */
    private static func decoder(_ object: Any) -> MyUser? {
        let apiUser: LGMyUser? = decode(object)
        return apiUser
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
