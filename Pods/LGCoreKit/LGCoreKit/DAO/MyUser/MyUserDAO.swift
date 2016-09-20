//
//  MyUserDAO.swift
//  LGCoreKit
//
//  Created by AHL on 23/11/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import RxSwift

protocol MyUserDAO: class {
    var myUser: MyUser? { get }
    var rx_myUser: Variable<MyUser?> { get }
    func save(newMyUser: MyUser)
    func delete()
}
