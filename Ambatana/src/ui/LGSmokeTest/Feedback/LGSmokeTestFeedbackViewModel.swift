import LGComponents

final class LGSmokeTestFeedbackViewModel: BaseViewModel {
    
    weak var navigator: UINavigationController?
    
    private let tracker: Tracker
    private let feature: LGSmokeTestFeature
    private let featureFlags: FeatureFlaggeable
    private let keyValueStorage: KeyValueStorage
    private let openThankYouAction: (() -> Void)?
    
    // MARK: - Lifecycle
    
    convenience init(feature: LGSmokeTestFeature,
                     openThankYouAction: (() -> Void)? = nil) {
        self.init(feature: feature,
                  tracker: TrackerProxy.sharedInstance,
                  featureFlags: FeatureFlags.sharedInstance,
                  keyValueStorage: KeyValueStorage.sharedInstance,
                  openThankYouAction: openThankYouAction)
    }
    
    init(feature: LGSmokeTestFeature,
         tracker: Tracker,
         featureFlags: FeatureFlaggeable,
         keyValueStorage: KeyValueStorage,
         openThankYouAction: (() -> Void)?) {
        self.feature = feature
        self.tracker = tracker
        self.featureFlags = featureFlags
        self.keyValueStorage = keyValueStorage
        self.openThankYouAction = openThankYouAction
        super.init()
    }
    
    //  MARK: - Actions
    
    func didTapCloseFeedback() {
        trackCloseButtonPressed()
        navigator?.dismiss(animated: true, completion: nil)
    }
    
    func didTapSendFeedback(feedbackId: String, feedback: String, feedbackDescription: String?) {
        keyValueStorage[.clickToTalkShown] = true
        trackFeedback(feedbackId: feedbackId, feedback: feedback, feedbackDescription: feedbackDescription)
        navigator?.dismiss(animated: false, completion: openThankYouAction)
    }
    
}

//  MARK: - Tracker

extension LGSmokeTestFeedbackViewModel {
    private func trackCloseButtonPressed() {
        let event = TrackerEvent.smokeTestClose(testType: feature.smokeTestType,
                                                stepName: .feedbackScreen)
        tracker.trackEvent(event)
    }
    
    private func trackFeedback(feedbackId: String, feedback: String, feedbackDescription: String?) {
        let event = TrackerEvent.smokeTestFeedback(testType: feature.smokeTestType,
                                                   feedbackId: feedbackId,
                                                   feedback: feedback,
                                                   feedbackDescription: feedbackDescription ?? "")
        tracker.trackEvent(event)
    }
}

//  MARK: - Input

extension LGSmokeTestFeedbackViewModel {
    var subtitle: String { return feature.subtitle }
    var feedbackOptions: [Feedback] { return feature.feedbackOptions }
}
