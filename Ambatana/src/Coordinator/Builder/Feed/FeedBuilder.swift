import LGComponents

enum FeedType {
    case pro
    case classic
}

extension SectionedMainFeed {
    var isActive: Bool { return self != .control && self != .baseline }
    var feedAssembly: FeedType { return isActive ? .pro : .classic }
}

protocol FeedAssembly {
    func makePro(withSearchType: SearchType, filters: ListingFilters) -> (BaseViewController, FeedNavigatorOwnership)
    func makeClassic(withSearchType: SearchType, filters: ListingFilters) -> (BaseViewController, FeedNavigatorOwnership)
    func makePro() -> (BaseViewController, FeedNavigatorOwnership)
    func makeClassic() -> (BaseViewController, FeedNavigatorOwnership)
}

enum FeedBuilder: FeedAssembly {
    case standard(nc: UINavigationController)
    
    func makePro(
        withSearchType searchType: SearchType,
        filters: ListingFilters) -> (BaseViewController, FeedNavigatorOwnership) {
        let vm = FeedViewModel(searchType: searchType, filters: filters)
        let vc = FeedViewController(withViewModel: vm)
        switch self {
        case .standard(let nc):
            vm.wireframe = FeedWireframe(nc: nc)
        }
        return (vc, vm)
    }
    
    func makeClassic(
        withSearchType searchType: SearchType,
        filters: ListingFilters) -> (BaseViewController, FeedNavigatorOwnership) {
        let vm = MainListingsViewModel(searchType: searchType, filters: filters)
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
