import Foundation

protocol FiltersAssembly {
    func buildFilters(filters: ListingFilters,
                      dataDelegate: FiltersViewModelDataDelegate?) -> UIViewController
}

enum LGFiltersBuilder {
    case standard(navigationController: UINavigationController)
    case modal
}

extension LGFiltersBuilder: FiltersAssembly {
    func buildFilters(filters: ListingFilters,
                      dataDelegate: FiltersViewModelDataDelegate?) -> UIViewController {
        let vm = FiltersViewModel(currentFilters: filters)
        vm.dataDelegate = dataDelegate
        let vc = FiltersViewController(viewModel: vm)

        switch self {
        case .standard(let navigationController):
            vm.navigator = FiltersStandardRouter(controller: navigationController)
            return vc
        case .modal:
            let nav = UINavigationController(rootViewController: vc)
            vm.navigator = FiltersModalRouter(controller: vc, navigationController: nav)
            return nav
        }
    }
}
