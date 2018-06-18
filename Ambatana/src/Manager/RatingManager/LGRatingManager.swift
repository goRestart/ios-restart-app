import RxSwift
import LGComponents


class LGRatingManager {
    static let sharedInstance: LGRatingManager = LGRatingManager()

    fileprivate let keyValueStorage: KeyValueStorage
    fileprivate let crashManager: CrashManager
    fileprivate let featureFlags: FeatureFlaggeable

    
    // MARK: - Lifecycle

    convenience init() {
        let keyValueStorage = KeyValueStorage.sharedInstance
        let versionChecker = VersionChecker.sharedInstance
        let crashManager = CrashManager.sharedInstance
        let featureFlags = FeatureFlags.sharedInstance

        self.init(keyValueStorage: keyValueStorage, crashManager: crashManager,
                  versionChange: versionChecker.versionChange, featureFlags: featureFlags)
    }

    init(keyValueStorage: KeyValueStorage, crashManager: CrashManager, versionChange: VersionChange,
         featureFlags: FeatureFlaggeable) {
        self.keyValueStorage = keyValueStorage
        self.crashManager = crashManager
        self.featureFlags = featureFlags
        switch versionChange {
        case .newInstall, .major, .minor:
            keyValueStorage.userRatingAlreadyRated = false
            keyValueStorage.userRatingRemindMeLaterDate = nil
        case .patch:
            keyValueStorage.userRatingRemindMeLaterDate = nil
        case .none:
            break
        }
    }
}


// MARK: - Internal methods

extension LGRatingManager: RatingManager {
    var shouldShowRating: Bool {
        guard !crashManager.appCrashed else { return false }
        guard !keyValueStorage.userRatingAlreadyRated else { return false }
        guard let remindMeLaterDate = keyValueStorage.userRatingRemindMeLaterDate else { return true }
        return remindMeLaterDate.timeIntervalSinceNow <= 0
    }

    func userDidRate() {
        keyValueStorage.userRatingAlreadyRated = true
    }

    func userDidRemindLater() {
        if keyValueStorage.userRatingRemindMeLaterDate == nil {
            // If we don't have a remind later date then set it up
            let remindDate = Date().addingTimeInterval(SharedConstants.ratingRepeatTime)
            keyValueStorage.userRatingRemindMeLaterDate = remindDate
        } else {
            // Otherwise, we set it in a distant future... (might be overriden when updating)
            keyValueStorage.userRatingRemindMeLaterDate = Date.distantFuture
        }
    }
}

