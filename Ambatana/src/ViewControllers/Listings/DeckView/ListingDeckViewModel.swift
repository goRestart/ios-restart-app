import Foundation
import LGCoreKit
import RxSwift
import GoogleMobileAds
import LGComponents
import RxSwift
import RxCocoa

struct Pagination {
    let first: Int
    var next: Int
    var isLast: Bool

    func moveToNextPage() -> Pagination {
        let nextPage = next + 1
        return Pagination(first: first, next: nextPage, isLast: isLast)
    }

    static func makePagination(first: Int, next: Int, isLast: Bool) -> Pagination {
        return Pagination(first: first, next: next, isLast: isLast)
    }

    private init(first: Int, next: Int, isLast: Bool) {
        self.first = first
        self.next = next
        self.isLast = isLast
    }
}

struct Prefetching {
    let previousCount: Int
    let nextCount: Int
}

protocol ListingDeckViewModelDelegate: BaseViewModelDelegate {
    func vmShareViewControllerAndItem() -> (UIViewController, UIBarButtonItem?)
    func vmResetBumpUpBannerCountdown()
}

typealias DeckActionOnFirstAppear = ProductCarouselActionOnFirstAppear
final class ListingDeckViewModel: BaseViewModel {

    let objects = CollectionVariable<ListingCellModel>([])

    let binder: ListingDeckViewModelBinder
    let currentListingViewModel: ListingViewModel?
    weak var navigator: ListingDetailNavigator? { didSet { currentListingViewModel?.navigator = navigator } }
    weak var deckNavigator: DeckNavigator?
    weak var delegate: ListingDeckViewModelDelegate?

    var pagination: Pagination

    // Just for pagination
    private(set) var currentIndex: Int = 0 { didSet { setCurrentIndex(currentIndex) } }
    var isNextPageAvailable: Bool { return !pagination.isLast }
    var isLoading = false

    let prefetching: Prefetching
    private var prefetchingIndexes: [Int] = []

    let startIndex: Int
    var shouldSyncFirstListing: Bool = false
    private let trackingIndex: Int?

    private let trackingIdentifier: String?
    private var lastMovement: CarouselMovement = .initial
    private let source: EventParameterListingVisitSource
    private let listingListRequester: ListingListRequester
    private let userRepository: MyUserRepository

    private let listingViewModelMaker: ListingViewModelMaker
    private let tracker: Tracker
    private let listingTracker: ListingTracker

    private let featureFlags: FeatureFlaggeable

    let actionOnFirstAppear: DeckActionOnFirstAppear

    lazy var actionButtons = Variable<[UIAction]>([])
    var navBarButtons: [UIAction] { return currentListingViewModel?.navBarActionsNewItemPage ?? [] }

    let quickChatViewModel = QuickChatViewModel()
    lazy var bumpUpBannerInfo = Variable<BumpUpInfo?>(nil)

    let imageDownloader: ImageDownloaderType
    private var sectionFeedChatTrackingInfo: SectionedFeedChatTrackingInfo? {
        guard let id = trackingIdentifier, let position = trackingIndex else {
            return nil
        }
        let sectionName = EventParameterSectionName.identifier(id: id)
        let feedIndex = EventParameterFeedPosition.position(index: position)
        return SectionedFeedChatTrackingInfo(sectionId: sectionName,
                                             itemIndexInSection: feedIndex)
    }
    
    override var active: Bool {
        didSet { currentListingViewModel?.active = active }
    }

    var userHasScrolled: Bool = false
    private var shouldShowDeckOnBoarding: Bool {
        return !userHasScrolled && !keyValueStorage[.didShowDeckOnBoarding]
    }
    var shouldShowCardGesturesOnBoarding: Bool { return !keyValueStorage[.didShowCardGesturesOnBoarding] }

    private let keyValueStorage: KeyValueStorageable
    private let adsRequester: AdsRequester
    
    convenience init(listModels: [ListingCellModel],
                     listing: Listing,
                     listingListRequester: ListingListRequester,
                     source: EventParameterListingVisitSource,
                     detailNavigator: ListingDetailNavigator?,
                     actionOnFirstAppear: DeckActionOnFirstAppear,
                     trackingIndex: Int?,
                     trackingIdentifier: String?) {
        let pagination = Pagination.makePagination(first: 0, next: 1, isLast: false)
        let prefetching = Prefetching(previousCount: 3, nextCount: 3)
        self.init(listModels: listModels,
                  initialListing: listing,
                  listingListRequester: listingListRequester,
                  detailNavigator: detailNavigator,
                  source: source,
                  imageDownloader: ImageDownloader.make(usingImagePool: true),
                  listingViewModelMaker: ListingViewModel.ConvenienceMaker(),
                  myUserRepository: Core.myUserRepository,
                  pagination: pagination,
                  prefetching: prefetching,
                  shouldSyncFirstListing: false,
                  binder: ListingDeckViewModelBinder(),
                  tracker: TrackerProxy.sharedInstance,
                  actionOnFirstAppear: actionOnFirstAppear,
                  trackingIndex: trackingIndex,
                  trackingIdentifier: trackingIdentifier,
                  keyValueStorage: KeyValueStorage.sharedInstance,
                  featureFlags: FeatureFlags.sharedInstance,
                  adsRequester: AdsRequester())
    }

    convenience init(listModels: [ListingCellModel],
                     initialListing: Listing,
                     listingListRequester: ListingListRequester,
                     detailNavigator: ListingDetailNavigator?,
                     source: EventParameterListingVisitSource,
                     imageDownloader: ImageDownloaderType,
                     listingViewModelMaker: ListingViewModelMaker,
                     shouldSyncFirstListing: Bool,
                     binder: ListingDeckViewModelBinder,
                     actionOnFirstAppear: DeckActionOnFirstAppear,
                     trackingIndex: Int?,
                     trackingIdentifier: String?) {
        let pagination = Pagination.makePagination(first: 0, next: 1, isLast: false)
        let prefetching = Prefetching(previousCount: 1, nextCount: 3)
        self.init(listModels: listModels,
                  initialListing: initialListing,
                  listingListRequester: listingListRequester,
                  detailNavigator: detailNavigator,
                  source: source,
                  imageDownloader: imageDownloader,
                  listingViewModelMaker: listingViewModelMaker,
                  myUserRepository: Core.myUserRepository,
                  pagination: pagination,
                  prefetching: prefetching,
                  shouldSyncFirstListing: shouldSyncFirstListing,
                  binder: binder,
                  tracker: TrackerProxy.sharedInstance,
                  actionOnFirstAppear: actionOnFirstAppear,
                  trackingIndex: trackingIndex,
                  trackingIdentifier: trackingIdentifier,
                  keyValueStorage: KeyValueStorage.sharedInstance,
                  featureFlags: FeatureFlags.sharedInstance,
                  adsRequester: AdsRequester())
    }

    init(listModels: [ListingCellModel],
         initialListing: Listing,
         listingListRequester: ListingListRequester,
         detailNavigator: ListingDetailNavigator?,
         source: EventParameterListingVisitSource,
         imageDownloader: ImageDownloaderType,
         listingViewModelMaker: ListingViewModelMaker,
         myUserRepository: MyUserRepository,
         pagination: Pagination,
         prefetching: Prefetching,
         shouldSyncFirstListing: Bool,
         binder: ListingDeckViewModelBinder,
         tracker: Tracker,
         actionOnFirstAppear: DeckActionOnFirstAppear,
         trackingIndex: Int?,
         trackingIdentifier: String?,
         keyValueStorage: KeyValueStorageable,
         featureFlags: FeatureFlaggeable,
         adsRequester: AdsRequester) {
        self.imageDownloader = imageDownloader
        self.pagination = pagination
        self.prefetching = prefetching
        self.listingListRequester = listingListRequester
        self.listingViewModelMaker = listingViewModelMaker
        self.source = source
        self.binder = binder
        self.userRepository = myUserRepository
        self.navigator = detailNavigator
        self.tracker = tracker
        self.listingTracker = ListingTracker.init(tracker: tracker,
                                                  featureFlags: featureFlags,
                                                  myUserRepository: myUserRepository)
        self.actionOnFirstAppear = actionOnFirstAppear
        self.trackingIndex = trackingIndex
        self.keyValueStorage = keyValueStorage
        self.featureFlags = featureFlags
        self.adsRequester = adsRequester

        let filteredModels = listModels.filter(ListingDeckViewModel.isListable)

        if !filteredModels.isEmpty {
            self.objects.appendContentsOf(filteredModels)
            self.pagination.isLast = listingListRequester.isLastPage(filteredModels.count)
        } else {
            self.objects.appendContentsOf([initialListing].compactMap{ $0 }.map { .listingCell(listing: $0) })
            self.pagination.isLast = false
        }
        startIndex = objects.value.index(where: {
            guard let aListing = $0.listing else { return false }
            return aListing.objectId == initialListing.objectId
        }) ?? 0
        currentListingViewModel = listingViewModelMaker.make(listing: initialListing, visitSource: source)
        currentIndex = startIndex
        self.trackingIdentifier = trackingIdentifier
        super.init()
        self.shouldSyncFirstListing = shouldSyncFirstListing
        binder.deckViewModel = self
    }

    override func didBecomeActive(_ firstTime: Bool) {
        if shouldSyncFirstListing {
            syncFirstListing()
        }
        moveToListingAtIndex(currentIndex, movement: .initial)
    }


    func moveToListingAtIndex(_ index: Int, movement: DeckMovement) {
        guard let listing = objects.value[safeAt: index]?.listing else { return }
        lastMovement = movement
        if active {
            currentListingViewModel?.delegate = nil
            currentListingViewModel?.listing.value = listing
            currentListingViewModel?.delegate = self

            quickChatViewModel.listingViewModel = currentListingViewModel
            quickChatViewModel.sectionFeedChatTrackingInfo = sectionFeedChatTrackingInfo
            //            binder.bind(to:viewModel, quickChatViewModel: quickChatViewModel)

            currentIndex = index
            prefetchNeighborsImages(index, movement: movement)

            // Tracking ABIOS-4531
        }
    }

    func didTapCardAction() {
        if let isFav = currentListingViewModel?.cardIsFavoritable, isFav {
            currentListingViewModel?.switchFavorite()
        } else {
            currentListingViewModel?.editListing()
        }
    }

    private func syncFirstListing() {
        currentListingViewModel?.syncListing() { [weak self] in
            guard let strongSelf = self else { return }
            guard let listing = strongSelf.currentListingViewModel?.listing.value else { return }
            strongSelf.objects.replace(strongSelf.startIndex, with: ListingCellModel.listingCell(listing: listing))
        }
    }

    func replaceListingCellModelAtIndex(_ index: Int, withListing listing: Listing) {
        let cellModel: ListingCellModel = .listingCell(listing: listing)
        objects.replace(index, with: cellModel)
    }

    func createAndLoadInterstitial() -> GADInterstitial? {
        return adsRequester.createAndLoadInterstitialForUserRepository(userRepository)
    }
    
    func presentInterstitial(_ interstitial: GADInterstitial?, index: Int, fromViewController: UIViewController) {
        adsRequester.presentInterstitial(interstitial, index: index, fromViewController: fromViewController)
    }

    // TODO: Tracking ABIOS-4531

    func bumpUpBannerShown(bumpInfo: BumpUpInfo) {
        guard bumpInfo.shouldTrackBumpBannerShown else { return }
        guard let listing = currentListingViewModel?.listing.value else { return }
        listingTracker.trackBumpUpBannerShown(listing,
                                              type: bumpInfo.type,
                                              storeProductId: currentListingViewModel?.storeProductId)
    }

    func interstitialAdTapped(typePage: EventParameterTypePage) {
        let adType = AdRequestType.interstitial.trackingParamValueFor(size: nil)
        let isMine = EventParameterBoolean(bool: currentListingViewModel?.isMine)
        let feedPosition: EventParameterFeedPosition = .position(index: currentIndex)
        let willLeave = EventParameterBoolean(bool: true)

        guard let listing = currentListingViewModel?.listing.value else { return }
        listingTracker.trackInterstitialAdTapped(listing,
                                                 adType: adType,
                                                 feedPosition: feedPosition,
                                                 willLeaveApp: willLeave,
                                                 typePage: typePage)
    }
    
    func interstitialAdShown(typePage: EventParameterTypePage) {
        let adType = AdRequestType.interstitial.trackingParamValueFor(size: nil)
        let isMine = EventParameterBoolean(bool: currentListingViewModel?.isMine)
        let feedPosition: EventParameterFeedPosition = .position(index: currentIndex)
        let adShown = EventParameterBoolean(bool: true)

        guard let listing = currentListingViewModel?.listing.value else { return }
        listingTracker.trackInterstitialAdShown(listing,
                                                adType: adType,
                                                feedPosition: feedPosition,
                                                adShown: adShown,
                                                typePage: typePage)
    }

    // MARK: Paginable

    func retrievePage(_ page: Int) {
        let isFirstPage = (page == firstPage)
        isLoading = true

        let nextPage = pagination.moveToNextPage()
        let completion: ListingsRequesterCompletion = { [weak self] result in
            self?.isLoading = false
            if let newListings = result.listingsResult.value {
                self?.pagination = nextPage
                self?.objects.appendContentsOf(newListings
                    .map { ListingCellModel.listingCell(listing: $0) }
                    .filter(ListingDeckViewModel.isListable))
                self?.pagination.isLast = self?.listingListRequester.isLastPage(newListings.count) ?? false
                if let isNextPageAvailable = self?.isNextPageAvailable, newListings.isEmpty && isNextPageAvailable {
                    self?.retrieveNextPage()
                }
            }
        }

        if isFirstPage {
            listingListRequester.retrieveFirstPage(completion)
        } else {
            listingListRequester.retrieveNextPage(completion)
        }
    }

    func didTapStatusView() {
        navigator?.openFeaturedInfo()
        guard let listing = currentListingViewModel?.listing.value else { return }
        listingTracker.trackOpenFeaturedInfo(listing)
    }

    func close() {
        if shouldShowDeckOnBoarding {
            showOnBoarding()
        } else {
            deckNavigator?.closeDeck()
        }
    }

    func showOnBoarding() {
        deckNavigator?.showOnBoarding()
        keyValueStorage[.didShowDeckOnBoarding] = true
    }

    func didShowCardsGesturesOnBoarding() {
        keyValueStorage[.didShowCardGesturesOnBoarding] = true
    }

    func cachedImageAtIndex(_ index: Int) -> UIImage? {
        guard let url = currentListingViewModel?.productImageURLs.value[safeAt: index],
            let cached = imageDownloader.cachedImageForUrl(url) else { return nil }
        return cached
    }

    func openPhotoViewer() {
        guard let listingViewModel = currentListingViewModel else { return }
        // we will force index = 0 for now, but in the future we need to move to the exact position
        // ABIOS-3981
        deckNavigator?.openPhotoViewer(listingViewModel: listingViewModel,
                                       atIndex: 0,
                                       source: source,
                                       quickChatViewModel: quickChatViewModel)
    }

    func showListingDetail(at index: Int) {
        guard let listing = objects.value[safeAt: index]?.listing else { return }
        deckNavigator?.showListingDetail(listing: listing, visitSource: source)
    }

    func showBumpUpView(_ action: DeckActionOnFirstAppear) {
        if case .triggerBumpUp(let bumpUpProductData,
                               let bumpUpType,
                               let triggerBumpUpSource,
                               let typePage) = action {
            currentListingViewModel?.showBumpUpView(bumpUpProductData: bumpUpProductData,
                                                    bumpUpType: bumpUpType,
                                                    bumpUpSource: triggerBumpUpSource,
                                                    typePage: typePage)
        }
    }
}

// MARK: ListingViewModelDelegate

extension ListingDeckViewModel: ListingViewModelDelegate {
    
    var listingOrigin: ListingOrigin {
        let result: ListingOrigin
        switch lastMovement {
        case .initial:
            result = .initial
        case .tap, .swipeRight:
            result = .inResponseToNextRequest
        case .swipeLeft:
            result = .inResponseToPreviousRequest
        }
        return result
    }

    func vmShareViewControllerAndItem() -> (UIViewController, UIBarButtonItem?) {
        guard let delegate = delegate else { return (UIViewController(), nil) }
        return delegate.vmShareViewControllerAndItem()
    }

    var trackingFeedPosition: EventParameterFeedPosition {
        guard let trackingIndex = trackingIndex else { return .none }
        return .position(index: trackingIndex)
    }
    
    var trackingFeedSectionName: EventParameterSectionName? {
        guard let trackingId = trackingIdentifier else { return nil }
        return .identifier(id: trackingId)
    }

    func vmResetBumpUpBannerCountdown() {
        delegate?.vmResetBumpUpBannerCountdown()
    }

    // BaseViewModelDelegate forwarding methods

    func vmShowAutoFadingMessage(_ message: String, completion: (() -> ())?) {
        delegate?.vmShowAutoFadingMessage(message, completion: completion)
    }
    func vmShowAutoFadingMessage(title: String, message: String, time: Double, completion: (() -> ())?) {
        delegate?.vmShowAutoFadingMessage(title: title, message: message, time: time, completion: completion)
    }
    func vmShowAutoFadingMessage(message: String, time: Double, completion: (() -> ())?) {
        delegate?.vmShowAutoFadingMessage(message: message, time: time, completion: completion)
    }
    func vmShowLoading(_ loadingMessage: String?) {
        delegate?.vmShowLoading(loadingMessage)
    }
    func vmHideLoading(_ finishedMessage: String?, afterMessageCompletion: (() -> ())?) {
        delegate?.vmHideLoading(finishedMessage, afterMessageCompletion: afterMessageCompletion)
    }
    func vmShowAlertWithTitle(_ title: String?, text: String, alertType: AlertType, actions: [UIAction]?) {
        delegate?.vmShowAlertWithTitle(title, text: text, alertType: alertType, actions: actions)
    }
    func vmShowAlertWithTitle(_ title: String?, text: String, alertType: AlertType, actions: [UIAction]?, dismissAction: (() -> ())?) {
        delegate?.vmShowAlertWithTitle(title, text: text, alertType: alertType, actions: actions, dismissAction: dismissAction)
    }
    func vmShowAlertWithTitle(_ title: String?, text: String, alertType: AlertType, buttonsLayout: AlertButtonsLayout, actions: [UIAction]?) {
        delegate?.vmShowAlertWithTitle(title, text: text, alertType: alertType, buttonsLayout: buttonsLayout, actions: actions)
    }
    func vmShowAlertWithTitle(_ title: String?, text: String, alertType: AlertType, buttonsLayout: AlertButtonsLayout, actions: [UIAction]?, dismissAction: (() -> ())?) {
        delegate?.vmShowAlertWithTitle(title, text: text, alertType: alertType, buttonsLayout: buttonsLayout, actions: actions, dismissAction: dismissAction)
    }
    func vmShowAlert(_ title: String?, message: String?, actions: [UIAction]) {
        delegate?.vmShowAlert(title, message: message, actions: actions)
    }
    func vmShowAlert(_ title: String?, message: String?, cancelLabel: String, actions: [UIAction]) {
        delegate?.vmShowAlert(title, message: message, cancelLabel: cancelLabel, actions: actions)
    }
    func vmShowActionSheet(_ cancelAction: UIAction, actions: [UIAction]) {
        delegate?.vmShowActionSheet(cancelAction, actions: actions)
    }
    func vmShowActionSheet(_ cancelLabel: String, actions: [UIAction]) {
        delegate?.vmShowActionSheet(cancelLabel, actions: actions)
    }
    func vmShowActionSheet(_ cancelAction: UIAction, actions: [UIAction], withTitle title: String?) {
        delegate?.vmShowActionSheet(cancelAction, actions: actions, withTitle: title)
    }
    func vmOpenInAppWebViewWith(url: URL) {
        delegate?.vmOpenInAppWebViewWith(url:url)
    }
    func vmPop() {
        delegate?.vmPop()
    }
    func vmDismiss(_ completion: (() -> Void)?) {
        delegate?.vmDismiss(completion)
    }
}

// ListingDeckViewModelType

extension ListingDeckViewModel: ListingDeckViewModelType {
    var rxIsChatEnabled: Observable<Bool> { return quickChatViewModel.rx.isChatEnabled }
    var rxObjectChanges: Observable<CollectionChange<ListingCellModel>> { return objects.changesObservable }
    var rxActionButtons: Observable<[UIAction]> { return actionButtons.asObservable() }
    var rxBumpUpBannerInfo: Observable<BumpUpInfo?> { return bumpUpBannerInfo.asObservable() }

    func openVideoPlayer() {
        openPhotoViewer()
    }
    func didTapActionButton() {
        actionButtons.value.first?.action()
    }
}

// MARK: Paginable

extension ListingDeckViewModel: Paginable {
    var objectCount: Int { return objects.value.count }

    var firstPage: Int { return pagination.first }
    var nextPage: Int { return pagination.next }
    var isLastPage: Bool { return pagination.isLast }
}

// MARK: Prefetching images

extension ListingDeckViewModel {

    private func prefetchingRange(atIndex index: Int, movement: CarouselMovement) -> CountableClosedRange<Int> {
        let range: CountableClosedRange<Int>
        switch movement {
        case .initial:
            range = (index - prefetching.previousCount)...(index + prefetching.nextCount)
        case .swipeRight:
            range = (index + 1)...(index + prefetching.nextCount)
        case .swipeLeft:
            range = (index - prefetching.previousCount)...(index - 1)
        default:
            range = (index - prefetching.previousCount)...(index + prefetching.nextCount)
        }
        return range
    }

    func prefetchNeighborsImages(_ index: Int, movement: CarouselMovement) {
        let range: CountableClosedRange<Int>
        switch movement {
        case .initial:
            range = (index - prefetching.previousCount)...(index + prefetching.nextCount)
        case .swipeRight:
            range = (index + 1)...(index + prefetching.nextCount)
        case .swipeLeft:
            range = (index - prefetching.previousCount)...(index - 1)
        default:
            range = (index - prefetching.previousCount)...(index + prefetching.nextCount)
        }
        var imagesToPrefetch: [URL] = []
        for index in range {
            guard !prefetchingIndexes.contains(index) else { continue }
            prefetchingIndexes.append(index)
            if let url = objects.value[safeAt: index]?.listing?.images.first?.fileURL {
                imagesToPrefetch.append(url)
            }
        }
        imageDownloader.downloadImagesWithURLs(imagesToPrefetch)
    }

    private static func isListable(_ model: ListingCellModel) -> Bool {
        guard let listing = model.listing else { return false }
        return !listing.status.isDiscarded
    }
}

extension ListingDeckViewModel: DeckCollectionViewModel {
    func cardModel(at index: Int) -> ListingCardModel? {
        guard let model = objects.value[safeAt: index] else { return nil }
        guard let price = model.listing?.priceString(freeModeAllowed: featureFlags.freePostingModeAllowed),
            let media = model.listing?.media else { return nil }

        return ListingCardModel(title: model.listing?.title,
                                price: price,
                                media: media)
    }
}

// MARK: Rx

typealias ListingDeckStatus = (status: ListingViewModelStatus, isFeatured: Bool)
extension ListingDeckViewModel: ReactiveCompatible {}
extension Reactive where Base: ListingDeckViewModel {
    var listingStatus: Driver<ListingDeckStatus> {
        let status = base.currentListingViewModel?.status.asObservable() ?? .just(.pending)
        let isFeatured = base.currentListingViewModel?.cardIsFeatured.asObservable()  ?? .just(false)

        let combined = Observable<ListingDeckStatus>.combineLatest(status, isFeatured) { ($0, $1) }
        return combined.asDriver(onErrorJustReturn: (.pending, false))
    }
}
