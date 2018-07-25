import LGCoreKit
import RxSwift
import LGComponents

class BlockingPostingListingEditionViewModel: BaseViewModel {
    
    enum ListingEditionState: Equatable {
        case updatingListing
        case success
        case error
        
        var message: String {
            switch self {
            case .updatingListing, .success:
                return ""
            case .error:
                return R.Strings.productPostGenericError
            }
        }
        
        var isAnimated: Bool {
            return self == .updatingListing
        }
        
        var isError: Bool {
            return self == .error
        }
    }
    
    private let listingRepository: ListingRepository
    private let tracker: Tracker
    private let featureFlags: FeatureFlaggeable
    private let listingParams: ListingEditionParams
    private var listing: Listing
    private let images: [UIImage]
    private let imageSource: EventParameterMediaSource
    private let videoLength: TimeInterval?
    private let postingSource: PostingSource
    
    var state = Variable<ListingEditionState?>(nil)
    
    weak var navigator: BlockingPostingNavigator?
    
    
    // MARK: - Lifecycle

    convenience init(listingParams: ListingEditionParams, listing: Listing, images: [UIImage],
                     imageSource: EventParameterMediaSource, videoLength: TimeInterval?, postingSource: PostingSource) {
        self.init(listingRepository: Core.listingRepository,
                  tracker: TrackerProxy.sharedInstance,
                  featureFlags: FeatureFlags.sharedInstance,
                  listingParams: listingParams,
                  listing: listing,
                  images: images,
                  imageSource: imageSource,
                  videoLength: videoLength,
                  postingSource: postingSource)
    }

    init(listingRepository: ListingRepository,
         tracker: Tracker,
         featureFlags: FeatureFlaggeable,
         listingParams: ListingEditionParams,
         listing: Listing,
         images: [UIImage],
         imageSource: EventParameterMediaSource,
         videoLength: TimeInterval?,
         postingSource: PostingSource) {
        self.listingRepository = listingRepository
        self.tracker = tracker
        self.featureFlags = featureFlags
        self.listingParams = listingParams
        self.listing = listing
        self.images = images
        self.imageSource = imageSource
        self.postingSource = postingSource
        self.videoLength = videoLength
        super.init()
    }

    
    // MARK: - Requests
    
    func updateListing() {
        state.value = .updatingListing
        let shouldUseServicesEndpoint = featureFlags.showServicesFeatures.isActive
        let updateAction = listingRepository.updateAction(forParams: listingParams,
                                                          shouldUseServicesEndpoint: shouldUseServicesEndpoint)
        updateAction(listingParams) { [weak self] result in
            if let responseListing = result.value {
                self?.listing = responseListing
                self?.state.value = .success
            } else if let _ = result.error {
                self?.state.value = .error
            }
        }
    }
    
    
    // MARK: - Navigation
    
    func openListingPosted() {
        navigator?.openListingPosted(listing: listing,
                                     images: images,
                                     imageSource: imageSource,
                                     videoLength: videoLength,
                                     postingSource: postingSource)
    }
    
    func closeButtonAction() {
        trackPostSellComplete()
        navigator?.closePosting()
    }
    
    
    // MARK: - Tracking
    
    fileprivate func trackPostSellComplete() {
        let trackingInfo = PostListingTrackingInfo(buttonName: .close,
                                                   sellButtonPosition: postingSource.sellButtonPosition,
                                                   imageSource: imageSource,
                                                   videoLength: videoLength,
                                                   price: String.fromPriceDouble(listing.price.value),
                                                   typePage: postingSource.typePage,
                                                   mostSearchedButton: postingSource.mostSearchedButton,
                                                   machineLearningInfo: MachineLearningTrackingInfo.defaultValues())
        
        let event = TrackerEvent.listingSellComplete(listing,
                                                     buttonName: trackingInfo.buttonName,
                                                     sellButtonPosition: trackingInfo.sellButtonPosition,
                                                     negotiable: trackingInfo.negotiablePrice,
                                                     pictureSource: trackingInfo.imageSource,
                                                     videoLength: trackingInfo.videoLength,
                                                     freePostingModeAllowed: featureFlags.freePostingModeAllowed,
                                                     typePage: trackingInfo.typePage,
                                                     mostSearchedButton: trackingInfo.mostSearchedButton,
                                                     machineLearningTrackingInfo: trackingInfo.machineLearningInfo)
        tracker.trackEvent(event)
    }
}
