
import Foundation
import LGCoreKit
import LGComponents
import RxSwift
import RxCocoa

private enum MultiListingPostedViewSection: Int {
    case congrats, listings, postIncentivisor
}

enum MultiListingPostedViewItem {
    case congrats(title: String?, subtitle: String?, actionText: String?)
    case listingItem(Listing)
    case postIncentivisor(wasFreePosting: Bool)
}

enum MultiListingPostedHeaderItem {
    case header(title: String, textAlignment: NSTextAlignment)
}

final class MultiListingPostedViewModel: BaseViewModel {

    private struct Layout {
        static let congratsItemHeight: CGFloat = 220.0
        static let listingItemHeight: CGFloat = 95.0
        static let postIncentivisorHeight: CGFloat = 300.0
    }
    
    private let statusVariable: Variable<MultiListingPostedStatus>
    private let isLoadingVariable: Variable<Bool> = Variable<Bool>(false)
    
    var statusDriver: Driver<MultiListingPostedStatus> {
        return statusVariable.asDriver()
    }
    
    var isLoadingDriver: Driver<Bool> {
        return isLoadingVariable.asDriver()
    }
    
    private var status: MultiListingPostedStatus {
        didSet {
            statusVariable.value = status
        }
    }
    private let trackingInfo: PostListingTrackingInfo
    private let tracker: Tracker
    private let featureFlags: FeatureFlaggeable
    private let keyValueStorage: KeyValueStorage
    private var listings: [Listing] {
        return status.listings
    }
    
    private var isFreePosting: Bool {
        switch self.status {
        case let .posting(_, _, params):
            return params.first?.price.isFree ?? false
        case let .success(listings):
            return listings.first?.price.isFree ?? false
        case .error:
            return false
        }
    }
    
    weak var navigator: MultiListingPostedNavigator?
    
    
    // MARK:- Lifecycle
    
    convenience init(navigator: MultiListingPostedNavigator,
                     postParams: [ListingCreationParams],
                     listingImages: [UIImage]?,
                     video: RecordedVideo?,
                     trackingInfo: PostListingTrackingInfo) {
        self.init(navigator: navigator,
                  status: MultiListingPostedStatus(images: listingImages, video: video, params: postParams),
                  trackingInfo: trackingInfo)
    }
    
    convenience init(navigator: MultiListingPostedNavigator,
                     listingsResult: ListingsResult,
                     trackingInfo: PostListingTrackingInfo) {
        self.init(navigator: navigator,
                  status: MultiListingPostedStatus(listingsResult: listingsResult),
                  trackingInfo: trackingInfo)
    }
    
    convenience init(navigator: MultiListingPostedNavigator,
                     status: MultiListingPostedStatus,
                     trackingInfo: PostListingTrackingInfo) {
        self.init(navigator: navigator,
                  status: status,
                  trackingInfo: trackingInfo,
                  tracker: TrackerProxy.sharedInstance,
                  featureFlags: FeatureFlags.sharedInstance,
                  keyValueStorage: KeyValueStorage.sharedInstance)
    }
    
    init(navigator: MultiListingPostedNavigator,
         status: MultiListingPostedStatus,
         trackingInfo: PostListingTrackingInfo,
         tracker: Tracker,
         featureFlags: FeatureFlaggeable,
         keyValueStorage: KeyValueStorage) {
        self.navigator = navigator
        self.status = status
        self.trackingInfo = trackingInfo
        self.tracker = tracker
        self.featureFlags = featureFlags
        self.keyValueStorage = keyValueStorage
        self.statusVariable = Variable(status)
        super.init()
    }
    
    override func didBecomeActive(_ isFirstTime: Bool) {
        super.didBecomeActive(isFirstTime)
        
        if isFirstTime {
            switch status {
            case let .posting(images, video, params): break
            // FIXME: Implement once Posting flow is merged with Congrats UI
            case .success, .error:
                trackProductUploadResultScreen()
            }
        }
    }
}


// MARK:- Public actions

extension MultiListingPostedViewModel {
    
    @objc func closeButtonTapped() {
        var listings: [Listing] = []
        switch status {
        case let .success(postedListings):
            // FIXME: Implement in ABIOS-4319
            // tracker.trackEvent(TrackerEvent.listingSellConfirmationClose(listingPosted))
            listings = postedListings
        case .posting:
            break
        case let .error(error):
            tracker.trackEvent(TrackerEvent.listingSellErrorClose(error))
        }
        
        guard listings.count > 0 else {
            navigator?.cancelListingPosted()
            return
        }
        
        navigator?.closeListingsPosted(listings)
    }
    
    func itemTapped(atIndex index: IndexPath) {
        guard let item = viewItem(forIndex: index) else {
            return
        }
        switch item {
        case .listingItem(let listing):
            editListing(listing: listing)
        case .congrats:
            postAnotherListingTapped()
        case .postIncentivisor:
            postIncentivisorTapped()
        }
    }
}


// MARK:- Private actions

extension MultiListingPostedViewModel {
    
    private func editListing(listing: Listing) {
        tracker.trackEvent(TrackerEvent.listingSellConfirmationEdit(listing))
        navigator?.closeListingPostedAndOpenEdit(listing)
    }
    
    private func postAnotherListingTapped() {
        switch status {
        case .posting:
            break
        case let .success(listings):
            break
            // FIXME: Implement in ABIOS-4319
//            tracker.trackEvent(TrackerEvent.listingSellConfirmationPost(listings, buttonType: .button))
        case let .error(error):
            tracker.trackEvent(TrackerEvent.listingSellErrorPost(error))
        }
        navigator?.closeProductPostedAndOpenPost()
    }
    
    private func postIncentivisorTapped() {
        // FIXME: Implement in ABIOS-4319
//        guard let listing = status.listing else { return }
//        tracker.trackEvent(TrackerEvent.listingSellConfirmationPost(listing, buttonType: .itemPicture))
        navigator?.closeProductPostedAndOpenPost()
    }
    
    private func updateStatusAfterPosting(status: MultiListingPostedStatus) {
        self.status = status
        trackProductUploadResultScreen()
    }
}


// MARK: Data source interactors

extension MultiListingPostedViewModel {
    
    func viewItem(forIndex index: IndexPath) -> MultiListingPostedViewItem? {
        guard let section = MultiListingPostedViewSection(rawValue: index.section) else {
            return nil
        }
        
        switch section {
        case .congrats:
            return .congrats(title: congratsItemMainText(),
                             subtitle: congratsItemSubtitleText(),
                             actionText: congratsItemActionButtonText())
        case .listings:
            guard let listingModel = listings[safeAt: index.row] else {
                return nil
            }
            return .listingItem(listingModel)
        case .postIncentivisor:
            return .postIncentivisor(wasFreePosting: isFreePosting)
        }
    }
    
    
    func headerItem(forSection section: Int) -> MultiListingPostedHeaderItem? {
        guard let section = MultiListingPostedViewSection(rawValue: section) else {
            return nil
        }
        
        switch section {
        case .congrats, .postIncentivisor:
            return nil
        case .listings:
            return .header(title: R.Strings.postDetailsServicesCongratulationReview,
                           textAlignment: NSTextAlignment.left)
        }
    }
    
    func numberOfItems(inSection section: Int) -> Int {
        guard let section = MultiListingPostedViewSection(rawValue: section) else {
            return 0
        }
        switch section {
        case .congrats, .postIncentivisor:
            return 1
        case .listings:
            return listings.count
        }
    }
    
    func numberOfSections() -> Int {
        return 3
    }
    
    func sizeForItem(atIndex index: IndexPath,
                     inCollectionView collectionView: UICollectionView) -> CGSize {
        let height = heightForItem(inSection: index.section)
        return CGSize(width: collectionView.frame.size.width,
                      height: height)
    }
    
    func sizeForHeader(inSection section: Int,
                       inCollectionView collectionView: UICollectionView) -> CGSize {
        guard let headerItem = headerItem(forSection: section) else {
            return CGSize.zero
        }
        
        switch headerItem {
        case .header(let text, _):
            let constraintRect = CGSize(width: collectionView.frame.size.width,
                                        height: CGFloat.greatestFiniteMagnitude)
            
            let boundingBox = text.boundingRect(with: constraintRect,
                                                options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                attributes: [.font: UIFont.mediumBodyFont],
                                                context: nil)
            
            return CGSize(width: collectionView.frame.size.width,
                          height: boundingBox.height)
        }
    }
    
    private func heightForItem(inSection section: Int) -> CGFloat {
        guard let section = MultiListingPostedViewSection(rawValue: section) else {
            return 0
        }
        
        switch section {
        case .congrats:
            return Layout.congratsItemHeight
        case .listings:
            return Layout.listingItemHeight
        case .postIncentivisor:
            return Layout.postIncentivisorHeight
        }
    }
}


// MARK:- Status dependant functions

extension MultiListingPostedViewModel {
    
    private func congratsItemMainText() -> String? {
        switch status {
        case .posting:
            return nil
        case .success:
            return R.Strings.postDetailsServicesCongratulationTitle
        case .error:
            return R.Strings.commonErrorTitle.localizedCapitalized
        }
    }
    
    private func congratsItemSubtitleText() -> String? {
        switch status {
        case .posting:
            return nil
        case .success:
            return R.Strings.postDetailsServicesCongratulationSubtitle
        case let .error(error):
            switch error {
            case .forbidden(cause: .differentCountry):
                return R.Strings.productPostDifferentCountryError
            case .network:
                return R.Strings.productPostNetworkError
            default:
                return R.Strings.productPostGenericError
            }
        }
    }
    
    private func congratsItemActionButtonText() -> String? {
        switch status {
        case .posting:
            return nil
        case .success:
            return R.Strings.postDetailsServicesCongratulationPostAnother
        case .error:
            return R.Strings.productPostRetryButton
        }
    }
}


// MARK:- Tracking

extension MultiListingPostedViewModel {
    
    private func trackPostSellComplete(postedListing: Listing) {
        let buttonName = trackingInfo.buttonName
        let negotiable = trackingInfo.negotiablePrice
        let pictureSource = trackingInfo.imageSource
        let videoLength = trackingInfo.videoLength
        let typePage = trackingInfo.typePage
        let mostSearchedButton = trackingInfo.mostSearchedButton
        let event = TrackerEvent.listingSellComplete(postedListing,
                                                     buttonName: buttonName,
                                                     sellButtonPosition: trackingInfo.sellButtonPosition,
                                                     negotiable: negotiable, pictureSource: pictureSource,
                                                     videoLength: videoLength,
                                                     freePostingModeAllowed: featureFlags.freePostingModeAllowed,
                                                     typePage: typePage,
                                                     mostSearchedButton: mostSearchedButton,
                                                     machineLearningTrackingInfo: trackingInfo.machineLearningInfo)
        tracker.trackEvent(event)
        
        // Track product was sold in the first 24h (and not tracked before)
        if let firstOpenDate = keyValueStorage[.firstRunDate], NSDate().timeIntervalSince(firstOpenDate as Date) <= 86400 &&
            !keyValueStorage.userTrackingProductSellComplete24hTracked {
            keyValueStorage.userTrackingProductSellComplete24hTracked = true
            let event = TrackerEvent.listingSellComplete24h(postedListing)
            tracker.trackEvent(event)
        }
    }
    
    private func trackPostSellError(error: RepositoryError) {
        let sellError = EventParameterPostListingError(error: error)
        let sellErrorDataEvent = TrackerEvent.listingSellErrorData(sellError)
        tracker.trackEvent(sellErrorDataEvent)
    }
    
    private func trackProductUploadResultScreen() {
        // FIXME: Implement in ABIOS-4319
        /*
        switch status {
        case .posting:
            break
        case let .success(listing): break
            tracker.trackEvent(TrackerEvent.listingSellConfirmation(listing))
        case let .error(error):
            tracker.trackEvent(TrackerEvent.listingSellError(error))
        }
 */
    }
}

