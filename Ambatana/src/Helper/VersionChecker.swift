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
    case NewInstall
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
    private let previousVersion: String?
    let versionChange: VersionChange


    // MARK: - Lifecycle

    convenience init() {
        let currentVersion: AppVersion
        #if GOD_MODE
            currentVersion = VersionChecker.godModeVersion ?? NSBundle.mainBundle()
        #else
            currentVersion = NSBundle.mainBundle()
        #endif

        self.init(currentVersion: currentVersion, previousVersion: KeyValueStorage.sharedInstance[.lastRunAppVersion])
    }

    init(currentVersion: AppVersion, previousVersion: String?) {
        self.currentVersion = currentVersion
        self.previousVersion = previousVersion
        self.versionChange = VersionChecker.checkVersionChange(newVersion: currentVersion, oldVersion: previousVersion)
    }


    // MARK: - Private methods

    private static func checkVersionChange(newVersion newVersion: AppVersion, oldVersion: String?) -> VersionChange {
        guard let oldVersion = oldVersion else { return .NewInstall }
        guard let newVersion = newVersion.version else { return .None }

        var newVersionComps = newVersion.componentsSeparatedByString(".").flatMap { Int($0) }
        var oldVersionComps = oldVersion.componentsSeparatedByString(".").flatMap { Int($0) }

        // If there's a components difference fill with zeroes
        let countDiff = newVersionComps.count - oldVersionComps.count
        if countDiff > 0 {
            for _ in 0..<countDiff { oldVersionComps.append(0) }
        } else if countDiff < 0 {
            for _ in 0..<abs(countDiff) { newVersionComps.append(0) }
        }

        for (idx, (newVersionComp, oldVersionComp)) in zip(newVersionComps, oldVersionComps).enumerate() {
            let gt = newVersionComp > oldVersionComp
            switch idx {
            case 0:
                if gt { return .Major }
            case 1:
                if gt { return .Minor }
            case 2:
                if gt { return .Patch }
            default:
                if gt { return .Patch }
            }
        }
        return .None
    }

    private static var godModeVersion: AppVersion? {
        let userDefaults = NSUserDefaults()
        let shouldOverride = userDefaults.boolForKey("god_mode_override_version")
        guard shouldOverride else { return nil }
        guard let version = userDefaults.stringForKey("god_mode_version") else { return nil }
        return GodModeAppVersion(version: version)
    }
}

private struct GodModeAppVersion: AppVersion {
    let version: String?
}