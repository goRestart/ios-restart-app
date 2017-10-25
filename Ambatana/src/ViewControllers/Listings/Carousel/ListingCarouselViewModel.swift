//
//  ListingCarouselViewModel.swift
//  LetGo
//
//  Created by Isaac Roldan on 14/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

protocol ListingCarouselViewModelDelegate: BaseViewModelDelegate {
    func vmRemoveMoreInfoTooltip()
    func vmShowOnboarding()

    // Forward from ListingViewModelDelegate
    func vmShowCarouselOptions(_ cancelLabel: String, actions: [UIAction])
    func vmShareViewControllerAndItem() -> (UIViewController, UIBarButtonItem?)
    func vmResetBumpUpBannerCountdown()
}

enum CarouselMovement {
    case tap, swipeLeft, swipeRight, initial
}

class ListingCarouselViewModel: BaseViewModel {

    // Paginable
    let firstPage: Int = 0
    var nextPage: Int = 1
    var isLastPage: Bool
    var isLoading: Bool = false

    var currentListingViewModel: ListingViewModel?
    let currentViewModelIsBeingUpdated = Variable<Bool>(false)
    let startIndex: Int
    fileprivate(set) var currentIndex: Int = 0 {
        didSet {
            // Just for pagination
            setCurrentIndex(currentIndex)
        }
    }
    
    weak var delegate: ListingCarouselViewModelDelegate?
    weak var navigator: ListingDetailNavigator? {
        didSet {
            currentListingViewModel?.navigator = navigator
        }
    }

    let objects = CollectionVariable<ListingCarouselCellModel>([])
    var objectChanges: Observable<CollectionChange<ListingCarouselCellModel>> {
        return objects.changesObservable
    }

    var objectCount: Int {
        return objects.value.count
    }

    var shouldShowMoreInfoTooltip: Bool {
        return !keyValueStorage[.listingMoreInfoTooltipDismissed]
    }
    
    let actionOnFirstAppear: ProductCarouselActionOnFirstAppear

    let productInfo = Variable<ListingVMProductInfo?>(nil)
    let productImageURLs = Variable<[URL]>([])
    let userInfo = Variable<ListingVMUserInfo?>(nil)
    let listingStats = Variable<ListingStats?>(nil)

    let navBarButtons = Variable<[UIAction]>([])
    let actionButtons = Variable<[UIAction]>([])

    let status = Variable<ListingViewModelStatus>(.pending)
    let isFeatured = Variable<Bool>(false)

    let quickAnswers = Variable<[[QuickAnswer]]>([[]])
    let quickAnswersAvailable = Variable<Bool>(false)

    let directChatEnabled = Variable<Bool>(false)
    var directChatPlaceholder = Variable<String>("")
    let directChatMessages = CollectionVariable<ChatViewMessage>([])

    let isFavorite = Variable<Bool>(false)
    let favoriteButtonState = Variable<ButtonState>(.enabled)
    let shareButtonState = Variable<ButtonState>(.hidden)
    let bumpUpBannerInfo = Variable<BumpUpInfo?>(nil)

    let socialMessage = Variable<SocialMessage?>(nil)
    let socialSharer = Variable<SocialSharer>(SocialSharer())

    // UI - Input
    let moreInfoState = Variable<MoreInfoState>(.hidden)

    // Image prefetching
    fileprivate let previousImagesToPrefetch = 1
    fileprivate let nextImagesToPrefetch = 3
    fileprivate var prefetchingIndexes: [Int] = []

    fileprivate var shouldShowOnboarding: Bool {
        let shouldShowOldOnboarding = !featureFlags.newCarouselNavigationTapNextPhotoEnabled.isActive
            && !keyValueStorage[.didShowListingDetailOnboarding]
        let shouldShowNewOnboarding = featureFlags.newCarouselNavigationTapNextPhotoEnabled.isActive
            && !keyValueStorage[.didShowHorizontalListingDetailOnboarding]
        return shouldShowOldOnboarding || shouldShowNewOnboarding
    }

    var imageScrollDirection: UICollectionViewScrollDirection {
        if featureFlags.newCarouselNavigationTapNextPhotoEnabled.isActive {
            return .horizontal
        }
        return .vertical
    }

    let imageHorizontalNavigationEnabled = Variable<Bool>(false)

    var isMyListing: Bool {
        return currentListingViewModel?.isMine ?? false
    }

    var isStatusLabelClickable: Bool {
        return featureFlags.featuredRibbonImprovementInDetail == .active
    }

    fileprivate var trackingIndex: Int?
    fileprivate var initialThumbnail: UIImage?

    private var activeDisposeBag = DisposeBag()

    fileprivate let source: EventParameterListingVisitSource
    fileprivate let listingListRequester: ListingListRequester
    fileprivate var productsViewModels: [String: ListingViewModel] = [:]
    fileprivate let keyValueStorage: KeyValueStorageable
    fileprivate let imageDownloader: ImageDownloaderType
    fileprivate let listingViewModelMaker: ListingViewModelMaker
    fileprivate let featureFlags: FeatureFlaggeable

    fileprivate let disposeBag = DisposeBag()

    override var active: Bool {
        didSet {
            currentListingViewModel?.active = active
        }
    }
    

    // MARK: - Init

    convenience init(listing: Listing,
                     listingListRequester: ListingListRequester,
                     source: EventParameterListingVisitSource,
                     actionOnFirstAppear: ProductCarouselActionOnFirstAppear,
                     trackingIndex: Int?) {
        self.init(productListModels: nil,
                  initialListing: listing,
                  thumbnailImage: nil,
                  listingListRequester: listingListRequester,
                  source: source,
                  actionOnFirstAppear: actionOnFirstAppear,
                  trackingIndex: trackingIndex,
                  firstProductSyncRequired: true)
    }

    convenience init(listing: Listing,
                     thumbnailImage: UIImage?,
                     listingListRequester: ListingListRequester,
                     source: EventParameterListingVisitSource,
                     actionOnFirstAppear: ProductCarouselActionOnFirstAppear,
                     trackingIndex: Int?) {
        self.init(productListModels: nil,
                  initialListing: listing,
                  thumbnailImage: thumbnailImage,
                  listingListRequester: listingListRequester,
                  source: source,
                  actionOnFirstAppear: actionOnFirstAppear,
                  trackingIndex: trackingIndex,
                  firstProductSyncRequired: false)
    }

    convenience init(productListModels: [ListingCellModel]?,
         initialListing: Listing?,
         thumbnailImage: UIImage?,
         listingListRequester: ListingListRequester,
         source: EventParameterListingVisitSource,
         actionOnFirstAppear: ProductCarouselActionOnFirstAppear,
         trackingIndex: Int?,
         firstProductSyncRequired: Bool) {
        self.init(productListModels: productListModels,
                  initialListing: initialListing,
                  thumbnailImage: thumbnailImage,
                  listingListRequester: listingListRequester,
                  source: source,
                  actionOnFirstAppear: actionOnFirstAppear,
                  trackingIndex: trackingIndex,
                  firstProductSyncRequired: firstProductSyncRequired,
                  featureFlags: FeatureFlags.sharedInstance,
                  keyValueStorage: KeyValueStorage.sharedInstance,
                  imageDownloader: ImageDownloader.sharedInstance,
                  listingViewModelMaker: ListingViewModel.ConvenienceMaker())
    }

    init(productListModels: [ListingCellModel]?,
         initialListing: Listing?,
         thumbnailImage: UIImage?,
         listingListRequester: ListingListRequester,
         source: EventParameterListingVisitSource,
         actionOnFirstAppear: ProductCarouselActionOnFirstAppear,
         trackingIndex: Int?,
         firstProductSyncRequired: Bool,
         featureFlags: FeatureFlaggeable,
         keyValueStorage: KeyValueStorageable,
         imageDownloader: ImageDownloaderType,
         listingViewModelMaker: ListingViewModelMaker) {
        if let productListModels = productListModels {
            self.objects.appendContentsOf(productListModels.flatMap(ListingCarouselCellModel.adapter))
            self.isLastPage = listingListRequester.isLastPage(productListModels.count)
        } else {
            self.objects.appendContentsOf([initialListing].flatMap{$0}.map(ListingCarouselCellModel.init))
            self.isLastPage = false
        }
        self.initialThumbnail = thumbnailImage
        self.listingListRequester = listingListRequester
        self.source = source
        self.actionOnFirstAppear = actionOnFirstAppear
        self.keyValueStorage = keyValueStorage
        self.imageDownloader = imageDownloader
        self.listingViewModelMaker = listingViewModelMaker
        self.featureFlags = featureFlags
        if let initialListing = initialListing {
            self.startIndex = objects.value.index(where: { $0.listing.objectId == initialListing.objectId}) ?? 0
        } else {
            self.startIndex = 0
        }
        self.currentIndex = startIndex
        super.init()
        self.trackingIndex = trackingIndex
        setupRxBindings()
        moveToProductAtIndex(startIndex, movement: .initial)

        if firstProductSyncRequired {
            syncFirstListing()
        }
    }

    override func didBecomeActive(_ firstTime: Bool) {
        if firstTime && shouldShowOnboarding {
            delegate?.vmShowOnboarding()
        }

        // Tracking
        currentListingViewModel?.trackVisit(.none, source: source, feedPosition: trackingFeedPosition)
    }
        
    private func syncFirstListing() {
        currentListingViewModel?.syncListing() { [weak self] in
            guard let strongSelf = self else { return }
            guard let listing = strongSelf.currentListingViewModel?.listing.value else { return }
            let newModel = ListingCarouselCellModel(listing: listing)
            strongSelf.objects.replace(strongSelf.startIndex, with: newModel)
        }
    }


    // MARK: - Public Methods

    func close() {
        navigator?.closeProductDetail()
    }

    func moveToProductAtIndex(_ index: Int, movement: CarouselMovement) {
        guard let viewModel = viewModelAt(index: index) else { return }
        currentListingViewModel?.active = false
        currentListingViewModel?.delegate = nil
        currentListingViewModel = viewModel
        currentListingViewModel?.delegate = self
        currentListingViewModel?.active = active
        currentIndex = index
        setupCurrentProductVMRxBindings(forIndex: index)
        prefetchNeighborsImages(index, movement: movement)

        // Tracking
        if active {
            let feedPosition = movement.feedPosition(for: trackingIndex)
            if source == .relatedListings {
                currentListingViewModel?.trackVisit(movement.visitUserAction,
                                                    source: movement.visitSource(source),
                                                    feedPosition: feedPosition)
            } else {
                currentListingViewModel?.trackVisit(movement.visitUserAction, source: source, feedPosition: feedPosition)
            }
        }
    }

    func listingCellModelAt(index: Int) -> ListingCarouselCellModel? {
        guard 0..<objectCount ~= index else { return nil }
        return objects.value[index]
    }
    
    func thumbnailAtIndex(_ index: Int) -> UIImage? {
        if index == startIndex { return initialThumbnail }
        return nil
    }

    func userAvatarPressed() {
        currentListingViewModel?.openProductOwnerProfile()
    }

    func directMessagesItemPressed() {
        currentListingViewModel?.chatWithSeller()
    }

    func send(quickAnswer: QuickAnswer) {
        currentListingViewModel?.sendQuickAnswer(quickAnswer: quickAnswer)
    }

    func send(directMessage: String, isDefaultText: Bool) {
        currentListingViewModel?.sendDirectMessage(directMessage, isDefaultText: isDefaultText)
    }

    func editButtonPressed() {
        currentListingViewModel?.editListing()
    }

    func favoriteButtonPressed() {
        currentListingViewModel?.switchFavorite()
    }

    func shareButtonPressed() {
        currentListingViewModel?.shareProduct()
    }

    func titleURLPressed(_ url: URL) {
        currentListingViewModel?.titleURLPressed(url)
    }

    func descriptionURLPressed(_ url: URL) {
        currentListingViewModel?.descriptionURLPressed(url)
    }

    func bumpUpBannerShown(type: BumpUpType) {
        currentListingViewModel?.trackBumpUpBannerShown(type: type)
    }
    
    func moveQuickAnswerToTheEnd(_ index: Int) {
        guard index >= 0 else { return }
        quickAnswers.value.move(fromIndex: index, toIndex: quickAnswers.value.count-1)
    }

    func statusLabelTapped() {
        print("⚡️⚡️⚡️⚡️⚡️")

    }
    
    
    // MARK: - Private Methods

    fileprivate func listingAt(index: Int) -> Listing? {
        return listingCellModelAt(index: index)?.listing
    }

    private func viewModelAt(index: Int) -> ListingViewModel? {
        guard let listing = listingAt(index: index) else { return nil }
        return viewModelFor(listing: listing)
    }
    
    private func viewModelFor(listing: Listing) -> ListingViewModel? {
        guard let listingId = listing.objectId else { return nil }
        if let vm = productsViewModels[listingId] {
            return vm
        }
        let vm = listingViewModelMaker.make(listing: listing, visitSource: source)
        vm.navigator = navigator
        productsViewModels[listingId] = vm
        return vm
    }

    private func setupRxBindings() {
        imageHorizontalNavigationEnabled.value = imageScrollDirection == .horizontal
        
        moreInfoState.asObservable().map { $0 == .shown }.distinctUntilChanged().filter { $0 }.bindNext { [weak self] _ in
            self?.currentListingViewModel?.trackVisitMoreInfo()
            self?.keyValueStorage[.listingMoreInfoTooltipDismissed] = true
            self?.delegate?.vmRemoveMoreInfoTooltip()
        }.addDisposableTo(disposeBag)
    }

    private func setupCurrentProductVMRxBindings(forIndex index: Int) {
        activeDisposeBag = DisposeBag()
        guard let currentVM = currentListingViewModel else { return }
        currentVM.listing.asObservable().skip(1).bindNext { [weak self] updatedListing in
            guard let strongSelf = self else { return }
            strongSelf.currentViewModelIsBeingUpdated.value = true
            strongSelf.objects.replace(index, with: ListingCarouselCellModel(listing:updatedListing))
            strongSelf.currentViewModelIsBeingUpdated.value = false
        }.addDisposableTo(activeDisposeBag)

        currentVM.status.asObservable().bindTo(status).addDisposableTo(activeDisposeBag)
        currentVM.isShowingFeaturedStripe.asObservable().bindTo(isFeatured).addDisposableTo(activeDisposeBag)

        currentVM.productInfo.asObservable().bindTo(productInfo).addDisposableTo(activeDisposeBag)
        currentVM.productImageURLs.asObservable().bindTo(productImageURLs).addDisposableTo(activeDisposeBag)
        currentVM.userInfo.asObservable().bindTo(userInfo).addDisposableTo(activeDisposeBag)
        currentVM.listingStats.asObservable().bindTo(listingStats).addDisposableTo(activeDisposeBag)

        currentVM.actionButtons.asObservable().bindTo(actionButtons).addDisposableTo(activeDisposeBag)
        currentVM.navBarButtons.asObservable().bindTo(navBarButtons).addDisposableTo(activeDisposeBag)

        quickAnswers.value = currentVM.quickAnswers
        currentVM.directChatEnabled.asObservable().bindTo(quickAnswersAvailable).addDisposableTo(activeDisposeBag)

        currentVM.directChatEnabled.asObservable().bindTo(directChatEnabled).addDisposableTo(activeDisposeBag)
        directChatMessages.removeAll()
        currentVM.directChatMessages.changesObservable.subscribeNext { [weak self] change in
            self?.performCollectionChange(change: change)
        }.addDisposableTo(activeDisposeBag)
        directChatPlaceholder.value = currentVM.directChatPlaceholder

        currentVM.isFavorite.asObservable().bindTo(isFavorite).addDisposableTo(activeDisposeBag)
        currentVM.favoriteButtonState.asObservable().bindTo(favoriteButtonState).addDisposableTo(activeDisposeBag)
        currentVM.shareButtonState.asObservable().bindTo(shareButtonState).addDisposableTo(activeDisposeBag)
        currentVM.bumpUpBannerInfo.asObservable().bindTo(bumpUpBannerInfo).addDisposableTo(activeDisposeBag)

        currentVM.socialMessage.asObservable().bindTo(socialMessage).addDisposableTo(activeDisposeBag)
        socialSharer.value = currentVM.socialSharer

        moreInfoState.asObservable().bindTo(currentVM.moreInfoState).addDisposableTo(activeDisposeBag)
    }
    
    private func performCollectionChange(change: CollectionChange<ChatViewMessage>) {
        switch change {
        case let .insert(index, value):
            directChatMessages.insert(value, atIndex: index)
        case let .remove(index, _):
            directChatMessages.removeAtIndex(index)
        case let .swap(fromIndex, toIndex, replacingWith):
            directChatMessages.swap(fromIndex: fromIndex, toIndex: toIndex, replacingWith: replacingWith)
        case let .move(fromIndex, toIndex, replacingWith):
            directChatMessages.move(fromIndex: fromIndex, toIndex: toIndex, replacingWith: replacingWith)
        case let .composite(changes):
            for change in changes {
                performCollectionChange(change: change)
            }            
        }
    }
}

extension ListingCarouselViewModel: Paginable {
    func retrievePage(_ page: Int) {
        let isFirstPage = (page == firstPage)
        isLoading = true
        
        let completion: ListingsRequesterCompletion = { [weak self] result in
            guard let strongSelf = self else { return }
            self?.isLoading = false
            if let newListings = result.listingsResult.value {
                strongSelf.nextPage = strongSelf.nextPage + 1
                strongSelf.objects.appendContentsOf(newListings.map(ListingCarouselCellModel.init))
                
                strongSelf.isLastPage = strongSelf.listingListRequester.isLastPage(newListings.count)
                if newListings.isEmpty && !strongSelf.isLastPage {
                    strongSelf.retrieveNextPage()
                }
            }
        }
        
        if isFirstPage {
            listingListRequester.retrieveFirstPage(completion)
        } else {
            listingListRequester.retrieveNextPage(completion)
        }
    }
}


// MARK: > Image PreCaching

extension ListingCarouselViewModel {
    func prefetchNeighborsImages(_ index: Int, movement: CarouselMovement) {
        let range: CountableClosedRange<Int>
        switch movement {
        case .initial:
            range = (index-previousImagesToPrefetch)...(index+nextImagesToPrefetch)
        case .tap, .swipeRight:
            range = (index+1)...(index+nextImagesToPrefetch)
        case .swipeLeft:
            range = (index-previousImagesToPrefetch)...(index-1)
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
}


// MARK: - ListingViewModelDelegate

extension ListingCarouselViewModel: ListingViewModelDelegate {
    // ListingViewModelDelegate forwarding methods
    func vmShowProductDetailOptions(_ cancelLabel: String, actions: [UIAction]) {
        var finalActions: [UIAction] = actions

        //Adding show onboarding action
        let title = LGLocalizedString.productOnboardingShowAgainButtonTitle
        finalActions.append(UIAction(interface: .text(title), action: { [weak self] in
            self?.delegate?.vmShowOnboarding()
        }))
        delegate?.vmShowCarouselOptions(cancelLabel, actions: finalActions)
    }

    func vmShareViewControllerAndItem() -> (UIViewController, UIBarButtonItem?) {
        guard let delegate = delegate else { return (UIViewController(), nil) }
        return delegate.vmShareViewControllerAndItem()
    }

    var trackingFeedPosition: EventParameterFeedPosition {
        if let trackingIndex = trackingIndex, currentIndex == startIndex {
            return .position(index: trackingIndex)
        } else {
            return .none
        }
    }
    
    func vmResetBumpUpBannerCountdown() {
        delegate?.vmResetBumpUpBannerCountdown()
    }

    // BaseViewModelDelegate forwarding methods
    
    func vmShowAutoFadingMessage(_ message: String, completion: (() -> ())?) {
        delegate?.vmShowAutoFadingMessage(message, completion: completion)
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
    func vmOpenInternalURL(_ url: URL) {
        delegate?.vmOpenInternalURL(url)
    }
    func vmPop() {
        delegate?.vmPop()
    }
    func vmDismiss(_ completion: (() -> Void)?) {
        delegate?.vmDismiss(completion)
    }
}



// MARK: - Tracking

extension CarouselMovement {
    func visitSource(_ originSource: EventParameterListingVisitSource) -> EventParameterListingVisitSource {
        switch self {
        case .tap:
            return .next
        case .swipeRight:
            return .next
        case .initial:
            return originSource
        case .swipeLeft:
            return .previous
        }
    }

    var visitUserAction: ListingVisitUserAction {
        switch self {
        case .tap:
            return .tap
        case .swipeLeft:
            return .swipeLeft
        case .swipeRight:
            return .swipeRight
        case .initial:
            return .none
        }
    }
    func feedPosition(for index: Int?) -> EventParameterFeedPosition {
        guard let index = index else  { return .none }
        switch self {
        case .tap, .swipeLeft, .swipeRight:
            return .none
        case .initial:
            return .position(index: index)
        }
    }
}
