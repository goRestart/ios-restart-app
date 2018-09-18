import LGCoreKit
import LGComponents

protocol MainListingNavigator: class {
    func openSearchResults(with searchType: SearchType, filters: ListingFilters, searchNavigator: SearchNavigator)
    func openFilters(withFilters: ListingFilters, dataDelegate: FiltersViewModelDataDelegate?)
    func openLocationSelection(with place: Place, distanceRadius: Int?, locationDelegate: EditLocationDelegate)
    func openMap(requester: ListingListMultiRequester, listingFilters: ListingFilters)
    func openAffiliationChallenges()
    func openClassicFeed(navigator: MainTabNavigator,
                         withSearchType searchType: SearchType?,
                         listingFilters: ListingFilters)
    func close()
    func closeAll()
}

final class MainListingWireframe: MainListingNavigator {
    private let nc: UINavigationController
    private let listingMapAssmebly: ListingsMapAssembly
    private lazy var affiliationChallengesAssembly = AffiliationChallengesBuilder.standard(nc)

    convenience init(nc: UINavigationController) {
        self.init(nc: nc, listingMapAssmebly: ListingsMapBuilder.standard(nc))
    }

    init(nc: UINavigationController, listingMapAssmebly: ListingsMapAssembly) {
        self.nc = nc
        self.listingMapAssmebly = listingMapAssmebly
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
    
    func openMap(requester: ListingListMultiRequester,
                 listingFilters: ListingFilters) {
        let vc = listingMapAssmebly.buildListingsMap(filters: listingFilters)
        nc.pushViewController(vc, animated: true)
    }
    
    func openAffiliationChallenges() {
        let vc = affiliationChallengesAssembly.buildAffiliationChallenges()
        nc.pushViewController(vc, animated: true)
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
