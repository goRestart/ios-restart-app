import LGCoreKit
import RxSwift
import LGComponents

protocol SellCoordinatorDelegate: class {
    func sellCoordinatorDidCancel(_ coordinator: SellCoordinator)
    func sellCoordinator(_ coordinator: SellCoordinator, didFinishWithListing listing: Listing)
    func sellCoordinator(_ coordinator: SellCoordinator, closePostAndOpenEditForListing listing: Listing)
}

final class SellCoordinator: Coordinator {
    var child: Coordinator?
    weak var coordinatorDelegate: CoordinatorDelegate?
    var viewController: UIViewController
    var navigationController: SellNavigationController
    weak var presentedAlertController: UIAlertController?
    let bubbleNotificationManager: BubbleNotificationManager
    let sessionManager: SessionManager
    
    fileprivate var parentViewController: UIViewController?

    fileprivate let listingRepository: ListingRepository
    fileprivate let keyValueStorage: KeyValueStorage
    fileprivate let tracker: Tracker
    fileprivate let featureFlags: FeatureFlaggeable
    fileprivate let postingSource: PostingSource
    fileprivate let postCategory: PostCategory?
    weak var delegate: SellCoordinatorDelegate?



    // MARK: - Lifecycle

    convenience init(source: PostingSource,
                     postCategory: PostCategory?,
                     forcedInitialTab: PostListingViewController.Tab?,
                     listingTitle: String?) {
        self.init(source: source,
                  postCategory: postCategory,
                  forcedInitialTab: forcedInitialTab,
                  listingTitle: listingTitle,
                  listingRepository: Core.listingRepository,
                  bubbleNotificationManager: LGBubbleNotificationManager.sharedInstance,
                  keyValueStorage: KeyValueStorage.sharedInstance,
                  tracker: TrackerProxy.sharedInstance,
                  featureFlags: FeatureFlags.sharedInstance,
                  sessionManager: Core.sessionManager)
    }

    init(source: PostingSource,
         postCategory: PostCategory?,
         forcedInitialTab: PostListingViewController.Tab?,
         listingTitle: String?,
         listingRepository: ListingRepository,
         bubbleNotificationManager: BubbleNotificationManager,
         keyValueStorage: KeyValueStorage,
         tracker: Tracker,
         featureFlags: FeatureFlags,
         sessionManager: SessionManager) {
        self.listingRepository = listingRepository
        self.bubbleNotificationManager = bubbleNotificationManager
        self.keyValueStorage = keyValueStorage
        self.tracker = tracker
        self.postingSource = source
        self.postCategory = postCategory
        self.featureFlags = featureFlags
        self.sessionManager = sessionManager

        if source == .onboardingBlockingPosting {
            let getStartedVM = PostingGetStartedViewModel()
            let getStartedVC = PostingGetStartedViewController(viewModel: getStartedVM)
            navigationController = SellNavigationController(root: getStartedVC)
            self.viewController = navigationController
            getStartedVM.navigator = self
        } else {
            let language = Locale.systemLanguage()
            let machineLearningSupported = featureFlags.predictivePosting.isSupportedFor(postCategory: postCategory,
                                                                                         language: language)
            let postListingVM = PostListingViewModel(source: source,
                                                     postCategory: postCategory,
                                                     listingTitle: listingTitle,
                                                     isBlockingPosting: false,
                                                     machineLearningSupported: machineLearningSupported)
            let postListingVC = PostListingViewController(viewModel: postListingVM,
                                                          forcedInitialTab: forcedInitialTab)
            navigationController = SellNavigationController(root: postListingVC)
            navigationController.setupInitialCategory(postCategory: postCategory)
            self.viewController = navigationController
            postListingVM.navigator = self
        }
    }

    func presentViewController(parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard let postListingVC = viewController as? UINavigationController else { return }
        guard postListingVC.parent == nil else { return }
        parentViewController = parent
        parent.present(postListingVC, animated: animated, completion: completion)
    }

    func dismissViewController(animated: Bool, completion: (() -> Void)?) {
        viewController.dismissWithPresented(animated: animated, completion: completion)
    }
}


// MARK: - PostListingNavigator

extension SellCoordinator: PostListingNavigator {    

    func cancelPostListing() {
        closeCoordinator(animated: true) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.sellCoordinatorDidCancel(strongSelf)
        }
    }
    
    func closePostProductAndPostInBackground(params: ListingCreationParams,
                                             trackingInfo: PostListingTrackingInfo) {
        dismissViewController(animated: true) { [weak self] in
            self?.listingRepository.create(listingParams: params) { [weak self] result in
                if let listing = result.value {
                    self?.trackPost(withListing: listing, trackingInfo: trackingInfo)
                    self?.keyValueStorage.userPostProductPostedPreviously = true
                    self?.showConfirmation(listingResult: ListingResult(value: listing),
                                           trackingInfo: trackingInfo, modalStyle: true)
                } else if let error = result.error {
                    self?.trackListingPostedInBackground(withError: error)
                    self?.showConfirmation(listingResult: ListingResult(error: error),
                                           trackingInfo: trackingInfo, modalStyle: true)
                }
            }
        }
    }
    
    func closePostServicesAndPostInBackground(completion: @escaping (() -> Void)) {
        dismissViewController(animated: true,
                              completion: completion)
    }
    
    func startDetails(firstStep: PostingDetailStep,
                      postListingState: PostListingState,
                      uploadedImageSource: EventParameterPictureSource?,
                      uploadedVideoLength: TimeInterval?,
                      postingSource: PostingSource,
                      postListingBasicInfo: PostListingBasicDetailViewModel) {
        let viewModel = PostingDetailsViewModel(step: firstStep,
                                                postListingState: postListingState,
                                                uploadedImageSource: uploadedImageSource,
                                                uploadedVideoLength: uploadedVideoLength,
                                                postingSource: postingSource,
                                                postListingBasicInfo: postListingBasicInfo,
                                                previousStepIsSummary: false)
        viewModel.navigator = self
        let vc = PostingDetailsViewController(viewModel: viewModel)
        navigationController.startDetails(category: postListingState.category)
        navigationController.pushViewController(vc, animated: false)
    }
    
    private func shouldShowPriceStep(postListingPrice: ListingPrice?, showPriceActive: Bool) -> Bool {
        guard showPriceActive else { return false }
        guard let _ = postListingPrice else { return true }
        return false
    }
    
    func nextPostingDetailStep(step: PostingDetailStep,
                               postListingState: PostListingState,
                               uploadedImageSource: EventParameterPictureSource?,
                               uploadedVideoLength: TimeInterval?,
                               postingSource: PostingSource,
                               postListingBasicInfo: PostListingBasicDetailViewModel,
                               previousStepIsSummary: Bool) {
        let viewModel = PostingDetailsViewModel(step: step,
                                                postListingState: postListingState,
                                                uploadedImageSource: uploadedImageSource,
                                                uploadedVideoLength: uploadedVideoLength,
                                                postingSource: postingSource,
                                                postListingBasicInfo: postListingBasicInfo,
                                                previousStepIsSummary: previousStepIsSummary)
        viewModel.navigator = self
        let vc = PostingDetailsViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }
    
    
    fileprivate func trackListingPostedInBackground(withError error: RepositoryError) {
        let sellError = EventParameterPostListingError(error: error)
        let sellErrorDataEvent = TrackerEvent.listingSellErrorData(sellError)
        TrackerProxy.sharedInstance.trackEvent(sellErrorDataEvent)
    }
    
    func openListingCreation(listingParams: ListingCreationParams, trackingInfo: PostListingTrackingInfo) {
        let viewModel = ListingCreationViewModel(listingParams: listingParams, trackingInfo: trackingInfo)
        viewModel.navigator = self
        let vc = ListingCreationViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: false)
    }
    
    func openListingsCreation(uploadedImageId: String,
                              multipostingSubtypes: [ServiceSubtype],
                              multipostingNewSubtypes: [String],
                              postListingState: PostListingState,
                              trackingInfo: PostListingTrackingInfo) {
        let viewModel = ListingCreationViewModel(uploadedImageId: uploadedImageId,
                                                 multipostingSubtypes: multipostingSubtypes,
                                                 multipostingNewSubtypes: multipostingNewSubtypes,
                                                 postListingState: postListingState,
                                                 trackingInfo: trackingInfo)
        viewModel.navigator = self
        let vc = ListingCreationViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: false)
    }

    func showConfirmation(listingResult: ListingResult,
                          trackingInfo: PostListingTrackingInfo,
                          modalStyle: Bool) {
        guard let parentVC = parentViewController else { return }
        
        let listingPostedVM = ListingPostedViewModel(listingResult: listingResult, trackingInfo: trackingInfo)
        listingPostedVM.navigator = self
        let listingPostedVC = ListingPostedViewController(viewModel: listingPostedVM)
        showCongrats(listingPostedVC, modalStyle, parentVC)
    }
    
    func showMultiListingPostConfirmation(listingResult listingsResult: ListingsResult,
                                          trackingInfo: PostListingTrackingInfo,
                                          modalStyle: Bool) {
        guard let parentVC = parentViewController else { return }
        
        let viewModel = MultiListingPostedViewModel(navigator: self,
                                                    listingsResult: listingsResult,
                                                    trackingInfo: trackingInfo)
        let multiPostedVC = MultiListingPostedViewController(viewModel: viewModel)
        showCongrats(multiPostedVC, modalStyle, parentVC)
    }
    
    private func showCongrats(_ listingPostedVC: UIViewController,
                              _ modalStyle: Bool,
                              _ parentVC: UIViewController) {
        viewController = listingPostedVC
        if modalStyle {
            parentVC.present(listingPostedVC, animated: true, completion: nil)
        } else {
            navigationController.pushViewController(listingPostedVC, animated: false)
        }
    }

    func closePostProductAndPostLater(params: ListingCreationParams,
                                      images: [UIImage]?,
                                      video: RecordedVideo?,
                                      trackingInfo: PostListingTrackingInfo) {
        guard let parentVC = parentViewController else { return }

        dismissViewController(animated: true) { [weak self] in
            let listingPostedVM = ListingPostedViewModel(postParams: params,
                                                         listingImages: images,
                                                         video: video,
                                                         trackingInfo: trackingInfo)
            listingPostedVM.navigator = self
            let listingPostedVC = ListingPostedViewController(viewModel: listingPostedVM)
            self?.viewController = listingPostedVC
            parentVC.present(listingPostedVC, animated: true, completion: nil)
        }
    }
    
    func closePostServicesAndPostLater(params: [ListingCreationParams],
                                       images: [UIImage]?,
                                       trackingInfo: PostListingTrackingInfo) {
        guard let parentVC = parentViewController else { return }
        
        dismissViewController(animated: true) { [weak self] in
            guard let strongSelf = self else { return }
            let viewModel = MultiListingPostedViewModel(navigator: strongSelf,
                                                        postParams: params,
                                                        images: images,
                                                        trackingInfo: trackingInfo)
            let multiPostedVC = MultiListingPostedViewController(viewModel: viewModel)
            strongSelf.showCongrats(multiPostedVC, true, parentVC)
        }
    }

    func openLoginIfNeededFromListingPosted(from: EventParameterLoginSourceValue,
                                            loggedInAction: @escaping (() -> Void),
                                            cancelAction: (() -> Void)?) {
        openLoginIfNeeded(from: from, style: .popup(R.Strings.productPostLoginMessage), loggedInAction: loggedInAction, cancelAction: cancelAction)
    }
    
    func backToSummary() {
        let _ = navigationController.popViewController(animated: true)
    }
    
    func openQueuedRequestsLoading(images: [UIImage], listingCreationParams: ListingCreationParams,
                                   imageSource: EventParameterPictureSource, postingSource: PostingSource) {
        let viewModel = BlockingPostingQueuedRequestsViewModel(images: images,
                                                               listingCreationParams: listingCreationParams,
                                                               imageSource: imageSource,
                                                               postingSource: postingSource,
                                                               featureFlags: featureFlags)
        viewModel.navigator = self
        let vc = BlockingPostingQueuedRequestsViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: false)
    }

}


// MARK: - ListingPostedNavigator

extension SellCoordinator: ListingPostedNavigator {
    func cancelListingPosted() {
        closeCoordinator(animated: true) { [weak self] in
            guard let strongSelf = self, let delegate = strongSelf.delegate else { return }
            delegate.sellCoordinatorDidCancel(strongSelf)
        }
    }

    func closeListingPosted(_ listing: Listing) {
        closeCoordinator(animated: true) { [weak self] in
            guard let strongSelf = self, let delegate = strongSelf.delegate else { return }

            delegate.sellCoordinator(strongSelf, didFinishWithListing: listing)
        }
    }

    func closeListingPostedAndOpenEdit(_ listing: Listing) {
        closeCoordinator(animated: true) { [weak self] in
            guard let strongSelf = self, let delegate = strongSelf.delegate else { return }
            delegate.sellCoordinator(strongSelf, closePostAndOpenEditForListing: listing)
        }
    }

    func closeProductPostedAndOpenPost() {
        dismissViewController(animated: true) { [weak self] in
            guard let strongSelf = self, let parentVC = strongSelf.parentViewController else { return }
            let postCategory: PostCategory? = nil
            let language = Locale.systemLanguage()
            let machineLearningSupported = strongSelf.featureFlags.predictivePosting.isSupportedFor(postCategory: postCategory,
                                                                                         language: language)
            let postListingVM = PostListingViewModel(source: strongSelf.postingSource,
                                                     postCategory: postCategory,
                                                     listingTitle: nil,
                                                     isBlockingPosting: false,
                                                     machineLearningSupported: machineLearningSupported)
            let postListingVC = PostListingViewController(viewModel: postListingVM,
                                                          forcedInitialTab: nil)
            strongSelf.viewController = postListingVC
            postListingVM.navigator = self
            strongSelf.navigationController = SellNavigationController(root: postListingVC)
            strongSelf.navigationController.setupInitialCategory(postCategory: nil)
            strongSelf.viewController = strongSelf.navigationController
            strongSelf.presentViewController(parent: parentVC, animated: true, completion: nil)
        }
    }
}


// MARK: - MultiListingPostedNavigtor

extension SellCoordinator: MultiListingPostedNavigator {

    func closeListingsPosted(_ listings: [Listing]) {
        guard let listing = listings.first else {
            return
        }
        closeListingPosted(listing)
    }
    
    func openEdit(forListing listing: Listing) {
        
        let editListingNavigator = EditListingCoordinator(listing: listing, bumpUpProductData: nil, pageType: EventParameterTypePage.edit, listingCanBeBoosted: false, timeSinceLastBump: nil, maxCountdown: 0)
        editListingNavigator.delegate = self
        openChild(coordinator: editListingNavigator,
                  parent: viewController,
                  animated: true,
                  forceCloseChild: false,
                  completion: nil)
    }
}


// MARK: - EditListingCoordinatorDelegate
extension SellCoordinator: EditListingCoordinatorDelegate {
    func editListingCoordinatorDidCancel(_ coordinator: EditListingCoordinator) {
        // Do nothing, todo esta canela fina
    }
    
    func editListingCoordinator(_ coordinator: EditListingCoordinator,
                                didFinishWithListing listing: Listing,
                                bumpUpProductData: BumpUpProductData?,
                                timeSinceLastBump: TimeInterval?,
                                maxCountdown: TimeInterval) {
        guard let multiListingVC = viewController as? MultiListingPostedViewController else {
            return
        }
        multiListingVC.listingEdited(listing: listing)
    }
}


// MARK: - BlockingPostingNavigator

extension SellCoordinator: BlockingPostingNavigator  {

    func openCamera() {
        let postListingVM = PostListingViewModel(source: .onboardingBlockingPosting,
                                                 postCategory: nil,
                                                 listingTitle: nil,
                                                 isBlockingPosting: true,
                                                 machineLearningSupported: false)
        postListingVM.navigator = self
        let postListingVC = PostListingViewController(viewModel: postListingVM,
                                                      forcedInitialTab: nil)
        navigationController.pushViewController(postListingVC, animated: true)
    }
    
    func openPrice(listing: Listing, images: [UIImage], imageSource: EventParameterPictureSource, videoLength: TimeInterval?, postingSource: PostingSource) {
        let viewModel = BlockingPostingAddPriceViewModel(listing: listing,
                                                         images: images,
                                                         imageSource: imageSource,
                                                         videoLength: videoLength,
                                                         postingSource: postingSource)
        viewModel.navigator = self
        let vc = BlockingPostingAddPriceViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func openListingPosted(listing: Listing, images: [UIImage], imageSource: EventParameterPictureSource, videoLength: TimeInterval?, postingSource: PostingSource) {
        let viewModel = ListingPostedDescriptiveViewModel(listing: listing,
                                                          listingImages: images,
                                                          imageSource: imageSource,
                                                          videoLength: videoLength,
                                                          postingSource: postingSource)
        viewModel.navigator = self
        let vc = ListingPostedDescriptiveViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }

    func openCategoriesPickerWith(selectedCategory: ListingCategory?, delegate: PostingCategoriesPickDelegate) {
        let viewModel = PostingCategoriesPickViewModel(selectedCategory: selectedCategory)
        viewModel.delegate = delegate
        viewModel.navigator = self
        let viewController = PostingCategoriesPickViewController(viewModel: viewModel)
        navigationController.removeBackground()
        navigationController.pushViewController(viewController, animated: true)
    }

    func closeCategoriesPicker() {
        let _ = navigationController.popViewController(animated: true)
    }

    func closePosting() {
        cancelPostListing()
    }

    func postingSucceededWith(listing: Listing) {
        closeCoordinator(animated: true) { [weak self] in
            guard let strongSelf = self, let delegate = strongSelf.delegate else { return }
            delegate.sellCoordinator(strongSelf, didFinishWithListing: listing)
        }
    }
    
    func openListingEditionLoading(listingParams: ListingEditionParams,
                                   listing: Listing,
                                   images: [UIImage],
                                   imageSource: EventParameterPictureSource,
                                   videoLength: TimeInterval?,
                                   postingSource: PostingSource) {
        let viewModel = BlockingPostingListingEditionViewModel(listingParams: listingParams,
                                                               listing: listing,
                                                               images: images,
                                                               imageSource: imageSource,
                                                               videoLength: videoLength,
                                                               postingSource: postingSource)
        viewModel.navigator = self
        let vc = BlockingPostingListingEditionViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: false)
    }
}


// MARK: - Tracking

fileprivate extension SellCoordinator {
    func trackPost(withListing listing: Listing, trackingInfo: PostListingTrackingInfo) {
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
        if let firstOpenDate = keyValueStorage[.firstRunDate], Date().timeIntervalSince(firstOpenDate) <= 86400 &&
                !keyValueStorage.userTrackingProductSellComplete24hTracked {
            keyValueStorage.userTrackingProductSellComplete24hTracked = true

            let event = TrackerEvent.listingSellComplete24h(listing)
            tracker.trackEvent(event)
        }
    }
}
