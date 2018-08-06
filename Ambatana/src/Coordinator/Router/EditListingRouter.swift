import Foundation
import LGCoreKit

protocol EditListingNavigator: class {
    func editingListingDidFinish(_ editedListing: Listing,
                                 bumpUpProductData: BumpUpProductData?,
                                 timeSinceLastBump: TimeInterval?,
                                 maxCountdown: TimeInterval)
    func openListingAttributePicker(viewModel: ListingAttributeSingleSelectPickerViewModel)
    func editingListingDidCancel()
}

typealias OnEditAction = ((Listing, BumpUpProductData?, TimeInterval?, TimeInterval)->())

final class EditListingRouter: EditListingNavigator {
    private weak var navigationController: UINavigationController?
    weak var listingRefreshable: ListingsRefreshable?
    private var onEditAction: OnEditAction?

    init(navigationController: UINavigationController, onEditAction: OnEditAction?) {
        self.navigationController = navigationController
        self.onEditAction = onEditAction
    }

    func editingListingDidCancel() {
        navigationController?.dismiss(animated: true, completion: nil)
    }

    func editingListingDidFinish(_ editedListing: Listing,
                                 bumpUpProductData: BumpUpProductData?,
                                 timeSinceLastBump: TimeInterval?,
                                 maxCountdown: TimeInterval) {
        listingRefreshable?.listingsRefresh()
        onEditAction?(editedListing, bumpUpProductData, timeSinceLastBump, maxCountdown)
        navigationController?.dismiss(animated: true, completion: nil)
    }

    func openListingAttributePicker(viewModel: ListingAttributeSingleSelectPickerViewModel) {
        let vc = ListingAttributePickerViewController(viewModel: viewModel)
        viewModel.delegate = vc
        navigationController?.pushViewController(vc, animated: true)
    }
}
