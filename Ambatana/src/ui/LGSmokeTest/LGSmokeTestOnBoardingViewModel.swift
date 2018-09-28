import Foundation
import LGCoreKit
import LGComponents


final class LGSmokeTestOnBoardingViewModel: BaseViewModel {
    
    weak var navigator: UINavigationController?
    
    private let tracker: Tracker
    private let feature: LGSmokeTestFeature
    private let startAction: (() -> Void)?
    
    var pagesCount: Int {
        return feature.pages.count
    }
    
    var actionTitle: String {
        return feature.actionTitle
    }
    
    var smokeTestType: EventParameterSmokeTestType {
        return feature.smokeTestType
    }
    
    func page(at index: Int) -> LGSmokeTestPage? {
        return feature.pages[safeAt: index]
    }
    
    // MARK: - Lifecycle
   
    convenience init(feature: LGSmokeTestFeature,
                     startAction: (() -> Void)? = nil) {
        self.init(feature: feature,
                  tracker: TrackerProxy.sharedInstance,
                  startAction: startAction)
    }
    
    init(feature: LGSmokeTestFeature,
         tracker: Tracker,
         startAction: (() -> Void)?) {
        self.feature = feature
        self.tracker = tracker
        self.startAction = startAction
        super.init()
    }
    
    
    // MARK: Actions
    
    func didTapStartButton() {
        trackGetStartedButtonPressed()
        navigator?.dismiss(animated: true, completion: startAction)
    }
    
    func didTapCloseButton(onPageNumber pageNumber: Int) {
        trackCloseButtonPressed()
        navigator?.dismiss(animated: true, completion: nil)
    }
    
    private func trackCloseButtonPressed() {
        let event = TrackerEvent.smokeTestClose(testType: smokeTestType,
                                                stepName: .smokeScreen)
        tracker.trackEvent(event)
    }
    
    private func trackGetStartedButtonPressed() {
        let event = TrackerEvent.smokeTestInfoGetStarted(testType: smokeTestType)
        tracker.trackEvent(event)
    }
    
}
