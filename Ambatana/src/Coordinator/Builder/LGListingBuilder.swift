import Foundation
import LGCoreKit

protocol ListingBuilder {
    func buildEditView(listing: Listing,
                       pageType: EventParameterTypePage?,
                       bumpUpProductData: BumpUpProductData?,
                       listingCanBeBoosted: Bool,
                       timeSinceLastBump: TimeInterval?,
                       maxCountdown: TimeInterval,
                       onEditAction: OnEditAction?) -> EditListingViewController
}

enum LGListingBuilder {
    case standard(navigationController: UINavigationController)
}

extension LGListingBuilder: ListingBuilder {
    func buildEditView(listing: Listing,
                       pageType: EventParameterTypePage?,
                       bumpUpProductData: BumpUpProductData?,
                       listingCanBeBoosted: Bool,
                       timeSinceLastBump: TimeInterval?,
                       maxCountdown: TimeInterval,
                       onEditAction: OnEditAction?) -> EditListingViewController {
        switch self {
        case .standard(let nav):
            let vm = EditListingViewModel(listing: listing,
                                          pageType: pageType,
                                          bumpUpProductData: bumpUpProductData,
                                          listingCanBeBoosted: listingCanBeBoosted,
                                          timeSinceLastBump: timeSinceLastBump,
                                          maxCountdown: maxCountdown)
            vm.navigator = EditListingRouter(navigationController: nav, onEditAction: onEditAction)
            let vc = EditListingViewController(viewModel: vm)
            return vc
        }
    }
}




