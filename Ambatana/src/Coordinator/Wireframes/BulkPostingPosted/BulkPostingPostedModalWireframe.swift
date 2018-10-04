import LGComponents
import LGCoreKit

final class BulkPostingPostedModalWireframe: BulkPostingPostedNavigator {

    let root: UIViewController
    let postAgainAction: (() -> Void)?
    let closeAction: (([Listing]) -> Void)?

    init(root: UIViewController, postAgainAction: (() -> Void)?, closeAction: (([Listing]) -> Void)?) {
        self.root = root
        self.postAgainAction = postAgainAction
        self.closeAction = closeAction
    }

    func close(listings: [Listing]) {
        root.dismiss(animated: true) {
            self.closeAction?(listings)
        }
    }

    func openEditListing(listing: Listing, onEditAction: OnEditActionable) {
        guard let viewController = root.presentedViewController else { return }
        let editListingAssembly = EditListingBuilder.modal(viewController)
        let vc = editListingAssembly.buildEditView(listing: listing,
                                                   pageType: nil,
                                                   purchases: [],
                                                   listingCanBeBoosted: false,
                                                   timeSinceLastBump: nil,
                                                   maxCountdown: 0,
                                                   onEditAction: onEditAction,
                                                   onCancelEditAction: nil)
        viewController.present(vc, animated: true, completion: nil)
    }

    func postAnotherListing() {
        root.dismiss(animated: true) {
            self.postAgainAction?()
        }
    }
}
