import Foundation
import LGCoreKit
import LGComponents

final class P2PPaymentsOnboardingViewModel: BaseViewModel {
    var navigator: P2PPaymentsMakeAnOfferNavigator?

    // MARK: - Public methods

    func closeButtonPressed() {
        navigator?.closeOnboarding()
    }

    func makeAnOfferButtonPressed() {
        navigator?.openMakeAnOffer()
    }
}
