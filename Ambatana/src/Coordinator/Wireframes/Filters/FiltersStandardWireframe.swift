import LGCoreKit

final class FiltersStandardWireframe: FiltersNavigator {
    private weak var nc: UINavigationController?
    
    init(nc: UINavigationController) {
        self.nc = nc
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
        guard let nc = nc else { return }
        let assembly = QuickLocationFiltersBuilder.standard(nc)
        let vc = assembly.buildQuickLocationFilters(mode: mode,
                                                    initialPlace: initialPlace,
                                                    distanceRadius: distanceRadius,
                                                    locationDelegate: locationDelegate)
        nc.pushViewController(vc, animated: true)
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
        nc?.popViewController(animated: true)
    }
}
