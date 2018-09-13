import Foundation

import LGComponents

final class RewardsFAQViewModel: BaseViewModel {
    var navigator: RewardsFAQNavigator?

    override func backButtonPressed() -> Bool {
        navigator?.closeRewardsFAQ()
        return true
    }
}
