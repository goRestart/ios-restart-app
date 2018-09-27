import Foundation

import LGComponents

final class AffiliationFAQViewModel: BaseViewModel {
    var navigator: AffiliationFAQNavigator?
    
    public var url: URL? {
        return LetgoURLHelper.buildAffiliationFAQS()
    }

    override func backButtonPressed() -> Bool {
        navigator?.closeAffiliationFAQ()
        return true
    }
}
