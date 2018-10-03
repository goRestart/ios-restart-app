import Foundation
import LGCoreKit

protocol EditListingAssembly {
    func buildEditView(listing: Listing,
                       pageType: EventParameterTypePage?,
                       purchases: [BumpUpProductData],
                       listingCanBeBoosted: Bool,
                       timeSinceLastBump: TimeInterval?,
                       maxCountdown: TimeInterval,
                       onEditAction: OnEditActionable?,
                       onCancelEditAction: OnEditActionable?) -> UIViewController
}

enum EditListingBuilder {
    case standard(UINavigationController)
    case modal(UIViewController)
}

extension EditListingBuilder: EditListingAssembly {
    func buildEditView(listing: Listing,
                       pageType: EventParameterTypePage?,
                       purchases: [BumpUpProductData],
                       listingCanBeBoosted: Bool,
                       timeSinceLastBump: TimeInterval?,
                       maxCountdown: TimeInterval,
                       onEditAction: OnEditActionable?,
                       onCancelEditAction: OnEditActionable?) -> UIViewController {
        let vm = EditListingViewModel(listing: listing,
                                      pageType: pageType,
                                      purchases: purchases,
                                      listingCanBeBoosted: listingCanBeBoosted,
                                      timeSinceLastBump: timeSinceLastBump,
                                      maxCountdown: maxCountdown)
        let vc = EditListingViewController(viewModel: vm)

        switch self {
        case .standard(let nav):
            vm.navigator = EditListingStandardWireframe(nc: nav,
                                                        onEditActionable: onEditAction,
                                                        onCancelEditActionable: onCancelEditAction)
            return vc
        case .modal(let root):
            let nav = UINavigationController(rootViewController: vc)
            vm.navigator = EditListingModalWireframe(root: root,
                                                     nc: nav,
                                                     onEditActionable: onEditAction,
                                                     onCancelEditActionable: onCancelEditAction)
            return nav
        }
    }
}
