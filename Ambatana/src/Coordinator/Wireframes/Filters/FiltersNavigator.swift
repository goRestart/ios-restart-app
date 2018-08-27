import LGCoreKit

protocol FiltersNavigator {
    func openEditLocation(mode: EditLocationMode,
                          initialPlace: Place?,
                          distanceRadius: Int?,
                          locationDelegate: EditLocationDelegate)
    func openCarAttributeSelection(withViewModel viewModel: CarAttributeSelectionViewModel)
    func openListingAttributePicker(viewModel: ListingAttributePickerViewModel)
    func openServicesDropdown(viewModel: DropdownViewModel)
    func closeFilters()
}
