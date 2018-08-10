protocol FiltersRouter: class {
    func openEditLocation(withViewModel viewModel: EditLocationViewModel)
    func openCarAttributeSelection(withViewModel viewModel: CarAttributeSelectionViewModel)
    func openTaxonomyList(withViewModel viewModel: TaxonomiesViewModel)
    func openListingAttributePicker(viewModel: ListingAttributePickerViewModel)
    func openServicesDropdown(viewModel: DropdownViewModel)
    func closeFilters()
}
