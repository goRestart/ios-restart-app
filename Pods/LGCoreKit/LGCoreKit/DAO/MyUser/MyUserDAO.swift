//
//  MyUserDAO.swift
//  LGCoreKit
//
//  Created by AHL on 23/11/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

protocol MyUserDAO: class {
    var myUser: MyUser? { get }
    func save(newMyUser: MyUser)
    func delete()
}
