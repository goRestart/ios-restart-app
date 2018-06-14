
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
    
    var statusDriver: Driver<MultiListingPostedStatus> {
        return statusVariable.asDriver()
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
    
    private let listingRepository: ListingRepository
    private let fileRepository: FileRepository
    private let imageMultiplierRepository: ImageMultiplierRepository
    
    private var listings: [Listing] {
        return status.listings
    }
    
    private var isFreePosting: Bool {
        switch self.status {
        case .servicesPosting(let params):
            return params.first?.price.isFree ?? false
        case let .success(listings):
            return listings.first?.price.isFree ?? false
        case .servicesImageUpload, .error:
            return false
        }
    }
    
    weak var navigator: MultiListingPostedNavigator?
    
    
    // MARK:- Lifecycle
    
    convenience init(navigator: MultiListingPostedNavigator,
                     postParams: [ListingCreationParams],
                     images: [UIImage]?,
                     trackingInfo: PostListingTrackingInfo) {
        self.init(navigator: navigator,
                  status: MultiListingPostedStatus(params: postParams, images: images),
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
                  keyValueStorage: KeyValueStorage.sharedInstance,
                  listingRepository: Core.listingRepository,
                  fileRepository: Core.fileRepository,
                  imageMultiplierRepository: Core.imageMultiplierRepository)
    }
    
    init(navigator: MultiListingPostedNavigator,
         status: MultiListingPostedStatus,
         trackingInfo: PostListingTrackingInfo,
         tracker: Tracker,
         featureFlags: FeatureFlaggeable,
         keyValueStorage: KeyValueStorage,
         listingRepository: ListingRepository,
         fileRepository: FileRepository,
         imageMultiplierRepository: ImageMultiplierRepository) {
        self.navigator = navigator
        self.status = status
        self.trackingInfo = trackingInfo
        self.tracker = tracker
        self.featureFlags = featureFlags
        self.keyValueStorage = keyValueStorage
        
        self.listingRepository = listingRepository
        self.fileRepository = fileRepository
        self.imageMultiplierRepository = imageMultiplierRepository
        
        self.statusVariable = Variable(status)
        super.init()
    }
    
    func viewDidLoad() {
        switch status {
        case let .servicesPosting(params):
            postListings(withParams: params, trackingInfo: trackingInfo)
        case let .servicesImageUpload(params, images):
            uploadImagesAndPost(params: params, images: images, trackingInfo: trackingInfo)
        case .success, .error:
            track(status: status)
        }
    }
}


// MARK:- Public actions

extension MultiListingPostedViewModel {
    
    func listingEdited(listing: Listing) {
        guard let indexToUpdate = indexMatchingListing(listing: listing) else {
            return
        }
        
        var newListings = self.listings
        newListings.remove(at: indexToUpdate)
        newListings.insert(listing, at: indexToUpdate)
        updateStatus(to: MultiListingPostedStatus.success(listings: newListings))
    }

    @objc func closeButtonTapped() {
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


// MARK:- Posting
extension MultiListingPostedViewModel {
    
    private func uploadImagesAndPost(params: [ListingCreationParams],
                                     images: [UIImage],
                                     trackingInfo: PostListingTrackingInfo) {
        // Upload the images
        fileRepository.upload(images, progress: nil) { [weak self] (result) in
            guard let imageId = result.value?.first?.objectId else {
                if let error = result.error {
                    let statusError = MultiListingPostedStatus(error: error)
                    self?.updateStatus(to: statusError)
                    self?.track(status: statusError)
                }
                return
            }
            
            // Get the multiplied image ids from the endpoint
            self?.fetchImagesIds(forUploadedImageId: imageId, count: params.count) { [weak self] (multImageIds) in
                // Update the params with the retireved image Ids
                guard let newParams = self?.updatedParams(params: params, forImageIds: multImageIds) else {
                    self?.showImageMultiplierError()
                    return
                }
                self?.updateStatus(to: MultiListingPostedStatus.servicesPosting(params: newParams))
                self?.postListings(withParams: newParams, trackingInfo: trackingInfo)
            }
        }
    }
    
    private func updatedParams(params: [ListingCreationParams],
                               forImageIds imageIds: [String]) -> [ListingCreationParams] {
        var newParams: [ListingCreationParams] = []
        for (index, item) in params.enumerated().makeIterator() {
            let imageFile = LGFile(id: imageIds[safeAt: index], url: nil)
            let newItem = item.updating(images: [imageFile])
            newParams.append(newItem)
        }
        return newParams
    }
    
    private func showImageMultiplierError() {
        let errorStatus = MultiListingPostedStatus(error: RepositoryError.internalError(message: "Images Multiplier Error"))
        updateStatus(to: errorStatus)
        track(status: errorStatus)
    }
    
    private func showPostingMultiplierError() {
        let errorStatus = MultiListingPostedStatus(error: RepositoryError.internalError(message: "Multipost params creation"))
        updateStatus(to: errorStatus)
        track(status: errorStatus)
    }
    
    private func fetchImagesIds(forUploadedImageId imageUploadedId: String,
                                count: Int,
                                completion: (([String]) -> Void)?) {
        guard count > 0 else { return showPostingMultiplierError() }
        let imageMultiplierParams = ImageMultiplierParams(imageId: imageUploadedId,
                                                          times: count)
        imageMultiplierRepository.imageMultiplier(imageMultiplierParams) { [weak self] result in
            guard let imagesIds = result.value, !imagesIds.isEmpty else {
                self?.showImageMultiplierError()
                completion?([])
                return
            }
            
            completion?(imagesIds)
        }
    }
    

    private func postListings(withParams params: [ListingCreationParams], trackingInfo: PostListingTrackingInfo) {
        guard params.count > 0 else {
            showPostingMultiplierError()
            return
        }
        
        listingRepository.createServices(listingParams: params) { [weak self] results in
            if let listings = results.value {
                let postedStatus = MultiListingPostedStatus.success(listings: listings)
                self?.trackPostSellComplete(withListings: listings, trackingInfo: trackingInfo)
                self?.updateStatus(to: postedStatus)
                self?.track(status: postedStatus)
            } else if let error = results.error {
                self?.showPostingMultiplierError()
                self?.trackPostSellError(error: error)
            }
        }
    }
}


// MARK:- Private actions

extension MultiListingPostedViewModel {

    private func indexMatchingListing(listing: Listing) -> Int? {
        return listings.enumerated().first(where: { $1.objectId == listing.objectId})?.offset
    }
    
    private func editListing(listing: Listing) {
        trackEditStart(for: listing)
        navigator?.openEdit(forListing: listing)
    }
    
    private func postAnotherListingTapped() {
        switch status {
        case let .error(error):
            tracker.trackEvent(TrackerEvent.listingSellErrorPost(error))
        case .servicesPosting, .servicesImageUpload, .success:
            break
        }
        
        trackSellStart(forTrackingInfo: trackingInfo)
        navigator?.closeProductPostedAndOpenPost()
    }
    
    private func postIncentivisorTapped() {
        trackSellStart(forTrackingInfo: trackingInfo)
        navigator?.closeProductPostedAndOpenPost()
    }
    
    private func updateStatus(to status: MultiListingPostedStatus) {
        self.status = status
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
            guard listings.count != 0 else {
                return nil
            }
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
            guard listings.count != 0 else {
                return nil
            }
            return .header(title: R.Strings.postDetailsServicesCongratulationReview,
                           textAlignment: NSTextAlignment.left)
        }
    }
    
    func numberOfItems(inSection section: Int) -> Int {
        guard let section = MultiListingPostedViewSection(rawValue: section) else {
            return 0
        }
        switch section {
        case .congrats:
            return 1
        case .postIncentivisor:
            return listings.count > 0 ? 1 : 0
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
        case .servicesPosting, .servicesImageUpload:
            return nil
        case .success:
            return R.Strings.postDetailsServicesCongratulationTitle
        case .error:
            return R.Strings.commonErrorTitle.localizedCapitalized
        }
    }
    
    private func congratsItemSubtitleText() -> String? {
        switch status {
        case .servicesPosting, .servicesImageUpload:
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
        case .servicesPosting, .servicesImageUpload:
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
    
    private func trackPostSellComplete(listing: Listing, trackingInfo: PostListingTrackingInfo) {
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
        
        // Track product was sold in the first 24h (and not tracked before)
        if let firstOpenDate = keyValueStorage[.firstRunDate], NSDate().timeIntervalSince(firstOpenDate as Date) <= 86400 &&
            !keyValueStorage.userTrackingProductSellComplete24hTracked {
            keyValueStorage.userTrackingProductSellComplete24hTracked = true
            let event = TrackerEvent.listingSellComplete24h(listing)
            tracker.trackEvent(event)
        }
    }
    
    private func trackPostSellComplete(withListings listing: [Listing], trackingInfo: PostListingTrackingInfo) {
        listing.forEach { trackPostSellComplete(listing: $0, trackingInfo: trackingInfo) }
    }
    
    private func trackPostSellError(error: RepositoryError) {
        let sellError = EventParameterPostListingError(error: error)
        let sellErrorDataEvent = TrackerEvent.listingSellErrorData(sellError)
        tracker.trackEvent(sellErrorDataEvent)
    }

    private func track(status: MultiListingPostedStatus) {
        switch status {
        case .servicesImageUpload, .servicesPosting:
            break
        case let .success(listings):
            trackSellConfirmation(listings: listings)
        case let .error(error):
            tracker.trackEvent(TrackerEvent.listingSellError(error))
        }
    }
    
    private func trackSellConfirmation(listings: [Listing]) {
        let listingsIds = listings.flatMap { $0.objectId }
        tracker.trackEvent(TrackerEvent.listingsSellConfirmation(listingIds: listingsIds))
    }
    
    private func trackEditStart(for listing: Listing) {
        tracker.trackEvent(TrackerEvent.listingEditStart(nil,
                                                         listing: listing,
                                                         pageType: EventParameterTypePage.sell))
    }
    
    private func trackSellStart(forTrackingInfo trackingInfo: PostListingTrackingInfo) {
        let event = TrackerEvent.listingSellStart(trackingInfo.typePage,
                                                  buttonName: trackingInfo.buttonName,
                                                  sellButtonPosition: trackingInfo.sellButtonPosition,
                                                  category: nil,
                                                  mostSearchedButton: trackingInfo.mostSearchedButton,
                                                  predictiveFlow: false)
        tracker.trackEvent(event)
    }


}

