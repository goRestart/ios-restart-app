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

    private let tracker: Tracker
    private let keyValueStorageable: KeyValueStorageable

    convenience init(referrerInfo: ReferrerInfo) {
        self.init(referrerInfo: referrerInfo,
                  tracker: TrackerProxy.sharedInstance,
                  keyValueStorageable: KeyValueStorage.sharedInstance)
    }

    init(referrerInfo: ReferrerInfo,
         tracker: Tracker,
         keyValueStorageable: KeyValueStorageable) {
        let message = R.Strings.affiliationInviteOnboardingText(referrerInfo.name)
        self.onboardingData = BehaviorRelay(value: AffiliationOnBoardingVM(message: message,
                                                                           referrer: referrerInfo))
        self.tracker = tracker
        self.keyValueStorageable = keyValueStorageable
        super.init()
    }

    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        keyValueStorageable[.didShowAffiliationOnBoarding] = true
        tracker.trackEvent(TrackerEvent.inviteeRewardBannerShown())
    }

    func close() {
        navigator?.close()
    }

    func dismiss() {
        navigator?.dismiss()
    }
}
