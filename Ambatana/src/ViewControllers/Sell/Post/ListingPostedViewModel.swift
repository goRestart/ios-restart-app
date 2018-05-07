//
//  ListingPostedViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 14/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift


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
            return wasFreePosting ? LGLocalizedString.productPostFreeConfirmationAnotherButton : LGLocalizedString.productPostConfirmationAnotherListingButton
        case .error:
            return LGLocalizedString.productPostRetryButton
        }
    }
    
    var mainButtonHidden: Bool {
        switch status {
        case .posting:
            return false
        case .success:
            return false
        case let .error(error):
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
            return LGLocalizedString.productPostIncentiveTitle
        case .error:
            return LGLocalizedString.commonErrorTitle.localizedCapitalized
        }
    }

    var secondaryText: String? {
        switch status {
        case .posting:
            return nil
        case .success:
            return wasFreePosting ? LGLocalizedString.productPostIncentiveSubtitleFree : LGLocalizedString.productPostIncentiveSubtitle
        case let .error(error):
            switch error {
            case .forbidden(cause: .differentCountry):
                return LGLocalizedString.productPostDifferentCountryError
            case .network:
                return LGLocalizedString.productPostNetworkError
            default:
                return LGLocalizedString.productPostGenericError
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
        case let .error(error):
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
        case let .error(error):
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

        let shouldUseCarEndpoint = featureFlags.createUpdateIntoNewBackend.shouldUseCarEndpoint(with: params)
        let createAction = listingRepository.createAction(shouldUseCarEndpoint)

        if let images = images {
            fileRepository.upload(images, progress: nil) { [weak self] result in
                if let images = result.value {
                    let updatedParams = params.updating(images: images)

                    createAction(updatedParams) { [weak self] result in
                        if let postedListing = result.value {
                            self?.trackPostSellComplete(postedListing: postedListing)
                        } else if let error = result.error {
                            self?.trackPostSellError(error: error)
                        }
                        self?.updateStatusAfterPosting(status: ListingPostedStatus(listingResult: result))
                    }
                } else if let error = result.error {
                    self?.trackPostSellError(error: error)
                    self?.updateStatusAfterPosting(status: ListingPostedStatus(error: error))
                }
            }
        } else if let video = video {

            fileRepository.upload([video.snapshot], progress: nil) { [weak self] result in
                if let image = result.value?.first {
                    guard let snapshot = image.objectId else {
                        let error = RepositoryError.internalError(message: "Missing uploaded image identifier")
                        self?.trackPostSellError(error: error)
                        self?.updateStatusAfterPosting(status: ListingPostedStatus(error: error))
                        return
                    }

                    self?.preSignedUploadUrlRepository.create(fileExtension: Constants.videoFileExtension, completion: { [weak self] result in

                        if let preSignedUploadUrl = result.value {
                            guard let path = preSignedUploadUrl.form.fileKey else {
                                let error = RepositoryError.internalError(message: "Missing video file id")
                                self?.trackPostSellError(error: error)
                                self?.updateStatusAfterPosting(status: ListingPostedStatus(error: error))
                                return
                            }

                            self?.preSignedUploadUrlRepository.upload(url: preSignedUploadUrl.form.action,
                                                                      file: video.url,
                                                                      inputs: preSignedUploadUrl.form.inputs,
                                                                      progress: nil) { [weak self] result in
                                    if result.value != nil {

                                        let video: Video = LGVideo(path: path , snapshot: snapshot)
                                        let updatedParams = params.updating(videos: [video])

                                        createAction(updatedParams) { [weak self] result in
                                            if let postedListing = result.value {
                                                self?.trackPostSellComplete(postedListing: postedListing)
                                            } else if let error = result.error {
                                                self?.trackPostSellError(error: error)
                                            }
                                            self?.updateStatusAfterPosting(status: ListingPostedStatus(listingResult: result))
                                        }
                                    } else if let error = result.error {
                                        self?.trackPostSellError(error: error)
                                        self?.updateStatusAfterPosting(status: ListingPostedStatus(error: error))
                                    }
                            }
                        } else if let error = result.error {
                            self?.trackPostSellError(error: error)
                            self?.updateStatusAfterPosting(status: ListingPostedStatus(error: error))
                        }
                    })
                    
                } else if let error = result.error {
                    self?.trackPostSellError(error: error)
                    self?.updateStatusAfterPosting(status: ListingPostedStatus(error: error))
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
        let sellError: EventParameterPostListingError
        switch error {
        case .network:
            sellError = .network
        case .serverError, .notFound, .forbidden, .unauthorized, .tooManyRequests, .userNotVerified:
            sellError = .serverError(code: error.errorCode)
        case .internalError, .wsChatError, .searchAlertError:
            sellError = .internalError
        }
        let sellErrorDataEvent = TrackerEvent.listingSellErrorData(sellError)
        tracker.trackEvent(sellErrorDataEvent)
    }

    private func trackProductUploadResultScreen() {
        switch status {
        case .posting:
            break
        case let .success(listing):
            tracker.trackEvent(TrackerEvent.listingSellConfirmation(listing))
        case let .error(error):
            tracker.trackEvent(TrackerEvent.listingSellError(error))
        }
    }
}


// MARK: - ListingPostedStatus

enum ListingPostedStatus {
    case posting(images: [UIImage]?, video: RecordedVideo?, params: ListingCreationParams)
    case success(listing: Listing)
    case error(error: EventParameterPostListingError)

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
            switch error {
            case .network:
                self = .error(error: .network)
            case let .forbidden(cause: cause):
                self = .error(error: .forbidden(cause: cause))
            default:
                self = .error(error: .internalError)
            }
        } else {
            self = .error(error: .internalError)
        }
    }

    init(error: RepositoryError) {
        switch error {
        case .network:
            self = .error(error: .network)
        default:
            self = .error(error: .internalError)
        }
    }
}
