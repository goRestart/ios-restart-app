import Foundation
import LGComponents
import LGCoreKit
import RxSwift

class CommunityViewModel: BaseViewModel {

    weak var navigator: CommunityTabNavigator?
    private let communityRepository: CommunityRepository
    private let sessionManager: SessionManager
    private let tracker: Tracker
    private let source: CommunitySource
    private let disposeBag = DisposeBag()

    var urlRequest = Variable<URLRequest?>(nil)
    var showNavBar: Bool
    var showCloseButton: Bool

    init(communityRepository: CommunityRepository,
         sessionManager: SessionManager,
         source: CommunitySource,
         tracker: Tracker) {
        self.communityRepository = communityRepository
        self.sessionManager = sessionManager
        self.showNavBar = source == .navBar
        self.showCloseButton = source == .navBar
        self.source = source
        self.tracker = tracker
        super.init()
        setupRx()
        buildRequest()
    }

    private func setupRx() {
        sessionManager
            .sessionEvents
            .distinctUntilChanged {
                switch($0, $1) {
                case (.login, .login), (.logout, .logout): return true
                default: return false
                }
            }
            .subscribe { [weak self] sessionEvent in
                self?.buildRequest()
            }
            .disposed(by: disposeBag)
    }

    private func buildRequest() {
        urlRequest.value = communityRepository.buildCommunityURLRequest()
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
