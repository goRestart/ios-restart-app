import LGCoreKit
import LGComponents

protocol MainListingNavigator: class {
    func openSearchResults(with searchType: SearchType, filters: ListingFilters, searchNavigator: SearchNavigator)
    func openFilters(withFilters: ListingFilters, dataDelegate: FiltersViewModelDataDelegate?)
    func openLocationSelection(with place: Place, distanceRadius: Int?, locationDelegate: EditLocationDelegate)
    func openMap(requester: ListingListMultiRequester, listingFilters: ListingFilters, searchNavigator: ListingsMapNavigator)
    func openClassicFeed(navigator: MainTabNavigator,
                         withSearchType searchType: SearchType?,
                         listingFilters: ListingFilters)
    func close()
    func closeAll()
}

final class MainListingWireframe: MainListingNavigator {
    private let nc: UINavigationController

    init(nc: UINavigationController) {
        self.nc = nc
    }
    
    func openSearchResults(with searchType: SearchType, filters: ListingFilters, searchNavigator: SearchNavigator) {
        let oldFeedVM = MainListingsViewModel(searchType: searchType, filters: filters)
        oldFeedVM.searchNavigator = searchNavigator
        oldFeedVM.wireframe = MainListingWireframe(nc: nc)
        let oldFeed = MainListingsViewController(viewModel: oldFeedVM)
        nc.pushViewController(oldFeed, animated: true)
    }
    
    func openFilters(withFilters listingFilters: ListingFilters,
                     dataDelegate delegate: FiltersViewModelDataDelegate?) {
        let vc = LGFiltersBuilder.standard(navigationController: nc)
            .buildFilters(
                filters: listingFilters,
                dataDelegate: delegate
        )
        nc.pushViewController(vc, animated: true)
    }
    
    func openLocationSelection(with place: Place,
                               distanceRadius: Int?,
                               locationDelegate: EditLocationDelegate) {
        let assembly = QuickLocationFiltersBuilder.standard(nc)
        let vc = assembly.buildQuickLocationFilters(mode: .quickFilterLocation,
                                                    initialPlace: place,
                                                    distanceRadius: distanceRadius,
                                                    locationDelegate: locationDelegate)
        nc.pushViewController(vc, animated: true)
    }
    
    func openMap(requester: ListingListMultiRequester, listingFilters: ListingFilters, searchNavigator: ListingsMapNavigator) {
        let viewModel = ListingsMapViewModel(navigator: searchNavigator, currentFilters: listingFilters)
        let viewController = ListingsMapViewController(viewModel: viewModel)
        nc.pushViewController(viewController, animated: true)
    }
    
    func openClassicFeed(navigator: MainTabNavigator,
                         withSearchType searchType: SearchType? = nil,
                         listingFilters: ListingFilters) {
        let (vc, vm) = FeedBuilder.standard(nc: nc).makeClassic(
            withSearchType: searchType, filters: listingFilters)
        vm.navigator = navigator
        nc.pushViewController(vc, animated: true)
    }
    
    func close() { nc.popViewController(animated: true) }
    
    func closeAll() { nc.popToRootViewController(animated: true) }
}
