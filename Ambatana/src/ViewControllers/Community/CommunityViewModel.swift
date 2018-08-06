import Foundation
import LGComponents
import LGCoreKit

class CommunityViewModel: BaseViewModel {

    weak var navigator: CommunityTabNavigator?
    private let communityRepository: CommunityRepository
    private let tracker: Tracker
    private let source: CommunitySource

    var urlRequest: URLRequest?
    var showNavBar: Bool
    var showCloseButton: Bool

    init(communityRepository: CommunityRepository, source: CommunitySource, tracker: Tracker) {
        self.communityRepository = communityRepository
        self.showNavBar = source == .navBar
        self.showCloseButton = source == .navBar
        self.source = source
        self.tracker = tracker
        super.init()
        setupRequest()
    }

    private func setupRequest() {
        urlRequest = communityRepository.buildCommunityURLRequest()
    }

    func didTapClose() {
        navigator?.closeCommunity()
    }

    func didAppear() {
        trackOpenCommunity()
    }

    private func trackOpenCommunity() {
        let trackerEvent: TrackerEvent
        switch source {
        case .navBar:
            trackerEvent = TrackerEvent.openCommunityFromProductList(showingBanner: true, bannerType: .joinCommunity)
        case .tabbar:
            trackerEvent = TrackerEvent.openCommunityFromTabBar()
        }
        tracker.trackEvent(trackerEvent)
    }
}
