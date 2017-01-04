//
//  VersionChecker.swift
//  LetGo
//
//  Created by Dídac on 04/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation


enum VersionChange {
    case none
    case patch
    case minor
    case major
    case newInstall
}

protocol AppVersion {
    var version: String? { get }
}

extension Bundle: AppVersion {
    var version: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
}

class VersionChecker {

    static var sharedInstance: VersionChecker = VersionChecker()

    let currentVersion: AppVersion
    private let previousVersion: String?
    let versionChange: VersionChange


    // MARK: - Lifecycle

    convenience init() {
        let currentVersion: AppVersion
        #if GOD_MODE
            currentVersion = VersionChecker.godModeVersion ?? NSBundle.mainBundle()
        #else
            currentVersion = Bundle.main
        #endif

        self.init(currentVersion: currentVersion, previousVersion: KeyValueStorage.sharedInstance[.lastRunAppVersion])
    }

    init(currentVersion: AppVersion, previousVersion: String?) {
        self.currentVersion = currentVersion
        self.previousVersion = previousVersion
        self.versionChange = VersionChecker.checkVersionChange(newVersion: currentVersion, oldVersion: previousVersion)
    }


    // MARK: - Private methods

    private static func checkVersionChange(newVersion: AppVersion, oldVersion: String?) -> VersionChange {
        guard let oldVersion = oldVersion else { return .newInstall }
        guard let newVersion = newVersion.version else { return .none }

        var newVersionComps = newVersion.components(separatedBy: ".").flatMap { Int($0) }
        var oldVersionComps = oldVersion.components(separatedBy: ".").flatMap { Int($0) }

        // If there's a components difference fill with zeroes
        let countDiff = newVersionComps.count - oldVersionComps.count
        if countDiff > 0 {
            for _ in 0..<countDiff { oldVersionComps.append(0) }
        } else if countDiff < 0 {
            for _ in 0..<abs(countDiff) { newVersionComps.append(0) }
        }

        for (idx, (newVersionComp, oldVersionComp)) in zip(newVersionComps, oldVersionComps).enumerated() {
            let gt = newVersionComp > oldVersionComp
            switch idx {
            case 0:
                if gt { return .major }
            case 1:
                if gt { return .minor }
            case 2:
                if gt { return .patch }
            default:
                if gt { return .patch }
            }
        }
        return .none
    }

    private static var godModeVersion: AppVersion? {
        let userDefaults = UserDefaults()
        let shouldOverride = userDefaults.bool(forKey: "god_mode_override_version")
        guard shouldOverride else { return nil }
        guard let version = userDefaults.string(forKey: "god_mode_version") else { return nil }
        return GodModeAppVersion(version: version)
    }
}

private struct GodModeAppVersion: AppVersion {
    let version: String?
}
