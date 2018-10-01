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

    private let disposeBag = DisposeBag()

    let objects = CollectionVariable<ListingCellModel>([])

    let currentListingViewModel: ListingViewModel
    var navigator: ListingDeckNavigator?

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

    private let listingViewModelAssembly: ListingViewModelAssembly
    private let listingTracker: ListingTracker

    private let featureFlags: FeatureFlaggeable

    private let actionOnFirstAppear: DeckActionOnFirstAppear

    fileprivate let actionButtons = Variable<[UIAction]>([])
    var navBarButtons: [UIAction] { return currentListingViewModel.navBarActionsNewItemPage }

    private let quickChatViewModel = QuickChatViewModel()
    let bumpUpBannerInfo = Variable<BumpUpInfo?>(nil)
    fileprivate let isFavorite: BehaviorRelay<Bool> = .init(value: false)
    private var favoriteCache: [String: Bool] = [:]

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
        didSet { currentListingViewModel.active = active }
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
                     viewModelMaker: ListingViewModelAssembly,
                     listingListRequester: ListingListRequester,
                     source: EventParameterListingVisitSource,
                     actionOnFirstAppear: DeckActionOnFirstAppear,
                     trackingIndex: Int?,
                     trackingIdentifier: String?) {
        let pagination = Pagination.makePagination(first: 0, next: 1, isLast: false)
        let prefetching = Prefetching(previousCount: 3, nextCount: 3)
        self.init(listModels: listModels,
                  initialListing: listing,
                  viewModelMaker: viewModelMaker,
                  listingListRequester: listingListRequester,
                  source: source,
                  imageDownloader: ImageDownloader.make(usingImagePool: true),
                  myUserRepository: Core.myUserRepository,
                  pagination: pagination,
                  prefetching: prefetching,
                  shouldSyncFirstListing: false,
                  tracker: ListingTracker(),
                  actionOnFirstAppear: actionOnFirstAppear,
                  trackingIndex: trackingIndex,
                  trackingIdentifier: trackingIdentifier,
                  keyValueStorage: KeyValueStorage.sharedInstance,
                  featureFlags: FeatureFlags.sharedInstance,
                  adsRequester: AdsRequester())
    }

    convenience init(listModels: [ListingCellModel],
                     initialListing: Listing,
                     viewModelMaker: ListingViewModelAssembly,
                     listingListRequester: ListingListRequester,
                     source: EventParameterListingVisitSource,
                     imageDownloader: ImageDownloaderType,
                     listingViewModelAssembly: ListingViewModelAssembly,
                     shouldSyncFirstListing: Bool,
                     actionOnFirstAppear: DeckActionOnFirstAppear,
                     trackingIndex: Int?,
                     trackingIdentifier: String?) {
        let pagination = Pagination.makePagination(first: 0, next: 1, isLast: false)
        let prefetching = Prefetching(previousCount: 1, nextCount: 3)
        self.init(listModels: listModels,
                  initialListing: initialListing,
                  viewModelMaker: viewModelMaker,
                  listingListRequester: listingListRequester,
                  source: source,
                  imageDownloader: imageDownloader,
                  myUserRepository: Core.myUserRepository,
                  pagination: pagination,
                  prefetching: prefetching,
                  shouldSyncFirstListing: shouldSyncFirstListing,
                  tracker: ListingTracker(),
                  actionOnFirstAppear: actionOnFirstAppear,
                  trackingIndex: trackingIndex,
                  trackingIdentifier: trackingIdentifier,
                  keyValueStorage: KeyValueStorage.sharedInstance,
                  featureFlags: FeatureFlags.sharedInstance,
                  adsRequester: AdsRequester())
    }

    init(listModels: [ListingCellModel],
         initialListing: Listing,
         viewModelMaker: ListingViewModelAssembly,
         listingListRequester: ListingListRequester,
         source: EventParameterListingVisitSource,
         imageDownloader: ImageDownloaderType,
         myUserRepository: MyUserRepository,
         pagination: Pagination,
         prefetching: Prefetching,
         shouldSyncFirstListing: Bool,
         tracker: ListingTracker,
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
        self.listingViewModelAssembly = viewModelMaker
        self.source = source
        self.userRepository = myUserRepository
        self.listingTracker = tracker
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
        currentListingViewModel = listingViewModelAssembly.build(listing: initialListing, visitSource: source)
        quickChatViewModel.listingViewModel = currentListingViewModel

        currentIndex = startIndex
        self.trackingIdentifier = trackingIdentifier
        super.init()
        self.shouldSyncFirstListing = shouldSyncFirstListing
    }

    override func didBecomeActive(_ firstTime: Bool) {
        if shouldSyncFirstListing {
            syncFirstListing()
        }
        if firstTime {
            bind(to: currentListingViewModel)
            processActionOnFirstAppear()
        }
        moveToListingAtIndex(currentIndex, movement: .initial)
    }

    private func processActionOnFirstAppear() {
        switch actionOnFirstAppear {
        case .showKeyboard: // we no longer support this one
            break
        case .showShareSheet:
            currentListingViewModel.shareProduct()
        case .triggerBumpUp:
            showBumpUpView(actionOnFirstAppear)
        case .triggerMarkAsSold:
            currentListingViewModel.markAsSold()
        case .edit:
            currentListingViewModel.editListing()
        case .nonexistent:
            break
        }
    }

    func moveToListingAtIndex(_ index: Int, movement: DeckMovement) {
        guard let listing = objects.value[safeAt: index]?.listing else { return }
        lastMovement = movement
        if active {
            currentListingViewModel.delegate = nil
            currentListingViewModel.active = false
            currentListingViewModel.listing.value = listing
            forceCurrentUpdate(listing: listing)
            currentListingViewModel.active = true
            currentListingViewModel.delegate = self
            quickChatViewModel.sectionFeedChatTrackingInfo = sectionFeedChatTrackingInfo

            currentIndex = index
            prefetchNeighborsImages(index, movement: movement)

            // Tracking ABIOS-4531
        }
    }

    private func forceCurrentUpdate(listing: Listing) {
        currentListingViewModel.forcedUpdate()
        guard let objectId = listing.objectId,
            let cachedValue = favoriteCache[objectId] else {
                isFavorite.accept(false)
                return
        }
        isFavorite.accept(cachedValue)
    }

    private func bind(to current: ListingViewModel) {
        current.listing
            .asObservable()
            .bind { [weak self] listing in
                guard let strongSelf = self else { return }
                guard let index = strongSelf.objects.value.index(where: {
                    $0.listing?.objectId == listing.objectId
                }) else { return }
                strongSelf.replaceListingCellModelAtIndex(index, withListing: listing)
            }.disposed(by: disposeBag)
        current.isFavorite.asObservable().bind { [weak self] in
            self?.isFavorite.accept($0)
            if let listingID = current.listing.value.objectId {
                self?.favoriteCache[listingID] = $0
            }
        }.disposed(by: disposeBag)
        current.actionButtons.asObservable().bind(to: actionButtons).disposed(by: disposeBag)
        current.cardBumpUpBannerInfo.bind(to: bumpUpBannerInfo).disposed(by: disposeBag)

    }

    @objc func edit() {
        currentListingViewModel.editListing()
    }

    @objc func share() {
        currentListingViewModel.shareProduct()
    }

    @objc func switchFavorite() {
        currentListingViewModel.switchFavorite()
    }

    private func syncFirstListing() {
        currentListingViewModel.syncListing() { [weak self] in
            guard let strongSelf = self else { return }
            let listing = strongSelf.currentListingViewModel.listing.value
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
        let listing = currentListingViewModel.listing.value
        listingTracker.trackBumpUpBannerShown(listing,
                                              type: bumpInfo.type,
                                              storeProductId: currentListingViewModel.storeProductId)
    }

    func interstitialAdTapped(typePage: EventParameterTypePage) {
        let adType = AdRequestType.interstitial.trackingParamValueFor(size: nil)
        let feedPosition: EventParameterFeedPosition = .position(index: currentIndex)
        let willLeave = EventParameterBoolean(bool: true)

        let listing = currentListingViewModel.listing.value
        listingTracker.trackInterstitialAdTapped(listing,
                                                 adType: adType,
                                                 feedPosition: feedPosition,
                                                 willLeaveApp: willLeave,
                                                 typePage: typePage)
    }
    
    func interstitialAdShown(typePage: EventParameterTypePage) {
        let adType = AdRequestType.interstitial.trackingParamValueFor(size: nil)
        let feedPosition: EventParameterFeedPosition = .position(index: currentIndex)
        let adShown = EventParameterBoolean(bool: true)

        let listing = currentListingViewModel.listing.value
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
        listingTracker.trackOpenFeaturedInfo(currentListingViewModel.listing.value)
    }

    func close() {
        if shouldShowDeckOnBoarding {
            showOnBoarding()
        } else {
            navigator?.close()
        }
    }

    func showOnBoarding() {
        navigator?.openOnboarding()
        keyValueStorage[.didShowDeckOnBoarding] = true
    }

    func didShowCardsGesturesOnBoarding() {
        keyValueStorage[.didShowCardGesturesOnBoarding] = true
    }

    func showListingDetail() {
        navigator?.openListingDetail(withVM: currentListingViewModel, source: source)
    }

    func showBumpUpView(_ action: DeckActionOnFirstAppear) {

        if case .triggerBumpUp(let purchases,
                               let maxCountdown,
                               let bumpUpType,
                               let triggerBumpUpSource,
                               let typePage) = action {
            currentListingViewModel.showBumpUpView(purchases: purchases,
                                                   maxCountdown: maxCountdown,
                                                   bumpUpType: bumpUpType,
                                                   bumpUpSource: triggerBumpUpSource,
                                                   typePage: typePage)
        }
    }

    func didTapActionButton() {
        actionButtons.value.first?.action()
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

struct ListingAction: Equatable {
    let isFavorite: Bool
    let isFavoritable: Bool
    let isEditable: Bool
}
typealias ListingDeckStatus = (status: ListingViewModelStatus, isFeatured: Bool)
extension ListingDeckViewModel: ReactiveCompatible {}
extension Reactive where Base: ListingDeckViewModel {
    var listingStatus: Driver<ListingDeckStatus> {
        let status = base.currentListingViewModel.status.asObservable()
        let isFeatured = base.currentListingViewModel.cardIsFeatured.asObservable()

        let combined = Observable<ListingDeckStatus>.combineLatest(status, isFeatured) { ($0, $1) }
        return combined.asDriver(onErrorJustReturn: (.pending, false))
    }

    var listingAction: Driver<ListingAction> {
        let isFavorite = base.isFavorite.asObservable()
        let isFavoritable = isMine.map { return !$0 }
        let isEditable = base.currentListingViewModel.status.asObservable().map { return $0.isEditable }

        return Observable.combineLatest(isFavorite, isFavoritable, isEditable) { ($0, $1, $2) }
            .map { return ListingAction(isFavorite: $0, isFavoritable: $1, isEditable: $2) }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: ListingAction(isFavorite: false, isFavoritable: false, isEditable: false))
    }
    var isMine: Observable<Bool> {
        return base.currentListingViewModel.productIsFavoriteable.asObservable().map { return !$0 }
    }

    var objectChanges: Observable<CollectionChange<ListingCellModel>> { return base.objects.changesObservable }
    var actionButtons: Observable<[UIAction]> { return base.actionButtons.asObservable() }
    var bumpUpBannerInfo: Observable<BumpUpInfo?> { return base.bumpUpBannerInfo.asObservable() }
}
