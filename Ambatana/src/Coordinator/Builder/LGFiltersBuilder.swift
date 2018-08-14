import Foundation

protocol FiltersAssembly {
    func buildFilters(filters: ListingFilters,
                      dataDelegate: FiltersViewModelDataDelegate?) -> FiltersViewController
}

enum LGFiltersBuilder {
    case standard(navigationController: UINavigationController)
    case modal
}

extension LGFiltersBuilder: FiltersAssembly {
    func buildFilters(filters: ListingFilters,
                      dataDelegate: FiltersViewModelDataDelegate?) -> FiltersViewController {
        let vm = FiltersViewModel(currentFilters: filters)
        vm.dataDelegate = dataDelegate
        let vc = FiltersViewController(viewModel: vm)

        switch self {
        case .standard(let navigationController):
            vm.navigator = FiltersStandardRouter(controller: navigationController)
        case .modal:
            vm.navigator = FiltersModalRouter(controller: vc)
        }
        return vc
    }
}
