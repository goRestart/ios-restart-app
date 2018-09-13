import LGCoreKit

protocol ListingsMapAssembly {
    func buildListingsMap(filters: ListingFilters) -> UIViewController
}

enum ListingsMapBuilder {
    case standard(UINavigationController)
}

extension ListingsMapBuilder: ListingsMapAssembly {
    func buildListingsMap(filters: ListingFilters) -> UIViewController {
        let vm = ListingsMapViewModel(currentFilters: filters)
        switch self {
        case .standard(let nc):
            vm.navigator = ListingWireframe(nc: nc)
        }
        return ListingsMapViewController(viewModel: vm)
    }
}

extension ListingWireframe: ListingsMapNavigator {}
