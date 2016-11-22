//
//  InstallationUserDefaultsDAO.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 11/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Foundation
import Argo
import RxSwift

class InstallationUserDefaultsDAO: InstallationDAO {

    static let userDefaultsKey = "Installation"

    var installation: Installation? {
        return installationVar.value
    }
    var rx_installation: Observable<Installation?> {
        return installationVar.asObservable()
    }

    private let userDefaults: NSUserDefaults
    private let installationVar = Variable<Installation?>(nil)


    // MARK: Inits

    init(userDefaults: NSUserDefaults) {
        self.userDefaults = userDefaults
        installationVar.value = fetch()
    }


    // MARK: InstallationDAO Protocol

    func save(installation: Installation) {
        let dict = installation.encode()
        userDefaults.setValue(dict, forKey: InstallationUserDefaultsDAO.userDefaultsKey)
        installationVar.value = installation
    }

    func delete() {
        userDefaults.removeObjectForKey(InstallationUserDefaultsDAO.userDefaultsKey)
        installationVar.value = nil
    }


    // MARK: Private methods

    private func fetch() -> Installation? {
        guard let dict = userDefaults.dictionaryForKey(InstallationUserDefaultsDAO.userDefaultsKey) else { return nil }
        let installation: LGInstallation? = LGInstallation.decode(dict)
        return installation
    }
}
