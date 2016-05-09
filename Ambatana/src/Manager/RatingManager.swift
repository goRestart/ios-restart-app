//
//  RatingManager.swift
//  LetGo
//
//  Created by Dídac on 03/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

class RatingManager {

    // Singleton
    static let sharedInstance: RatingManager = RatingManager()

    private var alreadyRated: Bool {
        return userDefaults.loadAlreadyRated()
    }

    private var shouldRemind: Bool {
        guard let remindLaterDate = userDefaults.loadRemindMeLaterDate() else { return true }

        let time = remindLaterDate.timeIntervalSince1970
        let now = NSDate().timeIntervalSince1970
        let seconds = Float(now - time)
        let repeatTime = Float(Constants.ratingRepeatTime)

        return seconds > repeatTime
    }

    var shouldShowRatingAlert: Bool {
        return !crashManager.appCrashed && !alreadyRated && shouldRemind
    }

    private let userDefaults: UserDefaultsManager
    private let crashManager: CrashManager


    // MARK: - Lifecycle

    convenience init() {
        let userDefaultsManager = UserDefaultsManager.sharedInstance
        let versionChecker = VersionChecker.sharedInstance
        let crashManager = CrashManager.sharedInstance

        self.init(userDefaultsManager: userDefaultsManager, crashManager: crashManager,
                  versionChange: versionChecker.versionChange)
    }

    init(userDefaultsManager: UserDefaultsManager, crashManager: CrashManager, versionChange: VersionChange) {
        self.userDefaults = userDefaultsManager
        self.crashManager = crashManager
        switch versionChange {
        case .Major, .Minor:
            resetRatingConditions()
        case .Patch:
            resetRemindMeLater()
        case .None:
            break
        }
    }

    func resetRatingConditions() {
        userDefaults.saveAlreadyRated(false)
        resetRemindMeLater()
    }

    func resetRemindMeLater() {
        userDefaults.deleteRemindMeLaterDate()
    }

    func userRatedOrFeedback() {
        userDefaults.saveAlreadyRated(true)
    }

    func userWantsRemindLater() {
        userDefaults.saveRemindMeLaterDate()
    }
}
