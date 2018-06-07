import Foundation
import LGCoreKit

typealias ListingsRequesterCompletion = (ListingsRequesterResult) -> Void

protocol ListingListRequester: class {
    var itemsPerPage: Int { get }
    var isFirstPage: Bool { get }
    func canRetrieve() -> Bool
    func retrieveFirstPage(_ completion: ListingsRequesterCompletion?)
    func retrieveNextPage(_ completion: ListingsRequesterCompletion?)
    func isLastPage(_ resultCount: Int) -> Bool
    func updateInitialOffset(_ newOffset: Int)
    func duplicate() -> ListingListRequester
    func isEqual(toRequester requester: ListingListRequester) -> Bool
    func distanceFromListingCoordinates(_ listingCoords: LGLocationCoordinates2D) -> Double?
    var countryCode: String? { get }
}
