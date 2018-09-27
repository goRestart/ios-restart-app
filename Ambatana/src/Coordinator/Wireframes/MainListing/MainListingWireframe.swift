import LGCoreKit
import LGComponents

protocol MainListingNavigator: class {
    func openSearchResults(with searchType: SearchType, filters: ListingFilters, searchNavigator: SearchNavigator)
    func openFilters(withFilters: ListingFilters, dataDelegate: FiltersViewModelDataDelegate?)
    func openLocationSelection(with place: Place, distanceRadius: Int?, locationDelegate: EditLocationDelegate)
    func openMap(requester: ListingListMultiRequester, listingFilters: ListingFilters)
    func openAffiliationChallenges(sourceButton: AffiliationChallengesSource.FeedButtonName)
    func openLoginIfNeededFromFeed(from: EventParameterLoginSourceValue,
                                   loggedInAction: @escaping (() -> Void))
    func openClassicFeed(navigator: MainTabNavigator,
                         withSearchType searchType: SearchType?,
                         listingFilters: ListingFilters)
    func close()
    func closeAll()
}

final class MainListingWireframe: MainListingNavigator {
    private weak var nc: UINavigationController?
    private let listingsMapAssembly: ListingsMapAssembly
    private let sessionManager: SessionManager
    private let loginAssembly: LoginAssembly

    convenience init(nc: UINavigationController) {
        self.init(nc: nc,
                  listingsMapAssembly: ListingsMapBuilder.standard(nc),
                  sessionManager: Core.sessionManager,
                  loginAssembly: LoginBuilder.standard(context: nc))
    }

    init(nc: UINavigationController,
         listingsMapAssembly: ListingsMapAssembly,
         sessionManager: SessionManager,
         loginAssembly: LoginAssembly) {
        self.nc = nc
        self.listingsMapAssembly = listingsMapAssembly
        self.sessionManager = sessionManager
        self.loginAssembly = loginAssembly
    }
    
    func openSearchResults(with searchType: SearchType, filters: ListingFilters, searchNavigator: SearchNavigator) {
        guard let nc = nc else { return }

        let oldFeedVM = MainListingsViewModel(searchType: searchType, filters: filters)
        oldFeedVM.searchNavigator = searchNavigator
        oldFeedVM.wireframe = MainListingWireframe(nc: nc)
        let oldFeed = MainListingsViewController(viewModel: oldFeedVM)
        nc.pushViewController(oldFeed, animated: true)
    }
    
    func openFilters(withFilters listingFilters: ListingFilters,
                     dataDelegate delegate: FiltersViewModelDataDelegate?) {
        guard let nc = nc else { return }

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
        guard let nc = nc else { return }

        let assembly = QuickLocationFiltersBuilder.standard(nc)
        let vc = assembly.buildQuickLocationFilters(mode: .quickFilterLocation,
                                                    initialPlace: place,
                                                    distanceRadius: distanceRadius,
                                                    locationDelegate: locationDelegate)
        nc.pushViewController(vc, animated: true)
    }
    
    func openMap(requester: ListingListMultiRequester,
                 listingFilters: ListingFilters) {
        let vc = listingsMapAssembly.buildListingsMap(filters: listingFilters)
        nc?.pushViewController(vc, animated: true)
    }
    
    func openAffiliationChallenges(sourceButton: AffiliationChallengesSource.FeedButtonName) {
        guard let nc = nc else { return }
        let assembly = AffiliationChallengesBuilder.standard(nc)
        let vc = assembly.buildAffiliationChallenges(source: .feed(sourceButton))
        nc.pushViewController(vc, animated: true)
    }
    
    func openLoginIfNeededFromFeed(from: EventParameterLoginSourceValue,
                                   loggedInAction: @escaping (() -> Void)) {
        guard !sessionManager.loggedIn else {
            loggedInAction()
            return
        }
        
        let vc = LoginBuilder.modal.buildMainSignIn(
            withSource: from,
            loginAction: loggedInAction,
            cancelAction: nil)
        let nav = UINavigationController(rootViewController: vc)
        nc?.present(nav, animated: true, completion: nil)
    }
    
    func openClassicFeed(navigator: MainTabNavigator,
                         withSearchType searchType: SearchType? = nil,
                         listingFilters: ListingFilters) {
        guard let nc = nc else { return }
        let (vc, vm) = FeedBuilder.standard(nc: nc).makeClassic(
            withSearchType: searchType, filters: listingFilters)
        vm.navigator = navigator
        nc.pushViewController(vc, animated: true)
    }
    
    func close() { nc?.popViewController(animated: true) }
    
    func closeAll() { nc?.popToRootViewController(animated: true) }
}
