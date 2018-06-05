import Foundation
import LGCoreKit

final class LGReputationTooltipManager: ReputationTooltipManager {

    static let sharedInstance = LGReputationTooltipManager()
    private let keyValueStorage: KeyValueStorage
    private let myUserRepository: MyUserRepository

    init(keyValueStorage: KeyValueStorage, myUserRepository: MyUserRepository) {
        self.keyValueStorage = keyValueStorage
        self.myUserRepository = myUserRepository
    }

    convenience init() {
        self.init(keyValueStorage: KeyValueStorage.sharedInstance, myUserRepository: Core.myUserRepository)
    }

    func shouldShowTooltip() -> Bool {
        return false // Disabled until Product decides to use this
        guard let myUser = myUserRepository.myUser, !myUser.hasBadge else { return false }
        if !keyValueStorage[.reputationTooltipShown] { return true }
        guard let lastShownDate = keyValueStorage[.lastShownReputationTooltipDate] else { return true }
        return lastShownDate.isOlderThan(days: 30)
    }

    func didShowTooltip() {
        keyValueStorage[.reputationTooltipShown] = true
        keyValueStorage[.lastShownReputationTooltipDate] = Date()
    }
}
