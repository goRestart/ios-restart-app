import Foundation
import RxSwift
import RxCocoa
import LGCoreKit
import LGComponents

final class FeedViewModel: BaseViewModel, FeedViewModelType {
    
    private let tracker: Tracker
    let infoBubbleText = Variable<String>(R.Strings.productPopularNearYou)
    let infoBubbleVisible = Variable<Bool>(true) // FIXME: Change to false after implementing Listing Cells
    
    var rxHasFilter: Driver<Bool> {
        return filtersVar.asDriver().map({ !$0.isDefault() })
    }
    
    private let filtersVar: Variable<ListingFilters>
    
    private let disposeBag = DisposeBag()
    
    private let featureFlags: FeatureFlaggeable

    weak var navigator: MainTabNavigator?
    
    
    // MARK:- Section Components
    
    private let sectionCollection: FeedSectionMapCollection = FeedSectionMapCollection()

    var sectionsDriver: Driver<[FeedSectionMap]> {
        return sectionCollection.sectionsDriver
    }
    
    
    // MARK:- All possibile header & cell types that could be presented during the lifecycle of the VM
    var allHeaderPresenters: [FeedPresenter.Type] {
        return [PushPermissionsPresenter.self, FilterTagFeedPresenter.self, CategoryPresenter.self]
    }
    
    var allCellItemPresenters: [FeedPresenter.Type] {
        return [EmptyFeedCellPresenter.self]
    }

    
    // MARK:- Life Cycle
    
    private var filters: ListingFilters
    var queryString: String?
    private let application: Application
    private let searchType: SearchType?
    private var shouldTrackSearch = false
    private let bubbleTextGenerator: DistanceBubbleTextGenerator
    private let myUserRepository: MyUserRepository
    private let pushPermissionsManager: LGPushPermissionsManager
    private let locationManager: LocationManager
    
    init(searchType: SearchType? = nil,
         filters: ListingFilters,
         bubbleTextGenerator: DistanceBubbleTextGenerator = DistanceBubbleTextGenerator(),
         myUserRepository: MyUserRepository = Core.myUserRepository,
         tracker: Tracker = TrackerProxy.sharedInstance,
         pushPermissionsManager: LGPushPermissionsManager = LGPushPermissionsManager.sharedInstance,
         application: Application = UIApplication.shared,
         locationManager: LocationManager = Core.locationManager,
         featureFlags: FeatureFlaggeable = FeatureFlags.sharedInstance) {
        self.filters = filters
        self.filtersVar = Variable<ListingFilters>(filters)
        self.bubbleTextGenerator = bubbleTextGenerator
        self.searchType = searchType
        self.queryString = searchType?.query
        if let search = searchType, let query = search.query, !search.isCollection && !query.isEmpty {
            self.shouldTrackSearch = true
        }
        self.myUserRepository = myUserRepository
        self.tracker = tracker
        self.pushPermissionsManager = pushPermissionsManager
        self.application = application
        self.locationManager = locationManager
        self.featureFlags = featureFlags

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
    
    var searchString: String? { return searchType?.text }

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
    
    private var defaultBubbleText: String {
        let distance = filters.distanceRadius ?? 0
        let type = filters.distanceType
        return bubbleTextGenerator.bubbleInfoText(forDistance: distance, type: type, distanceRadius: filters.distanceRadius, place: filters.place)
    }
    
    func bubbleTapped() {
        let currentLocation = locationManager.currentLocation
        let initialPlace = filters.place ?? Place(postalAddress: currentLocation?.postalAddress,
                                                  location: currentLocation?.location)
        navigator?.openLocationSelection(initialPlace: initialPlace,
                                         distanceRadius: filters.distanceRadius,
                                         locationDelegate: self)
    }
    
    
    // MARK:- Navigation
    
    var shouldShowInviteButton: Bool {
        return navigator?.canOpenAppInvite() ?? false
    }
    
    
    // App share
    private var myUserId: String? {
        return myUserRepository.myUser?.objectId
    }
    
    private var myUserName: String? {
        return myUserRepository.myUser?.name
    }
    
    // MARK:- Rx
    
    var rxOperations: Driver<FeedOperation> {
        return Driver.just(FeedOperation.reloadAll)
    }
    
    // MARK: - Private methods
    
    private func setup() {
        setupSectionCollection()
        infoBubbleText.value = defaultBubbleText
        setupPermissionsNotification()
        refreshFeed()
    }
    
    private func setupSectionCollection() {
        // FIXME: Do this dynamically
        let defaultSections = [FeedSectionMap.makeFilterSection(filters: filters),
                               FeedSectionMap.makeCategorySection(),
                               FeedSectionMap.makeListingSection()]
        sectionCollection.populate(with: defaultSections)
    }
    
    private func refreshFeed() {
        // FIXME: Add more refresh logic
        updatePermissionsPresenter()
    }
}

extension FeedViewModel {

    func openInvite() {
        navigator?.openAppInvite(myUserId: myUserId, myUserName: myUserName)
    }
    
    func showFilters() {
        navigator?.openFilters(withListingFilters: filters, filtersVMDataDelegate: nil) // FIXME: filtersVMDataDelegate should be implemented
        tracker.trackEvent(TrackerEvent.filterStart())
    }
    
    func refreshControlTriggered() {
        // FIXME: Add Refresh logic
    }
}


// MARK: Relating to section feed data source

extension FeedViewModel {
    
    func item(for indexPath: IndexPath) -> FeedPresenter? {
        return sectionCollection.sortedSections[safeAt: indexPath.section]?.items[safeAt: indexPath.item]
    }
    
    func header(for section: Int) -> FeedPresenter? {
        return sectionCollection.sortedSections[section].header
    }
    
    func numberOfItems(in section: Int) -> Int {
        return sectionCollection.sortedSections[safeAt: section]?.items.count ?? 0
    }
    
    func numberOfSections() -> Int {
        return sectionCollection.sortedSections.count
    }
}


// MARK: PushPermissionsPresenterDelegate conformance

extension FeedViewModel: PushPermissionsPresenterDelegate {
    
    func showPushPermissionsAlert(withPositiveAction positiveAction: @escaping (() -> Void),
                                  negativeAction: @escaping (() -> Void)) {
        navigator?.showPushPermissionsAlert(withPositiveAction: positiveAction, negativeAction: negativeAction)
    }
    
    // MARK: Handling Push Permissions Changes
    private func setupPermissionsNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(updatePermissionsPresenter),
                                               name: NSNotification.Name(rawValue: PushManager.Notification.DidRegisterUserNotificationSettings.rawValue), object: nil)
    }
    
    @objc private dynamic func updatePermissionsPresenter() {
        if application.areRemoteNotificationsEnabled {
            sectionCollection.removeSection(ofType: .pushPermissions)
        } else {
            if !sectionCollection.containsSection(ofType: .pushPermissions) {
                let pushPermissionTracker = PushPermissionsTracker(tracker: tracker,
                                                                   pushPermissionsManager: pushPermissionsManager)
                sectionCollection.insert(section: FeedSectionMap.makePushSection(delegate: self,
                                                                                 pushPermissionTracker: pushPermissionTracker),
                                         forOrderCondition: OrderCondition.after(item: .filters))
            }
        }
    }
}


extension FeedViewModel: EditLocationDelegate {
    func editLocationDidSelectPlace(_ place: Place, distanceRadius: Int?) {
        filters.place = place
        filters.distanceRadius = distanceRadius
        filtersVar.value = filters
        refreshFeed()
    }
}
