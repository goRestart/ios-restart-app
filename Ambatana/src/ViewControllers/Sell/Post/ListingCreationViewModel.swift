import RxSwift
import LGCoreKit
import LGComponents

final class ListingCreationViewModel : BaseViewModel {
    
    typealias ListingMultiCreationCompletion = ([ListingCreationParams]) -> Void
    
    private let listingRepository: ListingRepository
    private let uploadedImageId: String
    private let multipostingSubtypes: [ServiceSubtype]
    private let multipostingNewSubtypes: [String]
    private let postListingState: PostListingState?
    private let tracker: Tracker
    private let listingParams: ListingCreationParams?
    
    private let keyValueStorage: KeyValueStorage
    private let featureFlags: FeatureFlags
    private let trackingInfo: PostListingTrackingInfo
    private var listingResult: ListingResult?
    private var listingsResult: ListingsResult?
    private let imageMultiplierRepository: ImageMultiplierRepository
    private let locationManager: LocationManager
    private let currencyHelper: CurrencyHelper
    
    weak var navigator: PostListingNavigator?
    private let disposeBag = DisposeBag()
    
    var didFinishRequest = Variable<Bool?>(false)
    
    private var numberOfSelectedServicesSubtypes: Int {
        return multipostingSubtypes.count + multipostingNewSubtypes.count
    }
    
    // MARK: - LifeCycle
    
    convenience init(listingParams: ListingCreationParams, trackingInfo: PostListingTrackingInfo) {
        self.init(listingRepository: Core.listingRepository,
                  uploadedImageId: "",
                  multipostingSubtypes: [],
                  multipostingNewSubtypes: [],
                  postListingState: nil,
                  imageMultiplierRepository: Core.imageMultiplierRepository,
                  tracker: TrackerProxy.sharedInstance,
                  keyValueStorage: KeyValueStorage.sharedInstance,
                  featureFlags: FeatureFlags.sharedInstance,
                  listingParams: listingParams,
                  trackingInfo: trackingInfo,
                  locationManager: Core.locationManager,
                  currencyHelper: Core.currencyHelper)
    }
    
    convenience init(uploadedImageId: String,
                     multipostingSubtypes: [ServiceSubtype],
                     multipostingNewSubtypes: [String],
                     postListingState: PostListingState,
                     trackingInfo: PostListingTrackingInfo) {
        self.init(listingRepository: Core.listingRepository,
                  uploadedImageId: uploadedImageId,
                  multipostingSubtypes: multipostingSubtypes,
                  multipostingNewSubtypes: multipostingNewSubtypes,
                  postListingState: postListingState,
                  imageMultiplierRepository: Core.imageMultiplierRepository,
                  tracker: TrackerProxy.sharedInstance,
                  keyValueStorage: KeyValueStorage.sharedInstance,
                  featureFlags: FeatureFlags.sharedInstance,
                  listingParams: nil,
                  trackingInfo: trackingInfo,
                  locationManager: Core.locationManager,
                  currencyHelper: Core.currencyHelper)
    }
    
    init(listingRepository: ListingRepository,
         uploadedImageId: String,
         multipostingSubtypes: [ServiceSubtype],
         multipostingNewSubtypes: [String],
         postListingState: PostListingState?,
         imageMultiplierRepository: ImageMultiplierRepository,
         tracker: Tracker,
         keyValueStorage: KeyValueStorage,
         featureFlags: FeatureFlags,
         listingParams: ListingCreationParams?,
         trackingInfo: PostListingTrackingInfo,
         locationManager: LocationManager,
         currencyHelper: CurrencyHelper) {
        self.listingRepository = listingRepository
        self.uploadedImageId = uploadedImageId
        self.multipostingSubtypes = multipostingSubtypes
        self.multipostingNewSubtypes = multipostingNewSubtypes
        self.postListingState = postListingState
        self.imageMultiplierRepository = imageMultiplierRepository
        self.tracker = tracker
        self.keyValueStorage = keyValueStorage
        self.featureFlags = featureFlags
        self.listingParams = listingParams
        self.trackingInfo = trackingInfo
        self.currencyHelper = currencyHelper
        self.locationManager = locationManager
    }
    
    func createListing() {
        if !uploadedImageId.isEmpty,
            numberOfSelectedServicesSubtypes > 0 {
            fetchImagesAndCreateListings()
        } else {
            createFirstListing()
        }
    }
    
    private func createFirstListing() {
        guard let listingParams = listingParams else {
            didFinishRequest.value = true
            return
        }
        
        listingRepository.create(listingParams: listingParams) { [weak self] result in
            if let listing = result.value, let trackingInfo = self?.trackingInfo {
                self?.trackPost(withListing: listing, trackingInfo: trackingInfo)
            } else if let error = result.error {
                self?.trackPostSellError(error: error)
            }
            self?.listingResult = result
            self?.didFinishRequest.value = true
        }
    }

    private func fetchImagesAndCreateListings() {
        fetchImagesIdsAndCreateParams(trackingInfo: trackingInfo) { [weak self] listingParams in
            guard listingParams.count > 0 else { return }
            self?.createServices(fromListingParams: listingParams)
        }
    }
    
    private func createServices(fromListingParams listingParams: [ListingCreationParams]) {
        let paramsToPost = PostingParamsImageAssigner.assign(images: postListingState?.lastImagesUploadResult?.value,
                                                             toFirstItemInParams: listingParams)
        listingRepository.createServices(listingParams: paramsToPost) { [weak self] results in

            if let listings = results.value, let trackingInfo = self?.trackingInfo {
                self?.trackPost(withListings: listings, trackingInfo: trackingInfo)
            } else if let error = results.error {
                self?.trackPostSellError(error: error)
            }
            self?.listingsResult = results
            self?.didFinishRequest.value = true
        }
    }
    
    private func fetchImagesIdsAndCreateParams(trackingInfo: PostListingTrackingInfo,
                                               completion: ListingMultiCreationCompletion?) {
        guard numberOfSelectedServicesSubtypes > 1 else {
            createParams(fromImageIds: [uploadedImageId],
                         trackingInfo: trackingInfo,
                         completion: completion)
            return
        }
        
        let imageMultiplierParams = ImageMultiplierParams(imageId: uploadedImageId,
                                                          times: numberOfSelectedServicesSubtypes)
        imageMultiplierRepository.imageMultiplier(imageMultiplierParams) { [weak self] result in
            guard let imagesIds = result.value else {
                completion?([])
                let error = result.error ?? RepositoryError.internalError(message: "Images Multiplier Error")
                self?.navigator?.showMultiListingPostConfirmation(listingResult: ListingsResult(error: error),
                                                                  trackingInfo: trackingInfo,
                                                                  modalStyle: false)
                return
            }
            
            self?.createParams(fromImageIds: imagesIds,
                               trackingInfo: trackingInfo,
                               completion: completion)
        }
    }
    
    private func createParams(fromImageIds imagesIds: [String],
                              trackingInfo: PostListingTrackingInfo,
                              completion: ListingMultiCreationCompletion?) {
        guard let postListingState = postListingState else {
            let error = RepositoryError.internalError(message: "No post listing state available, needed to create params")
            navigator?.showMultiListingPostConfirmation(listingResult: ListingsResult(error: error),
                                                        trackingInfo: trackingInfo,
                                                        modalStyle: false)
            completion?([])
            return
        }
        
        let modifiedParams = multipostParams(subtypes: multipostingSubtypes,
                                             newSubtypes: multipostingNewSubtypes,
                                             imagesIds: imagesIds,
                                             postListingState: postListingState)
        guard !modifiedParams.isEmpty else {
            let errorResult = ListingsResult(error: RepositoryError.internalError(message: "Multipost params creation failed, params were empty"))
            navigator?.showMultiListingPostConfirmation(listingResult: errorResult,
                                                        trackingInfo: trackingInfo,
                                                        modalStyle: true)
            completion?([])
            return
        }
        completion?(modifiedParams)
    }
    
    func nextStep() {
        if let result = listingResult {
            navigator?.showConfirmation(listingResult: result,
                                        trackingInfo: trackingInfo,
                                        shareAfterPost: postListingState?.shareAfterPost,
                                        modalStyle: false)
        } else if let results = listingsResult {
            navigator?.showMultiListingPostConfirmation(listingResult: results, trackingInfo: trackingInfo, modalStyle: false)
        } else {
            navigator?.cancelPostListing() // It should never happen
            return
        }
    }
    
    private func trackPost(withListing listing: Listing, trackingInfo: PostListingTrackingInfo) {
        let event = TrackerEvent.listingSellComplete(listing,
                                                     buttonName: trackingInfo.buttonName,
                                                     sellButtonPosition: trackingInfo.sellButtonPosition,
                                                     negotiable: trackingInfo.negotiablePrice,
                                                     pictureSource: trackingInfo.imageSource,
                                                     videoLength: trackingInfo.videoLength,
                                                     freePostingModeAllowed: featureFlags.freePostingModeAllowed,
                                                     typePage: trackingInfo.typePage,
                                                     machineLearningTrackingInfo: trackingInfo.machineLearningInfo)
        
        tracker.trackEvent(event)
    }
    
    func trackPost(withListings listing: [Listing], trackingInfo: PostListingTrackingInfo) {
        listing.forEach { trackPost(withListing: $0, trackingInfo: trackingInfo) }
    }
    
    private func trackPostSellError(error: RepositoryError) {
        let sellError = EventParameterPostListingError(error: error)
        let sellErrorDataEvent = TrackerEvent.listingSellErrorData(sellError)
        tracker.trackEvent(sellErrorDataEvent)
    }
}

extension ListingCreationViewModel {
    
    private func multipostParams(subtypes: [ServiceSubtype],
                                 newSubtypes: [String],
                                 imagesIds: [String],
                                 postListingState: PostListingState) -> [ListingCreationParams] {
        guard let location = locationManager.currentLocation?.location else { return [] }
        
        let postalAddress = locationManager.currentLocation?.postalAddress ?? PostalAddress.emptyAddress()
        let currency = currencyHelper.currencyWithCountryCode(postalAddress.countryCode ?? SharedConstants.currencyDefault)
        
        let multipostSubtypeParams = subtypes.makeCreationParams(imagesIds: imagesIds,
                                                                 location: location,
                                                                 postalAddress: postalAddress,
                                                                 currency: currency,
                                                                 postListingState: postListingState)
        
        
        let multipostNewParams: [ListingCreationParams] = newSubtypes.enumerated().compactMap { (index, newSubtype) in
            guard let imageFileId = imagesIds[safeAt: index+multipostSubtypeParams.count] else { return nil }
            let serviceAttribute = postListingState.verticalAttributes?.serviceAttributes ?? ServiceAttributes()
            let imageFile = LGFile(id: imageFileId, url: nil)
            
            return ListingCreationParams.make(title: newSubtype,
                                              description: "",
                                              currency: currency,
                                              location: location,
                                              postalAddress: postalAddress,
                                              postListingState: postListingState.updating(servicesInfo: serviceAttribute,
                                                                                          uploadedImages: [imageFile]))
        }
        return multipostSubtypeParams + multipostNewParams
    }
    
}

