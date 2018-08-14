protocol FiltersRouter: class {
    func openEditLocation(withViewModel viewModel: EditLocationViewModel)
    func openCarAttributeSelection(withViewModel viewModel: CarAttributeSelectionViewModel)
    func openListingAttributePicker(viewModel: ListingAttributePickerViewModel)
    func openServicesDropdown(viewModel: DropdownViewModel)
    func closeFilters()
}
