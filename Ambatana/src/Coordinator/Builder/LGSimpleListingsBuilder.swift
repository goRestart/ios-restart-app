import Foundation
import LGCoreKit
import LGComponents

protocol SimpleListingsAssembly {
    func buildSimpleListingViewController(listingId: String,
                                          source: EventParameterListingVisitSource,
                                          requester: ListingListRequester,
                                          relatedListings: [Listing],
                                          detailNavigator: ListingDetailNavigator?) -> SimpleListingsViewController

}

enum LGSimpleListingsBuilder {
    case standard(nav: UINavigationController)
}

extension LGSimpleListingsBuilder: SimpleListingsAssembly {
    func buildSimpleListingViewController(listingId: String,
                                          source: EventParameterListingVisitSource,
                                          requester: ListingListRequester,
                                          relatedListings: [Listing],
                                          detailNavigator: ListingDetailNavigator?) -> SimpleListingsViewController {
        switch self {
        case .standard(let nav):
            let simpleRelatedListingsVM = SimpleListingsViewModel(requester: requester,
                                                                  listings: relatedListings,
                                                                  title: R.Strings.relatedItemsTitle,
                                                                  listingVisitSource: source)
            simpleRelatedListingsVM.navigator = SimpleProductsRouter(navigationController: nav,
                                                                     detailNavigator: detailNavigator)
            return SimpleListingsViewController(viewModel: simpleRelatedListingsVM)
        }
    }
}
