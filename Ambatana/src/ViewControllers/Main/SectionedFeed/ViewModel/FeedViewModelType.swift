import Foundation
import RxSwift
import RxCocoa
import IGListKit

protocol FeedNavigatorOwnership: class {
    var navigator: MainTabNavigator? { get set }
}

protocol FeedViewModelType: FeedNavigatorOwnership {

    var feedRenderingDelegate: FeedRenderable? { get set }
    var delegate: FeedViewModelDelegate? { get set }
    var rootViewController: UIViewController? { get set }
    
    var rxHasFilter: Driver<Bool> { get }
    var searchString: String? { get }
    var shouldShowInviteButton: Bool { get }
    var shouldShowAffiliateButton: Bool { get }

    var shouldShowCommunityButton: Bool { get }
    var shouldShowUserProfileButton: Bool { get }
    var viewState: ViewState { get }
    
    var feedItems: [ListDiffable] { get }
    var waterfallColumnCount: Int { get }
    var locationSectionIndex: Int? { get }

    var rx_userAvatar: BehaviorRelay<UIImage?> { get }
    var rx_updateAffiliate: Driver<Bool> { get }
    
    func openInvite()
    func openSearches()
    func showFilters()
    func openAffiliationChallenges()
    func refreshControlTriggered()
    func openCommunity()
    func openUserProfile()

    func resetFirstLoadState()
    
    func loadFeedItems(uponPullToRefresh: Bool)
    func willScroll(toSection section: Int)
    func feedSectionController(for object: Any) -> ListSectionController
}
