import Foundation
import LGCoreKit
import LGComponents

protocol SearchNavigator: class {
    func openSearchResults(with searchType: SearchType)
    func openSearchResults(with searchType: SearchType, filters: ListingFilters)
    func openFilters(with listingFilters: ListingFilters, dataDelegate: FiltersViewModelDataDelegate?)
    func openLocationSelection(with place: Place?, distanceRadius: Int?, locationDelegate: EditLocationDelegate)
    func openMap(requester: ListingListMultiRequester, listingFilters: ListingFilters)
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

    private let listingCoordinator: ListingCoordinator
    private let navigationController: UINavigationController

    convenience init(searchType: SearchType?, query: String?) {
        self.init(searchType: searchType,
                  query: query,
                  bubbleNotificationManager: LGBubbleNotificationManager.sharedInstance,
                  sessionManager: Core.sessionManager)
    }

    convenience override init() {
        self.init(searchType: nil,
                  query: nil,
                  bubbleNotificationManager: LGBubbleNotificationManager.sharedInstance,
                  sessionManager: Core.sessionManager)
    }

    init(searchType: SearchType?,
         query: String?,
         bubbleNotificationManager: BubbleNotificationManager,
         sessionManager: SessionManager) {
        let vm = SearchViewModel(searchType: searchType)
        let vc = UINavigationController.init(rootViewController: SearchViewController.init(vm: vm))
        self.navigationController = vc
        self.viewController = vc
        let userCoordinator = UserCoordinator(navigationController: navigationController)
        self.listingCoordinator = ListingCoordinator(navigationController: vc,
                                                     userCoordinator: userCoordinator)
        userCoordinator.listingCoordinator = listingCoordinator

        self.bubbleNotificationManager = bubbleNotificationManager
        self.sessionManager = sessionManager
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
        openSearchResults(with: searchType, filters: .init())
    }

    func cancelSearch() {
        closeCoordinator(animated: true, completion: nil)
    }
}

extension SearchCoordinator {
    func openSearchResults(with searchType: SearchType, filters: ListingFilters) {
        let oldFeedVM = MainListingsViewModel(searchType: searchType, filters: filters)
        oldFeedVM.searchNavigator = self
        let oldFeed = MainListingsViewController(viewModel: oldFeedVM)
        navigationController.pushViewController(oldFeed, animated: true)
    }

    func openFilters(with listingFilters: ListingFilters, dataDelegate: FiltersViewModelDataDelegate?) {
        let vm = FiltersViewModel(currentFilters: listingFilters)
        vm.dataDelegate = dataDelegate
        vm.navigator = self
        let vc = FiltersViewController(viewModel: vm)
        vm.delegate = vc
        navigationController.pushViewController(vc, animated: true)
    }
    func openLocationSelection(with place: Place?, distanceRadius: Int?, locationDelegate: EditLocationDelegate) {
        let vm = EditLocationViewModel(mode: .quickFilterLocation,
                                       initialPlace: place,
                                       distanceRadius: distanceRadius)
        vm.locationDelegate = locationDelegate
        vm.navigator = self
        let vc = EditLocationViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }
}

extension SearchCoordinator: EditLocationNavigator {
    func closeEditLocation() {
        navigationController.popViewController(animated: true)
    }
}

extension SearchCoordinator: ListingsMapNavigator {
    func openMap(requester: ListingListMultiRequester, listingFilters: ListingFilters) {
        let viewModel = ListingsMapViewModel(navigator: self, currentFilters: listingFilters)
        let viewController = ListingsMapViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }

    func openListing(_ data: ListingDetailData,
                     source: EventParameterListingVisitSource,
                     actionOnFirstAppear: ProductCarouselActionOnFirstAppear) {
        listingCoordinator.openListing(data, source: source, actionOnFirstAppear: actionOnFirstAppear)
    }
}

extension SearchCoordinator: FiltersNavigator {
    func openServicesDropdown(viewModel: DropdownViewModel) {
        let vc = DropdownViewController(withViewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }

    func openEditLocation(withViewModel viewModel: EditLocationViewModel) {
        let vc = EditLocationViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }

    func openCarAttributeSelection(withViewModel viewModel: CarAttributeSelectionViewModel) {
        let vc = CarAttributeSelectionViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }

    func openTaxonomyList(withViewModel viewModel: TaxonomiesViewModel) {
        let vc = TaxonomiesViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }

    func openListingAttributePicker(viewModel: ListingAttributePickerViewModel) {
        let vc = ListingAttributePickerViewController(viewModel: viewModel)
        viewModel.delegate = vc
        navigationController.pushViewController(vc, animated: true)
    }

    func closeFilters() {
        navigationController.popViewController(animated: true)
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
