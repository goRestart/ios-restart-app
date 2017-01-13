//
//  CrashManager.swift
//  LetGo
//
//  Created by Dídac on 04/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//


class CrashManager {
    static let sharedInstance: CrashManager = CrashManager()

    var appCrashed: Bool
    private(set) var shouldResetCrashFlags: Bool


    // MARK: - Lifecycle

    convenience init() {
        let keyValueStorage = KeyValueStorage.sharedInstance
        let versionChecker = VersionChecker.sharedInstance
        self.init(appCrashed: keyValueStorage[.didCrash], versionChange: versionChecker.versionChange)
    }

    init(appCrashed: Bool, versionChange: VersionChange) {
        switch versionChange {
        case .newInstall, .major, .minor, .patch:
            self.appCrashed = false
            self.shouldResetCrashFlags = true
        case .none:
            self.appCrashed = appCrashed
            self.shouldResetCrashFlags = false
        }
    }
}
