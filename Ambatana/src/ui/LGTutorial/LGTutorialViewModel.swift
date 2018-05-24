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
    
    static func makeRealEstateTutorial(typeOfOnboarding: RealEstateTutorial) -> [LGTutorialPage]? {
        switch typeOfOnboarding {
        case .baseline, .control, .onlyBadge: return nil
        case .oneScreen:
            let section01Page01 = SectionTutorialPage(image:#imageLiteral(resourceName: "ilustraHouseSmall"),
                                                      title: R.Strings.realEstateTutorialOnePageFirstSectionTitle,
                                                      description: nil)
            let section02Page01 = SectionTutorialPage(image:#imageLiteral(resourceName: "ilustraPhoneSmall"),
                                                      title: R.Strings.realEstateTutorialOnePageSecondSectionTitle,
                                                      description: nil)
            let page01 = LGTutorialPage(title: R.Strings.commonNew,
                                        sections: [section01Page01, section02Page01],
                                        aligment: .center)
            return [page01]
        case .twoScreens:
            let section01Page01 = SectionTutorialPage(image:#imageLiteral(resourceName: "houseSale") , title: R.Strings.realEstateTutorialTwoPagesFirstSectionFirstPageTitle, description: nil)
            let page01 = LGTutorialPage(title: nil,
                                        sections: [section01Page01],
                                        aligment: .left)
            let section01Page02 = SectionTutorialPage(image:#imageLiteral(resourceName: "ilustraPhoneLocate"),
                                                      title: R.Strings.realEstateTutorialTwoPagesFirstSectionSecondPageTitle,
                                                      description: nil)
            let page02 = LGTutorialPage(title: nil,
                                        sections: [section01Page02],
                                        aligment: .left)
            return [page01, page02]
        case .threeScreens:
            let section01Page01 = SectionTutorialPage(image:#imageLiteral(resourceName: "houseSale") ,
                                                      title: R.Strings.realEstateTutorialThreePagesFirstPageTitle,
                                                      description: R.Strings.realEstateTutorialThreePagesFirstPageDescription)
            let page01 = LGTutorialPage(title: nil,
                                        sections: [section01Page01],
                                        aligment: .left)
            let section01Page02 = SectionTutorialPage(image:#imageLiteral(resourceName: "ilustraPhoneLocate"),
                                                      title: R.Strings.realEstateTutorialThreePagesSecondPageTitle,
                                                      description: R.Strings.realEstateTutorialThreePagesSecondPageDecription)
            let page02 = LGTutorialPage(title: nil,
                                        sections: [section01Page02],
                                        aligment: .left)
            let section01Page03 = SectionTutorialPage(image:#imageLiteral(resourceName: "ilustraAroundMe"),
                                                      title: R.Strings.realEstateTutorialThreePagesThirdPageTitle,
                                                      description: R.Strings.realEstateTutorialThreePagesThirdPageDescription)
            let page03 = LGTutorialPage(title: nil,
                                        sections: [section01Page03],
                                        aligment: .left)
            return [page01, page02, page03]
        }
    }
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
