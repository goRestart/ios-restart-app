//
//  UsersMemoryDAO.swift
//  LGCoreKit
//
//  Created by Dídac on 28/12/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Foundation

class UsersMemoryDAO: UsersDAO {

    private var usersDict: [String : User] = [:]

    func save(user: User) {
        guard let userId = user.objectId else { return }
        usersDict[userId] = user
    }

    func retrieve(userId: String) -> User? {
        return usersDict[userId]
    }

    func clean() {
        usersDict = [:]
    }
}
