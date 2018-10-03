import LGCoreKit
import LGComponents

protocol BulkListingPostedAssembly {
    func buildListingPosted(listings: [Listing],
                            postAgainAction: (() -> Void)?,
                            closeAction: (([Listing]) -> Void)?) -> BulkListingsPostedViewController
}

enum BulkListingPostedBuilder {
    case modal(root: UIViewController)
}

extension BulkListingPostedBuilder: BulkListingPostedAssembly {
    func buildListingPosted(listings: [Listing],
                            postAgainAction: (() -> Void)?,
                            closeAction: (([Listing]) -> Void)?) -> BulkListingsPostedViewController {
        let vm = BulkListingsPostedViewModel(listings: listings)
        let vc = BulkListingsPostedViewController(viewModel: vm)
        switch self {
        case .modal(let root):
            vm.navigator = BulkListingPostedModalWireframe(root: root,
                                                           postAgainAction: postAgainAction,
                                                           closeAction: closeAction)
        }
        return vc
    }
}
