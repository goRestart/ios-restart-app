import LGCoreKit

final class FiltersModalWireframe: FiltersNavigator {
    private let controller: UIViewController
    private weak var nc: UINavigationController?

    private let quickFiltersAssembly: QuickLocationFiltersAssembly

    init(controller: UIViewController, nc: UINavigationController) {
        self.controller = controller
        self.nc = nc
        self.quickFiltersAssembly = QuickLocationFiltersBuilder.standard(nc)
    }
    
    func openServicesDropdown(viewModel: DropdownViewModel) {
        nc?.pushViewController(
            DropdownViewController(withViewModel: viewModel),
            animated: true
        )
    }
    
    func openEditLocation(mode: EditLocationMode,
                          initialPlace: Place?,
                          distanceRadius: Int?,
                          locationDelegate: EditLocationDelegate) {
        let vc = quickFiltersAssembly.buildQuickLocationFilters(mode: mode,
                                                                initialPlace: initialPlace,
                                                                distanceRadius: distanceRadius,
                                                                locationDelegate: locationDelegate)
        nc?.pushViewController(vc, animated: true)
    }
    
    func openCarAttributeSelection(withViewModel viewModel: CarAttributeSelectionViewModel) {
        nc?.pushViewController(
            CarAttributeSelectionViewController(viewModel: viewModel),
            animated: true
        )
    }
    
    func openListingAttributePicker(viewModel: ListingAttributePickerViewModel) {
        let vc = ListingAttributePickerViewController(viewModel: viewModel)
        viewModel.delegate = vc
        nc?.pushViewController(vc, animated: true)
    }
    
    func closeFilters() {
        controller.dismiss(animated: true, completion: nil)
    }
}
