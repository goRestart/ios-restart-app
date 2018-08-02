import Foundation
import LGCoreKit
import LGComponents

class SimpleListingsViewModel: BaseViewModel, ListingListViewModelDataDelegate {

    var navigator: SimpleProductsNavigator?

    let title: String
    let listingVisitSource: EventParameterListingVisitSource
    let listingListRequester: ListingListRequester
    let listingListViewModel: ListingListViewModel
    let featureFlags: FeatureFlaggeable

    convenience init(requester: ListingListRequester,
                     listings: [Listing],
                     title: String,
                     listingVisitSource: EventParameterListingVisitSource) {
        self.init(requester: requester,
                  listings: listings,
                  title: title,
                  listingVisitSource: listingVisitSource,
                  featureFlags: FeatureFlags.sharedInstance)
    }

    init(requester: ListingListRequester,
         listings: [Listing]?,
         title: String,
         listingVisitSource: EventParameterListingVisitSource,
         featureFlags: FeatureFlaggeable) {
        self.title = title
        self.listingVisitSource = listingVisitSource
        self.listingListRequester = requester
        let show3Columns = DeviceFamily.current.isWiderOrEqualThan(.iPhone6Plus)
        let columns = show3Columns ? 3 : 2
        self.listingListViewModel = ListingListViewModel(requester: requester,
                                                         listings: listings,
                                                         numberOfColumns: columns)
        self.featureFlags = featureFlags
        super.init()
        listingListViewModel.dataDelegate = self
    }

    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)

        if firstTime {
            listingListViewModel.refresh()
        }
    }

    override func backButtonPressed() -> Bool {
        guard let navigator = navigator else { return false }
        navigator.closeSimpleProducts()
        return true
    }

    func listingListMV(_ viewModel: ListingListViewModel,
                       didFailRetrievingListingsPage page: UInt,
                       hasListings: Bool,
                       error: RepositoryError) {

    }
    func listingListVM(_ viewModel: ListingListViewModel,
                       didSucceedRetrievingListingsPage page: UInt,
                       withResultsCount resultsCount: Int,
                       hasListings: Bool) {

    }
    func listingListVM(_ viewModel: ListingListViewModel, 
                       didSelectItemAtIndex index: Int,
                       thumbnailImage: UIImage?,
                       originFrame: CGRect?) {
        guard let listing = viewModel.listingAtIndex(index) else { return }
        let cellModels = viewModel.objects
        let data = ListingDetailData.listingList(listing: listing, cellModels: cellModels,
                                                 requester: listingListRequester, thumbnailImage: thumbnailImage,
                                                 originFrame: originFrame, showRelated: false, index: index)
        navigator?.openListing(data, source: listingVisitSource, actionOnFirstAppear: .nonexistent)
    }

    func vmProcessReceivedListingPage(_ listings: [ListingCellModel],
                                      page: UInt) -> [ListingCellModel] {
        return listings
    }
    func vmDidSelectSellBanner(_ type: String) {}
    func vmDidSelectCollection(_ type: CollectionCellType) {}
}
