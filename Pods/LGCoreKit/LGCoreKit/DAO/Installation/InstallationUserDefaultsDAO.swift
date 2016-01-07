//
//  InstallationUserDefaultsDAO.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 11/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Foundation
import Argo

class InstallationUserDefaultsDAO: InstallationDAO {
    
    static let sharedInstance = InstallationUserDefaultsDAO()
    private let userDefaults: NSUserDefaults
    static let userDefaultsKey = "Installation"
   
    
    // MARK: Inits
    
    convenience init() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        self.init(userDefaults: userDefaults)
    }
    
    init(userDefaults: NSUserDefaults) {
        self.userDefaults = userDefaults
    }
    
    
    // MARK: InstallationDAO Protocol
    
    lazy var installation: Installation? = {
        return self.fetch()
    }()

    func save(installation: Installation) {
        let dict = installation.encode()
        userDefaults.setValue(dict, forKey: InstallationUserDefaultsDAO.userDefaultsKey)
        self.installation = installation
    }
    
    func delete() {
        userDefaults.removeObjectForKey(InstallationUserDefaultsDAO.userDefaultsKey)
        self.installation = nil
    }
    
    
    // MARK: Private methods
    
    private func fetch() -> Installation? {
        guard let dict = userDefaults.dictionaryForKey(InstallationUserDefaultsDAO.userDefaultsKey) else { return nil }
        let installation: LGInstallation? = LGInstallation.decode(dict)
        self.installation = installation
        return installation
    }
}