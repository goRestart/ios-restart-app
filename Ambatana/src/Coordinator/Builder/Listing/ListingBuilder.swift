import LGCoreKit

protocol ListingAssembly {
    func buildListingDetail(for listing: Listing, source: EventParameterListingVisitSource) -> UIViewController
}

enum ListingBuilder {
    case standard(UINavigationController)
}

extension ListingBuilder: ListingAssembly {
    func buildListingDetail(for listing: Listing, source: EventParameterListingVisitSource) -> UIViewController {
        let vm = ListingDetailViewModel(withListing: listing, visitSource: source)
        let vc = ListingDetailViewController(viewModel: vm)

        switch self {
        case .standard(let nc):
            vm.navigator = ListingFullDetailWireframe(nc: nc)
            vm.listingDetailNavigator = ListingDetailWireframe(nc: nc)

            return vc
        }
    }

}
