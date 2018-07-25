import Foundation
import RxSwift
import RxCocoa
import LGCoreKit
import LGComponents
import IGListKit

final class FeedViewModel: BaseViewModel, FeedViewModelType {

    // Protocol conformance
    
    weak var navigator: MainTabNavigator?
    weak var feedRenderingDelegate: FeedRenderable?
    weak var delegate: FeedViewModelDelegate?
    
    let numberOfColumnsInLastSection: Int
    var queryString: String?
    private(set) var feedItems: [ListDiffable] = []

    var rxHasFilter: Driver<Bool> {
        return filtersVar.asDriver().map({ !$0.isDefault() })
    }
    
    private(set) var viewState: ViewState {
        didSet {
            delegate?.vmDidUpdateState(self, state: viewState)
        }
    }
    
    var searchString: String? {
        return searchType?.text
    }
    
    // Private vars
    
    private let filtersVar: Variable<ListingFilters>
    private let disposeBag = DisposeBag()
    
    private var listingRetrievalState: ListingRetrievalState = ListingRetrievalState.error //TODO: ABIOS-4511 Set correct loading state when loading objects https://ambatana.atlassian.net/browse/ABIOS-4511
    
    // Dependencies
    
    private let searchType: SearchType?
    private var filters: ListingFilters
    private let bubbleTextGenerator: DistanceBubbleTextGenerator
    private let myUserRepository: MyUserRepository
    private let categoryRepository: CategoryRepository
    private let tracker: Tracker
    private let pushPermissionsManager: LGPushPermissionsManager
    private let application: Application
    private let locationManager: LocationManager
    private let featureFlags: FeatureFlaggeable
    private let keyValueStorage: KeyValueStorage

    private var shouldTrackSearch = false
    private let shouldShow3ColumnsInLastSection: Bool
    
    
    // MARK:- Life Cycle
    
    init(searchType: SearchType? = nil,
         filters: ListingFilters,
         bubbleTextGenerator: DistanceBubbleTextGenerator = DistanceBubbleTextGenerator(),
         myUserRepository: MyUserRepository = Core.myUserRepository,
         categoryRepository: CategoryRepository = Core.categoryRepository,
         tracker: Tracker = TrackerProxy.sharedInstance,
         pushPermissionsManager: LGPushPermissionsManager = LGPushPermissionsManager.sharedInstance,
         application: Application = UIApplication.shared,
         locationManager: LocationManager = Core.locationManager,
         featureFlags: FeatureFlaggeable = FeatureFlags.sharedInstance,
         keyValueStorage: KeyValueStorage = KeyValueStorage.sharedInstance,
         deviceFamily: DeviceFamily = DeviceFamily.current) {
        self.filters = filters
        self.filtersVar = Variable<ListingFilters>(filters)
        self.bubbleTextGenerator = bubbleTextGenerator
        self.searchType = searchType
        self.queryString = searchType?.query
        if let search = searchType, let query = search.query, !search.isCollection && !query.isEmpty {
            self.shouldTrackSearch = true
        }
        self.myUserRepository = myUserRepository
        self.categoryRepository = categoryRepository
        self.tracker = tracker
        self.pushPermissionsManager = pushPermissionsManager
        self.application = application
        self.locationManager = locationManager
        self.featureFlags = featureFlags
        self.keyValueStorage = keyValueStorage
        self.shouldShow3ColumnsInLastSection = deviceFamily.isWiderOrEqualThan(.iPhone6Plus)
        self.numberOfColumnsInLastSection = shouldShow3ColumnsInLastSection ? 3 : 2
        self.viewState = .loading
        super.init()
        setup()
    }
    
    convenience override init() {
        let filters = ListingFilters()
        self.init(filters: filters)
    }
    
    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        refreshFeed()
    }
    
    
    // MARK:- Search
    
    var clearTextOnSearch: Bool {
        guard let searchType = searchType else { return false }
        switch searchType {
        case .collection:
            return true
        case .user, .trending, .suggestive, .lastSearch:
            return false
        }
    }
    
    
    // MARK:- Filter
    
    var hasFilters: Bool {
        return !filters.isDefault()
    }
    
    
    // MARK:- Info Bubble
    
    private var locationText: String {
        let distance = filters.distanceRadius ?? 0
        let type = filters.distanceType
        return bubbleTextGenerator.bubbleInfoText(forDistance: distance, type: type, distanceRadius: filters.distanceRadius, place: filters.place)
    }
    
    
    // MARK:- Navigation
    
    var shouldShowInviteButton: Bool {
        return navigator?.canOpenAppInvite() ?? false
    }
    
    
    // MARK: - App share
    
    private var myUserId: String? {
        return myUserRepository.myUser?.objectId
    }
    
    private var myUserName: String? {
        return myUserRepository.myUser?.name
    }


    // MARK: - Load Feed Items
    
    func loadFeedItems() {
        feedItems.append(StaticSectionType.categoryBubble.rawValue as ListDiffable)
        let listingSections = ListingSectionBuilder.buildListingSections(locationString: locationText)
        feedItems.append(contentsOf: listingSections)
        
        // TODO: Temporarily giving a delay to see the loading of fake feeditems. Will be removed when implementing ABIOS-4511 https://ambatana.atlassian.net/browse/ABIOS-4511
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.viewState = .data
        }
    }
    
    private func updateLocationTextInFeedItems(newLocationString: String) {
        guard let lastSectionModel = feedItems.last as? ListingSectionModel,
            lastSectionModel.type == ListingSectionType.vertical.rawValue else { return }
        lastSectionModel.title = newLocationString
    }

    func feedSectionController(for object: Any) -> ListSectionController {

        if let listingSectionModel = object as? ListingSectionModel,
            let sectionType = ListingSectionType(rawValue: listingSectionModel.type) {
            return feedListingSectionController(for: sectionType)
        } else if let staticSectionString = object as? String,
            let staticSectionType = StaticSectionType(rawValue: staticSectionString) {
            return staticSectionController(for: staticSectionType)
        } else {
            return ListSectionController()
        }
    }
    
    private func staticSectionController(for type: StaticSectionType) -> ListSectionController {
        switch type {
        case .categoryBubble:
            let categoryBubbleSectionController = CategoryBubbleSectionController()
            categoryBubbleSectionController.delegate = self
            return categoryBubbleSectionController
        case .pushBanner:
            let pushTracker = PushPermissionsTracker(tracker: tracker,
                                                     pushPermissionsManager: pushPermissionsManager)
            let pushMessageSectionController = PushMessageSectionController(pushPermissionTracker: pushTracker)
            pushMessageSectionController.delegate = self
            return pushMessageSectionController
        }
    }
    
    private func feedListingSectionController(for sectionType: ListingSectionType) -> ListSectionController {
        switch sectionType {
        case .horizontal:
            let horizontalSectionController = HorizontalSectionController()
            return horizontalSectionController
        case .vertical:
            let listingSectionController = ListingSectionController(numberOfColumns: numberOfColumnsInLastSection, listingState: listingRetrievalState)
            listingSectionController.locationEditable = self
            return listingSectionController
        }
    }

    // MARK: - Private methods
    
    private func setup() {
        setupPermissionsNotification()
        updatePermissionsPresenter()
    }
    
    private func refreshFeed() {
        feedRenderingDelegate?.updateFeed()
    }
    
    private func refreshFiltersVar() {
        filtersVar.value = filters
    }
}

extension FeedViewModel {

    func openInvite() {
        navigator?.openAppInvite(myUserId: myUserId, myUserName: myUserName)
    }
    
    func showFilters() {
        navigator?.openFilters(withListingFilters: filters,
                               filtersVMDataDelegate: self)
        tracker.trackEvent(TrackerEvent.filterStart())
    }
    
    func refreshControlTriggered() {
        // FIXME: Add Refresh logic
    }
    
    func updateFilters(fromCategoryHeaderInfo categoryHeaderInfo: CategoryHeaderInfo) {
        switch categoryHeaderInfo.categoryHeaderElement {
        case .listingCategory(let listingCategory):
            filters.selectedCategories = [listingCategory]
        case .superKeywordGroup(let taxonomy):
            filters.selectedTaxonomy = taxonomy
        case .showMore:
            trackFilterCategoryHeaderSelection(with: categoryHeaderInfo)
            return // do not update any filters
        case .mostSearchedItems, .superKeyword:
            return
        }
        
        trackFilterCategoryHeaderSelection(with: categoryHeaderInfo)
        refreshFiltersVar()
        refreshFeed()
    }

    private func trackFilterCategoryHeaderSelection(with categoryHeader: CategoryHeaderInfo) {
        tracker.trackEvent(TrackerEvent.filterCategoryHeaderSelected(position: categoryHeader.position,
                                                                     name: categoryHeader.name))
    }
}


// MARK:- Categories

extension FeedViewModel {
    
    private var primaryTags: [FilterTag] {
        return FilterTagBuilder(filters: filters).primaryTags
    }
    
    var shouldShowCategoriesSection: Bool {
        return primaryTags.isEmpty // FIXME: Add && !listViewModel.isListingListEmpty.value && !isSearchAlertsEnabled
    }
}


// MARK:- CategoryPresenterDelegate conformance

extension FeedViewModel: CategoriesHeaderCollectionViewDelegate {
    
    private func getTaxonomies() -> [Taxonomy] {
        return categoryRepository.indexTaxonomies()
    }
    
    private func getTaxonomyChildren() -> [TaxonomyChild] {
        return getTaxonomies().flatMap { $0.children }
    }
    
    func openTaxonomyList() {
        let taxonomiesViewModel = TaxonomiesViewModel(taxonomies: getTaxonomies(),
                                                      taxonomySelected: nil,
                                                      taxonomyChildSelected: nil,
                                                      source: .listingList)
        taxonomiesViewModel.taxonomiesDelegate = self
        navigator?.openTaxonomyList(withViewModel: taxonomiesViewModel)
    }
    
    func openMostSearchedItems() {
        navigator?.openMostSearchedItems(source: .mostSearchedCategoryHeader, enableSearch: true)
    }
    
    func categoryHeaderDidSelect(categoryHeaderInfo: CategoryHeaderInfo) {
        updateFilters(fromCategoryHeaderInfo: categoryHeaderInfo)
    }
}


// MARK:- TaxonomiesDelegate conformance

extension FeedViewModel: TaxonomiesDelegate {
    
    func didSelect(taxonomy: Taxonomy) {
        filters.selectedTaxonomy = taxonomy
        filters.selectedTaxonomyChildren = []
        refreshFiltersVar()
        refreshFeed()
    }
    
    func didSelect(taxonomyChild: TaxonomyChild) {
        filters.selectedTaxonomyChildren = [taxonomyChild]
        refreshFiltersVar()
        refreshFeed()
    }
}


// MARK:- FiltersViewModelDataDelegate conformance
extension FeedViewModel: FiltersViewModelDataDelegate {
    
    func viewModelDidUpdateFilters(_ viewModel: FiltersViewModel,
                                   filters: ListingFilters) {
        self.filters = filters
        refreshFiltersVar()
        refreshFeed()
    }
}

// MARK: PushPermissionsPresenterDelegate conformance

extension FeedViewModel: PushPermissionsPresenterDelegate {
    
    func showPushPermissionsAlert(withPositiveAction positiveAction: @escaping (() -> Void),
                                  negativeAction: @escaping (() -> Void)) {
        navigator?.showPushPermissionsAlert(withPositiveAction: positiveAction,
                                            negativeAction: negativeAction)
    }
    
    // MARK: Handling Push Permissions Changes
    private func setupPermissionsNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(updatePermissionsPresenter),
                                               name: NSNotification.Name(rawValue:
                                                PushManager.Notification.DidRegisterUserNotificationSettings.rawValue),
                                               object: nil)
    }
    
    @objc private dynamic func updatePermissionsPresenter() {
        let pushBannerId = StaticSectionType.pushBanner.rawValue as ListDiffable
        let hasPushMessage = feedItems.contains(where: { $0.isEqual(toDiffableObject: pushBannerId) })
        if application.areRemoteNotificationsEnabled && hasPushMessage {
            feedItems.remove(at: 0)
        } else {
            if !hasPushMessage {
                feedItems.insert(pushBannerId, at: 0)
            }
        }
        feedRenderingDelegate?.updateFeed()
    }
}

extension FeedViewModel {
    func openSearches() {
        navigator?.openSearches()
    }
}

extension FeedViewModel: EditLocationDelegate, LocationEditable {
    
    func openEditLocation() {
        let currentLocation = locationManager.currentLocation
        let initialPlace = filters.place ?? Place(postalAddress: currentLocation?.postalAddress,
                                                  location: currentLocation?.location)
        navigator?.openLocationSelection(initialPlace: initialPlace,
                                         distanceRadius: filters.distanceRadius,
                                         locationDelegate: self)
    }
    
    func editLocationDidSelectPlace(_ place: Place, distanceRadius: Int?) {
        filters.place = place
        filters.distanceRadius = distanceRadius
        updateLocationTextInFeedItems(newLocationString: locationText)
        refreshFiltersVar()
        refreshFeed()
    }
}
