//
//  VersionChecker.swift
//  LetGo
//
//  Created by Dídac on 04/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation


enum VersionChange {
    case None
    case Patch
    case Minor
    case Major
}

protocol AppVersion {
    var version: String? { get }
}

extension NSBundle: AppVersion {
    var version: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
}

class VersionChecker {

    static var sharedInstance: VersionChecker = VersionChecker()

    let currentVersion: AppVersion
    private let lastVersion: String?
    let versionChange: VersionChange


    // Lifecycle

    convenience init() {
        self.init(appVersion: NSBundle.mainBundle(), lastAppVersion: UserDefaultsManager.sharedInstance.loadLastAppVersion())
    }

    init(appVersion: AppVersion, lastAppVersion: String?) {
        self.currentVersion = appVersion
        self.lastVersion = lastAppVersion
        self.versionChange = VersionChecker.checkVersionChange(appVersion, lastAppVersion: lastAppVersion)
    }


    // MARK: - Public methods

    static func checkVersionChange(appVersion: AppVersion, lastAppVersion: String?) -> VersionChange {
        guard let lastVersion = lastAppVersion, currentVersionVersion = appVersion.version else {
            return .None
        }
        let currentVersionArray = currentVersionVersion.characters.split { $0 == "." }.map { String($0) }
        let lastVersionArray = lastVersion.characters.split { $0 == "." }.map { String($0) }

        if currentVersionArray.count > 0 && lastVersionArray.count > 0 &&
            currentVersionArray[0] != lastVersionArray[0] {
            return .Major
        } else if currentVersionArray.count > 1 && lastVersionArray.count > 1 &&
            currentVersionArray[1] != lastVersionArray[1] {
            return .Minor
        } else if currentVersionArray.count > 2 && lastVersionArray.count > 2 &&
            currentVersionArray[2] != lastVersionArray[2] {
            return .Patch
        }
        return .None
    }
}
