import Foundation
import LGCoreKit

final class EditListingStandardWireframe: EditListingNavigator {
    private weak var nc: UINavigationController?

    weak var listingRefreshable: ListingsRefreshable?
    private var onEditActionable: OnEditActionable?
    private var onCancelEditActionable: OnEditActionable?
    private let editLocationAssembly: QuickLocationFiltersAssembly
    private let carMakesAssembly: CarAttributesSelectionAssembly

    init(nc: UINavigationController,
         onEditActionable: OnEditActionable?,
         onCancelEditActionable: OnEditActionable?) {
        self.nc = nc
        self.onEditActionable = onEditActionable
        self.onCancelEditActionable = onCancelEditActionable
        self.editLocationAssembly = QuickLocationFiltersBuilder.standard(nc)
        self.carMakesAssembly = CarAttributesSelectionBuilder.standard(nc)
    }

    func editingListingDidCancel(_ originalListing: Listing,
                                 purchases: [BumpUpProductData],
                                 timeSinceLastBump: TimeInterval?,
                                 maxCountdown: TimeInterval) {
        nc?.popViewController(animated: true, completion: {
            self.onEditActionable?.onEdit(listing: originalListing,
                                          purchases: purchases,
                                          timeSinceLastBump: timeSinceLastBump,
                                          maxCountdown: maxCountdown)
        })
    }

    func editingListingDidFinish(_ editedListing: Listing,
                                 purchases: [BumpUpProductData],
                                 timeSinceLastBump: TimeInterval?,
                                 maxCountdown: TimeInterval) {
        listingRefreshable?.listingsRefresh()
        nc?.popViewController(animated: true, completion: {
            self.onEditActionable?.onEdit(listing: editedListing,
                                          purchases: purchases,
                                          timeSinceLastBump: timeSinceLastBump,
                                          maxCountdown: maxCountdown)
        })
    }

    func openListingAttributePicker(viewModel: ListingAttributeSingleSelectPickerViewModel) {
        let vc = ListingAttributePickerViewController(viewModel: viewModel)
        viewModel.delegate = vc
        nc?.pushViewController(vc, animated: true)
    }

    func openEditLocation(mode: EditLocationMode,
                          initialPlace: Place?,
                          locationDelegate: EditLocationDelegate) {
        let vc = editLocationAssembly.buildQuickLocationFilters(mode: mode,
                                                                initialPlace: initialPlace,
                                                                distanceRadius: nil,
                                                                locationDelegate: locationDelegate)
        nc?.pushViewController(vc, animated: true)
    }

    func openCarMakesSelection(_ carMakes: [CarsMake],
                               selectedMake: String?,
                               style: CarAttributeSelectionTableStyle,
                               delegate: CarAttributeSelectionDelegate) {
        let vc = carMakesAssembly.buildCarMakesSelection(carMakes,
                                                         selectedMake: selectedMake,
                                                         style: style,
                                                         delegate: delegate)
        nc?.pushViewController(vc, animated: true)
    }

    func openCarModelsSelection(_ carModels: [CarsModel],
                                selectedModel: String?,
                                style: CarAttributeSelectionTableStyle, delegate: CarAttributeSelectionDelegate) {
        let vc = carMakesAssembly.buildCarModelsSelection(carModels,
                                                          selectedModel: selectedModel,
                                                          style: style,
                                                          delegate: delegate)
        nc?.pushViewController(vc, animated: true)
    }

    func openCarYearSelection(_ yearsList: [Int],
                              selectedYear: Int?,
                              delegate: CarAttributeSelectionDelegate) {
        let vc = carMakesAssembly.buildCarYearSelection(yearsList,
                                                        selectedYear: selectedYear,
                                                        delegate: delegate)
        nc?.pushViewController(vc, animated: true)
    }
}
