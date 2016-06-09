//
//  MyUserUserDefaultsDAO.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 11/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Foundation
import RxSwift

class MyUserUDDAO: MyUserDAO {

    // Constants
    static let MyUserKeyMainKey = "MyUser"

    // iVars
    let userDefaults: NSUserDefaults
    var myUser: MyUser? {
        return rx_myUser.value
    }
    let rx_myUser = Variable<MyUser?>(nil)


    // MARK: - Lifecycle

    convenience init() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        self.init(userDefaults: userDefaults)
    }

    init(userDefaults: NSUserDefaults) {
        self.userDefaults = userDefaults
        self.rx_myUser.value = fetch()
    }


    // MARK : - MyUserDAO

    func save(theMyUser: MyUser) {
        rx_myUser.value = theMyUser

        let localMyUser = LocalMyUser(myUser: theMyUser)
        let dict: [String: AnyObject] = localMyUser.encode()
        userDefaults.setValue(dict, forKey: MyUserUDDAO.MyUserKeyMainKey)
    }

    func delete() {
        rx_myUser.value = nil
        userDefaults.removeObjectForKey(MyUserUDDAO.MyUserKeyMainKey)
    }


    // MARK: - Private methods

    private func fetch() -> MyUser? {
        guard let dict = userDefaults.dictionaryForKey(MyUserUDDAO.MyUserKeyMainKey) else { return nil }
        return LocalMyUser.decode(dict)
    }
}
