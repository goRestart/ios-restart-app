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
    
    static let sharedInstance = MyUserApiDataSource()

    
    // MARK: - MyUserDataSource
    
    func show(myUserId: String, completion: ((Result<MyUser, ApiError>) -> ())?) {
        let request = MyUserRouter.Show(myUserId: myUserId)
        ApiClient.request(request, decoder: decoder, completion: completion)
    }
    
    func createWithEmail(email: String, password: String, name: String, location: LGLocation?,
        completion: ((Result<MyUser, ApiError>) -> ())?) {
            var data: [String: AnyObject] = [:]
            
            data[LGMyUser.JSONKeys.email] = email
            data[LGMyUser.JSONKeys.password] = password
            data[LGMyUser.JSONKeys.name] = name
            data[LGMyUser.JSONKeys.latitude] = location?.coordinate.latitude
            data[LGMyUser.JSONKeys.longitude] = location?.coordinate.longitude
            
            let request = MyUserRouter.Create(params: data)
            ApiClient.request(request, decoder: decoder, completion: completion)
    }

    func update(myUserId: String, params: [String : AnyObject], completion: ((Result<MyUser, ApiError>) -> ())?) {
        let request = MyUserRouter.Update(myUserId: myUserId, params: params)
        ApiClient.request(request, decoder: decoder, completion: completion)
    }

    func uploadAvatar(avatar: NSData, myUserId: String, progressBlock: ((Int) -> ())?, completion: ((Result<MyUser, ApiError>) -> ())?) {
        var data: [String: AnyObject] = [:]

        data[LGMyUser.JSONKeys.avatar] = avatar
        
        let request = MyUserRouter.UpdateAvatar(myUserId: myUserId, params: data)

        ApiClient.upload(request, decoder: decoder, multipart: { multipartFormData in
            multipartFormData.appendBodyPart(data: avatar, name: "avatar", fileName: "avatar.jpg", mimeType: "image/jpg")
            }, completion: completion) { (written, totalWritten, totalExpectedToWrite) -> Void in
                let p = totalWritten*100/totalExpectedToWrite
                progressBlock?(Int(p))
        }
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
}