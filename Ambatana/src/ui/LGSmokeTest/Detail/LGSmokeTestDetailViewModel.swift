import LGComponents
import RxSwift
import RxCocoa

final class LGSmokeTestDetailViewModel: BaseViewModel {
    
    weak var navigator: UINavigationController?
    
    private let tracker: Tracker
    private let feature: LGSmokeTestFeature
    private let featureFlags: FeatureFlaggeable
    private let userAvatarInfo: UserAvatarInfo?
    private let keyValueStorage: KeyValueStorage
    private let openFeedbackAction: (() -> Void)?
    private let openThankYouAction: (() -> Void)?
    
    // MARK: - Lifecycle
    
    convenience init(feature: LGSmokeTestFeature,
                     userAvatarInfo: UserAvatarInfo?,
                     openFeedbackAction: (() -> Void)? = nil,
                     openThankYouAction: (() -> Void)? = nil) {
        self.init(feature: feature,
                  tracker: TrackerProxy.sharedInstance,
                  featureFlags: FeatureFlags.sharedInstance,
                  userAvatarInfo: userAvatarInfo,
                  keyValueStorage: KeyValueStorage.sharedInstance,
                  openFeedbackAction: openFeedbackAction,
                  openThankYouAction: openThankYouAction)
    }
    
    init(feature: LGSmokeTestFeature,
         tracker: Tracker,
         featureFlags: FeatureFlaggeable,
         userAvatarInfo: UserAvatarInfo?,
         keyValueStorage: KeyValueStorage,
         openFeedbackAction: (() -> Void)?,
         openThankYouAction: (() -> Void)?) {
        self.feature = feature
        self.tracker = tracker
        self.featureFlags = featureFlags
        self.userAvatarInfo = userAvatarInfo
        self.keyValueStorage = keyValueStorage
        self.openFeedbackAction = openFeedbackAction
        self.openThankYouAction = openThankYouAction
        super.init()
    }
    
    //  MARK: - Actions
    
    func didTapCloseDetail() {
        navigator?.dismiss(animated: true, completion: openFeedbackAction)
    }
    
    func sendFeedBack(feedbackId: String, feedback: String) {
        keyValueStorage[.clickToTalkShown] = true
        trackFeedback(feedbackId: feedbackId, feedback: feedback)
        navigator?.dismiss(animated: true, completion: openThankYouAction)
    }
    
    private var detail: SmokeTestDetail {
        return feature.smokeTestDetail(userAvatarInfo: userAvatarInfo, featureFlags: featureFlags)
    }
    
}

//  MARK: - Tracker

extension LGSmokeTestDetailViewModel {

    private func trackFeedback(feedbackId: String, feedback: String) {
        let event = TrackerEvent.smokeTestFeedback(testType: feature.smokeTestType,
                                                   feedbackId: feedbackId,
                                                   feedback: feedback,
                                                   feedbackDescription: nil)
        tracker.trackEvent(event)
    }
}

//  MARK: - Input

extension LGSmokeTestDetailViewModel {
    var title: String { return detail.title }
    var subtitle: String { return detail.subtitle }
    var avatarUrl: URL? { return detail.userAvatarInfo?.avatarURL }
    var avatarPlaceholder: UIImage? { return detail.userAvatarInfo?.placeholder }
    var plans: [SmokeTestSubscriptionPlan]? { return detail.plans }
    var features: [String] { return detail.featuresTitles }
}
