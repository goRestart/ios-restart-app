import Foundation
import LGCoreKit
import LGComponents

struct SectionTutorialPage {
    let image: UIImage?
    let title: String?
    let description: String?
}

struct LGTutorialPage {
    let title: String?
    let sections: [SectionTutorialPage]
    let aligment: NSTextAlignment
}

final class LGTutorialViewModel: BaseViewModel {
    
    let pages: [LGTutorialPage]
    
    private let tracker: Tracker
    private let origin: EventParameterTypePage
    private let tutorialType: EventParameterTutorialType
    
    // MARK: - Lifecycle
   
    convenience init(pages: [LGTutorialPage],
                     origin: EventParameterTypePage,
                     tutorialType: EventParameterTutorialType) {
        self.init(pages: pages,
                  origin: origin,
                  tutorialType: tutorialType,
                  tracker: TrackerProxy.sharedInstance)
    }
    
    init(pages: [LGTutorialPage],
         origin: EventParameterTypePage,
         tutorialType: EventParameterTutorialType,
         tracker: Tracker) {
        self.pages = pages
        self.origin = origin
        self.tutorialType = tutorialType
        self.tracker = tracker
        super.init()
    }
    
    func startTutorial() {
        tracker.trackEvent(TrackerEvent.tutorialDialogStart(typePage: origin, typeTutorialDialog: tutorialType))
    }
    
    func trackCloseButtonPressed(pageNumber: Int) {
        tracker.trackEvent(TrackerEvent.tutorialDialogAbandon(typePage: origin, typeTutorialDialog: tutorialType, pageNumber: pageNumber))
    }
    
    func trackGetStartedButtonPressed() {
        tracker.trackEvent(TrackerEvent.tutorialDialogComplete(typePage: origin, typeTutorialDialog: tutorialType))
    }
}
