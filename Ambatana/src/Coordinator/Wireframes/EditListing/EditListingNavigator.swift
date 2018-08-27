import LGCoreKit

protocol EditListingNavigator {
    func editingListingDidFinish(_ editedListing: Listing,
                                 bumpUpProductData: BumpUpProductData?,
                                 timeSinceLastBump: TimeInterval?,
                                 maxCountdown: TimeInterval)
    func openListingAttributePicker(viewModel: ListingAttributeSingleSelectPickerViewModel)
    func editingListingDidCancel()
    func openEditLocation(mode: EditLocationMode,
                          initialPlace: Place?,
                          locationDelegate: EditLocationDelegate)
    func openCarMakesSelection(_ carMakes: [CarsMake],
                               selectedMake: String?,
                               style: CarAttributeSelectionTableStyle,
                               delegate: CarAttributeSelectionDelegate)
    func openCarModelsSelection(_ carModels: [CarsModel],
                                 selectedModel: String?,
                                 style: CarAttributeSelectionTableStyle,
                                 delegate: CarAttributeSelectionDelegate)
    func openCarYearSelection(_ yearsList: [Int],
                               selectedYear: Int?,
                               delegate: CarAttributeSelectionDelegate)
}

protocol OnEditActionable: class {
    func onEdit(listing: Listing,
                bumpData: BumpUpProductData?,
                timeSinceLastBump: TimeInterval?,
                maxCountdown: TimeInterval)
}
