//
//  InstallationUserDefaultsDAO.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 11/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Foundation
import RxSwift

class InstallationUserDefaultsDAO: InstallationDAO {

    static let userDefaultsKey = "Installation"

    var installation: Installation? {
        return installationVar.value
    }
    var rx_installation: Observable<Installation?> {
        return installationVar.asObservable()
    }

    private let userDefaults: UserDefaults
    private let installationVar = Variable<Installation?>(nil)


    // MARK: Inits

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
        installationVar.value = fetch()
    }


    // MARK: InstallationDAO Protocol

    func save(_ installation: Installation) {
        let installationUD = LGInstallationUD.makeInstallationUD(from: installation)
        let data = installationUD.encode()
        userDefaults.setValue(data, forKey: InstallationUserDefaultsDAO.userDefaultsKey)
        installationVar.value = installation
    }

    func delete() {
        userDefaults.removeObject(forKey: InstallationUserDefaultsDAO.userDefaultsKey)
        installationVar.value = nil
    }


    // MARK: Private methods

    private func fetch() -> Installation? {
        guard let dict = userDefaults.dictionary(forKey: InstallationUserDefaultsDAO.userDefaultsKey) else { return nil }
        let installation = LGInstallationUD(dictionary: dict)
        return installation
    }
}
