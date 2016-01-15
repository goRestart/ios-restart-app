//
//  UserManager.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 22/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

public class UserManager {

    private var userRetrieveService: UserRetrieveService

    // MARK: - Lifecycle

    public required init(userRetrieveService: UserRetrieveService) {
        self.userRetrieveService = userRetrieveService
    }

    public convenience init() {
        let userRetrieveService = LGUserRetrieveService()
        self.init(userRetrieveService: userRetrieveService)
    }

    // MARK: - Public methods

    /**
        Retrieves a product with the given id.

        - parameter productId: The product identifier.
        - parameter result: The completion closure.
    */
    public func retrieveUserWithId(userId: String, completion: UserRetrieveServiceCompletion) {
        userRetrieveService.retrieveUserWithId(userId, completion: completion)
    }
}
