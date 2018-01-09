//
//  UsersDAO.swift
//  LGCoreKit
//
//  Created by Dídac on 28/12/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

protocol UsersDAO {
    func save(user: User)
    func retrieve(userId: String) -> User?
    func clean()
}
