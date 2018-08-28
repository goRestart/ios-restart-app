import Foundation
import LGCoreKit

final class EditListingModalWireframe: EditListingNavigator {
    private let root: UIViewController
    private let nc: UINavigationController

    private let editLocationAssembly: QuickLocationFiltersAssembly
    private let carMakesAssembly: CarAttributesSelectionAssembly

    weak var listingRefreshable: ListingsRefreshable?
    private weak var onEditActionable: OnEditActionable?

    init(root: UIViewController, nc: UINavigationController, onEditActionable: OnEditActionable?) {
        self.root = root
        self.nc = nc
        self.onEditActionable = onEditActionable
        self.editLocationAssembly = QuickLocationFiltersBuilder.standard(nc)
        self.carMakesAssembly = CarAttributesSelectionBuilder.standard(nc)
    }

    func editingListingDidCancel() {
        root.dismiss(animated: true, completion: nil)
    }

    func editingListingDidFinish(_ editedListing: Listing,
                                 bumpUpProductData: BumpUpProductData?,
                                 timeSinceLastBump: TimeInterval?,
                                 maxCountdown: TimeInterval) {
        listingRefreshable?.listingsRefresh()
        root.dismiss(animated: true, completion: {
            self.onEditActionable?.onEdit(listing: editedListing,
                                          bumpData: bumpUpProductData,
                                          timeSinceLastBump: timeSinceLastBump,
                                          maxCountdown: maxCountdown)
        })
    }

    func openListingAttributePicker(viewModel: ListingAttributeSingleSelectPickerViewModel) {
        let vc = ListingAttributePickerViewController(viewModel: viewModel)
        viewModel.delegate = vc
        nc.pushViewController(vc, animated: true)
    }

    func openEditLocation(mode: EditLocationMode,
                          initialPlace: Place?,
                          locationDelegate: EditLocationDelegate) {
        let vc = editLocationAssembly.buildQuickLocationFilters(mode: mode,
                                                                initialPlace: initialPlace,
                                                                distanceRadius: nil,
                                                                locationDelegate: locationDelegate)
        nc.pushViewController(vc, animated: true)
    }

    func openCarMakesSelection(_ carMakes: [CarsMake],
                               selectedMake: String?,
                               style: CarAttributeSelectionTableStyle,
                               delegate: CarAttributeSelectionDelegate) {
        let vc = carMakesAssembly.buildCarMakesSelection(carMakes,
                                                         selectedMake: selectedMake,
                                                         style: style,
                                                         delegate: delegate)
        nc.pushViewController(vc, animated: true)
    }
    func openCarModelsSelection(_ carModels: [CarsModel],
                                selectedModel: String?,
                                style: CarAttributeSelectionTableStyle, delegate: CarAttributeSelectionDelegate) {
        let vc = carMakesAssembly.buildCarModelsSelection(carModels,
                                                          selectedModel: selectedModel,
                                                          style: style,
                                                          delegate: delegate)
        nc.pushViewController(vc, animated: true)
    }

    func openCarYearSelection(_ yearsList: [Int],
                              selectedYear: Int?,
                              delegate: CarAttributeSelectionDelegate) {
        let vc = carMakesAssembly.buildCarYearSelection(yearsList,
                                                        selectedYear: selectedYear,
                                                        delegate: delegate)
        nc.pushViewController(vc, animated: true)
    }
}