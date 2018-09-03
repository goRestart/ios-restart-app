import LGComponents

enum FeedType {
    case pro
    case classic
}

extension SectionedDiscoveryFeed {
    var isActive: Bool { return self != .control && self != .baseline }
    var feedAssembly: FeedType { return isActive ? .pro : .classic }
}

protocol FeedAssembly {
    func makePro(withSearchType: SearchType?,
                 filters: ListingFilters,
                 hideSearchBox: Bool,
                 showFilters: Bool,
                 showLocationEditButton: Bool) -> (BaseViewController, FeedNavigatorOwnership)
    func makeClassic(withSearchType: SearchType?,
                     filters: ListingFilters,
                     shouldCloseOnRemoveAllFilters: Bool) -> (BaseViewController, FeedNavigatorOwnership)
    func makePro() -> (BaseViewController, FeedNavigatorOwnership)
    func makeClassic() -> (BaseViewController, FeedNavigatorOwnership)
}

enum FeedBuilder: FeedAssembly {
    case standard(nc: UINavigationController)
    
    func makePro(
        withSearchType searchType: SearchType? = nil,
        filters: ListingFilters,
        hideSearchBox: Bool = false,
        showFilters: Bool = true,
        showLocationEditButton: Bool = true
    ) -> (BaseViewController, FeedNavigatorOwnership) {
        let vm = FeedViewModel(
            searchType: searchType,
            filters: filters,
            shouldShowEditOnLocationHeader: showLocationEditButton)
        let vc: FeedViewController = FeedViewController(
            withViewModel: vm,
            hideSearchBox: hideSearchBox,
            showFilters: showFilters
        )
        
        switch self {
        case .standard(let nc):
            vm.wireframe = FeedWireframe(nc: nc)
            vm.listingWireframe = ListingWireframe(nc: nc)
        }
        return (vc, vm)
    }
    
    func makeClassic(
        withSearchType searchType: SearchType? = nil,
        filters: ListingFilters,
        shouldCloseOnRemoveAllFilters: Bool = false) -> (BaseViewController, FeedNavigatorOwnership) {
        let vm = MainListingsViewModel(
            searchType: searchType,
            filters: filters,
            shouldCloseOnRemoveAllFilters: shouldCloseOnRemoveAllFilters
        )
        let vc = MainListingsViewController(viewModel: vm)
        switch self {
        case .standard(let nc):
            vm.wireframe = MainListingWireframe(nc: nc)
        }
        return (vc, vm)
    }
    
    func makePro() -> (BaseViewController, FeedNavigatorOwnership) {
        let vm = FeedViewModel()
        switch self {
        case .standard(let nc):
            vm.wireframe = FeedWireframe(nc: nc)
            vm.listingWireframe = ListingWireframe(nc: nc)
        }
        return (FeedViewController(withViewModel: vm), vm)
    }
    
    func makeClassic() -> (BaseViewController, FeedNavigatorOwnership) {
        let vm = MainListingsViewModel(searchType: nil, tabNavigator: nil)
        switch self {
        case .standard(let nc):
            vm.wireframe = MainListingWireframe(nc: nc)
        }
        return  (MainListingsViewController(viewModel: vm), vm)
    }
}
