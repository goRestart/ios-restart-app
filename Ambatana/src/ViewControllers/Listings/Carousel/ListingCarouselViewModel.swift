//
//  ListingCarouselViewModel.swift
//  LetGo
//
//  Created by Isaac Roldan on 14/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift
import GoogleMobileAds

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

enum AdRequestType {
    case dfp
    case moPub

    var trackingParamValue: EventParameterAdType {
        switch self {
        case .dfp:
            return .dfp
        case .moPub:
            return .moPub
        }
    }
}

enum AdRequestQueryType {
    case listingTitle
    case listingAutoTitle
    case listingCategory
    case hardcoded

    var trackingParamValue: EventParameterAdQueryType {
        switch self {
        case .listingTitle:
            return .title
        case .listingAutoTitle:
            return .cloudsight
        case .listingCategory:
            return .category
        case .hardcoded:
            return .hardcoded
        }
    }
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
    fileprivate var lastMovement: CarouselMovement = .initial
    
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
    let altActions = Variable<[UIAction]>([])

    let status = Variable<ListingViewModelStatus>(.pending)
    let isFeatured = Variable<Bool>(false)

    let ownerIsProfessional = Variable<Bool>(false)
    let showExactLocationOnMap = Variable<Bool>(true)
    let ownerPhoneNumber = Variable<String?>(nil)
    var deviceCanCall: Bool {
        return PhoneCallsHelper.deviceCanCall
    }

    let quickAnswers = Variable<[QuickAnswer]>([])
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

    fileprivate var shouldShowOnboarding: Bool { return !keyValueStorage[.didShowListingDetailOnboarding] }

    var imageScrollDirection: UICollectionViewScrollDirection = .vertical

    var isMyListing: Bool {
        return currentListingViewModel?.isMine ?? false
    }

    var isPlayable: Bool { return currentListingViewModel?.isPlayable ?? false }

    fileprivate var trackingIndex: Int?
    fileprivate var initialThumbnail: UIImage?

    private var activeDisposeBag = DisposeBag()

    fileprivate let source: EventParameterListingVisitSource
    fileprivate let listingListRequester: ListingListRequester
    fileprivate var productsViewModels: [String: ListingViewModel] = [:]
    fileprivate let keyValueStorage: KeyValueStorageable
    fileprivate let imageDownloader: ImageDownloaderType
    fileprivate let listingViewModelMaker: ListingViewModelMaker
    let featureFlags: FeatureFlaggeable
    fileprivate let locationManager: LocationManager
    fileprivate let myUserRepository: MyUserRepository

    fileprivate let disposeBag = DisposeBag()

    override var active: Bool {
        didSet {
            currentListingViewModel?.active = active
        }
    }

    fileprivate let adsRequester: AdsRequester

    // Ads
    var dfpAdUnitId: String {
        return featureFlags.moreInfoDFPAdUnitId
    }
    var adActive: Bool {
        return !isMyListing && userShouldSeeAds
    }

    var userShouldSeeAds: Bool {
        let myUserCreationDate: Date? = myUserRepository.myUser?.creationDate
        return featureFlags.noAdsInFeedForNewUsers.shouldShowAdsInMoreInfoForUser(createdIn: myUserCreationDate)
    }

    var dfpContentURL: String? {
        guard let listingId = currentListingViewModel?.listing.value.objectId else { return nil}
        return LetgoURLHelper.buildProductURL(listingId: listingId)?.absoluteString
    }
    var randomHardcodedAdQuery: String {
        let popularItems = ["ps4", "iphone", LGLocalizedString.productPostIncentiveDresser]
        let term = popularItems.random() ?? "iphone"
        return term
    }

    var currentAdRequestType: AdRequestType? {
        return adActive ? .dfp : nil
    }
    var currentAdRequestQueryType: AdRequestQueryType? = nil
    var adRequestQuery: String? = nil
    var adBannerTrackingStatus: AdBannerTrackingStatus? = nil
    let sideMargin: CGFloat = DeviceFamily.current.isWiderOrEqualThan(.iPhone6) ? Metrics.margin : 0

    var meetingsEnabled: Bool {
        return featureFlags.chatNorris.isActive
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
                  listingViewModelMaker: ListingViewModel.ConvenienceMaker(),
                  adsRequester: AdsRequester(),
                  locationManager: Core.locationManager,
                  myUserRepository: Core.myUserRepository)
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
         listingViewModelMaker: ListingViewModelMaker,
         adsRequester: AdsRequester,
         locationManager: LocationManager,
         myUserRepository: MyUserRepository) {
        if let productListModels = productListModels {
            let listingCarouselCellModels = productListModels
                .flatMap(ListingCarouselCellModel.adapter)
                .filter(featureFlags.discardedProducts.notDiscarded)
            self.objects.appendContentsOf(listingCarouselCellModels)
            self.isLastPage = listingListRequester.isLastPage(productListModels.count)
        } else {
            let listingCarouselCellModels = [initialListing]
                .flatMap{$0}
                .map(ListingCarouselCellModel.init)
                .filter(featureFlags.discardedProducts.notDiscarded)
            self.objects.appendContentsOf(listingCarouselCellModels)
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
        self.adsRequester = adsRequester
        self.locationManager = locationManager
        self.myUserRepository = myUserRepository
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
        adBannerTrackingStatus = nil
        currentListingViewModel?.active = false
        currentListingViewModel?.delegate = nil
        currentListingViewModel = viewModel
        currentListingViewModel?.delegate = self
        currentListingViewModel?.active = active
        currentIndex = index
        lastMovement = movement
        setupCurrentProductVMRxBindings(forIndex: index)
        prefetchNeighborsImages(index, movement: movement)

        if active {
            currentListingViewModel?.trackVisit(movement.visitUserAction,
                                                source: movement.visitSource(source),
                                                feedPosition: movement.feedPosition(for: trackingIndex))
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

    func videoButtonTapped() {
        currentListingViewModel?.openVideoPlayer(atIndex: 0, source: source)
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
        currentListingViewModel?.trackBumpUpBannerShown(type: type, storeProductId: currentListingViewModel?.storeProductId)
    }

    func showBumpUpView(bumpUpProductData: BumpUpProductData,
                        bumpUpType: BumpUpType,
                        bumpUpSource: BumpUpSource?,
                        typePage: EventParameterTypePage?) {
        currentListingViewModel?.showBumpUpView(bumpUpProductData: bumpUpProductData,
                                                bumpUpType: bumpUpType,
                                                bumpUpSource: bumpUpSource,
                                                typePage: typePage)
    }

    func bumpUpBannerBoostTimerReachedZero() {
        currentListingViewModel?.refreshBumpeableBanner()
    }

    func bumpUpBoostSucceeded() {
        currentListingViewModel?.bumpUpBoostSucceeded()
    }

    func didReceiveAd(bannerTopPosition: CGFloat, bannerBottomPosition: CGFloat, screenHeight: CGFloat) {

        let isMine = EventParameterBoolean(bool: currentListingViewModel?.isMine)
        let adShown: EventParameterBoolean = .trueParameter
        let adType = currentAdRequestType?.trackingParamValue
        let queryType = currentAdRequestQueryType?.trackingParamValue
        let query = adRequestQuery
        let visibility = EventParameterAdVisibility(bannerTopPosition: bannerTopPosition,
                                                    bannerBottomPosition: bannerBottomPosition,
                                                    screenHeight: screenHeight)
        let errorReason: EventParameterAdSenseRequestErrorReason? = nil

        adBannerTrackingStatus = AdBannerTrackingStatus(isMine: isMine,
                                                    adShown: adShown,
                                                    adType: adType,
                                                    queryType: queryType,
                                                    query: query,
                                                    visibility: visibility,
                                                    errorReason: errorReason)

        currentListingViewModel?.trackVisitMoreInfo(isMine: isMine,
                                                    adShown: adShown,
                                                    adType: adType,
                                                    queryType: queryType,
                                                    query: query,
                                                    visibility: visibility,
                                                    errorReason: errorReason)
    }

    func didFailToReceiveAd(withErrorCode code: GADErrorCode) {

        let isMine = EventParameterBoolean(bool: currentListingViewModel?.isMine)
        let adShown: EventParameterBoolean = .falseParameter
        let adType = currentAdRequestType?.trackingParamValue
        let queryType = currentAdRequestQueryType?.trackingParamValue
        let query = adRequestQuery
        let visibility: EventParameterAdVisibility? = nil
        let errorReason: EventParameterAdSenseRequestErrorReason? = EventParameterAdSenseRequestErrorReason(errorCode: code)
        
        adBannerTrackingStatus = AdBannerTrackingStatus(isMine: isMine,
                                                    adShown: adShown,
                                                    adType: adType,
                                                    queryType: queryType,
                                                    query: query,
                                                    visibility: visibility,
                                                    errorReason: errorReason)

        currentListingViewModel?.trackVisitMoreInfo(isMine: isMine,
                                                    adShown: adShown,
                                                    adType: adType,
                                                    queryType: queryType,
                                                    query: query,
                                                    visibility: visibility,
                                                    errorReason: errorReason)
    }

    func adAlreadyRequestedWithStatus(adBannerTrackingStatus status: AdBannerTrackingStatus) {
        currentListingViewModel?.trackVisitMoreInfo(isMine: status.isMine,
                                                    adShown: status.adShown,
                                                    adType: status.adType,
                                                    queryType: status.queryType,
                                                    query: status.query,
                                                    visibility: status.visibility,
                                                    errorReason: status.errorReason)
    }

    func adTapped(typePage: EventParameterTypePage, willLeaveApp: Bool) {
        let adType = currentAdRequestType?.trackingParamValue
        let isMine = EventParameterBoolean(bool: currentListingViewModel?.isMine)
        let queryType = currentAdRequestQueryType?.trackingParamValue
        let query = adRequestQuery
        let willLeave = EventParameterBoolean(bool: willLeaveApp)
        currentListingViewModel?.trackAdTapped(adType: adType,
                                               isMine: isMine,
                                               queryType: queryType,
                                               query: query,
                                               willLeaveApp: willLeave,
                                               typePage: typePage)
    }

    func statusLabelTapped() {
        navigator?.openFeaturedInfo()
        currentListingViewModel?.trackOpenFeaturedInfo()
    }
    
    func callSeller() {
        guard let phoneNumber = ownerPhoneNumber.value else { return }
        PhoneCallsHelper.call(phoneNumber: phoneNumber)
        currentListingViewModel?.trackCallTapped(source: source, feedPosition: trackingFeedPosition)
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
        moreInfoState.asObservable().map { $0 == .shown }.distinctUntilChanged().filter { $0 }.bind { [weak self] _ in
            if let adActive = self?.adActive, !adActive {
                self?.currentListingViewModel?.trackVisitMoreInfo(isMine: EventParameterBoolean(bool: self?.currentListingViewModel?.isMine),
                                                                  adShown: .notAvailable,
                                                                  adType: nil,
                                                                  queryType: nil,
                                                                  query: nil,
                                                                  visibility: nil,
                                                                  errorReason: nil)
            }
            self?.keyValueStorage[.listingMoreInfoTooltipDismissed] = true
            self?.delegate?.vmRemoveMoreInfoTooltip()
        }.disposed(by: disposeBag)

        altActions.asDriver().drive(onNext: { [weak self] (actions) in
            self?.processAltActions(actions)
        }).disposed(by: disposeBag)
    }

    private func processAltActions(_ altActions: [UIAction]) {
        guard altActions.count > 0 else { return }
        
        let cancel = LGLocalizedString.commonCancel
        var finalActions: [UIAction] = altActions
        //Adding show onboarding action
        let title = LGLocalizedString.productOnboardingShowAgainButtonTitle
        finalActions.append(UIAction(interface: .text(title), action: { [weak self] in
            self?.delegate?.vmShowOnboarding()
        }))
        delegate?.vmShowCarouselOptions(cancel, actions: finalActions)
    }

    private func setupCurrentProductVMRxBindings(forIndex index: Int) {
        activeDisposeBag = DisposeBag()
        guard let currentVM = currentListingViewModel else { return }
        currentVM.listing.asObservable().skip(1).bind { [weak self] updatedListing in
            guard let strongSelf = self else { return }
            strongSelf.currentViewModelIsBeingUpdated.value = true
            strongSelf.objects.replace(index, with: ListingCarouselCellModel(listing:updatedListing))
            strongSelf.currentViewModelIsBeingUpdated.value = false
        }.disposed(by: activeDisposeBag)

        currentVM.status.asObservable().bind(to: status).disposed(by: activeDisposeBag)
        currentVM.isShowingFeaturedStripe.asObservable().bind(to: isFeatured).disposed(by: activeDisposeBag)

        currentVM.productInfo.asObservable().bind(to: productInfo).disposed(by: activeDisposeBag)
        currentVM.productImageURLs.asObservable().bind(to: productImageURLs).disposed(by: activeDisposeBag)
        currentVM.userInfo.asObservable().bind(to: userInfo).disposed(by: activeDisposeBag)
        currentVM.listingStats.asObservable().bind(to: listingStats).disposed(by: activeDisposeBag)

        currentVM.seller.asObservable().bind { [weak self] seller in
            self?.ownerIsProfessional.value = seller?.isProfessional ?? false
            self?.ownerPhoneNumber.value = seller?.phone
        }.disposed(by: activeDisposeBag)

        currentVM.actionButtons.asObservable().bind(to: actionButtons).disposed(by: activeDisposeBag)
        currentVM.navBarButtons.asObservable().bind(to: navBarButtons).disposed(by: activeDisposeBag)
        currentVM.altActions.asObservable().bind(to: altActions).disposed(by: activeDisposeBag)

        quickAnswers.value = currentVM.quickAnswers
        currentVM.directChatEnabled.asObservable().bind(to: quickAnswersAvailable).disposed(by: activeDisposeBag)

        currentVM.directChatEnabled.asObservable().bind(to: directChatEnabled).disposed(by: activeDisposeBag)
        directChatMessages.removeAll()
        currentVM.directChatMessages.changesObservable.subscribeNext { [weak self] change in
            self?.performCollectionChange(change: change)
        }.disposed(by: activeDisposeBag)
        directChatPlaceholder.value = currentVM.directChatPlaceholder

        currentVM.isFavorite.asObservable().bind(to: isFavorite).disposed(by: activeDisposeBag)
        currentVM.favoriteButtonState.asObservable().bind(to: favoriteButtonState).disposed(by: activeDisposeBag)
        currentVM.shareButtonState.asObservable().bind(to: shareButtonState).disposed(by: activeDisposeBag)
        currentVM.bumpUpBannerInfo.asObservable().bind(to: bumpUpBannerInfo).disposed(by: activeDisposeBag)

        currentVM.socialMessage.asObservable().bind(to: socialMessage).disposed(by: activeDisposeBag)
        socialSharer.value = currentVM.socialSharer

        moreInfoState.asObservable().bind(to: currentVM.moreInfoState).disposed(by: activeDisposeBag)

        currentVM.showExactLocationOnMap.asObservable().bind(to: showExactLocationOnMap).disposed(by: activeDisposeBag)
    }

    private func performCollectionChange(change: CollectionChange<ChatViewMessage>) {
        let directChatMessagesCount = directChatMessages.value.count
        switch change {
        case let .insert(index, value):
            directChatMessages.insert(value, atIndex: index)
        case let .remove(index, _):
            guard 0..<directChatMessagesCount ~= index else { break }
            directChatMessages.removeAtIndex(index)
        case let .swap(fromIndex, toIndex, replacingWith):
            guard 0..<directChatMessagesCount ~= fromIndex, 0..<directChatMessagesCount ~= toIndex else { break }
            directChatMessages.swap(fromIndex: fromIndex, toIndex: toIndex, replacingWith: replacingWith)
        case let .move(fromIndex, toIndex, replacingWith):
            guard 0..<directChatMessagesCount ~= fromIndex, 0..<directChatMessagesCount ~= toIndex else { break }
            directChatMessages.move(fromIndex: fromIndex, toIndex: toIndex, replacingWith: replacingWith)
        case let .composite(changes):
            for change in changes {
                performCollectionChange(change: change)
            }
        }
    }

    private func makeAFShRequestQuery() -> String {

        if let title = productInfo.value?.title {
            currentAdRequestQueryType = .listingTitle
            return title
        } else if let autoTitle = productInfo.value?.titleAuto {
            currentAdRequestQueryType = .listingAutoTitle
            return autoTitle
        } else if let category = productInfo.value?.category, category != .other {
            currentAdRequestQueryType = .listingCategory
            return category.name
        } else {
            currentAdRequestQueryType = .hardcoded
            return randomHardcodedAdQuery
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
                let listingCarouselCellModels = newListings
                    .map(ListingCarouselCellModel.init)
                    .filter(strongSelf.featureFlags.discardedProducts.notDiscarded)
                strongSelf.objects.appendContentsOf(listingCarouselCellModels)
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

    func visitSource(_ origin: EventParameterListingVisitSource) -> EventParameterListingVisitSource {
        switch self {
        case .tap: fallthrough
        case .swipeRight: return origin.next
        case .initial: return origin
        case .swipeLeft: return origin.previous
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

extension DiscardedProducts {
    
    func notDiscarded(model: ListingCarouselCellModel) -> Bool {
        guard isActive else { return true }
        return !model.listing.status.isDiscarded
    }
}
