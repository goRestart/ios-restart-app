//
//  UserRepository.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 3/2/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation
import Result

public final class UserRepository {
    let dataSource: UserDataSource
    
    
    // MARK: - Lifecycle
    
    init(dataSource: UserDataSource) {
        self.dataSource = dataSource
    }
    
    /**
    Retrieves the user for the given ID.
    - parameter userId: User identifier.
    - parameter completion: The completion closure.
    */
    public func show(userId: String, completion: ((Result<User, RepositoryError>) -> ())?) {
        dataSource.show(userId) { result in
            handleApiResult(result, success: nil, completion: completion)
        }
    }
}
