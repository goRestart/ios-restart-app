import LGCoreKit
import RxSwift
import LGComponents

struct BulkPostingListingData {
    var listing: Listing
    var image: UIImage?
}

final class BulkPostingListingsViewModel: BaseViewModel {
//    var listings = Variable<[BulkPostingListingData]>([])
//
//    private let listingRepository: ListingRepository
//    private let tracker: Tracker
//    private let featureFlags: FeatureFlaggeable

    let listings: [Listing]

    init(listings: [Listing]) {
//        self.listingRepository = listingRepository
//        self.tracker = tracker
//        self.featureFlags = featureFlags
        self.listings = listings
    }

//    convenience override init() {
//        self.init(listingRepository: Core.listingRepository,
//                  tracker: TrackerProxy.sharedInstance,
//                  featureFlags: FeatureFlags.sharedInstance)
//    }

//    func postListing(listingCreationParams: ListingCreationParams,
//                     postListingTrackingInfo: PostListingTrackingInfo,
//                     image: UIImage?) {
//        var data = BulkPostingListingData(listingCreationParams: listingCreationParams,
//                                          postListingTrackingInfo: postListingTrackingInfo,
//                                          status: .posting,
//                                          image: image)
//        listings.value.append(data)
//        listingRepository.create(listingParams: listingCreationParams) { [weak self] result in
//            if let listing = result.value {
//                data.status = .posted(listing: listing)
//                self?.trackPost(withListing: listing, trackingInfo: postListingTrackingInfo)
//            } else if let error = result.error {
//                data.status = .error(error: error)
//                self?.trackPost(withError: error)
//            }
//        }
//    }
//
//    // MARK: - Tracking
//
//    private func trackPost(withListing listing: Listing, trackingInfo: PostListingTrackingInfo) {
//        let event = TrackerEvent.listingSellComplete(listing,
//                                                     buttonName: trackingInfo.buttonName,
//                                                     sellButtonPosition: trackingInfo.sellButtonPosition,
//                                                     negotiable: trackingInfo.negotiablePrice,
//                                                     pictureSource: trackingInfo.imageSource,
//                                                     videoLength: trackingInfo.videoLength,
//                                                     freePostingModeAllowed: featureFlags.freePostingModeAllowed,
//                                                     typePage: trackingInfo.typePage,
//                                                     machineLearningTrackingInfo: trackingInfo.machineLearningInfo)
//
//        tracker.trackEvent(event)
//    }
//
//    private func trackPost(withError error: RepositoryError) {
//        let sellError = EventParameterPostListingError(error: error)
//        let sellErrorDataEvent = TrackerEvent.listingSellErrorData(sellError)
//        tracker.trackEvent(sellErrorDataEvent)
//    }
}
