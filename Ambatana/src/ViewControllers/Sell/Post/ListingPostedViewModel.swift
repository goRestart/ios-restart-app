import LGCoreKit
import RxSwift
import LGComponents

// MARK: - ListingPostedViewModelDelegate

protocol ListingPostedViewModelDelegate: class {
    func productPostedViewModelSetupLoadingState(_ viewModel: ListingPostedViewModel)
    func productPostedViewModel(_ viewModel: ListingPostedViewModel, finishedLoadingState correct: Bool)
    func productPostedViewModel(_ viewModel: ListingPostedViewModel, setupStaticState correct: Bool)
    func listingPostedViewModelShareNative()
}


// MARK: - ListingPostedViewModel

class ListingPostedViewModel: BaseViewModel {
    weak var navigator: ListingPostedNavigator?
    weak var delegate: ListingPostedViewModelDelegate?

    private var status: ListingPostedStatus
    private let trackingInfo: PostListingTrackingInfo
    private let featureFlags: FeatureFlaggeable
    private let keyValueStorage: KeyValueStorage
    private let tracker: Tracker
    private let listingRepository: ListingRepository
    private let fileRepository: FileRepository
    private let preSignedUploadUrlRepository: PreSignedUploadUrlRepository
    private let myUserRepository: MyUserRepository

    var wasFreePosting: Bool {
        switch self.status {
        case let .posting(_, _, params):
            return params.price.isFree
        case let .success(listing):
            return listing.price.isFree
        case .error:
            return false
        }
    }
    
    private var myUserId: String? {
        return myUserRepository.myUser?.objectId
    }

    private var myUserName: String? {
        return myUserRepository.myUser?.name
    }
    
    
    // MARK: - Lifecycle

    convenience init(listingResult: ListingResult, trackingInfo: PostListingTrackingInfo) {
        self.init(status: ListingPostedStatus(listingResult: listingResult),
                  trackingInfo: trackingInfo)
    }

    convenience init(postParams: ListingCreationParams, listingImages: [UIImage]?, video: RecordedVideo?, trackingInfo: PostListingTrackingInfo) {
        self.init(status: ListingPostedStatus(images: listingImages, video: video, params: postParams),
                  trackingInfo: trackingInfo)
    }

    convenience init(status: ListingPostedStatus, trackingInfo: PostListingTrackingInfo) {
        self.init(status: status,
                  trackingInfo: trackingInfo,
                  listingRepository: Core.listingRepository,
                  fileRepository: Core.fileRepository,
                  preSignedUploadUrlRepository: Core.preSignedUploadUrlRepository,
                  myUserRepository: Core.myUserRepository,
                  featureFlags: FeatureFlags.sharedInstance,
                  keyValueStorage: KeyValueStorage.sharedInstance,
                  tracker: TrackerProxy.sharedInstance)
    }

    init(status: ListingPostedStatus,
         trackingInfo: PostListingTrackingInfo,
         listingRepository: ListingRepository,
         fileRepository: FileRepository,
         preSignedUploadUrlRepository: PreSignedUploadUrlRepository,
         myUserRepository: MyUserRepository,
         featureFlags: FeatureFlaggeable,
         keyValueStorage: KeyValueStorage,
         tracker: Tracker) {
        self.status = status
        self.trackingInfo = trackingInfo
        self.featureFlags = featureFlags
        self.keyValueStorage = keyValueStorage
        self.tracker = tracker
        self.listingRepository = listingRepository
        self.fileRepository = fileRepository
        self.preSignedUploadUrlRepository = preSignedUploadUrlRepository
        self.myUserRepository = myUserRepository
    }

    override func didBecomeActive(_ firstTime: Bool) {
        if firstTime {
            switch status {
            case let .posting(images, video, params):
                postListing(images, video: video, params: params)
            case .success:
                delegate?.productPostedViewModel(self, setupStaticState: true)
                trackProductUploadResultScreen()
            case .error:
                delegate?.productPostedViewModel(self, setupStaticState: false)
                trackProductUploadResultScreen()
            }
        }
    }


    // MARK: - Public

    var mainButtonText: String? {
        switch status {
        case .posting:
            return nil
        case .success:
            return wasFreePosting ? R.Strings.productPostFreeConfirmationAnotherButton : R.Strings.productPostConfirmationAnotherListingButton
        case .error:
            return R.Strings.productPostRetryButton
        }
    }
    
    var mainButtonHidden: Bool {
        switch status {
        case .posting:
            return false
        case .success:
            return false
        case let .error(error, _):
            switch error {
            case .forbidden(cause: .differentCountry):
                return true
            default:
                return false
            }
        }
    }

    var mainText: String? {
        switch status {
        case .posting:
            return nil
        case .success:
            return R.Strings.productPostIncentiveTitle
        case .error:
            return R.Strings.commonErrorTitle.localizedCapitalized
        }
    }

    var secondaryText: String? {
        switch status {
        case .posting:
            return nil
        case .success:
            return wasFreePosting ? R.Strings.productPostIncentiveSubtitleFree : R.Strings.productPostIncentiveSubtitle
        case let .error(error, _):
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

    var socialMessage: SocialMessage? {
        switch status {
        case .posting, .error:
            return nil
        case let .success(listing):
            return ListingSocialMessage(listing: listing,
                                        fallbackToStore: false,
                                        myUserId: myUserId,
                                        myUserName: myUserName)
        }
    }
    

    // MARK: > Actions

    func closeActionPressed() {
        var listing: Listing? = nil
        switch status {
        case let .success(listingPosted):
            tracker.trackEvent(TrackerEvent.listingSellConfirmationClose(listingPosted))
            listing = listingPosted
        case .posting:
            break
        case let .error(error, _):
            tracker.trackEvent(TrackerEvent.listingSellErrorClose(error))
        }
        
        guard let listingValue = listing else {
            navigator?.cancelListingPosted()
            return
        }
        
        navigator?.closeListingPosted(listingValue)
    }
    
    func shareActionPressed() {
        delegate?.listingPostedViewModelShareNative()
    }

    func editActionPressed() {
        guard let listing = status.listing else { return }

        tracker.trackEvent(TrackerEvent.listingSellConfirmationEdit(listing))
        navigator?.closeListingPostedAndOpenEdit(listing)
    }

    func mainActionPressed() {
        switch status {
        case .posting:
            break
        case let .success(listing):
            tracker.trackEvent(TrackerEvent.listingSellConfirmationPost(listing, buttonType: .button))
        case let .error(error, _):
            tracker.trackEvent(TrackerEvent.listingSellErrorPost(error))
        }

        navigator?.closeProductPostedAndOpenPost()
    }

    func incentivateSectionPressed() {
        guard let listing = status.listing else { return }
        tracker.trackEvent(TrackerEvent.listingSellConfirmationPost(listing, buttonType: .itemPicture))
        navigator?.closeProductPostedAndOpenPost()
    }

    func shareStartedIn(_ shareType: ShareType) {
        guard let listing = status.listing else { return }
        tracker.trackEvent(TrackerEvent.listingSellConfirmationShare(listing, network: shareType.trackingShareNetwork))
    }

    func shareFinishedIn(_ shareType: ShareType, withState state: SocialShareState) {
        guard let listing = status.listing else { return }

        switch state {
        case .completed:
            tracker.trackEvent(TrackerEvent.listingSellConfirmationShareComplete(listing, network: shareType.trackingShareNetwork))
        case .cancelled:
            tracker.trackEvent(TrackerEvent.listingSellConfirmationShareCancel(listing, network: shareType.trackingShareNetwork))
        case .failed:
            break;
        }
    }
    

    // MARK: - Private methods
    
    private func postListing(_ images: [UIImage]?, video: RecordedVideo?, params: ListingCreationParams) {
        delegate?.productPostedViewModelSetupLoadingState(self)
        
        if let images = images {
            fileRepository.upload(images, progress: nil) { [weak self] result in
                if let images = result.value {
                    let updatedParams = params.updating(images: images)
                    
                    self?.listingRepository.create(listingParams: updatedParams) { [weak self] result in
                        if let postedListing = result.value {
                            self?.trackPostSellComplete(postedListing: postedListing)
                        } else if let error = result.error {
                            self?.trackPostSellError(error: error)
                        }
                        self?.updateStatusAfterPosting(status: ListingPostedStatus(listingResult: result))
                    }
                } else if let error = result.error {
                    self?.trackPostSellError(error: error)
                    self?.updateStatusAfterPosting(status: ListingPostedStatus(error: error, categoryId: params.category.rawValue))
                }
            }
        } else if let video = video {

            fileRepository.upload([video.snapshot], progress: nil) { [weak self] result in
                if let image = result.value?.first {
                    guard let snapshot = image.objectId else {
                        let error = RepositoryError.internalError(message: "Missing uploaded image identifier")
                        self?.trackPostSellError(error: error)
                        self?.updateStatusAfterPosting(status: ListingPostedStatus(error: error, categoryId: params.category.rawValue))
                        return
                    }

                    self?.preSignedUploadUrlRepository.create(fileExtension: SharedConstants.videoFileExtension, completion: { [weak self] result in

                        if let preSignedUploadUrl = result.value {
                            guard let path = preSignedUploadUrl.form.fileKey else {
                                let error = RepositoryError.internalError(message: "Missing video file id")
                                self?.trackPostSellError(error: error)
                                self?.updateStatusAfterPosting(status: ListingPostedStatus(error: error, categoryId: params.category.rawValue))
                                return
                            }

                            self?.preSignedUploadUrlRepository.upload(url: preSignedUploadUrl.form.action,
                                                                      file: video.url,
                                                                      inputs: preSignedUploadUrl.form.inputs,
                                                                      progress: nil) { [weak self] result in
                                    if result.value != nil {

                                        let video: Video = LGVideo(path: path , snapshot: snapshot)
                                        let updatedParams = params.updating(videos: [video])

                                        self?.listingRepository.create(listingParams: updatedParams) { [weak self] result in
                                            if let postedListing = result.value {
                                                self?.trackPostSellComplete(postedListing: postedListing)
                                            } else if let error = result.error {
                                                self?.trackPostSellError(error: error)
                                            }
                                            self?.updateStatusAfterPosting(status: ListingPostedStatus(listingResult: result))
                                        }
                                    } else if let error = result.error {
                                        self?.trackPostSellError(error: error)
                                        self?.updateStatusAfterPosting(status: ListingPostedStatus(error: error, categoryId: params.category.rawValue))
                                    }
                            }
                        } else if let error = result.error {
                            self?.trackPostSellError(error: error)
                            self?.updateStatusAfterPosting(status: ListingPostedStatus(error: error, categoryId: params.category.rawValue))
                        }
                    })
                    
                } else if let error = result.error {
                    self?.trackPostSellError(error: error)
                    self?.updateStatusAfterPosting(status: ListingPostedStatus(error: error, categoryId: params.category.rawValue))
                }
            }
        }
    }
    
    private func updateStatusAfterPosting(status: ListingPostedStatus) {
        self.status = status
        trackProductUploadResultScreen()
        delegate?.productPostedViewModel(self, finishedLoadingState: status.success)
    }

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
        switch status {
        case .posting:
            break
        case let .success(listing):
            tracker.trackEvent(TrackerEvent.listingSellConfirmation(listing))
        case let .error(error, categoryId):
            tracker.trackEvent(TrackerEvent.listingSellError(error, withCategoryId: categoryId))
        }
    }
}


// MARK: - ListingPostedStatus

enum ListingPostedStatus {
    case posting(images: [UIImage]?, video: RecordedVideo?, params: ListingCreationParams)
    case success(listing: Listing)
    case error(error: EventParameterPostListingError, categoryId: Int?)

    var listing: Listing? {
        switch self {
        case .posting, .error:
            return nil
        case let .success(listing):
            return listing
        }
    }

    var success: Bool {
        switch self {
        case .success:
            return true
        case .posting, .error:
            return false
        }
    }

    init(images: [UIImage]?, video: RecordedVideo?, params: ListingCreationParams) {
        self = .posting(images: images, video: video, params: params)
    }

    init(listingResult: ListingResult) {
        if let listing = listingResult.value {
            self = .success(listing: listing)
        } else if let error = listingResult.error {
            self = .error(error: EventParameterPostListingError(error: error), categoryId: nil)
        } else {
            self = .error(error: .internalError(description: nil), categoryId: nil)
        }
    }

    init(error: RepositoryError, categoryId: Int?) {
        let eventParameterPostListingError = EventParameterPostListingError(error: error)
        self = .error(error: eventParameterPostListingError, categoryId: categoryId)
    }
}

extension EventParameterPostListingError {
    init(error: RepositoryError) {
        switch error {
        case .network(_, _, _):
            self = .network
        case .serverError(let code):
            self = .serverError(code: code)
        case .wsChatError(let error): // we need to contemplate this case because everything is a RError
            self = .internalError(description: "chat-\(error)")
        case .searchAlertError(let error):
            self = .internalError(description: "search-alerts-\(error)")
        case .forbidden(let cause):
            self = .forbidden(cause: cause)
        case .notFound:
            self = .internalError(description: "not-found")
        case .tooManyRequests:
            self = .internalError(description: "too-many-requests")
        case .userNotVerified:
            self = .internalError(description: "user-not-verified")
        case .unauthorized(_, let description):
            self = .internalError(description: description)
        case .internalError(_):
            self = .internalError(description: nil)
        }
    }
}
