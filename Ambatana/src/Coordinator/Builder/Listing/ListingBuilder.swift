import LGCoreKit

protocol ListingAssembly {
    func buildListingDetail(withVM listingViewModel: ListingViewModel,
                            source: EventParameterListingVisitSource) -> UIViewController
    func buildDeck(with listing: Listing,
                   thumbnailImage: UIImage?,
                   listings: [ListingCellModel]?,
                   requester: ListingListRequester,
                   source: EventParameterListingVisitSource,
                   onFirstAppear: DeckActionOnFirstAppear,
                   trackingIndex: Int?,
                   trackingIdentifier: String?) -> UIViewController
}

enum ListingBuilder {
    case standard(UINavigationController)
}

extension ListingBuilder: ListingAssembly {
    func buildListingDetail(withVM listingViewModel: ListingViewModel,
                            source: EventParameterListingVisitSource) -> UIViewController {
        switch self {
        case .standard(let nc):
            let vm = ListingDetailViewModel(withVM: listingViewModel, visitSource: source)
            let vc = ListingDetailViewController(viewModel: vm)

            vm.navigator = ListingFullDetailWireframe(nc: nc)
            return vc
        }
    }

    func buildDeck(with listing: Listing,
                   thumbnailImage: UIImage?,
                   listings: [ListingCellModel]?,
                   requester: ListingListRequester,
                   source: EventParameterListingVisitSource,
                   onFirstAppear: DeckActionOnFirstAppear,
                   trackingIndex: Int?,
                   trackingIdentifier: String?) -> UIViewController {
        switch self {
        case .standard(let nc):
            let navigator = ListingDetailWireframe(nc: nc)
            let vm = ListingDeckViewModel(listModels: listings ?? [],
                                          listing: listing,
                                          viewModelMaker: ListingViewModel.ConvenienceMaker(detailNavigator: navigator),
                                          listingListRequester: requester,
                                          source: source,
                                          actionOnFirstAppear: onFirstAppear,
                                          trackingIndex: trackingIndex,
                                          trackingIdentifier: trackingIdentifier)
            vm.navigator = ListingDeckWireframe(nc: nc)
            let vc = ListingDeckViewController(viewModel: vm)
            vm.delegate = vc

            return vc
        }
    }
}
