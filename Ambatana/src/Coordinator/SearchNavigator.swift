import Foundation
import LGCoreKit
import LGComponents

protocol SearchNavigator: class {
    func openListing(_ data: ListingDetailData,
                     source: EventParameterListingVisitSource,
                     actionOnFirstAppear: ProductCarouselActionOnFirstAppear)
    func cancelSearch()
}

final class SearchCoordinator: NSObject, Coordinator, SearchNavigator {
    var child: Coordinator?
    weak var coordinatorDelegate: CoordinatorDelegate?
    var viewController: UIViewController
    weak var presentedAlertController: UIAlertController?
    let bubbleNotificationManager: BubbleNotificationManager
    let sessionManager: SessionManager

    private let deeplinkMailBox: DeepLinkMailBox
    private let listingNavigator: ListingWireframe

    private let navigationController: UINavigationController

    convenience init(searchType: SearchType?, query: String?) {
        self.init(searchType: searchType,
                  query: query,
                  deeplinkMailBox: LGDeepLinkMailBox.sharedInstance,
                  bubbleNotificationManager: LGBubbleNotificationManager.sharedInstance,
                  sessionManager: Core.sessionManager)
    }

    convenience override init() {
        self.init(searchType: nil,
                  query: nil,
                  deeplinkMailBox: LGDeepLinkMailBox.sharedInstance,
                  bubbleNotificationManager: LGBubbleNotificationManager.sharedInstance,
                  sessionManager: Core.sessionManager)
    }

    init(searchType: SearchType?,
         query: String?,
         deeplinkMailBox: DeepLinkMailBox,
         bubbleNotificationManager: BubbleNotificationManager,
         sessionManager: SessionManager ) {
        let vm = SearchViewModel(searchType: searchType)
        let vc = UINavigationController.init(rootViewController: SearchViewController.init(vm: vm))
        self.navigationController = vc
        self.viewController = vc
        self.deeplinkMailBox = deeplinkMailBox

        self.bubbleNotificationManager = bubbleNotificationManager
        self.sessionManager = sessionManager
        self.listingNavigator = ListingWireframe(nc: navigationController)

        super.init()
        vm.navigator = self
        vc.delegate = self
    }

    func presentViewController(parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard viewController.parent == nil else { return }
        parent.present(viewController, animated: animated, completion: completion)
    }

    func dismissViewController(animated: Bool, completion: (() -> Void)?) {
        viewController.dismissWithPresented(animated: animated, completion: completion)
    }
}

extension SearchCoordinator: TrendingSearchesNavigator {
    func openSearchResults(with searchType: SearchType) {
        let oldFeedVM = MainListingsViewModel(searchType: searchType, filters: .init())
        oldFeedVM.searchNavigator = self
        oldFeedVM.wireframe = MainListingWireframe(nc: navigationController)
        let oldFeed = MainListingsViewController(viewModel: oldFeedVM)
        navigationController.pushViewController(oldFeed, animated: true)
    }

    func cancelSearch() {
        closeCoordinator(animated: true, completion: nil)
    }
}

extension SearchCoordinator: ListingsMapNavigator {

    func openListing(_ data: ListingDetailData,
                     source: EventParameterListingVisitSource,
                     actionOnFirstAppear: ProductCarouselActionOnFirstAppear) {
        let listingCoordinator = ListingWireframe(nc: navigationController)
        listingCoordinator.openListing(data, source: source, actionOnFirstAppear: actionOnFirstAppear)
    }
}

// MARK: UINavigationControllerDelegate

extension SearchCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationControllerOperation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let animator = (toVC as? AnimatableTransition)?.animator, operation == .push {
            animator.pushing = true
            return animator
        } else if let animator = (fromVC as? AnimatableTransition)?.animator, operation == .pop {
            animator.pushing = false
            return animator
        }
        return nil
    }
}
