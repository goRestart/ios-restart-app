import Foundation
import LGCoreKit

final class EditListingModalWireframe: EditListingNavigator {
    private let root: UIViewController
    private weak var nc: UINavigationController?

    private let editLocationAssembly: QuickLocationFiltersAssembly
    private let carMakesAssembly: CarAttributesSelectionAssembly

    weak var listingRefreshable: ListingsRefreshable?
    private weak var onEditActionable: OnEditActionable?
    private weak var onCancelEditActionable: OnEditActionable?

    init(root: UIViewController,
         nc: UINavigationController,
         onEditActionable: OnEditActionable?,
         onCancelEditActionable: OnEditActionable?) {
        self.root = root
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
        root.dismiss(animated: true, completion: { [weak self] in
            self?.onCancelEditActionable?.onEdit(listing: originalListing,
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
        root.dismiss(animated: true, completion: {[weak self] in
            self?.onEditActionable?.onEdit(listing: editedListing,
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
