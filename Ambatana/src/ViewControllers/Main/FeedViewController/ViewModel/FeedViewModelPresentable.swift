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
    
    var rxHasFilter: Driver<Bool> { get }
    var searchString: String? { get }
    var shouldShowInviteButton: Bool { get }
    var viewState: ViewState { get }

    var feedItems: [ListDiffable] { get }
    var numberOfColumnsInLastSection: Int { get }
        
    func openInvite()
    func openSearches()
    func showFilters()
    func refreshControlTriggered()

    func loadFeedItems()
    func feedSectionController(for object: Any) -> ListSectionController
}