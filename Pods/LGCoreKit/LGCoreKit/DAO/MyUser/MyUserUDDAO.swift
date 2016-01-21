//
//  MyUserUserDefaultsDAO.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 11/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Foundation

class MyUserUDDAO: MyUserDAO {

    // Constants
    static let MyUserKeyMainKey = "MyUser"
    struct MyUserKeys {
        static let username = "username"
        static let email = "email"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let publicUsername = "publicUsername"
        static let avatar = "avatar"
        static let address = "address"
        static let city = "city"
        static let zipCode = "zipCode"
        static let countryCode = "countryCode"
        static let country = "country"
        static let objectId = "objectId"
    }

    // iVars
    let userDefaults: NSUserDefaults
    private(set) var myUser: MyUser?


    // MARK: - Lifecycle

    convenience init() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        self.init(userDefaults: userDefaults)
    }

    init(userDefaults: NSUserDefaults) {
        self.userDefaults = userDefaults
        self.myUser = fetch()
    }


    // MARK : - MyUserDAO

    func save(theMyUser: MyUser) {
        myUser = theMyUser

        let dict: [String: AnyObject] = theMyUser.encode()
        userDefaults.setValue(dict, forKey: MyUserUDDAO.MyUserKeyMainKey)
    }

    func delete() {
        myUser = nil
        userDefaults.removeObjectForKey(MyUserUDDAO.MyUserKeyMainKey)
    }


    // MARK: - Private methods

    private func fetch() -> MyUser? {
        guard let dict = userDefaults.dictionaryForKey(MyUserUDDAO.MyUserKeyMainKey) else { return nil }
        return LGMyUser.decode(dict)
    }
}
