import Foundation
import LGComponents
import LGCoreKit

protocol AdsImpressionConfigurable {
    var shouldShowAdsForUser: Bool { get }
    var ratio: Int { get }
}

struct LGAdsImpressionConfigurable: AdsImpressionConfigurable {

    private let featureFlags: FeatureFlaggeable
    private let myUserRepository: MyUserRepository

    init() {
        self.init(featureFlags: FeatureFlags.sharedInstance, myUserRepository: Core.myUserRepository)
    }

    init(featureFlags: FeatureFlaggeable, myUserRepository: MyUserRepository) {
        self.featureFlags = featureFlags
        self.myUserRepository = myUserRepository
    }

    var userCreationDate: Date? {
        return myUserRepository.myUser?.creationDate
    }

    var shouldShowAdsForUser: Bool {
        guard let creationDate = userCreationDate else { return true }
        return !creationDate.isNewerThan(seconds: SharedConstants.newUserTimeThresholdForAds)
    }

    var ratio: Int {
        return shouldShowAdsForUser ? 20 : 0
    }

    func customTargetingValueFor(position: Int) -> String {
        guard self.ratio != 0 else { return "" }
        let numberOfAd = ((position - MainListingsViewModel.adInFeedInitialPosition)/self.ratio) + 1
        return "var_c_pos_\(numberOfAd)"
    }
}


extension ShowAdsInFeedWithRatio {
    var ratio: Int {
        switch self {
        case .control, .baseline:
            return 0
        case .ten:
            return 10
        case .fifteen:
            return 15
        case .twenty:
            return 20
        }
    }

    func customTargetingValueFor(position: Int) -> String {
        guard self.ratio != 0 else { return "" }
        let numberOfAd = ((position - MainListingsViewModel.adInFeedInitialPosition)/self.ratio) + 1
        switch self {
        case .control, .baseline:
            return ""
        case .ten:
            return "var_a_pos_\(numberOfAd)"
        case .fifteen:
            return "var_b_pos_\(numberOfAd)"
        case .twenty:
            return "var_c_pos_\(numberOfAd)"
        }
    }
}
