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
        return navigator?.canOpenAppInvite() ?? false
    }
    
    private(set) var viewState: ViewState {
        didSet {
            delegate?.vmDidUpdateState(self, state: viewState)
        }
    }
    
    var locationSectionIndex: Int? {
        return feedItems.index(where: { $0 is LocationData })
    }
    
    var bottomStatusIndicatorIndex: Int? {
        guard feedItems.last is DiffableBox<ListingRetrievalState> else { return nil }
        return feedItems.count - 1
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
    
    // Private vars
    
    private let filtersVar: Variable<ListingFilters>
    private let disposeBag = DisposeBag()
    
    
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
    
    private var sectionControllerFactory: SectionControllerFactory
    
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
    private let feedRepository: FeedRepository
    private var shouldTrackSearch = false
    private var feedRequester: FeedRequester?
    private let chatWrapper: ChatWrapper
    private let adsImpressionConfigurable: AdsImpressionConfigurable
    private let interestedStateManager: InterestedStateUpdater
    private let sectionedFeedVMTrackerHelper: SectionedFeedVMTrackerHelper

    //  MARK: - Life Cycle
    
    init(feedRepository: FeedRepository = Core.feedRepository,
         searchType: SearchType? = nil,
         filters: ListingFilters,
         bubbleTextGenerator: DistanceBubbleTextGenerator = DistanceBubbleTextGenerator(),
         myUserRepository: MyUserRepository = Core.myUserRepository,
         userRepository: UserRepository = Core.userRepository,
         tracker: Tracker = TrackerProxy.sharedInstance,
         pushPermissionsManager: PushPermissionsManager = LGPushPermissionsManager.sharedInstance,
         application: Application = UIApplication.shared,
         locationManager: LocationManager = Core.locationManager,
         featureFlags: FeatureFlaggeable = FeatureFlags.sharedInstance,
         keyValueStorage: KeyValueStorageable = KeyValueStorage.sharedInstance,
         deviceFamily: DeviceFamily = DeviceFamily.current,
         chatWrapper: ChatWrapper = LGChatWrapper(),
         adsImpressionConfigurable: AdsImpressionConfigurable = LGAdsImpressionConfigurable(),
         sectionedFeedVMTrackerHelper: SectionedFeedVMTrackerHelper = SectionedFeedVMTrackerHelper(),
         interestedStateManager: InterestedStateUpdater = LGInterestedStateUpdater(),
         shouldShowEditOnLocationHeader: Bool = true) {

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
        self.application = application
        self.locationManager = locationManager
        self.featureFlags = featureFlags
        self.keyValueStorage = keyValueStorage
        self.waterfallColumnCount = deviceFamily.shouldShow3Columns() ? 3 : 2
        self.viewState = .loading
        self.feedRepository = feedRepository
        self.feedRequester = FeedRequesterFactory.make(
            withFeedRepository: feedRepository,
            location: locationManager.currentLocation?.location,
            countryCode: locationManager.currentLocation?.countryCode,
            variant: "\(featureFlags.sectionedFeedABTestIntValue)")
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
        super.init()
        setup()
    }
    
    convenience override init() {
        let filters = ListingFilters()
        self.init(filters: filters)
    }
    
    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        updatePermissionsPresenter()
        refreshFeed()
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
            retrieveNext(withUrl: page, completion: feedCompletion())
        }
    }
    
    func willScroll(toSection section: Int) {
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
}

//  MARK: - FeedRequester

extension FeedViewModel {
    
    func retrieve() {
        let completion = feedCompletion()
        isRetrieving = true
        if let nextFeedPageURL = paginationLinks?.next {
            listingRetrievalState = .loading
            retrieveNext(withUrl: nextFeedPageURL, completion: completion)
        } else {
            viewState = .loading
            retrieveFirst(completion)
        }
    }
    
    func retrieveFirst(_ completion: @escaping FeedCompletion) {
        feedRequester?.retrieve(completion)
    }
    
    func retrieveNext(withUrl url: URL, completion: @escaping FeedCompletion) {
        feedRequester?.retrieve(nextURL: url, completion)
    }
    
    private func feedCompletion() -> FeedCompletion {
        return { [weak self] result in
            self?.isRetrieving = false
            if let error = result.error {
                self?.show(error: error)
            } else if let feed = result.value {
                self?.removeLoadingBottom()
                defer {
                    self?.refreshFeed()
                    
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
                return
        }
        viewState = .error(errorViewModel)
    }
    
    private func updateFeedItems(withFeed feed: Feed) {
        
        let horizontalSections = feed.horizontalSections(featureFlags, myUserRepository, keyValueStorage, waterfallColumnCount)
        let verticalItemSections = feed.verticalItems(featureFlags, myUserRepository, keyValueStorage, waterfallColumnCount)
        
        feedItems.append(contentsOf: horizontalSections.listDiffable())
        if locationSectionIndex == nil {
            feedItems.append(LocationData(locationString: locationText))
        }
        
        let verticalSectionsWithAds = updateWithAds(listDiffable: verticalItemSections.listDiffable())
        let allVerticalSections = updateWithSelectedForYou(listDiffable: verticalSectionsWithAds,
                                                           positionInFeed: feedItems.count,
                                                           offset: SharedConstants.selectedForYouPosition)
        
        feedItems.append(contentsOf: allVerticalSections)
        
        previousVerticalPageSize = allVerticalSections.count
        trackSectionsAndItems(inFeed: feed)
    }
    
    private func updateWithAds(listDiffable: [ListDiffable]) -> [ListDiffable] {
        guard adsImpressionConfigurable.shouldShowAdsForUser  else { return listDiffable }
        
        let positions = adsPaginationHelper.adIndexesPositions(withItemListCount: listDiffable.count)
        let ads = positions.reversed().map { AdDataFactory.make(adPosition: feedItems.count + $0).listDiffable() }
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
        let location = currentPlace.location
        let countryCode = currentPlace.postalAddress?.countryCode
        feedRequester = FeedRequesterFactory.make(withFeedRepository: feedRepository,
                                                  location: location,
                                                  countryCode: countryCode,
                                                  variant: "\(featureFlags.sectionedFeedABTestIntValue)")
    }
    
    private func resetFeed() {
        pages.removeAll()
        previousVerticalPageSize = 0
        paginationLinks = nil
        feedItems.removeAll()
        adsPaginationHelper.reset()
    }
    
}

extension FeedViewModel {
    
    func openInvite() {
        wireframe?.openAppInvite(
            myUserId: myUserRepository.myUser?.objectId,
            myUserName:  myUserRepository.myUser?.name)
    }
    
    func openSearches() { navigator?.openSearches() }
    
    func showFilters() {
        wireframe?.openFilters(withListingFilters: filters,
                               filtersVMDataDelegate: self)
        tracker.trackEvent(TrackerEvent.filterStart())
    }
    
    func refreshControlTriggered() {
        resetFeed()
        guard let searchType = searchType else { return retrieve() }
        if case .feed(let page, _) = searchType {
            retrieveNext(withUrl: page, completion: feedCompletion())
        } else { retrieve() }
    }
}

// MARK:- FiltersViewModelDataDelegate

extension FeedViewModel: FiltersViewModelDataDelegate {
    
    func viewModelDidUpdateFilters(_ viewModel: FiltersViewModel,
                                   filters: ListingFilters) {
        self.filters = filters
        refreshFiltersVar()
        refreshFeed()
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
                                               selector: #selector(updatePermissionsPresenter),
                                               name: NSNotification.Name(rawValue:
                                                PushManager.Notification.DidRegisterUserNotificationSettings.rawValue),
                                               object: nil)
    }
    
    @objc private dynamic func updatePermissionsPresenter() {
        let pushBannerId = StaticSectionType.pushBanner.rawValue as ListDiffable
        let hasPushMessage = feedItems.contains(where: { $0.isEqual(toDiffableObject: pushBannerId) })
        
        if !hasPushMessage && !application.areRemoteNotificationsEnabled {
            feedItems.insert(pushBannerId, at: 0)
        } else if hasPushMessage && application.areRemoteNotificationsEnabled {
            feedItems.remove(at: 0)
        }
        refreshFeed()
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
        filters.place = place
        filters.distanceRadius = distanceRadius
        
        updateLocationTextInFeedItems(newLocationString: locationText)
        
        resetFeed()
        updateFeedRequester()
        refreshFiltersVar()
        retrieve()
    }
    
    private func updateLocationTextInFeedItems(newLocationString: String) {
        guard let index = locationSectionIndex else { return }
        feedItems[index] = LocationData(locationString: newLocationString)
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
            listingFilters: filters)
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
        feedItems.removeLast()
        retrieve()
    }
}

// MARK: - Horizontal selection delegate

extension FeedViewModel: HorizontalSectionDelegate {
    func didTapSeeAll(page: SearchType) { wireframe?.openProFeed(withSearchType: page) }
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
        let type = ChatWrapperMessageType.interested(QuickAnswer.interested.textToReply)
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
                          sectionIdentifier: String) {
        let data = ListingDetailData.sectionedNonRelatedListing(
            listing: listing,
            feedListingDatas: feedDataArray,
            thumbnailImage: thumbnailImage,
            originFrame: originFrame,
            index: index,
            sectionIdentifier: sectionIdentifier
        )
        listingWireframe?.openListing(
            data, source: listingVisitSource, actionOnFirstAppear: .nonexistent)
    }
    
    func didSelectListing(_ listing: Listing, thumbnailImage: UIImage?, originFrame: CGRect?) {
        let frame = feedRenderingDelegate?.convertViewRectInFeed(from: originFrame ?? .zero)
        let data = ListingDetailData.sectionedRelatedListing(
            listing: listing, thumbnailImage: thumbnailImage, originFrame: frame)
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


//  MARK: - Tracking

extension FeedViewModel {

    var listingVisitSource: EventParameterListingVisitSource {
        if let searchType = searchType {
            switch searchType {
            // TODO: Add tracker for feed!.
            case .collection, .feed: return .collection
            case .user, .trending, .suggestive, .lastSearch:
                return !hasFilters ? .search : .searchAndFilter
            }
        }
        if hasFilters {
            return filters.selectedCategories.isEmpty ? .filter : .category
        }
        return .section
    }
    
    var feedSource: EventParameterFeedSource {
        guard let search = searchType else {
            return hasFilters ? .filter : .section
        }
        
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
                                                           feedSource: feedSource)
    }
    
    private func trackFirstMessage(info: SendMessageTrackingInfo,
                                   sectionedFeedChatTrackingInfo: SectionedFeedChatTrackingInfo?,
                                   listing: Listing) {
        sectionedFeedVMTrackerHelper.trackFirstMessage(info: info,
                                                       listingVisitSource: listingVisitSource,
                                                       sectionedFeedChatTrackingInfo: sectionedFeedChatTrackingInfo,
                                                       listing: listing)
    }
}
