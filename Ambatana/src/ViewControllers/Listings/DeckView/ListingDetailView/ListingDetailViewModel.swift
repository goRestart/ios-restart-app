import Foundation
import LGComponents
import LGCoreKit
import RxSwift
import RxCocoa

final class ListingDetailViewModel: BaseViewModel {

    weak var navigator: DeckNavigator?

    lazy var listingViewModel: ListingViewModel = maker.make(listing: listing,
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

typealias ListingDetailStats = (views: Int?, favs: Int?, posted: Date?)
typealias ListingDetailLocation = (location: LGLocationCoordinates2D?, address: String?, showExactLocation: Bool)

extension ListingDetailViewModel: ReactiveCompatible { }

extension Reactive where Base: ListingDetailViewModel {
    var media: Driver<[Media]> { return base.listingViewModel.productMedia.asDriver() }
    var title: Driver<String?> { return base.listingViewModel.productInfo.asDriver().map { return $0?.title } }
    var price: Driver<String?> { return base.listingViewModel.productInfo.asDriver().map { return $0?.price } }
    var detail: Driver<String?> { return base.listingViewModel.listing.asDriver().map { return $0.description }}
    var stats: Driver<ListingDetailStats?> {
        let views = base.listingViewModel.listingStats.asObservable().map { $0?.viewsCount }
        let favs = base.listingViewModel.listingStats.asObservable().map { $0?.favouritesCount }
        let date = base.listingViewModel.productInfo.asObservable().map { $0?.creationDate }

        return Observable.combineLatest(views, favs, date) { ($0, $1, $2) }.asDriver(onErrorJustReturn: nil)
    }
    var user: Driver<ListingVMUserInfo> { return base.listingViewModel.userInfo.asDriver() }
    var location: Driver<ListingDetailLocation?> {
        let location = base.listingViewModel.productInfo.asObservable().map { return $0?.location }
        let address = base.listingViewModel.productInfo.asObservable().map { $0?.address }
        let showExactLocation = base.listingViewModel.cardShowExactLocationOnMap.asObservable()
        return Observable
            .combineLatest(location, address, showExactLocation) { ($0, $1, $2) }
            .asDriver(onErrorJustReturn: nil)
    }

}
