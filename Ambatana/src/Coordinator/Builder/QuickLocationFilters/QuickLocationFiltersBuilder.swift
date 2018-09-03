import LGCoreKit

protocol QuickLocationFiltersAssembly {
    func buildQuickLocationFilters(mode: EditLocationMode,
                                   initialPlace: Place?,
                                   distanceRadius: Int?,
                                   locationDelegate: EditLocationDelegate?) -> UIViewController
}

enum QuickLocationFiltersBuilder {
    case modal(UIViewController)
    case standard(UINavigationController)
}

extension QuickLocationFiltersBuilder: QuickLocationFiltersAssembly {
    func buildQuickLocationFilters(mode: EditLocationMode,
                                   initialPlace: Place?,
                                   distanceRadius: Int?,
                                   locationDelegate: EditLocationDelegate?) -> UIViewController {
        let vm = EditLocationViewModel(mode: mode,
                                       initialPlace: initialPlace,
                                       distanceRadius: distanceRadius)
        vm.locationDelegate = locationDelegate
        let vc = EditLocationViewController(viewModel: vm)
        switch self {
        case .modal(let root):
            let nav = UINavigationController(rootViewController: vc)
            vm.navigator = EditLocationStandardWireframe(nc: nav)
            vm.quickLocationFiltersNavigator = QuickLocationFiltersModalWireframe(root: root)
            return nav
        case .standard(let nav):
            vm.navigator = EditLocationStandardWireframe(nc: nav)
            vm.quickLocationFiltersNavigator = QuickLocationFiltersStandardWireframe(nc: nav)
            return vc
        }
    }
}
