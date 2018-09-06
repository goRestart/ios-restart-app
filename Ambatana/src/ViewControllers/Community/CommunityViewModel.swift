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
    private let urlRequestVariable = Variable<URLRequest?>(nil)

    var urlRequest: Observable<URLRequest?> { return urlRequestVariable.asObservable() }
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
        urlRequestVariable.value = communityRepository.buildCommunityURLRequest()
    }

    func didTapClose() {
        navigator?.closeCommunity()
    }

    func didAppear() {
        trackOpenCommunity()
    }

    func openLetgoHome() {
        switch source {
        case .navBar:
            navigator?.closeCommunity()
        case .tabbar:
            navigator?.openHome()
        }
    }

    func openLetgoLogin() {
        navigator?.openLogin()
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
