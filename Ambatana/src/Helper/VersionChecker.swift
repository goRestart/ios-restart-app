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

public class VersionChecker {

    static var sharedInstance: VersionChecker = VersionChecker()

    private let currentVersion: String
    private var lastVersion: String {
        if let lastAppVersion = UserDefaultsManager.sharedInstance.loadLastAppVersion() {
            return lastAppVersion
        } else {
            return currentVersion
        }
    }
    var versionChange: VersionChange


    // Lifecycle

    convenience init() {
        self.init(appVersion: NSBundle.mainBundle())
    }

    init(appVersion: AppVersion) {
        self.currentVersion = appVersion.version ?? ""
        self.versionChange = .None
    }


    // MARK: - Public methods

    func checkVersionChange() {
        let lastVersionArray = lastVersion.characters.split { $0 == "." }.map { String($0) }
        let currentVersionArray = currentVersion.characters.split { $0 == "." }.map { String($0) }

        if currentVersionArray[0] != lastVersionArray[0] {
            updateLastAppVersion()
            versionChange = .Major
        } else if currentVersionArray[1] != lastVersionArray[1] {
            updateLastAppVersion()
            versionChange = .Minor
        } else if currentVersionArray[2] != lastVersionArray[2] {
            updateLastAppVersion()
            versionChange = .Patch
        } else {
            versionChange = .None
        }
    }


    // MARK: - Private methods

    func updateLastAppVersion() {
        UserDefaultsManager.sharedInstance.saveLastAppVersion()
    }
}
