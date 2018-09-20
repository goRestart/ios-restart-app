import Foundation
import RxSwift
import RxCocoa
import LGCoreKit
import LGComponents
import IGListKit

final class FeedViewModel: BaseViewModel, FeedViewModelType {
    
    static let minimumSearchesSavedToShowCollection = 3
    static let interestingUndoTimeout: TimeInterval = 5

    // Protocol conformance
    
    weak var navigator: MainTabNavigator?
    weak var feedRenderingDelegate: FeedRenderable?
    weak var delegate: FeedViewModelDelegate?

    var wireframe: FeedNavigator?
    var listingWireframe: ListingWireframe?

    weak var rootViewController: UIViewController? {
        didSet {
            sectionControllerFactory.rootViewController = rootViewController
        }
    }
    
    let waterfallColumnCount: Int
    var queryString: String?
    private(set) var feedItems: [ListDiffable] = []
    
    var rxHasFilter: Driver<Bool> {
        return filtersVar.asDriver().map({ !$0.isDefault() })
    }
    
    var searchString: String? {
        return searchType?.text
    }
    
    var shouldShowInviteButton: Bool {
        guard !shouldShowAffiliateButton else { return false }
        return navigator?.canOpenAppInvite() ?? false
    }
    
    var shouldShowAffiliateButton: Bool {
        return featureFlags.affiliationEnabled.isActive
    }
    
    var shouldShowCommunityButton: Bool {
        return featureFlags.community.shouldShowOnNavBar
    }
    
    var shouldShowUserProfileButton: Bool {
        return featureFlags.community.shouldShowOnTab
    }

    private(set) var viewState: ViewState {
        didSet {
            delegate?.vmDidUpdateState(self, state: viewState)
        }
    }
    
    var locationSectionIndex: Int? {
        return feedItems.index(where: { $0 is LocationData })
    }
    
    var verticalSectionsCount: Int {
        guard let locationSectionIndex = locationSectionIndex,
            feedItems.count > locationSectionIndex else { return 0 }
        return feedItems.count - locationSectionIndex
    }
    
    var currentPlace: Place {
            let currentLocation = locationManager.currentLocation
            return filters.place ?? Place(postalAddress: currentLocation?.postalAddress,
                                          location: currentLocation?.location)
    }
    
    var rx_userAvatar: BehaviorRelay<UIImage?> { return userAvatar }
    
    // RX
    
    var userAvatar = BehaviorRelay<UIImage?>(value: nil)

    // Private vars
    
    private let filtersVar: Variable<ListingFilters>
    private let disposeBag = DisposeBag()
    
    private var lastReceivedLocation: LGLocation?
    private var listingRetrievalState: ListingRetrievalState = .error {
        didSet {
            removeLoadingBottom()
            feedItems.append(listingRetrievalState.listDiffable())
            refreshFeed()
        }
    }
    
    private var paginationLinks: PaginationLinks?
    private var isRetrieving = false
    private var pages = Set<String>()
    private var previousVerticalPageSize = 0
    private var feedIdSet: Set<String> = Set<String>()
    
    private var sectionControllerFactory: SectionControllerFactory
    
    // This var extens due a issue when the controller request the first
    // page and the locations changes and it also request the first too,
    // so when the request arrives it must detect if the fist page was loaded
    // or not and if it correspond to the correct location.
    // https://ambatana.atlassian.net/browse/ABIOS-5133
    private var isFirstPageAlreadyLoadedWithLocation: LGLocation?

    private var isCurrentLocationAutomatic: Bool?

    private var showingRetryState: Bool = false

    // This var contians the position of the correct section for
    // the feed, if the feed is the main it must set this variable
    // as nil because it is not coming from any section.
    private var comingSectionPosition: UInt? = nil
    private var comingSectionIdentifier: String? = nil
    
    // https://ambatana.atlassian.net/browse/ABIOS-5133
    private var isComingFromASection: Bool = false
    
    //  Ads
    
    private var adsPaginationHelper: AdsPaginationHelper
    
    
    // Dependencies
    
    private let searchType: SearchType?
    private var filters: ListingFilters
    private let bubbleTextGenerator: DistanceBubbleTextGenerator
    private let myUserRepository: MyUserRepository
    private let userRepository: UserRepository
    private let tracker: Tracker
    private let pushPermissionsManager: PushPermissionsManager
    private let application: Application
    private let locationManager: LocationManager
    private let featureFlags: FeatureFlaggeable
    private let keyValueStorage: KeyValueStorageable
    private var shouldTrackSearch = false
    private let chatWrapper: ChatWrapper
    private let adsImpressionConfigurable: AdsImpressionConfigurable
    private let interestedStateManager: InterestedStateUpdater
    private let sectionedFeedVMTrackerHelper: SectionedFeedVMTrackerHelper
    private let sectionedFeedRequester: SectionedFeedRequester
    private let sessionManager: SessionManager
    private let appsFlyerAffiliationResolver: AppsFlyerAffiliationResolver
    
    //  MARK: - Life Cycle
    
    init(searchType: SearchType? = nil,
         filters: ListingFilters,
         bubbleTextGenerator: DistanceBubbleTextGenerator = DistanceBubbleTextGenerator(),
         myUserRepository: MyUserRepository = Core.myUserRepository,
         userRepository: UserRepository = Core.userRepository,
         tracker: Tracker = TrackerProxy.sharedInstance,
         pushPermissionsManager: PushPermissionsManager = LGPushPermissionsManager.sharedInstance,
         sessionManager: SessionManager = Core.sessionManager,
         application: Application = UIApplication.shared,
         locationManager: LocationManager = Core.locationManager,
         featureFlags: FeatureFlaggeable = FeatureFlags.sharedInstance,
         keyValueStorage: KeyValueStorageable = KeyValueStorage.sharedInstance,
         deviceFamily: DeviceFamily = DeviceFamily.current,
         chatWrapper: ChatWrapper = LGChatWrapper(),
         appsFlyerAffiliationResolver: AppsFlyerAffiliationResolver = AppsFlyerAffiliationResolver.shared,
         adsImpressionConfigurable: AdsImpressionConfigurable = LGAdsImpressionConfigurable(),
         sectionedFeedVMTrackerHelper: SectionedFeedVMTrackerHelper = SectionedFeedVMTrackerHelper(),
         interestedStateManager: InterestedStateUpdater = LGInterestedStateUpdater(),
         shouldShowEditOnLocationHeader: Bool = true,
         comingSectionPosition: UInt? = nil,
         comingSectionIdentifier: String? = nil) {

        self.filters = filters
        self.filtersVar = Variable<ListingFilters>(filters)
        self.bubbleTextGenerator = bubbleTextGenerator
        self.searchType = searchType
        if let search = searchType, let query = search.query, !search.isCollection && !query.isEmpty {
            self.shouldTrackSearch = true
        }
        self.myUserRepository = myUserRepository
        self.userRepository = userRepository
        self.tracker = tracker
        self.pushPermissionsManager = pushPermissionsManager
        self.sessionManager = sessionManager
        self.application = application
        self.locationManager = locationManager
        self.featureFlags = featureFlags
        self.keyValueStorage = keyValueStorage
        self.appsFlyerAffiliationResolver = appsFlyerAffiliationResolver
        self.waterfallColumnCount = deviceFamily.shouldShow3Columns() ? 3 : 2
        self.viewState = .loading
        self.sectionControllerFactory = SectionControllerFactory(
            waterfallColumnCount: waterfallColumnCount,
            featureFlags: featureFlags,
            tracker: tracker,
            pushPermissionsManager: pushPermissionsManager,
            shouldShowEditOnLocationHeader: shouldShowEditOnLocationHeader)
        self.chatWrapper = chatWrapper
        self.adsImpressionConfigurable = adsImpressionConfigurable
        self.adsPaginationHelper = AdsPaginationHelper(featureFlags: featureFlags)
        self.interestedStateManager = interestedStateManager
        self.sectionedFeedVMTrackerHelper = sectionedFeedVMTrackerHelper
        self.sectionedFeedRequester = SectionedFeedRequester()
        self.comingSectionPosition = comingSectionPosition
        self.comingSectionIdentifier = comingSectionIdentifier
        super.init()
        setup()
    }
    
    convenience override init() {
        let filters = ListingFilters()
        self.init(filters: filters)
    }
    
    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        updatePermissionBanner()
        // Comment readme: https://ambatana.atlassian.net/browse/ABIOS-5145
        //setupLocation()
        
        guard firstTime else { return }
        refreshFeed()
        setupRx()
    }
    
    //  MARK: - Filter
    
    var hasFilters: Bool {
        return !filters.isDefault()
    }
    
    //  MARK: - Info Bubble
    
    private var locationText: String {
        let distance = filters.distanceRadius ?? 0
        let type = filters.distanceType
        return bubbleTextGenerator.bubbleInfoText(forDistance: distance,
                                                  type: type,
                                                  distanceRadius: filters.distanceRadius,
                                                  place: currentPlace)
    }
    
    //  MARK: - Load Feed Items
    
    func loadFeedItems() {
        guard let searchType = searchType else { return retrieve() }
        if case .feed(let page, _) = searchType {
            sectionedFeedRequester.retrieveNext(withUrl: page, completion: feedCompletion())
        }
    }
    
    func willScroll(toSection section: Int) {
        guard !showingRetryState else { return }
        if shouldRetrieveNextPage(section: section) { retrieve() }
    }
    
    private func shouldRetrieveNextPage(section: Int) -> Bool {
        
        guard !isRetrieving else { return false }
        
        guard let nextURL = paginationLinks?.next?.absoluteString, !pages.contains(nextURL) else { return false }
        
        let offsetThreshold = Float(previousVerticalPageSize) * SharedConstants.listingsPagingThresholdPercentage
        let threshold = verticalSectionsCount - Int(offsetThreshold)
        
        return section > threshold
    }
    
    func feedSectionController(for object: Any) -> ListSectionController {
        return sectionControllerFactory.make(for: object)
    }
    
    private func setup() {
        sectionControllerFactory.delegate = self
        setupPermissionsNotification()
        setupSession()
    }
    
    private func setupRx() {
        myUserRepository
            .rx_myUser
            .distinctUntilChanged { $0?.objectId == $1?.objectId }
            .filter { _ in
                return self.featureFlags.advancedReputationSystem11.isActive
            }
            .subscribe(onNext: { [weak self] myUser in
                self?.loadAvatar(for: myUser)
            })
            .disposed(by: disposeBag)
   
        appsFlyerAffiliationResolver.rx_affiliationCampaign.asObservable().bind { [weak self] status in
            switch status {
            case .campaignNotAvailableForUser:
                self?.navigator?.openWrongCountryModal()
            case.referral( let referrer):
                self?.navigator?.openAffiliationOnboarding(data: referrer)
            case .unknown:
                return
            }
        }.disposed(by: disposeBag)
    }
    
    private func refreshFeed() {
        feedRenderingDelegate?.updateFeed()
    }
    
    private func refreshFiltersVar() {
        filtersVar.value = filters
    }
    
    private func removeLoadingBottom() {
        if feedItems.last is DiffableBox<ListingRetrievalState> {
            feedItems.removeLast()
        }
    }
    
    private func findItemInFeed(with itemIdentifier: ListDiffable) -> Int? {
        return feedItems.filter {
            $0 is DiffableBox<FeedListingData> || $0 is DiffableBox<AdData>
        }.index { $0.isEqual(toDiffableObject: itemIdentifier) }
    }
}

// MARK: - Session and Location Manager change

extension FeedViewModel {
    
    private func setupSession() {
        sessionManager.sessionEvents.bind { [weak self] _ in
            guard self?.active == true else { return }
            self?.sessionDidChange() }
            .disposed(by: disposeBag)
    }
    
    private func setupLocation() {
        locationManager.locationEvents.filter { $0 == .locationUpdate }.bind { [weak self] _ in
            self?.locationDidChange()
        }.disposed(by: disposeBag)
    }
    
    private func sessionDidChange() {
        retrieve()
    }
    
    private func locationDidChange() {
        guard let newLocation = locationManager.currentLocation else { return }

        if let safeCurrentLocation = isCurrentLocationAutomatic,
            safeCurrentLocation && newLocation.isAuto {
            return
        }
        
        lastReceivedLocation = locationManager.currentLocation
        isCurrentLocationAutomatic = newLocation.isAuto
        trackLocationTypeChange(from: lastReceivedLocation?.type, to: newLocation.type)
        refreshFeedUponLocationChange()
    }
}

//  MARK: - FeedRequester

extension FeedViewModel {
    
    private func retrieve() {
        let completion = feedCompletion()
        isRetrieving = true
        if let nextFeedPageURL = paginationLinks?.next {
            listingRetrievalState = .loading
            sectionedFeedRequester.retrieveNext(withUrl: nextFeedPageURL, completion: completion)
        } else {
            guard isFirstPageAlreadyLoadedWithLocation != locationManager.currentLocation else { return }
            isFirstPageAlreadyLoadedWithLocation = locationManager.currentLocation
            viewState = .loading
            sectionedFeedRequester.retrieveFirst(completion)
        }
    }

    private func feedCompletion() -> FeedCompletion {
        return { [weak self] result in
            self?.isRetrieving = false
            if let error = result.error {
                self?.show(error: error)
            } else if let feed = result.value {
                self?.removeLoadingBottom()
                defer {
                    if feed.isFirstPage {
                        self?.feedRenderingDelegate?.updateFeed()
                    } else {
                        self?.refreshFeed()
                    }
                }
                guard !feed.isEmpty else {
                    self?.renderEmptyPage(feed)
                    self?.trackSectionsAndItems(inFeed: feed)
                    return
                }
                self?.updatePaginationLinks(feed.pagination)
                self?.viewState = .data
                self?.updateFeedItems(withFeed: feed)
            }
        }
    }

    private var isFirstPage: Bool {
        return paginationLinks == nil
    }

    private func renderEmptyPage(_ feed: Feed) {
        if feed.isFirstPage { showEmptyState() }
    }
    
    private func show(error: RepositoryError) {
        guard isFirstPage,
            let errorViewModel = LGEmptyViewModel.map(from: error, action: retrieve) else {
                listingRetrievalState = .error
                showingRetryState = true
                return
        }
        viewState = .error(errorViewModel)
    }
    
    private func updateFeedItems(withFeed feed: Feed) {
        let horizontalSections = feed.horizontalSections(featureFlags, myUserRepository, keyValueStorage, waterfallColumnCount, pages.count)
        let verticalSections = feed.verticalItems(featureFlags, myUserRepository, keyValueStorage, waterfallColumnCount)
        var duplications = feed.items.count - verticalSections.count
        let verticalItems = verticalSections.filter { feedListingData in
            guard let id = feedListingData.listingId else { return false }
            guard feedIdSet.contains(id) else { return true }
            duplications += 1
            return false
        }
        
        feedItems.append(contentsOf: horizontalSections.listDiffable())
        
        if locationSectionIndex == nil {
            feedItems.append(LocationData(locationString: locationText))
        }

        let verticalSectionsWithAds = updateWithAds(listDiffable: verticalItems.listDiffable())
        let allVerticalSections = updateWithSelectedForYou(listDiffable: verticalSectionsWithAds,
                                                           positionInFeed: feedItems.count,
                                                           offset: SharedConstants.selectedForYouPosition)
        
        feedItems.append(contentsOf: allVerticalSections)
        feedIdSet.formUnion(verticalItems.compactMap { $0.listingId })
        previousVerticalPageSize = allVerticalSections.count
        trackSectionsAndItems(inFeed: feed)
        sectionedFeedVMTrackerHelper.trackDuplicates(onPage: pages.count, numberOfDuplicates: duplications)
    }
    
    private func updateWithAds(listDiffable: [ListDiffable]) -> [ListDiffable] {
        guard adsImpressionConfigurable.shouldShowAdsForUser  else { return listDiffable }
        
        let positions = adsPaginationHelper.adIndexesPositions(withItemListCount: listDiffable.count)
        let ads = positions.reversed().map { AdDataFactory.make(adPosition: feedItems.count + $0).listDiffable() }
        return listDiffable.insert(newList: ads, at: positions)
    }
    
    private func updateWithBannerAds(listDiffable: [ListDiffable]) -> [ListDiffable] {
        guard adsImpressionConfigurable.shouldShowAdsForUser, listDiffable.count > 0  else { return listDiffable }
        let positions = adsPaginationHelper.bannerAdIndexesPositions(withItemListCount: listDiffable.count)
        let ads = positions.reversed().map { AdDataFactory.make(adPosition: $0,
                                                                bannerHeight: LGUIKitConstants.sectionedFeedBannerAdDefaultHeight,
                                                                type: .banner).listDiffable() }
        return listDiffable.insert(newList: ads, at: positions)
    }
    
    private func updateWithSelectedForYou(listDiffable: [ListDiffable],
                                          positionInFeed position: Int,
                                          offset: Int) -> [ListDiffable] {
        guard let newDiffable = selectedForYou(positionInFeed: position + offset) else { return listDiffable }
        return listDiffable.insert(newList: [newDiffable], at: [offset - 1])
    }
    
    private func updatePaginationLinks(_ paginationLinks: PaginationLinks) {
        self.paginationLinks = paginationLinks
        pages.insert(paginationLinks.this.absoluteString)
    }
    
    private func showEmptyState() {
        let emptyViewModel = EmptyViewModelBuilder(hasPerformedSearch: false, isRealEstateSearch: false).build()
        viewState = .empty(emptyViewModel)
    }
    
    private func updateFeedRequester() {
        sectionedFeedRequester.updateFeedRequester(withCurrentPlace: currentPlace)
    }
    
    private func resetFeed() {
        pages.removeAll()
        previousVerticalPageSize = 0
        paginationLinks = nil
        feedItems.removeAll()
        adsPaginationHelper.reset()
        feedIdSet.removeAll()
    }
}



extension FeedViewModel {
    private func loadAvatar(for user: User?) {
        guard let avatarUrl = user?.avatar?.fileURL else {
            self.userAvatar.accept(nil)
            return
        }
        
        if let cachedImage = ImageDownloader.sharedInstance.cachedImageForUrl(avatarUrl) {
            self.userAvatar.accept(cachedImage)
            return
        }
        
        ImageDownloader
            .sharedInstance
            .downloadImageWithURL(avatarUrl) { [weak self] (result, _) in
                guard case .success((let image, _)) = result else { return }
                self?.userAvatar.accept(image)
        }
    }
}

extension FeedViewModel {
    
    func openInvite() {
        wireframe?.openAppInvite(
            myUserId: myUserRepository.myUser?.objectId,
            myUserName:  myUserRepository.myUser?.name)
    }
    
    func openSearches() {
        guard let safeNavigator = navigator else { return }
        wireframe?.openSearches(withSearchType: searchType){ [weak self] searchType in
            guard let safeSelf = self else { return }
            safeSelf.wireframe?.openClassicFeed(
                navigator: safeNavigator,
                withSearchType: searchType,
                listingFilters: safeSelf.filters,
                shouldCloseOnRemoveAllFilters: false
            )
            safeSelf.delegate?.searchCompleted()
        }
    }
    
    func showFilters() {
        wireframe?.openFilters(withListingFilters: filters,
                               filtersVMDataDelegate: self)
        tracker.trackEvent(TrackerEvent.filterStart())
    }
    
    func openAffiliationChallenges() {
        wireframe?.openLoginIfNeededFromFeed(from: .feed, loggedInAction: { [weak self] in
            self?.wireframe?.openAffiliationChallenges()
        })
    }
    
    func refreshControlTriggered() {
        isFirstPageAlreadyLoadedWithLocation = nil
        resetFeed()
        updatePermissionBanner()
        loadFeedItems()
    }

    func resetFirstLoadState() { isFirstPageAlreadyLoadedWithLocation = nil }

    func openCommunity() { navigator?.openCommunity() }
    
    func openUserProfile() { navigator?.openPrivateUserProfile() }
}

// MARK:- FiltersViewModelDataDelegate

extension FeedViewModel: FiltersViewModelDataDelegate {
    
    func viewModelDidUpdateFilters(_ viewModel: FiltersViewModel,
                                   filters: ListingFilters) {
        defer {
            isFirstPageAlreadyLoadedWithLocation = nil
            refreshFeedUponLocationChange()
        }
        self.filters = filters
        guard !filters.isDefault() else { return }
        // For the moment when the user wants to filter something the app
        // must jump directly to the old feed with the applied filters.
        // Story: https://ambatana.atlassian.net/browse/ABIOS-4525?filter=18022.
        guard let safeNavigator = navigator else { return }
        guard !filters.hasOnlyPlace else { return }
        wireframe?.openClassicFeed(
            navigator: safeNavigator,
            withSearchType: searchType,
            listingFilters: filters,
            shouldCloseOnRemoveAllFilters: true,
            tagsDelegate: self
        )
        self.filters = ListingFilters()
    }
}

//  MARK: - PushPermissionsPresenterDelegate

extension FeedViewModel: PushPermissionsPresenterDelegate {
    
    func showPushPermissionsAlert(withPositiveAction positiveAction: @escaping (() -> Void),
                                  negativeAction: @escaping (() -> Void)) {
        wireframe?.showPushPermissionsAlert(pushPermissionsManager: pushPermissionsManager,
                                            withPositiveAction: positiveAction,
                                            negativeAction: negativeAction)
    }
    
    private func setupPermissionsNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(refreshPushPermissionBanner),
                                               name: NSNotification.Name(rawValue:
                                                PushManager.Notification.DidRegisterUserNotificationSettings.rawValue),
                                               object: nil)
    }
    
    @objc private dynamic func refreshPushPermissionBanner() {
        updatePermissionBanner()
        refreshFeed()
    }
    
    private func updatePermissionBanner() {
        let pushBannerId = StaticSectionType.pushBanner.rawValue as ListDiffable
        let hasPushMessage = feedItems.contains(where: { $0.isEqual(toDiffableObject: pushBannerId) })
        
        if !hasPushMessage && !application.areRemoteNotificationsEnabled {
            feedItems.insert(pushBannerId, at: 0)
        } else if hasPushMessage && application.areRemoteNotificationsEnabled {
            feedItems.remove(at: 0)
        }
    }
}

//  MARK: - Location Edition

extension FeedViewModel: EditLocationDelegate, LocationEditable {
    
    func openEditLocation() {
        wireframe?.openLocationSelection(initialPlace: currentPlace,
                                         distanceRadius: filters.distanceRadius,
                                         locationDelegate: self)
    }
    
    func editLocationDidSelectPlace(_ place: Place, distanceRadius: Int?) {
        var newFiltersWithLocationAndDistance = filters
        newFiltersWithLocationAndDistance.place = place
        newFiltersWithLocationAndDistance.distanceRadius = distanceRadius
        filters.place = place
        guard let safeNavigator = navigator else { return }
        wireframe?.openClassicFeed(
            navigator: safeNavigator,
            withSearchType: searchType,
            listingFilters: newFiltersWithLocationAndDistance,
            shouldCloseOnRemoveAllFilters: true,
            tagsDelegate: self
        )
        refreshFeedUponLocationChange()
    }
    
    private func updateLocationTextInFeedItems(newLocationString: String) {
        guard let index = locationSectionIndex else { return }
        feedItems[index] = LocationData(locationString: newLocationString)
    }
    
    private func refreshFeedUponLocationChange() {
        updateLocationTextInFeedItems(newLocationString: locationText)
        resetFeed()
        updateFeedRequester()
        refreshFiltersVar()
        retrieve()
    }
}

//  MARK: - Selected For you

extension FeedViewModel: SelectedForYouDelegate {
    
    func openSelectedForYou() {
        let collectionType = CollectionCellType.selectedForYou
        tracker.trackEvent(TrackerEvent.exploreCollection(collectionType.rawValue))
        let query = collectionType.buildQueryString(from: keyValueStorage)
        guard let strongNavigator = navigator else { return }
        wireframe?.openClassicFeed(
            navigator: strongNavigator,
            withSearchType: .collection(type: collectionType, query: query),
            listingFilters: filters,
            shouldCloseOnRemoveAllFilters: false)
    }
    
    private var shouldShowSelectedForYou: Bool {
        let hasMoreThan3Searches =  keyValueStorage[.lastSuggestiveSearches].count >= FeedViewModel.minimumSearchesSavedToShowCollection
        let noFiltersAreApplied = filters.noFilterCategoryApplied
        return hasMoreThan3Searches && noFiltersAreApplied && searchType == nil
    }
    
    private func selectedForYou(positionInFeed position: Int) -> SelectedForYou? {
        guard shouldShowSelectedForYou,
            let countryCode = currentPlace.postalAddress?.countryCode,
            featureFlags.collectionsAllowedFor(countryCode: countryCode) else { return nil }
        return SelectedForYou(positionInFeed: position)
    }
}

//  MARK: - Retry loading

extension FeedViewModel: RetryFooterDelegate {
    func retryClicked() {
        showingRetryState = false
        feedItems.removeLast()
        retrieve()
    }
}

// MARK: - Horizontal selection delegate

extension FeedViewModel: HorizontalSectionDelegate {
    func didTapSeeAll(page: SearchType, section: UInt, identifier: String) {
        guard let navigator = navigator else { return }
        wireframe?.openProFeed(
            navigator: navigator,
            withSearchType: page,
            andFilters: filters,
            andComingSectionPosition: section,
            andComingSectionIdentifier: identifier
        )
    }
}


//  MARK: - ProductListing Actions

extension FeedViewModel: ListingActionDelegate {
    func chatButtonPressedFor(listing: Listing) {
        let chatDetailData = ChatDetailData.listingAPI(listing: listing)
        openChat(withData: chatDetailData)
    }

    func getUserInfoFor(_ listing: Listing, completion: @escaping (User?) -> Void) {
        listing.listingUser(userRepository: userRepository,
                            completion: completion)
    }

    func interestedActionFor(_ listing: Listing,
                             userListing: LocalUser?,
                             sectionedFeedChatTrackingInfo: SectionedFeedChatTrackingInfo?,
                             completion: @escaping (InterestedState) -> Void) {
        if let user = userListing, user.isProfessional {
            interestedActionForProUser(forListing: listing, interlocutor: user)
        } else {
            interestedActionForNormalUser(listing,
                                          sectionedFeedChatTrackingInfo: sectionedFeedChatTrackingInfo,
                                          completion: completion)
        }
    }
    
    private func openChat(withData data: ChatDetailData) {
        navigator?.openChat(data,
                            source: .listingListFeatured,
                            predefinedMessage: nil)
    }
    
    private func interestedActionForProUser(forListing listing: Listing, interlocutor: LocalUser) {

        openLoginIfNeeded(message: R.Strings.chatLoginPopupText) { [weak self] in
            guard let shouldOpenProChat = self?.interestedStateManager.hasContactedProListing(listing),
                shouldOpenProChat else {
                    self?.navigator?.openAskPhoneFromMainFeedFor(listing: listing,
                                                                 interlocutor: interlocutor)
                    return
            }
            self?.openProChat(listing, interlocutor: interlocutor)
        }
    }
    
    private func interestedActionForNormalUser(_ listing: Listing, sectionedFeedChatTrackingInfo: SectionedFeedChatTrackingInfo?, completion: @escaping (InterestedState) -> Void) {

        guard !interestedStateManager.interestedIsDisabled(forListing: listing) else { return }

        openLoginIfNeeded(message: R.Strings.chatLoginPopupText) { [weak self] in
            guard let strSelf = self else { return }
            let shouldOpenChat = strSelf.interestedStateManager.hasContactedListing(listing)
            guard !shouldOpenChat else {
                strSelf.refreshFeed()
                completion(.seeConversation)
                let chatDetailData = ChatDetailData.listingAPI(listing: listing)
                strSelf.openChat(withData: chatDetailData)
                return
            }
            strSelf.handleCancellableInterestedAction(listing, sectionedFeedChatTrackingInfo: sectionedFeedChatTrackingInfo, completion: completion)
        }
    }
    
    private func handleCancellableInterestedAction(_ listing: Listing, sectionedFeedChatTrackingInfo: SectionedFeedChatTrackingInfo?, completion: @escaping (InterestedState) -> Void) {

        let (cancellable, timer) = LGTimer.cancellableWait(FeedViewModel.interestingUndoTimeout)
        
        showUndoBubble(withMessage: R.Strings.productInterestedBubbleMessage,
                       duration: FeedViewModel.interestingUndoTimeout) {
            cancellable.cancel()
        }
        
        timer.subscribe { [weak self] (event) in
            defer { self?.refreshFeed() }
            guard event.error == nil else {
                completion(.seeConversation)
                self?.sendMessage(forListing: listing, sectionedFeedChatTrackingInfo: sectionedFeedChatTrackingInfo)
                return
            }
            completion(.send(enabled: true))
            self?.undoSendingInterestedMessage(forListing: listing)
        }.disposed(by: disposeBag)
    }
    
    private func sendMessage(forListing listing: Listing, sectionedFeedChatTrackingInfo: SectionedFeedChatTrackingInfo?) {
        let type: ChatWrapperMessageType
        if featureFlags.randomImInterestedMessages.isActive {
            type = ChatWrapperMessageType.interested(QuickAnswer.dynamicInterested(
                interestedMessage: QuickAnswer.InterestedMessage.makeRandom()).textToReply)
        } else {
            type = ChatWrapperMessageType.interested(QuickAnswer.interested.textToReply)
        }
        interestedStateManager.addInterestedState(forListing: listing, completion: nil)
        let trackingInfo = SendMessageTrackingInfo
            .makeWith(type: type, listing: listing, freePostingAllowed: featureFlags.freePostingModeAllowed)
            .set(typePage: .listingList)
            .set(isBumpedUp: .falseParameter)
            .set(containsEmoji: false)
        tracker.trackEvent(.userMessageSent(info: trackingInfo, isProfessional: nil))
        chatWrapper.sendMessageFor(listing: listing, type: type) { [weak self] isFirstMessage in
            let isFirstMessage = isFirstMessage.value ?? false
            guard isFirstMessage else { return }
            self?.trackFirstMessage(info: trackingInfo, sectionedFeedChatTrackingInfo: sectionedFeedChatTrackingInfo, listing: listing)
        }
    }
    
    private func undoSendingInterestedMessage(forListing listing: Listing) {
        tracker.trackEvent(TrackerEvent.undoSentMessage())
    }
    
    private func openProChat(_ listing: Listing, interlocutor: LocalUser) {
        let trackHelper = ProductVMTrackHelper(tracker: tracker,
                                               listing: listing,
                                               featureFlags: featureFlags)
        trackHelper.trackChatWithSeller(.feed)
        navigator?.openListingChat(listing,
                                   source: .listingList,
                                   interlocutor: interlocutor)
    }
    
    private func openLoginIfNeeded(message: String, then action: @escaping () -> Void) {
        navigator?.openLoginIfNeeded(infoMessage: message, then: action)
    }
    
    private func showUndoBubble(withMessage message: String,
                        duration: TimeInterval,
                        then action: @escaping () -> ()) {
        navigator?.showUndoBubble(withMessage: message,
                                  duration: duration,
                                  withAction: action)
    }
}

extension FeedViewModel {
    
    func didSelectListing(_ listing: Listing,
                          from feedDataArray: [FeedListingData],
                          thumbnailImage: UIImage?,
                          originFrame: CGRect?,
                          index: Int,
                          sectionIdentifier: String,
                          sectionIndex: UInt?) {
        let data = ListingDetailData.sectionedNonRelatedListing(
            listing: listing,
            feedListingDatas: feedDataArray,
            thumbnailImage: thumbnailImage,
            originFrame: originFrame,
            index: index,
            sectionIdentifier: sectionIdentifier,
            sectionIndex: sectionIndex
        )
        listingWireframe?.openListing(
            data, source: listingVisitSource, actionOnFirstAppear: .nonexistent)
    }

    func didSelectListing(_ listing: Listing,
                          thumbnailImage: UIImage?,
                          originFrame: CGRect?,
                          index: Int?,
                          sectionIdentifier: String?,
                          sectionIndex: UInt?,
                          itemIdentifier: ListDiffable) {
        // https://ambatana.atlassian.net/browse/ABIOS-5133
        isComingFromASection = sectionIdentifier != nil
      
        let frame = feedRenderingDelegate?.convertViewRectInFeed(from: originFrame ?? .zero)
        let data = ListingDetailData.sectionedRelatedListing(
            listing: listing,
            thumbnailImage: thumbnailImage,
            originFrame: frame,
            index: index ?? (findItemInFeed(with: itemIdentifier) ?? 0),
            sectionIdentifier: sectionIdentifier,
            sectionIndex: sectionIndex)
        listingWireframe?.openListing(
            data, source: listingVisitSource, actionOnFirstAppear: .nonexistent)
    }
}

//  MARK: - AdUpdated

extension FeedViewModel: AdUpdated {
    func updatedAd() {
        refreshFeed()
    }
}

// MARK: - Main Listings Tags Delegate

extension FeedViewModel: MainListingsTagsDelegate {
    func onCloseAllFilters(finalFiters newFilters: ListingFilters) {
        self.filters = newFilters
        refreshFeedUponLocationChange()
    }
}


//  MARK: - Tracking

extension FeedViewModel {

    var listingVisitSource: EventParameterListingVisitSource {
        if let searchType = searchType {
            switch searchType {
            case .collection: return .collection
            case .user, .trending, .suggestive, .lastSearch:
                return !hasFilters ? .search : .searchAndFilter
            case .feed: return .sectionList
            }
        }
        if hasFilters {
            return filters.selectedCategories.isEmpty ? .filter : .category
        }
        if !isComingFromASection {
            return .listingList
        }
        // Reset the flag in order to know if the item is not in a section
        isComingFromASection = false
        
        return .section
    }
    
    var feedSource: EventParameterFeedSource {
        guard let search = searchType else {
            return hasFilters ? .filter : .section
        }
        
        if let _ = comingSectionIdentifier { return .section }
        
        guard search.isCollection else {
            return hasFilters ? .searchAndFilter : .search
        }
        return .collection
    }
    
    private func trackSectionsAndItems(inFeed feed: Feed?) {
        sectionedFeedVMTrackerHelper.trackSectionsAndItems(inFeed: feed,
                                                           user: myUserRepository.myUser,
                                                           categories: filters.selectedCategories,
                                                           searchQuery: queryString,
                                                           feedSource: feedSource,
                                                           sectionPosition: comingSectionPosition,
                                                           sectionIdentifier: comingSectionIdentifier)
    }
    
    private func trackFirstMessage(info: SendMessageTrackingInfo,
                                   sectionedFeedChatTrackingInfo: SectionedFeedChatTrackingInfo?,
                                   listing: Listing) {
        sectionedFeedVMTrackerHelper.trackFirstMessage(info: info,
                                                       listingVisitSource: listingVisitSource,
                                                       sectionedFeedChatTrackingInfo: sectionedFeedChatTrackingInfo,
                                                       sectionPosition: .none,
                                                       listing: listing)
    }
    
    private func trackLocationTypeChange(from old: LGLocationType?, to new: LGLocationType?) {
        sectionedFeedVMTrackerHelper.trackLocationTypeChange(from: old,
                                                             to: new,
                                                             locationServiceStatus: locationManager.locationServiceStatus,
                                                             distanceRadius: filters.distanceRadius)
    }
}
