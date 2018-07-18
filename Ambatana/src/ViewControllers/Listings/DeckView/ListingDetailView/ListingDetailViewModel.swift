import Foundation
import LGComponents
import LGCoreKit

final class ListingDetailViewModel: BaseViewModel {

    weak var navigator: DeckNavigator?

    private lazy var listingViewModel: ListingViewModel = maker.make(listing: listing,
                                                                     navigator: nil, // TODO: connect with screen
                                                                     visitSource: visitSource)
    private let maker: ListingViewModelMaker
    private let listing: Listing
    private let visitSource: EventParameterListingVisitSource
    init(withListing listing: Listing, visitSource: EventParameterListingVisitSource) {
        self.listing = listing
        self.visitSource = visitSource
        self.maker = ListingViewModel.ConvenienceMaker()
        super.init()
    }

    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        if firstTime {
            listingViewModel.didBecomeActive(firstTime)
        }
    }

    func closeDetail() {
        navigator?.closeDetail()
    }
}
