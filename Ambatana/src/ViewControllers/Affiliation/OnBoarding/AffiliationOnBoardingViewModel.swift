import RxSwift
import RxCocoa
import LGCoreKit
import LGComponents

struct AffiliationOnBoardingVM {
    let message: String
    private let referrer: ReferrerInfo

    init(message: String, referrer: ReferrerInfo) {
        self.message = message
        self.referrer = referrer
    }

    var inviterID: String { return referrer.userId }
    var inviterName: String { return referrer.name }
    var inviterURL: URL? { return referrer.avatar }
}

final class AffiliationOnBoardingViewModel: BaseViewModel {
    let onboardingData: BehaviorRelay<AffiliationOnBoardingVM?>
    var navigator: AffiliationOnBoardingNavigator?

    init(referrerInfo: ReferrerInfo) {
        let message = R.Strings.affiliationInviteMessageText(referrerInfo.name)
        self.onboardingData = BehaviorRelay(value: AffiliationOnBoardingVM(message: message, referrer: referrerInfo))
        super.init()
    }

    func close() {
        navigator?.close()
    }
}
