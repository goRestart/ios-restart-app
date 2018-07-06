import Foundation
import LGCoreKit
import RxSwift
import GoogleMobileAds
import LGComponents

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

    var pagination: Pagination

    // Just for pagination
    fileprivate(set) var currentIndex: Int = 0 { didSet { setCurrentIndex(currentIndex) } }
    var isNextPageAvailable: Bool { return !pagination.isLast }
    var isLoading = false

    let prefetching: Prefetching
    fileprivate var prefetchingIndexes: [Int] = []

    let startIndex: Int
    var shouldSyncFirstListing: Bool = false
    fileprivate let trackingIndex: Int?

    fileprivate var lastMovement: CarouselMovement = .initial
    fileprivate let source: EventParameterListingVisitSource
    fileprivate let listingListRequester: ListingListRequester
    fileprivate let userRepository: MyUserRepository
    fileprivate var productsViewModels: [String: ListingViewModel] = [:]
    fileprivate let listingViewModelMaker: ListingViewModelMaker
    fileprivate let tracker: Tracker
    private let featureFlags: FeatureFlaggeable

    let actionOnFirstAppear: DeckActionOnFirstAppear
    let objects = CollectionVariable<ListingCellModel>([])

    let binder: ListingDeckViewModelBinder

    lazy var actionButtons = Variable<[UIAction]>([])
    var navBarButtons: [UIAction] { return currentListingViewModel?.navBarActionsNewItemPage ?? [] }

    let quickChatViewModel = QuickChatViewModel()
    lazy var bumpUpBannerInfo = Variable<BumpUpInfo?>(nil)

    let imageDownloader: ImageDownloaderType

    weak var delegate: ListingDeckViewModelDelegate?

    weak var currentListingViewModel: ListingViewModel?
    var isPlayable: Bool { return currentListingViewModel?.isPlayable ?? false }

    weak var navigator: ListingDetailNavigator? { didSet { currentListingViewModel?.navigator = navigator } }
    weak var deckNavigator: DeckNavigator?
    var userHasScrolled: Bool = false

    override var active: Bool {
        didSet {
            productsViewModels.forEach { (_, listingViewModel) in
                listingViewModel.active = active
            }
        }
    }

    private var shouldShowDeckOnBoarding: Bool {
        return !userHasScrolled && !keyValueStorage[.didShowDeckOnBoarding]
    }
    private let keyValueStorage: KeyValueStorageable
    
    fileprivate let adsRequester: AdsRequester
    
    convenience init(listModels: [ListingCellModel],
                     listing: Listing,
                     listingListRequester: ListingListRequester,
                     source: EventParameterListingVisitSource,
                     detailNavigator: ListingDetailNavigator,
                     actionOnFirstAppear: DeckActionOnFirstAppear,
                     trackingIndex: Int?) {
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
                  keyValueStorage: KeyValueStorage.sharedInstance,
                  featureFlags: FeatureFlags.sharedInstance,
                  adsRequester: AdsRequester())
    }

    convenience init(listModels: [ListingCellModel],
                     initialListing: Listing?,
                     listingListRequester: ListingListRequester,
                     detailNavigator: ListingDetailNavigator,
                     source: EventParameterListingVisitSource,
                     imageDownloader: ImageDownloaderType,
                     listingViewModelMaker: ListingViewModelMaker,
                     shouldSyncFirstListing: Bool,
                     binder: ListingDeckViewModelBinder,
                     actionOnFirstAppear: DeckActionOnFirstAppear,
                     trackingIndex: Int?) {
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
                  keyValueStorage: KeyValueStorage.sharedInstance,
                  featureFlags: FeatureFlags.sharedInstance,
                  adsRequester: AdsRequester())
    }

    init(listModels: [ListingCellModel],
         initialListing: Listing?,
         listingListRequester: ListingListRequester,
         detailNavigator: ListingDetailNavigator,
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
            self.objects.appendContentsOf([initialListing].flatMap{ $0 }.map { .listingCell(listing: $0) })
            self.pagination.isLast = false
        }
        if let listing = initialListing {
            startIndex = objects.value.index(where: {
                guard let aListing = $0.listing else { return false }
                return aListing.objectId == listing.objectId
            }) ?? 0
        } else {
            startIndex = 0
        }
        currentIndex = startIndex
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
        guard let viewModel = viewModelAt(index: index) else { return }
        lastMovement = movement
        if active {
            currentListingViewModel?.active = false
            currentListingViewModel?.delegate = nil
            currentListingViewModel = viewModel
            currentListingViewModel?.delegate = self

            quickChatViewModel.listingViewModel = currentListingViewModel
            binder.bind(to:viewModel, quickChatViewModel: quickChatViewModel)

            currentIndex = index
            prefetchViewModels(index, movement: movement)
            prefetchNeighborsImages(index, movement: movement)

        // Tracking
            let feedPosition = trackingFeedPosition
            if source == .relatedListings {
                currentListingViewModel?.trackVisit(movement.visitUserAction,
                                                    source: movement.visitSource(source),
                                                    feedPosition: feedPosition)
            } else {
                currentListingViewModel?.trackVisit(movement.visitUserAction,
                                                    source: source,
                                                    feedPosition: feedPosition)
            }
        }
    }

    func didMoveToListing() {
        // embrace a smooth scroll experience with delayed activation
        delay(0.1) { [weak self] in self?.currentListingViewModel?.active = true }
    }

    func didTapCardAction() {
        if let isFav = currentListingViewModel?.cardIsFavoritable, isFav {
            currentListingViewModel?.switchFavorite()
        } else {
            currentListingViewModel?.editListing()
        }
    }

    func listingCellModelAt(index: Int) -> ListingCardViewCellModel? {
        guard 0..<objectCount ~= index, let listing = objects.value[index].listing else { return nil }
        return viewModelFor(listing: listing)
    }

    func snapshotModelAt(index: Int) -> ListingDeckSnapshotType? {
        guard 0..<objectCount ~= index, let listing = objects.value[index].listing else { return nil }
        if let listingId = listing.objectId, let viewModel = productsViewModels[listingId] {
            return listingViewModelMaker.makeListingDeckSnapshot(listingViewModel: viewModel)
        }
        return listingViewModelMaker.makeListingDeckSnapshot(listing: listing)
    }

    fileprivate func listingAt(index: Int) -> Listing? {
        guard 0..<objectCount ~= index, let listing = objects.value[index].listing else { return nil }
        return listing
    }

    fileprivate func viewModelAt(index: Int) -> ListingViewModel? {
        guard let listing = listingAt(index: index) else { return nil }
        return viewModelFor(listing: listing)
    }

    func viewModelFor(listing: Listing) -> ListingViewModel? {
        guard let listingId = listing.objectId else { return nil }
        if let viewModel = productsViewModels[listingId] {
            return viewModel
        }
        let vm = listingViewModelMaker.make(listing: listing, navigator: navigator, visitSource: source)
        productsViewModels[listingId] = vm
        return vm
    }

    func performCollectionChange(change: CollectionChange<ChatViewMessage>) {
        switch change {
        case let .insert(index, value):
            quickChatViewModel.directChatMessages.insert(value, atIndex: index)
        case let .remove(index, _):
            quickChatViewModel.directChatMessages.removeAtIndex(index)
        case let .swap(fromIndex, toIndex, replacingWith):
            quickChatViewModel.directChatMessages.swap(fromIndex: fromIndex, toIndex: toIndex, replacingWith: replacingWith)
        case let .move(fromIndex, toIndex, replacingWith):
            quickChatViewModel.directChatMessages.move(fromIndex: fromIndex, toIndex: toIndex, replacingWith: replacingWith)
        case let .composite(changes):
            for change in changes {
                performCollectionChange(change: change)
            }
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

    // MARK: Tracking

    func bumpUpBannerShown(type: BumpUpType) {
        currentListingViewModel?.trackBumpUpBannerShown(type: type,
                                                        storeProductId: currentListingViewModel?.storeProductId)
    }
    
    func interstitialAdTapped(typePage: EventParameterTypePage) {
        let adType = AdRequestType.interstitial.trackingParamValue
        let isMine = EventParameterBoolean(bool: currentListingViewModel?.isMine)
        let feedPosition: EventParameterFeedPosition = .position(index: currentIndex)
        let willLeave = EventParameterBoolean(bool: true)
        currentListingViewModel?.trackInterstitialAdTapped(adType: adType,
                                                           isMine: isMine,
                                                           feedPosition: feedPosition,
                                                           willLeaveApp: willLeave,
                                                           typePage: typePage)
    }
    
    func interstitialAdShown(typePage: EventParameterTypePage) {
        let adType = AdRequestType.interstitial.trackingParamValue
        let isMine = EventParameterBoolean(bool: currentListingViewModel?.isMine)
        let feedPosition: EventParameterFeedPosition = .position(index: currentIndex)
        let adShown = EventParameterBoolean(bool: true)
        currentListingViewModel?.trackInterstitialAdShown(adType: adType,
                                                          isMine: isMine,
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
        currentListingViewModel?.trackOpenFeaturedInfo()
    }

    func didTapReputationTooltip() {
        navigator?.openUserVerificationView()
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

    func cachedImageAtIndex(_ index: Int) -> UIImage? {
        guard let url = urlAtIndex(0),
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

    func showUser() {
        currentListingViewModel?.openProductOwnerProfile()
    }

    func urlAtIndex(_ index: Int) -> URL? {
        guard let urls = currentListingViewModel?.productImageURLs.value else { return nil }
        guard index >= 0 && index < urls.count else { return nil }

        return urls[index]
    }

    func didShowMoreInfo() {
        let isMine = EventParameterBoolean(bool: currentListingViewModel?.isMine)
        currentListingViewModel?.trackVisitMoreInfo(isMine: isMine,
                                                          adShown: .notAvailable,
                                                          adType: nil,
                                                          queryType: nil,
                                                          query: nil,
                                                          visibility: nil,
                                                          errorReason: nil)
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
    var rxIsChatEnabled: Observable<Bool> { return quickChatViewModel.rxIsChatEnabled }
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

    func prefetchAtIndexes(_ indexes: CountableClosedRange<Int>) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            indexes.forEach { _ = self?.viewModelAt(index: $0) }
        }
    }

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

    func prefetchViewModels(_ index: Int, movement: CarouselMovement) {
        prefetchAtIndexes(prefetchingRange(atIndex: index, movement: movement))
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
            if let imageUrl = listingAt(index: index)?.images.first?.fileURL {
                imagesToPrefetch.append(imageUrl)
            }
        }
        imageDownloader.downloadImagesWithURLs(imagesToPrefetch)
    }

    private static func isListable(_ model: ListingCellModel) -> Bool {
        guard let listing = model.listing else { return false }
        return !listing.status.isDiscarded
    }

}
