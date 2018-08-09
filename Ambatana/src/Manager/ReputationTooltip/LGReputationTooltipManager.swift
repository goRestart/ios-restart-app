import Foundation
import LGCoreKit

final class LGReputationTooltipManager: ReputationTooltipManager {

    static let sharedInstance = LGReputationTooltipManager()
    private let keyValueStorage: KeyValueStorage
    private let myUserRepository: MyUserRepository
    private let featureFlags: FeatureFlaggeable

    init(keyValueStorage: KeyValueStorage, myUserRepository: MyUserRepository, featureFlags: FeatureFlaggeable) {
        self.keyValueStorage = keyValueStorage
        self.myUserRepository = myUserRepository
        self.featureFlags = featureFlags
    }

    convenience init() {
        self.init(keyValueStorage: KeyValueStorage.sharedInstance,
                  myUserRepository: Core.myUserRepository,
                  featureFlags: FeatureFlags.sharedInstance)
    }

    func shouldShowTooltip() -> Bool {
        guard let myUser = myUserRepository.myUser,
            !myUser.hasBadge else { return false }
        if !keyValueStorage[.reputationTooltipShown] { return true }
        guard let lastShownDate = keyValueStorage[.lastShownReputationTooltipDate] else { return true }
        return lastShownDate.isOlderThan(days: 30)
    }

    func didShowTooltip() {
        keyValueStorage[.reputationTooltipShown] = true
        keyValueStorage[.lastShownReputationTooltipDate] = Date()
    }
}
