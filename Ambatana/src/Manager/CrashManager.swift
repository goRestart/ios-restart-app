//
//  CrashManager.swift
//  LetGo
//
//  Created by Dídac on 04/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//


class CrashManager {

    static var appCrashed: Bool = false
    var shouldResetCrashFlags = false


    // MARK: - Lifecycle

    init(appCrashed: Bool, versionChange: VersionChange) {
        CrashManager.appCrashed = appCrashed
        switch versionChange {
        case .Major, .Minor, .Patch:
            self.shouldResetCrashFlags = true
            CrashManager.appCrashed = false
        case .None:
            break
        }
    }
}
