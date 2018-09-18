import Foundation

import LGComponents

final class AffiliationFAQViewModel: BaseViewModel {
    var navigator: AffiliationFAQNavigator?

    override func backButtonPressed() -> Bool {
        navigator?.closeAffiliationFAQ()
        return true
    }
}
