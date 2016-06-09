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

    func show(myUserId: String, completion: ((Result<MyUser, ApiError>) -> ())?) {
        let request = MyUserRouter.Show(myUserId: myUserId)
        apiClient.request(request, decoder: decoder, completion: completion)
    }

    func createWithEmail(email: String, password: String, name: String, newsletter: Bool?, location: LGLocation?,
        postalAddress: PostalAddress?, completion: ((Result<MyUser, ApiError>) -> ())?) {
            var data: [String: AnyObject] = [:]

            data[LGMyUser.JSONKeys.email] = email
            data[LGMyUser.JSONKeys.password] = password
            data[LGMyUser.JSONKeys.name] = name
            data[LGMyUser.JSONKeys.latitude] = location?.coordinate.latitude
            data[LGMyUser.JSONKeys.longitude] = location?.coordinate.longitude
            data[LGMyUser.JSONKeys.locationType] = location?.type?.rawValue
            data[LGMyUser.JSONKeys.zipCode] = postalAddress?.zipCode
            data[LGMyUser.JSONKeys.address] = postalAddress?.address
            data[LGMyUser.JSONKeys.city] = postalAddress?.city
            data[LGMyUser.JSONKeys.countryCode] = postalAddress?.countryCode
            if let newsletter = newsletter {
                data[LGMyUser.JSONKeys.newsletter] = newsletter
            }

            let request = MyUserRouter.Create(params: data)
            apiClient.request(request, decoder: decoder, completion: completion)
    }

    func update(myUserId: String, params: [String : AnyObject], completion: ((Result<MyUser, ApiError>) -> ())?) {
        let request = MyUserRouter.Update(myUserId: myUserId, params: params)
        apiClient.request(request, decoder: decoder, completion: completion)
    }

    func uploadAvatar(avatar: NSData, myUserId: String, progressBlock: ((Int) -> ())?, completion: ((Result<MyUser, ApiError>) -> ())?) {
        var data: [String: AnyObject] = [:]

        data[LGMyUser.JSONKeys.avatar] = avatar

        let request = MyUserRouter.UpdateAvatar(myUserId: myUserId, params: data)

        apiClient.upload(request, decoder: decoder, multipart: { multipartFormData in
            multipartFormData.appendBodyPart(data: avatar, name: "avatar", fileName: "avatar.jpg", mimeType: "image/jpg")
            }, completion: completion) { (written, totalWritten, totalExpectedToWrite) -> Void in
                let p = totalWritten*100/totalExpectedToWrite
                progressBlock?(Int(p))
        }
    }

    func resetPassword(userId: String, params: [String: AnyObject], token: String,
        completion: ((Result<MyUser, ApiError>) -> ())?) {
            let request = MyUserRouter.ResetPassword(myUserId: userId, params: params, token: token)
            apiClient.request(request, decoder: decoder, completion: completion)
    }

    func linkAccount(userId: String, provider: LinkAccountProvider, completion: ((Result<Void, ApiError>)->())?) {
        var params: [String: AnyObject] = [:]
        params["provider"] = provider.accountProvider.rawValue
        params["credentials"] = provider.credentials
        let request = MyUserRouter.LinkAccount(myUserId: userId, params: params)
        apiClient.request(request, completion: completion)
    }

    func retrieveCounters(completion completion: ((Result<UserCounters, ApiError>)->())?) {
        let request = MyUserRouter.Counters
        apiClient.request(request, decoder: countersDecoder, completion: completion)
    }

    
    // MARK: - Private methods

    /**
    Decodes an object to a `MyUser` object.
    - parameter object: The object.
    - returns: A `MyUser` object.
    */
    private func decoder(object: AnyObject) -> MyUser? {
        let apiUser: LGMyUser? = decode(object)
        return apiUser
    }

    private func countersDecoder(object: AnyObject) -> UserCounters? {
        let counters: LGUserCounters? = decode(object)
        return counters
    }
}

// MARK: - AddAccount provider

private extension LinkAccountProvider {
    var credentials: String {
        switch self {
        case .Email(let email):
            return email
        case .Facebook(let facebookToken):
            return facebookToken
        case .Google(let googleToken):
            return googleToken
        }
    }
}
