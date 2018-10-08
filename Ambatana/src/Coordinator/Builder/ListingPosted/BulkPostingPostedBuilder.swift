import LGCoreKit
import LGComponents

protocol BulkPostingPostedAssembly {
    func buildListingPosted(listings: [Listing],
                            postAgainAction: (() -> Void)?,
                            closeAction: (([Listing]) -> Void)?) -> BulkPostingsPostedViewController
}

enum BulkPostingPostedBuilder {
    case modal(root: UIViewController)
}

extension BulkPostingPostedBuilder: BulkPostingPostedAssembly {
    func buildListingPosted(listings: [Listing],
                            postAgainAction: (() -> Void)?,
                            closeAction: (([Listing]) -> Void)?) -> BulkPostingsPostedViewController {
        let vm = BulkPostingsPostedViewModel(listings: listings)
        let vc = BulkPostingsPostedViewController(viewModel: vm)
        switch self {
        case .modal(let root):
            vm.navigator = BulkPostingPostedModalWireframe(root: root,
                                                           postAgainAction: postAgainAction,
                                                           closeAction: closeAction)
        }
        return vc
    }
}
