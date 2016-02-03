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
    
    func show(userId: String, completion: ((Result<User, ApiError>) -> ())?) {
        let request = UserRouter.Show(userId: userId)
        apiClient.request(request, decoder: decoder, completion: completion)
    }
    
    
    // MARK: - Private methods
    
    private func decoder(object: AnyObject) -> User? {
        let apiUser: LGUser? = decode(object)
        return apiUser
    }
}
