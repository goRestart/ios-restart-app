import LGCoreKit
import RxSwift
import LGComponents

class BlockingPostingQueuedRequestsViewModel: BaseViewModel {
    
    enum QueueState {
        case uploadingImages
        case createListing
        case createListingUI
        case listingPosted
        case error
        
        var message: String {
            switch self {
            case .uploadingImages:
                return R.Strings.postQueuedRequestsStateGeneratingTitle
            case .createListing:
                return R.Strings.postQueuedRequestsStateCategorizingListing
            case .createListingUI:
                return R.Strings.postQueuedRequestsStatePostingListing
            case .listingPosted:
                return R.Strings.postQueuedRequestsStateListingPosted
            case .error:
                return R.Strings.productPostGenericError
            }
        }
        
        var isAnimated: Bool {
            switch self {
            case .uploadingImages, .createListing, .createListingUI:
                return true
            case .listingPosted, .error:
                return false
            }
        }
        
        var isError: Bool {
            return self == .error
        }
    }

    private static let stateDelay: TimeInterval = 1.5
    
    private let listingRepository: ListingRepository
    private let fileRepository: FileRepository
    private let tracker: Tracker
    private let images: [UIImage]
    private var listingCreationParams: ListingCreationParams
    private let imageSource: EventParameterMediaSource
    private let postingSource: PostingSource
    private let featureFlags: FeatureFlaggeable
    
    private var listingCreated: Listing?
    let queueState = Variable<QueueState?>(nil)
    let uploadImagesTriggered = Variable<Bool>(false)
    let uploadImagesResult = Variable<FilesResult?>(nil)
    let createListingResult = Variable<ListingResult?>(nil)
    let createListingUITriggered = Variable<Bool>(false)
    let listingPostedTriggered = Variable<Bool>(false)
    
    weak var navigator: BlockingPostingNavigator?
    private let disposeBag = DisposeBag()
    
    
    // MARK: - Lifecycle

    convenience init(images: [UIImage],
                     listingCreationParams: ListingCreationParams,
                     imageSource: EventParameterMediaSource,
                     postingSource: PostingSource,
                     featureFlags: FeatureFlaggeable) {
        self.init(listingRepository: Core.listingRepository,
                  fileRepository: Core.fileRepository,
                  tracker: TrackerProxy.sharedInstance,
                  images: images,
                  listingCreationParams: listingCreationParams,
                  imageSource: imageSource,
                  postingSource: postingSource,
                  featureFlags: featureFlags)
    }
    
    init(listingRepository: ListingRepository,
         fileRepository: FileRepository,
         tracker: Tracker,
         images: [UIImage],
         listingCreationParams: ListingCreationParams,
         imageSource: EventParameterMediaSource,
         postingSource: PostingSource,
         featureFlags: FeatureFlaggeable) {
        self.listingRepository = listingRepository
        self.fileRepository = fileRepository
        self.tracker = tracker
        self.images = images
        self.listingCreationParams = listingCreationParams
        self.imageSource = imageSource
        self.postingSource = postingSource
        self.featureFlags = featureFlags
        super.init()
        setupRx()
    }
    
    private func setupRx() {
        queueState.asObservable().bind { [weak self] state in
            guard let strongSelf = self else { return }
            guard let state = state else { return }
            switch state {
            case .uploadingImages:
                strongSelf.uploadImages()
            case .createListing:
                strongSelf.createListing()
            case .createListingUI:
                strongSelf.createListingUITriggered.value = true
            case .listingPosted:
                strongSelf.listingPostedTriggered.value = true
            case .error:
                break
            }
            }.disposed(by: disposeBag)
        
        uploadImagesTriggered.asObservable()
            .filter{ $0 }
            .bind { [weak self] result in
                guard let strongSelf = self else { return }
                strongSelf.queueState.value = .uploadingImages
            }.disposed(by: disposeBag)
        
        uploadImagesResult.asObservable()
            .unwrap()
            .delay(BlockingPostingQueuedRequestsViewModel.stateDelay, scheduler: MainScheduler.asyncInstance)
            .bind { [weak self] result in
                guard let strongSelf = self else { return }
                if let images = result.value {
                    strongSelf.listingCreationParams = strongSelf.listingCreationParams.updating(images: images)
                    strongSelf.queueState.value = .createListing
                } else {
                    strongSelf.queueState.value = .error
                }
        }.disposed(by: disposeBag)

        createListingResult.asObservable()
            .unwrap()
            .delay(BlockingPostingQueuedRequestsViewModel.stateDelay, scheduler: MainScheduler.asyncInstance)
            .bind { [weak self] result in
                guard let strongSelf = self else { return }
                if let listing = result.value {
                    strongSelf.listingCreated = listing
                    strongSelf.queueState.value = .createListingUI
                } else {
                    strongSelf.queueState.value = .error
                }
            }.disposed(by: disposeBag)
        
        createListingUITriggered.asObservable()
            .filter{ $0 }
            .delay(BlockingPostingQueuedRequestsViewModel.stateDelay, scheduler: MainScheduler.asyncInstance)
            .bind { [weak self] result in
                guard let strongSelf = self else { return }
                strongSelf.queueState.value = .listingPosted
            }.disposed(by: disposeBag)
    
        listingPostedTriggered.asObservable()
            .filter{ $0 }
            .delay(BlockingPostingQueuedRequestsViewModel.stateDelay, scheduler: MainScheduler.asyncInstance)
            .bind { [weak self] result in
                guard let strongSelf = self else { return }
                if let listing = strongSelf.listingCreated {
                    strongSelf.openPrice(listing: listing)
                } else {
                    strongSelf.queueState.value = .error
                }
            }.disposed(by: disposeBag)
    }
    

    // MARK: - Repository requests
    
    func startQueuedRequests() {
        uploadImagesTriggered.value = true
    }
    
    private func uploadImages() {
        fileRepository.upload(images, progress: nil) { [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.uploadImagesResult.value = result
        }
    }
    
    private func createListing() {
        listingRepository.create(listingParams: listingCreationParams) { [weak self] result in
            self?.createListingResult.value = result
        }
    }
    
    // MARK: - Navigation
    
    func openPrice(listing: Listing) {
        navigator?.openPrice(listing: listing,
                             images: images,
                             imageSource: imageSource,
                             videoLength: nil,
                             postingSource: postingSource)
    }
    
    func closeButtonAction() {
        trackPostSellAbandon()
        navigator?.closePosting()
    }
    
    
    // MARK: - Tracker
    
    fileprivate func trackPostSellAbandon() {
        let event = TrackerEvent.listingSellAbandon(abandonStep: .retry,
                                                    pictureUploaded: uploadImagesResult.value != nil ? .trueParameter : .falseParameter,
                                                    loggedUser: .trueParameter,
                                                    buttonName: .skip)
        tracker.trackEvent(event)
    }
}
