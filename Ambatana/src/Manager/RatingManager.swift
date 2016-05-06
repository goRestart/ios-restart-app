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
        return !CrashManager.appCrashed && !alreadyRated && shouldRemind
    }

    var shouldShowAppRatingBanner: Bool {
        return !CrashManager.appCrashed && !alreadyRated && userDefaults.loadShouldShowRatingBanner()
    }

    private var userDefaults : UserDefaultsManager


    // MARK: Lifecycle

    init(userDefaultsManager: UserDefaultsManager, versionChange: VersionChange) {
        self.userDefaults = userDefaultsManager
        switch versionChange {
        case .Major, .Minor:
            resetRatingConditions()
        case .Patch:
            resetRemindMeLater()
        case .None:
            break
        }
    }

    convenience init() {
        self.init(userDefaultsManager: UserDefaultsManager.sharedInstance, versionChange: VersionChecker.sharedInstance.versionChange)
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
        userDefaults.saveShouldShowRatingBanner(true)
    }

    func userClosesRatingBanner() {
        userDefaults.saveShouldShowRatingBanner(false)
    }
}
