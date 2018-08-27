import LGCoreKit
import LGComponents

protocol SimpleListingsAssembly {
    func buildSimpleListingViewController(listingId: String,
                                          source: EventParameterListingVisitSource,
                                          requester: ListingListRequester,
                                          relatedListings: [Listing]) -> SimpleListingsViewController

}

enum SimpleListingsBuilder {
    case standard(nav: UINavigationController)
}

extension SimpleListingsBuilder: SimpleListingsAssembly {
    func buildSimpleListingViewController(listingId: String,
                                          source: EventParameterListingVisitSource,
                                          requester: ListingListRequester,
                                          relatedListings: [Listing]) -> SimpleListingsViewController {
        let vm = SimpleListingsViewModel(requester: requester,
                                         listings: relatedListings,
                                         title: R.Strings.relatedItemsTitle,
                                         listingVisitSource: source)
        let vc = SimpleListingsViewController(viewModel: vm)
        switch self {
        case .standard(let nav):
            vm.navigator = SimpleListingsWireframe(nc: nav)
        }
        return vc
    }
}
