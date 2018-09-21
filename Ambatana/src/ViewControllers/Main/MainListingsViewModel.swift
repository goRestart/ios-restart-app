import CoreLocation
import LGCoreKit
import Result
import RxSwift
import RxCocoa
import GoogleMobileAds
import MoPub
import LGComponents

protocol MainListingsViewModelDelegate: BaseViewModelDelegate {
    func vmDidSearch()
    func vmShowTags(tags: [FilterTag])
    func vmFiltersChanged()
    func vmShowMapToolTip(with configuration: TooltipConfiguration)
    func vmHideMapToolTip(hideForever: Bool)
}

protocol MainListingsAdsDelegate: class {
    func rootViewControllerForAds() -> UIViewController
}

protocol MainListingsTagsDelegate: class {
    func onCloseAllFilters(finalFiters: ListingFilters)
}

final class MainListingsViewModel: BaseViewModel, FeedNavigatorOwnership {
    
    weak var searchNavigator: SearchNavigator?
    
    static let adInFeedInitialPosition = 3
    private static let adsInFeedRatio = 20
    private static let searchAlertLimit = 20
    
    var wireframe: MainListingNavigator? // We'll call this wireframe to avoid clashing. Too many navigators here
    
    // > Input
    var searchString: String? {
        return searchType?.text
    }
    
    private var cellStyle: CellStyle {
        let showServiceCell = filters.hasSelectedCategory(.services)
        return showServiceCell ? .serviceList : .mainList
    }
    
    var clearTextOnSearch: Bool {
        guard let searchType = searchType else { return false }
        switch searchType {
        case .collection, .feed:
            return true
        case .user, .trending, .suggestive, .lastSearch:
            return false
        }
    }
    
    private let interestingUndoTimeout: TimeInterval = 5
    private let chatWrapper: ChatWrapper
    private let adsImpressionConfigurable: AdsImpressionConfigurable
    private let interestedHandler: InterestedHandleable

    let bannerCellPosition: Int = 8
    let suggestedSearchesLimit: Int = 10
    var filters: ListingFilters
    var queryString: String?
    var shouldHideCategoryAfterSearch = false
    var activeRequesterType: RequesterType?
    
    private var isMapTooltipAdded = false
    
    private var shouldCloseOnRemoveAllFilters: Bool = false
    
    var hasFilters: Bool {
        return !filters.isDefault()
    }
    
    private var isRealEstateSelected: Bool {
        return filters.selectedCategories.contains(.realEstate)
    }
    
    private var isServicesSelected: Bool {
        return filters.selectedCategories.contains(.services)
    }
    
    var isEngagementBadgingEnabled: Bool {
        return featureFlags.engagementBadging.isActive
    }

    lazy var rightBBItemsRelay = BehaviorRelay<[(image: UIImage, selector: Selector)]>(value: rightBarButtonsItems)

    private var rightBarButtonsItems: [(image: UIImage, selector: Selector)] {
        var rightButtonItems: [(image: UIImage, selector: Selector)] = []
        if isRealEstateSelected {
            rightButtonItems.append((image: R.Asset.IconsButtons.icMap.image, selector: #selector(MainListingsViewController.openMap)))
            if shouldShowRealEstateMapTooltip {
                showTooltipMap()
            }
        } else {
            isMapTooltipAdded = false
            delegate?.vmHideMapToolTip(hideForever: false)
        }
        
        rightButtonItems.append((image: hasFilters ? R.Asset.IconsButtons.icFiltersActive.image : R.Asset.IconsButtons.icFilters.image, selector: #selector(MainListingsViewController.openFilters)))
        if shouldShowAffiliateButton {
            rightButtonItems.append((image: R.Asset.Affiliation.affiliationIcon.image.tint(color: .primaryColor), selector: #selector(MainListingsViewController.openAffiliationChallenges)))
        }
        return rightButtonItems
    }
    
    var defaultBubbleText: String {
        let distance = filters.distanceRadius ?? 0
        let type = filters.distanceType
        return bubbleTextGenerator.bubbleInfoText(forDistance: distance, type: type, distanceRadius: filters.distanceRadius, place: filters.place)
    }
    
    let infoBubbleVisible = Variable<Bool>(false)
    let infoBubbleText = Variable<String>(R.Strings.productPopularNearYou)
    let recentItemsBubbleVisible = Variable<Bool>(false)
    let recentItemsBubbleText = Variable<String>(R.Strings.engagementBadgingFeedBubble)
    let isFreshBubbleVisible = Variable<Bool?>(nil)

    let errorMessage = Variable<String?>(nil)
    let containsListings = Variable<Bool>(false)
    let isShowingCategoriesHeader = Variable<Bool>(false)

    var userAvatar = BehaviorRelay<UIImage?>(value: nil)

    var categoryHeaderElements: [FilterCategoryItem] { return FilterCategoryItem.makeForFeed(with: featureFlags) }
    var categoryHighlighted: FilterCategoryItem { return FilterCategoryItem(category: .services) }
    
    private static let firstVersionNumber = 1
    
    var tags: [FilterTag] {
        
        var resultTags : [FilterTag] = []
        for prodCat in filters.selectedCategories {
            resultTags.append(.category(prodCat))
        }

        if filters.selectedWithin.listingTimeCriteria != ListingTimeFilter.defaultOption.listingTimeCriteria {
            resultTags.append(.within(filters.selectedWithin))
        }
        if let selectedOrdering = filters.selectedOrdering, selectedOrdering != ListingSortCriteria.defaultOption {
            resultTags.append(.orderBy(selectedOrdering))
        }
        
        switch filters.priceRange {
        case .freePrice:
            resultTags.append(.freeStuff)
        case let .priceRange(min, max):
            if min != nil || max != nil {
                var currency: Currency? = nil
                if let countryCode = locationManager.currentLocation?.countryCode {
                    currency = currencyHelper.currencyWithCountryCode(countryCode)
                }
                resultTags.append(.priceRange(from: filters.priceRange.min, to: filters.priceRange.max, currency: currency))
            }
        }
        
        if filters.selectedCategories.contains(.cars) {
            let carFilters = filters.verticalFilters.cars
            if let makeId = carFilters.makeId, let makeName = carFilters.makeName {
                resultTags.append(.make(id: makeId, name: makeName.localizedUppercase))
                if let modelId = carFilters.modelId, let modelName = carFilters.modelName {
                    resultTags.append(.model(id: modelId, name: modelName.localizedUppercase))
                }
            }
            
            if carFilters.yearStart != nil || carFilters.yearEnd != nil {
                resultTags.append(.yearsRange(from: carFilters.yearStart, to: carFilters.yearEnd))
            }
            
            if carFilters.mileageStart != nil || carFilters.mileageEnd != nil {
                resultTags.append(.mileageRange(from: carFilters.mileageStart,
                                                to: carFilters.mileageEnd))
            }
            
            if carFilters.numberOfSeatsStart != nil || carFilters.numberOfSeatsEnd != nil {
                resultTags.append(.numberOfSeats(from: carFilters.numberOfSeatsStart,
                                                 to: carFilters.numberOfSeatsEnd))
            }

            let carSellerTypeTags = carFilters.sellerTypes.map({ FilterTag.carSellerType(type: $0, name: $0.title) })
            resultTags.append(contentsOf: carSellerTypeTags)

            carFilters.bodyTypes.forEach({ resultTags.append(.carBodyType($0)) })
            carFilters.fuelTypes.forEach({ resultTags.append(.carFuelType($0)) })
            carFilters.driveTrainTypes.forEach({ resultTags.append(.carDriveTrainType($0)) })
            carFilters.transmissionTypes.forEach({ resultTags.append(.carTransmissionType($0)) })
        }
        
        if isRealEstateSelected {
            let realEstateFilters = filters.verticalFilters.realEstate
            if let propertyType = realEstateFilters.propertyType {
                resultTags.append(.realEstatePropertyType(propertyType))
            }
            
            realEstateFilters.offerTypes.forEach { resultTags.append(.realEstateOfferType($0)) }
            
            if let numberOfBedrooms = realEstateFilters.numberOfBedrooms {
                resultTags.append(.realEstateNumberOfBedrooms(numberOfBedrooms))
            }
            if let numberOfBathrooms = realEstateFilters.numberOfBathrooms {
                resultTags.append(.realEstateNumberOfBathrooms(numberOfBathrooms))
            }
            if let numberOfRooms = realEstateFilters.numberOfRooms {
                resultTags.append(.realEstateNumberOfRooms(numberOfRooms))
            }
            if realEstateFilters.sizeRange.min != nil || realEstateFilters.sizeRange.max != nil {
                resultTags.append(.sizeSquareMetersRange(from: realEstateFilters.sizeRange.min,
                                                         to: realEstateFilters.sizeRange.max))
            }
        }
        
        if isServicesSelected {
            let servicesFilters = filters.verticalFilters.services
            servicesFilters.listingTypes.forEach({ resultTags.append(.serviceListingType($0)) })

            if featureFlags.servicesUnifiedFilterScreen.isActive {
                if let serviceType = servicesFilters.type {
                    
                    if let serviceSubtypes = servicesFilters.subtypes {
                        if serviceType.subTypes.count == serviceSubtypes.count ||
                            serviceSubtypes.count == 0 {
                            resultTags.append(.serviceType(serviceType))
                        } else {
                            resultTags.append(.unifiedServiceType(type: serviceType,
                                                                  selectedSubtypes: serviceSubtypes))
                        }
                    } else {
                        resultTags.append(.serviceType(serviceType))
                    }
                }
            } else {
                if let serviceType = servicesFilters.type {
                    resultTags.append(.serviceType(serviceType))
                }
                
                if let tags = servicesFilters.subtypes?.map({ FilterTag.serviceSubtype($0) }) {
                    resultTags.append(contentsOf: tags)
                }
            }
        }
        
        return resultTags
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
    
    private var carSelectedWithFilters: Bool {
        guard filters.selectedCategories.contains(.cars) else { return false }
        return filters.hasAnyCarAttributes
    }
    
    private var realEstateSelectedWithFilters: Bool {
        guard isRealEstateSelected else { return false }
        return filters.hasAnyRealEstateAttributes
    }
    
    private var servicesSelectedWithFilters: Bool {
        guard filters.selectedCategories.contains(.services)  else { return false }
        return filters.hasAnyServicesAttributes
    }
    
    fileprivate var shouldShowNoExactMatchesDisclaimer: Bool {
        guard realEstateSelectedWithFilters || carSelectedWithFilters || servicesSelectedWithFilters else { return false }
        return true
    }
    
    private var shouldShowCollections: Bool {
        return keyValueStorage[.lastSuggestiveSearches].count >= minimumSearchesSavedToShowCollection && filters.noFilterCategoryApplied
    }
    
    private var shouldShowRealEstateMapTooltip: Bool {
        return keyValueStorage[.realEstateTooltipMapShown] && !isMapTooltipAdded
    }
    
    private func showTooltipMap() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3
        let title = R.Strings.realEstateMapTooltipTitle
        let attributedText = title.bicolorAttributedText(mainColor: .white,
                                                         colouredText: R.Strings.commonNew.capitalizedFirstLetterOnly,
                                                         otherColor: .primaryColor,
                                                         font: UIFont.systemSemiBoldFont(size: 15),
                                                         paragraphStyle: paragraphStyle)
        let tooltipConfiguration = TooltipConfiguration(title: attributedText,
                                                        style: .black(closeEnabled: false),
                                                        peakOnTop: true,
                                                        actionBlock: {},
                                                        closeBlock:{ [weak self] in
                                                            self?.isMapTooltipAdded = false
                                                            self?.delegate?.vmHideMapToolTip(hideForever: true)
        })
        isMapTooltipAdded = true
        delegate?.vmShowMapToolTip(with: tooltipConfiguration)
    }
    
    func tooltipDidHide() {
        keyValueStorage[.realEstateTooltipMapShown] = true
    }

    
    let mainListingsHeader = Variable<MainListingsHeader>([])
    let filterTitle = Variable<String?>(nil)
    let filterDescription = Variable<String?>(nil)
    
    // Manager & repositories
    fileprivate let sessionManager: SessionManager
    fileprivate let myUserRepository: MyUserRepository
    fileprivate let searchRepository: SearchRepository
    fileprivate let listingRepository: ListingRepository
    fileprivate let monetizationRepository: MonetizationRepository
    fileprivate let locationManager: LocationManager
    private let notificationsManager: NotificationsManager
    fileprivate let currencyHelper: CurrencyHelper
    fileprivate let bubbleTextGenerator: DistanceBubbleTextGenerator
    fileprivate let categoryRepository: CategoryRepository
    private let searchAlertsRepository: SearchAlertsRepository
    fileprivate let userRepository: UserRepository
    private let feedBadgingSynchronizer: FeedBadgingSynchronizer
    private let appsFlyerAffiliationResolver: AppsFlyerAffiliationResolver
    
    fileprivate let tracker: Tracker
    fileprivate let searchType: SearchType? // The initial search
    fileprivate var collections: [CollectionCellType] {
        guard shouldShowCollections else { return [] }
        return [.selectedForYou]
    }
    fileprivate let keyValueStorage: KeyValueStorage
    fileprivate let featureFlags: FeatureFlaggeable
    
    // > Delegate
    weak var delegate: MainListingsViewModelDelegate?
    weak var adsDelegate: MainListingsAdsDelegate?
    weak var tagsDelegate: MainListingsTagsDelegate?
    
    // > Navigator
    weak var navigator: MainTabNavigator?
    var feedNavigator: MainTabNavigator? { return navigator }
    
    // List VM
    let listViewModel: ListingListViewModel
    private var listingListRequester: ListingListMultiRequester
    var currentActiveFilters: ListingFilters? {
        return filters
    }
    var userActiveFilters: ListingFilters? {
        return filters
    }
    fileprivate var shouldRetryLoad = false
    fileprivate var lastReceivedLocation: LGLocation?
    fileprivate var bubbleDistance: Float = 1
    fileprivate var lastAdPosition: Int = 0
    fileprivate var previousPagesAdsOffset: Int = 0
    
    // Search tracking state
    fileprivate var shouldTrackSearch = false
    
    // Suggestion searches
    let minimumSearchesSavedToShowCollection = 3
    let lastSearchesSavedMaximum = 10
    let lastSearchesShowMaximum = 3
    let trendingSearches = Variable<[String]>([])
    let suggestiveSearchInfo = Variable<SuggestiveSearchInfo>(SuggestiveSearchInfo.empty())
    let lastSearches = Variable<[LocalSuggestiveSearch]>([])
    let searchText = Variable<String?>(nil)
    
    func numberOfItems(type: SearchSuggestionType) -> Int {
        switch type {
        case .suggestive:
            return suggestiveSearchInfo.value.count
        case .lastSearch:
            return lastSearches.value.count
        case .trending:
            return trendingSearches.value.count
        }
    }
    
    // App share
    fileprivate var myUserId: String? {
        return myUserRepository.myUser?.objectId
    }
    fileprivate var myUserName: String? {
        return myUserRepository.myUser?.name
    }
    
    private var isCurrentFeedACachedFeed: Bool = false {
        didSet { isFreshBubbleVisible.value = isCurrentFeedACachedFeed }
    }
    
    fileprivate let disposeBag = DisposeBag()
    
    var currentSearchAlertCreationData = Variable<SearchAlertCreationData?>(nil)
    private var searchAlerts: [SearchAlert] = []
    var shouldShowSearchAlertBanner: Bool {
        let isThereLoggedUser = myUserRepository.myUser != nil
        let hasSearchQuery = searchType?.text != nil
        return isThereLoggedUser && hasSearchQuery
    }
    private var shouldFetchCache: Bool {
        let isEmpty = listViewModel.isListingListEmpty.value
        return !isCurrentFeedACachedFeed && isEmpty && !hasFilters
    }

    private var shouldDisableOldestSearchAlertIfMaximumReached: Bool {
        return featureFlags.searchAlertsDisableOldestIfMaximumReached.isActive
    }
    
    private let requesterFactory: RequesterFactory
    private let requesterDependencyContainer: RequesterDependencyContainer
    
    
    private var canShowCarPromoCells: Bool {
        return featureFlags.carPromoCells.isActive && filters.isCarSearch
    }
    
    private var canShowServicePromoCells: Bool {
        return featureFlags.servicesPromoCells.isActive && filters.isJobsAndServicesSearch
    }
    
    // MARK: - Lifecycle
    
    init(sessionManager: SessionManager,
         myUserRepository: MyUserRepository,
         searchRepository: SearchRepository,
         listingRepository: ListingRepository,
         monetizationRepository: MonetizationRepository,
         categoryRepository: CategoryRepository,
         searchAlertsRepository: SearchAlertsRepository,
         userRepository: UserRepository,
         locationManager: LocationManager,
         notificationsManager: NotificationsManager,
         currencyHelper: CurrencyHelper,
         tracker: Tracker,
         searchType: SearchType? = nil,
         filters: ListingFilters,
         keyValueStorage: KeyValueStorage,
         featureFlags: FeatureFlaggeable,
         bubbleTextGenerator: DistanceBubbleTextGenerator,
         chatWrapper: ChatWrapper,
         adsImpressionConfigurable: AdsImpressionConfigurable,
         interestedHandler: InterestedHandleable,
         feedBadgingSynchronizer: FeedBadgingSynchronizer,
         appsFlyerAffiliationResolver: AppsFlyerAffiliationResolver) {
        self.sessionManager = sessionManager
        self.myUserRepository = myUserRepository
        self.searchRepository = searchRepository
        self.listingRepository = listingRepository
        self.monetizationRepository = monetizationRepository
        self.categoryRepository = categoryRepository
        self.searchAlertsRepository = searchAlertsRepository
        self.userRepository = userRepository
        self.locationManager = locationManager
        self.notificationsManager = notificationsManager
        self.currencyHelper = currencyHelper
        self.tracker = tracker
        self.searchType = searchType
        self.filters = filters
        self.queryString = searchType?.query
        self.keyValueStorage = keyValueStorage
        self.featureFlags = featureFlags
        self.bubbleTextGenerator = bubbleTextGenerator
        self.chatWrapper = chatWrapper
        self.adsImpressionConfigurable = adsImpressionConfigurable
        self.interestedHandler = interestedHandler
        self.feedBadgingSynchronizer = feedBadgingSynchronizer
        self.appsFlyerAffiliationResolver = appsFlyerAffiliationResolver
        let show3Columns = DeviceFamily.current.isWiderOrEqualThan(.iPhone6Plus)
        let columns = show3Columns ? 3 : 2
        let itemsPerPage = show3Columns ? SharedConstants.numListingsPerPageBig : SharedConstants.numListingsPerPageDefault
        self.requesterDependencyContainer = RequesterDependencyContainer(itemsPerPage: itemsPerPage,
                                                                         filters: filters,
                                                                         queryString: searchType?.query,
                                                                         similarSearchActive: featureFlags.emptySearchImprovements.isActive)
        let requesterFactory = SearchRequesterFactory(dependencyContainer: self.requesterDependencyContainer,
                                                      featureFlags: featureFlags)
        self.requesterFactory = requesterFactory
        self.listViewModel = ListingListViewModel(numberOfColumns: columns,
                                                  tracker: tracker,
                                                  featureFlags: featureFlags,
                                                  requesterFactory: requesterFactory,
                                                  searchType: searchType,
                                                  source: .feed,
                                                  interestedStateUpdater: interestedHandler.interestedStateUpdater)
        let multiRequester = self.listViewModel.currentActiveRequester as? ListingListMultiRequester
        self.listingListRequester = multiRequester ?? ListingListMultiRequester()
        self.listViewModel.listingListFixedInset = show3Columns ? 6 : 10
        
        if let search = searchType, let query = search.query, !search.isCollection && !query.isEmpty {
            self.shouldTrackSearch = true
        }
        
        super.init()
        
        self.listViewModel.listingCellDelegate = self
        setup()
    }
    
    convenience init(searchType: SearchType? = nil,
                     filters: ListingFilters,
                     shouldCloseOnRemoveAllFilters: Bool) {
        let sessionManager = Core.sessionManager
        let myUserRepository = Core.myUserRepository
        let searchRepository = Core.searchRepository
        let listingRepository = Core.listingRepository
        let monetizationRepository = Core.monetizationRepository
        let categoryRepository = Core.categoryRepository
        let searchAlertsRepository = Core.searchAlertsRepository
        let userRepository = Core.userRepository
        let locationManager = Core.locationManager
        let notificationsManager = LGNotificationsManager.sharedInstance
        let currencyHelper = Core.currencyHelper
        let tracker = TrackerProxy.sharedInstance
        let keyValueStorage = KeyValueStorage.sharedInstance
        let featureFlags = FeatureFlags.sharedInstance
        let bubbleTextGenerator = DistanceBubbleTextGenerator()
        let chatWrapper = LGChatWrapper()
        let adsImpressionConfigurable = LGAdsImpressionConfigurable()
        let interestedHandler = InterestedHandler()
        let feedBadgingSynchronizer = LGFeedBadgingSynchronizer()
        let appsFlyerAffiliationResolver = AppsFlyerAffiliationResolver.shared
        self.init(sessionManager: sessionManager,
                  myUserRepository: myUserRepository,
                  searchRepository: searchRepository,
                  listingRepository: listingRepository,
                  monetizationRepository: monetizationRepository,
                  categoryRepository: categoryRepository,
                  searchAlertsRepository: searchAlertsRepository,
                  userRepository: userRepository,
                  locationManager: locationManager,
                  notificationsManager: notificationsManager,
                  currencyHelper: currencyHelper,
                  tracker: tracker,
                  searchType: searchType,
                  filters: filters,
                  keyValueStorage: keyValueStorage,
                  featureFlags: featureFlags,
                  bubbleTextGenerator: bubbleTextGenerator,
                  chatWrapper: chatWrapper,
                  adsImpressionConfigurable: adsImpressionConfigurable,
                  interestedHandler: interestedHandler,
                  feedBadgingSynchronizer: feedBadgingSynchronizer,
                  appsFlyerAffiliationResolver: appsFlyerAffiliationResolver)
        self.shouldCloseOnRemoveAllFilters = shouldCloseOnRemoveAllFilters
    }
    
    convenience init(searchType: SearchType? = nil, filters: ListingFilters) {
        self.init(searchType: searchType,
                  filters: filters,
                  shouldCloseOnRemoveAllFilters: false)
    }
    
    convenience init(searchType: SearchType? = nil, tabNavigator: TabNavigator?) {
        let filters = ListingFilters()
        self.init(searchType: searchType, filters: filters)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        updatePermissionsWarning()
        updateCategoriesHeader()
        if firstTime {
            setupRx()
        }
        if let currentLocation = locationManager.currentLocation {
            retrieveProductsIfNeededWithNewLocation(currentLocation)
            retrieveLastUserSearch()
            retrieveTrendingSearches()
        }
        
        if shouldShowSearchAlertBanner && firstTime {
            createSearchAlert(fromEnable: false)
        }
        
        if showCategoriesCollectionBanner {
            filterTitle.value = nil
            filterDescription.value = nil
        }
    }
    
    
    // MARK: - Public methods
    
    /**
     Search action.
     */
    func search(_ query: String) {
        guard !query.isEmpty else { return }
        
        delegate?.vmDidSearch()
        guard let searchNavigator = searchNavigator else {
            navigator?.openMainListings(withSearchType: .user(query: query),
                                        listingFilters: filters)
            return
        }
        wireframe?.openSearchResults(
            with: .user(query: query),
            filters: filters,
            searchNavigator: searchNavigator
        )
    }
    
    func showFilters() {
        wireframe?.openFilters(withFilters: filters, dataDelegate: self)
        tracker.trackEvent(TrackerEvent.filterStart())
    }
    
    func openAffiliationChallenges() {
        wireframe?.openLoginIfNeededFromFeed(from: .feed, loggedInAction: { [weak self] in
            self?.wireframe?.openAffiliationChallenges()
        })
    }
    
    func showMap() {
        wireframe?.openMap(requester: listingListRequester,
                        listingFilters: filters)
    }
    
    /**
     Called when search button is pressed.
     */
    func searchBegan() {
        tracker.trackEvent(TrackerEvent.searchStart(myUserRepository.myUser))
    }
    
    /**
     Called when a filter gets removed
     */
    func updateFiltersFromTags(_ tags: [FilterTag],
                               removedTag: FilterTag?) {
        guard !shouldCloseOnRemoveAllFilters || tags.count > 0 else {
            wireframe?.close()
            var newFilter = ListingFilters()
            newFilter.place = filters.place
            tagsDelegate?.onCloseAllFilters(finalFiters: newFilter)
            return
        }
        var categories: [FilterCategoryItem] = []
        var orderBy = ListingSortCriteria.defaultOption
        var within = ListingTimeFilter.defaultOption
        var minPrice: Int? = nil
        var maxPrice: Int? = nil
        var free: Bool = false
        var carSellerTypes: [UserType] = []
        var makeId: String? = nil
        var makeName: String? = nil
        var modelId: String? = nil
        var modelName: String? = nil
        var carYearStart: Int? = nil
        var carYearEnd: Int? = nil
        var carBodyTypes: [CarBodyType] = []
        var carFuelTypes: [CarFuelType] = []
        var carMileageStart: Int? = nil
        var carMileageEnd: Int? = nil
        var carNumberOfSeatsStart: Int? = nil
        var carNumberOfSeatsEnd: Int? = nil
        var carTransmissionTypes: [CarTransmissionType] = []
        var carDrivetrainTypes: [CarDriveTrainType] = []
        var realEstatePropertyType: RealEstatePropertyType? = nil
        var realEstateOfferTypes: [RealEstateOfferType] = []
        var realEstateNumberOfBedrooms: NumberOfBedrooms? = nil
        var realEstateNumberOfBathrooms: NumberOfBathrooms? = nil
        var realEstateNumberOfRooms: NumberOfRooms? = nil
        var realEstateSizeSquareMetersMin: Int? = nil
        var realEstateSizeSquareMetersMax: Int? = nil
        
        var servicesServiceType: ServiceType? = nil
        var servicesServiceSubtype: [ServiceSubtype] = []
        var servicesListingTypes: [ServiceListingType] = []
        
        for filterTag in tags {
            switch filterTag {
            case .location:
                break
            case .category(let prodCategory):
                categories.append(FilterCategoryItem(category: prodCategory))
            case .orderBy(let prodSortOption):
                orderBy = prodSortOption
            case .within(let prodTimeOption):
                within = prodTimeOption
            case .priceRange(let minPriceOption, let maxPriceOption, _):
                minPrice = minPriceOption
                maxPrice = maxPriceOption
            case .freeStuff:
                free = true
            case .distance:
                break
            case .carSellerType(let type, _):
                carSellerTypes.append(type)
            case .make(let id, let name):
                makeId = id
                makeName = name
            case .model(let id, let name):
                modelId = id
                modelName = name
            case .yearsRange(let startYear, let endYear):
                carYearStart = startYear
                carYearEnd = endYear
            case .realEstatePropertyType(let propertyType):
                realEstatePropertyType = propertyType
            case .realEstateOfferType(let offerType):
                realEstateOfferTypes.append(offerType)
            case .realEstateNumberOfBedrooms(let numberOfBedrooms):
                realEstateNumberOfBedrooms = numberOfBedrooms
            case .realEstateNumberOfBathrooms(let numberOfBathrooms):
                realEstateNumberOfBathrooms = numberOfBathrooms
            case .realEstateNumberOfRooms(let numberOfRooms):
                realEstateNumberOfRooms = numberOfRooms
            case .sizeSquareMetersRange(let minSize, let maxSize):
                realEstateSizeSquareMetersMin = minSize
                realEstateSizeSquareMetersMax = maxSize
            case .serviceType(let type):
                servicesServiceType = type
            case .serviceSubtype(let subtype):
                servicesServiceSubtype.append(subtype)
            case .unifiedServiceType(let type, let selectedSubtypes):
                servicesServiceType = type
                servicesServiceSubtype = selectedSubtypes
            case .serviceListingType(let listingType):
                servicesListingTypes.append(listingType)
            case .carBodyType(let bodyType):
                carBodyTypes.append(bodyType)
            case .carFuelType(let fuelType):
                carFuelTypes.append(fuelType)
            case .carTransmissionType(let transmissionType):
                carTransmissionTypes.append(transmissionType)
            case .carDriveTrainType(let driveTrainType):
                carDrivetrainTypes.append(driveTrainType)
            case .mileageRange(let start, let end):
                carMileageStart = start
                carMileageEnd = end
            case .numberOfSeats(let start, let end):
                carNumberOfSeatsStart = start
                carNumberOfSeatsEnd = end
            }
        }

        filters.selectedCategories = categories.compactMap { filterCategoryItem in
            switch filterCategoryItem {
            case .free:
                return nil
            case .category(let cat):
                return cat
            }
        }
        
        filters.selectedOrdering = orderBy
        filters.selectedWithin = within
        if free {
            filters.priceRange = .freePrice
        } else {
            filters.priceRange = .priceRange(min: minPrice, max: maxPrice)
        }

        filters.verticalFilters.cars.sellerTypes = carSellerTypes
        
        filters.verticalFilters.cars.makeId = makeId
        filters.verticalFilters.cars.makeName = makeName
        
        filters.verticalFilters.cars.modelId = modelId
        filters.verticalFilters.cars.modelName = modelName
        
        filters.verticalFilters.cars.yearStart = carYearStart
        filters.verticalFilters.cars.yearEnd = carYearEnd
        
        filters.verticalFilters.cars.numberOfSeatsStart = carNumberOfSeatsStart
        filters.verticalFilters.cars.numberOfSeatsEnd = carNumberOfSeatsEnd
        filters.verticalFilters.cars.mileageStart = carMileageStart
        filters.verticalFilters.cars.mileageEnd = carMileageEnd
        
        filters.verticalFilters.cars.bodyTypes = carBodyTypes
        filters.verticalFilters.cars.fuelTypes = carFuelTypes
        filters.verticalFilters.cars.transmissionTypes = carTransmissionTypes
        filters.verticalFilters.cars.driveTrainTypes = carDrivetrainTypes
        
        filters.verticalFilters.realEstate.propertyType = realEstatePropertyType
        filters.verticalFilters.realEstate.offerTypes = realEstateOfferTypes
        filters.verticalFilters.realEstate.numberOfBedrooms = realEstateNumberOfBedrooms
        filters.verticalFilters.realEstate.numberOfBathrooms = realEstateNumberOfBathrooms
        
        filters.verticalFilters.realEstate.numberOfRooms = realEstateNumberOfRooms
        filters.verticalFilters.realEstate.sizeRange = SizeRange(min: realEstateSizeSquareMetersMin, max: realEstateSizeSquareMetersMax)
        
        filters.verticalFilters.services.type = servicesServiceType
        
        if servicesServiceSubtype.count > 0 {
            filters.verticalFilters.services.subtypes = servicesServiceSubtype
        } else {
            filters.verticalFilters.services.subtypes = nil
        }
        
        filters.verticalFilters.services.listingTypes = servicesListingTypes

        updateCategoriesHeader()
        updateListView()
    }
    
    func applyFilters(_ categoryHeaderInfo: CategoryHeaderInfo) {
        tracker.trackEvent(TrackerEvent.filterCategoryHeaderSelected(position: categoryHeaderInfo.position,
                                                                     name: categoryHeaderInfo.name))
        delegate?.vmShowTags(tags: tags)
        updateCategoriesHeader()
        updateListView()
    }
    
    func updateFiltersFromHeaderCategories(_ categoryHeaderInfo: CategoryHeaderInfo) {
        switch categoryHeaderInfo.filterCategoryItem {
        case .category(let category):
            filters.selectedCategories = [category]
        case .free:
            filters.priceRange = .freePrice
        }
        applyFilters(categoryHeaderInfo)
    }
    
    func bubbleTapped() {
        let initialPlace = filters.place ?? Place(postalAddress: locationManager.currentLocation?.postalAddress,
                                                  location: locationManager.currentLocation?.location)
        wireframe?.openLocationSelection(with: initialPlace,
                                      distanceRadius: filters.distanceRadius,
                                      locationDelegate: self)
    }
    
    func recentItemsBubbleTapped() {
        listViewModel.showRecentListings()
        feedBadgingSynchronizer.hideBadge()
    }
    
    
    // MARK: - Private methods
    
    private func setup() {
        setupProductList()
        setupSessionAndLocation()
        setupPermissionsNotification()
        infoBubbleText.value = defaultBubbleText
    }
    
    private func setupRx() {
        featureFlags.rx_affiliationEnabled
            .asDriver(onErrorJustReturn: .control)
            .filter { $0 == .active }
            .distinctUntilChanged()
            .map { [weak self] enabled in
                self?.rightBarButtonsItems ?? []
            }.drive(rightBBItemsRelay)
            .disposed(by: disposeBag)

        listViewModel.isListingListEmpty.asObservable().bind { [weak self] _ in
            self?.updateCategoriesHeader()
        }.disposed(by: disposeBag)
        
        appsFlyerAffiliationResolver.rx.affiliationCampaign
            .bind { [weak self] status in
            switch status {
            case .campaignNotAvailableForUser:
                self?.navigator?.openWrongCountryModal()
            case.referral( let referrer):
                guard !(self?.keyValueStorage[.didShowAffiliationOnBoarding] ?? true) else { return }
                delay(2, completion: { [weak self] in
                    self?.navigator?.openAffiliationOnboarding(data: referrer)
                })
            case .unknown:
                return
            }
        }.disposed(by: disposeBag)
        Observable.combineLatest(notificationsManager.engagementBadgingNotifications.asObservable(),
                                 containsListings.asObservable(),
                                 isShowingCategoriesHeader.asObservable()) { $0 && $1 && $2 }
            .bind(to: recentItemsBubbleVisible)
            .disposed(by: disposeBag)

        myUserRepository
            .rx_myUser
            .distinctUntilChanged { $0?.objectId == $1?.objectId }
            .subscribe(onNext: { [weak self] myUser in
                self?.loadAvatar(for: myUser)
            })
            .disposed(by: disposeBag)
    }

    private func loadAvatar(for user: User?) {
        guard featureFlags.advancedReputationSystem11.isActive else { return }

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
    

    /**
     Returns a view model for search.
     
     - returns: A view model for search.
     */
    private func viewModelForSearch(_ searchType: SearchType) -> MainListingsViewModel {
        return MainListingsViewModel(searchType: searchType, filters: filters)
    }


    
    fileprivate func updateListView() {
        if filters.selectedOrdering == ListingSortCriteria.defaultOption {
            infoBubbleText.value = defaultBubbleText
        }
        
        let currentItemsPerPage = listingListRequester.itemsPerPage
        requesterDependencyContainer.updateContainer(itemsPerPage: currentItemsPerPage,
                                                     filters: filters,
                                                     queryString: queryString,
                                                     similarSearchActive: featureFlags.emptySearchImprovements.isActive)
        let requesterFactory = SearchRequesterFactory(dependencyContainer: requesterDependencyContainer,
                                                      featureFlags: featureFlags)
        listViewModel.updateFactory(requesterFactory)
        listingListRequester = (listViewModel.currentActiveRequester as? ListingListMultiRequester) ?? ListingListMultiRequester()
        infoBubbleVisible.value = false
        recentItemsBubbleVisible.value = false
        errorMessage.value = nil
        listViewModel.cellStyle = cellStyle
        listViewModel.resetUI()

        listViewModel.refresh(shouldSaveToCache: !hasFilters)
    }
    
    
    // MARK: - Search alerts
    
    private func createSearchAlert(fromEnable: Bool) {
        guard let searchType = searchType, let query = searchType.text else { return }
        searchAlertsRepository.create(query: query) { [weak self] result in
            guard let strongSelf = self else { return }
            if let value = result.value {
                strongSelf.currentSearchAlertCreationData.value = value
                strongSelf.updateSearchAlertsHeader()
            } else if let error = result.error {
                switch error {
                case .searchAlertError(let searchAlertError):
                    switch searchAlertError {
                    case .alreadyExists:
                        strongSelf.retrieveSearchAlert(withQuery: query) { listResult in
                            if let value = listResult.value {
                                strongSelf.currentSearchAlertCreationData.value = value
                                strongSelf.updateSearchAlertsHeader()
                            }
                        }
                    case .limitReached:
                        if strongSelf.shouldDisableOldestSearchAlertIfMaximumReached {
                            strongSelf.disableOldestSearchAlert {
                                strongSelf.createSearchAlert(fromEnable: fromEnable)
                            }
                        } else {
                            if fromEnable {
                                strongSelf.showSearchAlertsLimitReachedAlert()
                            }
                            strongSelf.currentSearchAlertCreationData.value = SearchAlertCreationData(objectId: nil,
                                                                                                      query: query,
                                                                                                      isCreated: false,
                                                                                                      isEnabled: false)
                            strongSelf.updateSearchAlertsHeader()
                        }
                    case .apiError:
                        break
                    }
                case .tooManyRequests, .network, .forbidden, .internalError, .notFound, .unauthorized, .userNotVerified,
                     .serverError, .wsChatError:
                    break
                }
            }
        }
    }
    
    func triggerCurrentSearchAlert(fromEnabled: Bool) {
        if currentSearchAlertCreationData.value?.isCreated ?? false {
            if fromEnabled {
                enableCurrentSearchAlert(comesAfterDisablingOldestOne: false)
            } else {
                disableCurrentSearchAlert()
            }
        } else {
            createSearchAlert(fromEnable: true)
        }
        
        let trackerEvent = TrackerEvent.searchAlertSwitchChanged(userId: myUserRepository.myUser?.objectId,
                                                                 searchKeyword: currentSearchAlertCreationData.value?.query,
                                                                 enabled: EventParameterBoolean(bool: fromEnabled),
                                                                 source: .search)
        tracker.trackEvent(trackerEvent)
    }
    
    private func enableCurrentSearchAlert(comesAfterDisablingOldestOne: Bool) {
        guard let searchAlertId = currentSearchAlertCreationData.value?.objectId else { return }
        searchAlertsRepository.enable(searchAlertId: searchAlertId) { [weak self] result in
            guard let strongSelf = self else { return }
            if result.value != nil {
                strongSelf.currentSearchAlertCreationData.value?.isEnabled = true
                strongSelf.updateSearchAlertsHeader()
                if comesAfterDisablingOldestOne {
                    strongSelf.delegate?.vmShowAutoFadingMessage(R.Strings.searchAlertsDisabledOldestMessage, completion: nil)
                }
            }
            if let error = result.error {
                switch error {
                case .searchAlertError(let searchAlertError):
                    switch searchAlertError {
                    case .alreadyExists, .apiError:
                        strongSelf.keepCurrentSearchAlertDisabled()
                        strongSelf.delegate?.vmShowAutoFadingMessage(R.Strings.searchAlertEnableErrorMessage, completion: nil)
                    case .limitReached:
                        if strongSelf.shouldDisableOldestSearchAlertIfMaximumReached {
                            strongSelf.enableCurrentSearchAlertDisablingOldestOne()
                        } else {
                            strongSelf.keepCurrentSearchAlertDisabled()
                            strongSelf.showSearchAlertsLimitReachedAlert()
                        }
                    }
                case .tooManyRequests, .network, .forbidden, .internalError, .notFound, .unauthorized, .userNotVerified,
                     .serverError, .wsChatError:
                    strongSelf.keepCurrentSearchAlertDisabled()
                    strongSelf.delegate?.vmShowAutoFadingMessage(R.Strings.searchAlertEnableErrorMessage, completion: nil)
                }
            }
        }
    }
    
    private func enableCurrentSearchAlertDisablingOldestOne() {
        disableOldestSearchAlert { [weak self] in
            self?.enableCurrentSearchAlert(comesAfterDisablingOldestOne: true)
        }
    }
    
    private func keepCurrentSearchAlertDisabled() {
        currentSearchAlertCreationData.value?.isEnabled = false
        updateSearchAlertsHeader()
    }
    
    private func disableCurrentSearchAlert() {
        guard let searchAlertId = currentSearchAlertCreationData.value?.objectId else { return }
        searchAlertsRepository.disable(searchAlertId: searchAlertId) { [weak self] result in
            self?.currentSearchAlertCreationData.value?.isEnabled = result.value == nil
            self?.updateSearchAlertsHeader()
            if let _ = result.error {
                self?.delegate?.vmShowAutoFadingMessage(R.Strings.searchAlertDisableErrorMessage, completion: nil)
            }
        }
    }
    
    private func disableOldestSearchAlert(completion: @escaping (() -> Void)) {
        retrieveSearchAlerts { [weak self] in
            guard let strongSelf = self else { return }
            guard let firstSearchAlert = strongSelf.searchAlerts.first else { return }
            let oldestEnabledSearchAlert = strongSelf.searchAlerts.filter({ $0.enabled })
                .reduce(firstSearchAlert, { $0.createdAt < $1.createdAt ? $0 : $1 })
            if let searchAlertId = oldestEnabledSearchAlert.objectId {
                self?.disableSearchAlert(withId: searchAlertId, completion: {
                    completion()
                })
            }
        }
    }
    
    private func disableSearchAlert(withId searchAlertId: String, completion: @escaping (() -> Void)) {
        searchAlertsRepository.disable(searchAlertId: searchAlertId) { [weak self] result in
            guard result.error != nil else { return completion() }
            self?.delegate?.vmShowAutoFadingMessage(R.Strings.searchAlertDisableErrorMessage, completion: nil)
        }
    }

    private func showSearchAlertsLimitReachedAlert() {
        let alertAction = UIAction(interface: .styledText(R.Strings.searchAlertErrorTooManyButtonText, .destructive), action: { [weak self] in
            self?.navigator?.openSearchAlertsList()
        })
        
        let cancelAction = UIAction(interface: .styledText(R.Strings.commonCancel, .destructive), action: {})
        
        delegate?.vmShowAlert(nil,
                              message: R.Strings.searchAlertErrorTooManyText,
                              actions: [alertAction, cancelAction])
    }
    
    private func retrieveSearchAlerts(completion: @escaping () -> Void) {
        searchAlertsRepository.index(limit: MainListingsViewModel.searchAlertLimit, offset: 0) { [weak self] result in
            if let value = result.value {
                self?.searchAlerts = value
                completion()
            } else if let _ = result.error {
                self?.delegate?.vmShowAutoFadingMessage(R.Strings.searchAlertsPlaceholderErrorText, completion: nil)
            }
        }
    }

    private func retrieveSearchAlert(withQuery query: String, completion: SearchAlertsCreateCompletion?) {
        searchAlertsRepository.index(limit: MainListingsViewModel.searchAlertLimit, offset: 0) { result in
            if let searchAlerts = result.value,
                let searchAlert = searchAlerts.filter({$0.query == query}).first {
                let currentSearchAlertCreationData = SearchAlertCreationData(objectId: searchAlert.objectId,
                                                                      query: searchAlert.query,
                                                                      isCreated: true,
                                                                      isEnabled: searchAlert.enabled)
                completion?(SearchAlertsCreateResult(value: currentSearchAlertCreationData))
            }
        }
    }
}


// MARK: - FiltersViewModelDataDelegate

extension MainListingsViewModel: FiltersViewModelDataDelegate {
    
    func viewModelDidUpdateFilters(_ viewModel: FiltersViewModel, filters: ListingFilters) {
        guard !shouldCloseOnRemoveAllFilters || !filters.isDefault() else {
            wireframe?.close()
            self.filters = filters
            return
        }
        self.filters = filters
        delegate?.vmShowTags(tags: tags)
        updateListView()
    }
}


// MARK: - ListingListView

extension MainListingsViewModel: ListingListViewModelDataDelegate, ListingListViewCellsDelegate {
    
    func setupProductList() {
        listViewModel.dataDelegate = self
        listViewModel.cellStyle = cellStyle
        listingRepository.events.bind { [weak self] event in
            switch event {
            case let .update(listing):
                self?.listViewModel.update(listing: listing)
            case let .create(listing):
                self?.listViewModel.prepend(listing: listing)
            case let .delete(listingId):
                self?.listViewModel.delete(listingId: listingId)
            case .favorite, .unFavorite, .sold, .unSold, .createListings:
                break
            }
            }.disposed(by: disposeBag)
        
        monetizationRepository.events.bind { [weak self] event in
            switch event {
            case .freeBump, .pricedBump:
                let hasFilters = self?.hasFilters ?? false
                self?.listViewModel.refresh(shouldSaveToCache: !hasFilters)
            }
            }.disposed(by: disposeBag)
    }
    
    
    // MARK: > ListingListViewCellsDelegate
    
    func visibleTopCellWithIndex(_ index: Int, whileScrollingDown scrollingDown: Bool) {
        
        // set title for cell at index if necessary
        if !featureFlags.emptySearchImprovements.isActive {
            filterTitle.value = listViewModel.titleForIndex(index: index)
        }
        
        guard let sortCriteria = filters.selectedOrdering else { return }
        
        switch (sortCriteria) {
        case .distance:
            guard let topListing = listViewModel.listingAtIndex(index) else { return }
            guard let requesterDistance = listingListRequester.distanceFromListingCoordinates(topListing.location) else { return }
            let distance = Float(requesterDistance)
            
            // instance var max distance or MIN distance to avoid updating the label everytime
            if (scrollingDown && distance > bubbleDistance) || (!scrollingDown && distance < bubbleDistance) ||
                listViewModel.refreshing {
                bubbleDistance = distance
            }
            infoBubbleText.value = bubbleTextGenerator.bubbleInfoText(forDistance: max(1,Int(round(bubbleDistance))),
                                                                      type: DistanceType.systemDistanceType(),
                                                                      distanceRadius: filters.distanceRadius,
                                                                      place: filters.place)
        case .creation:
            infoBubbleText.value = defaultBubbleText
        case .priceAsc, .priceDesc:
            break
        }
    }
    
    // MARK: > ListingListViewModelDataDelegate

    func listingListVMDidSucceedRetrievingCache(viewModel: ListingListViewModel) {
        isCurrentFeedACachedFeed = true
    }

    func listingListVM(_ viewModel: ListingListViewModel,
                       didSucceedRetrievingListingsPage page: UInt,
                       withResultsCount resultsCount: Int,
                       hasListings: Bool,
                       containsRecentListings: Bool) {
        isCurrentFeedACachedFeed = false

        // Only save the string when there is products and we are not searching a collection
        if let search = searchType, hasListings {
            updateLastSearchStored(lastSearch: search)
        }
        
        if shouldRetryLoad {
            shouldRetryLoad = false
            listViewModel.retrieveListings()
            return
        }
        
        let requester = listViewModel.currentActiveRequester as? ListingListMultiRequester
        activeRequesterType = viewModel.currentRequesterType
        
        if let isFirstPage = requester?.multiIsFirstPage, isFirstPage {
            filterDescription.value = !hasListings && shouldShowNoExactMatchesDisclaimer ? R.Strings.filterResultsCarsNoMatches : nil
        }
        
        if !hasListings {
            if let isLastPage = requester?.multiIsLastPage, isLastPage {
                let hasPerformedSearch = queryString != nil || hasFilters
                let emptyViewModel = EmptyViewModelBuilder(hasPerformedSearch: hasPerformedSearch,
                                                           isRealEstateSearch: filters.isRealEstateSearch).build()
                listViewModel.setEmptyState(emptyViewModel)
                filterDescription.value = nil
                filterTitle.value = nil
                
                trackRequestSuccess(page: page,
                                    resultsCount: resultsCount,
                                    hasListings: hasListings,
                                    searchRelatedItems: featureFlags.emptySearchImprovements.isActive,
                                    recentItems: containsRecentListings)

            } else {
                listViewModel.retrieveListingsNextPage()
            }
            
        } else if let requesterType = activeRequesterType,
            featureFlags.emptySearchImprovements.isActive {
            
            let isFirstRequesterInAlwaysSimilarCase = featureFlags.emptySearchImprovements == .alwaysSimilar && requesterType == .nonFilteredFeed
            let isFirstRequesterInOtherCases = featureFlags.emptySearchImprovements != .alwaysSimilar && requesterType != .search
            if isFirstRequesterInAlwaysSimilarCase || isFirstRequesterInOtherCases {
                trackRequestSuccess(page: page,
                                    resultsCount: resultsCount,
                                    hasListings: hasListings,
                                    searchRelatedItems: true,
                                    recentItems: containsRecentListings)
                shouldHideCategoryAfterSearch = true
                filterDescription.value = featureFlags.emptySearchImprovements.filterDescription
                filterTitle.value = filterTitleString(forRequesterType: requesterType)
                updateCategoriesHeader()
            } else {
                trackRequestSuccess(page: page,
                                    resultsCount: resultsCount,
                                    hasListings: hasListings,
                                    searchRelatedItems: false,
                                    recentItems: containsRecentListings)
            }
        } else {
            trackRequestSuccess(page: page,
                                resultsCount: resultsCount,
                                hasListings: hasListings,
                                searchRelatedItems: false,
                                recentItems: containsRecentListings)
        }
        
        errorMessage.value = nil
        
        containsListings.value = hasListings
        isShowingCategoriesHeader.value = showCategoriesCollectionBanner
        infoBubbleVisible.value = hasListings && filters.infoBubblePresent
        
        if(page == 0) {
            bubbleDistance = 1
        }
        
        let isDefaultFeed = !hasFilters && searchType == nil
        let shouldShowRecentItems = (requester?.multiIsFirstPage == true) &&
            isDefaultFeed &&
            hasListings &&
            !containsRecentListings &&
        isEngagementBadgingEnabled
        if shouldShowRecentItems {
            // If recent listings have not been retrieved, retrieve them and show badge if necessary
            if listViewModel.recentListings.count == 0 {
                feedBadgingSynchronizer.retrieveRecentListings { [weak self] recentListings in
                    guard recentListings.count > 0 else { return }
                    self?.listViewModel.addRecentListings(recentListings)
                    self?.trackShowNewItemsBadge()
                }
            } else if listViewModel.hasPreviouslyShownRecentListings {
                // If already retrieved before, we should show them directly
                listViewModel.showRecentListings()
            }
        }
    }
    
    func listingListMV(_ viewModel: ListingListViewModel,
                       didFailRetrievingListingsPage page: UInt,
                       hasListings hasProducts: Bool,
                       error: RepositoryError) {
        if page == 0 && isCurrentFeedACachedFeed {
            isFreshBubbleVisible.value = false
            navigator?.showFailBubble(withMessage: R.Strings.cachedFeedError, duration: 3)
        }

        if shouldRetryLoad {
            shouldRetryLoad = false
            listViewModel.retrieveListings()
            return
        }


        if page == 0 && !hasProducts {
            let hasFilters = !self.hasFilters
            if let emptyViewModel = LGEmptyViewModel.map(from: error,
                                                         action: { [weak viewModel] in
                                                            viewModel?.refresh(shouldSaveToCache: !hasFilters) }) {
                listViewModel.setErrorState(emptyViewModel)
            }
        }
        
        var errorString: String? = nil
        if hasProducts && page > 0 {
            switch error {
            case .network:
                errorString = R.Strings.toastNoNetwork
            case .internalError, .notFound, .forbidden, .tooManyRequests, .userNotVerified, .serverError, .wsChatError, .searchAlertError:
                errorString = R.Strings.toastErrorInternal
            case .unauthorized:
                errorString = nil
            }
        }
        errorMessage.value = errorString
        
        containsListings.value = hasProducts
        isShowingCategoriesHeader.value = showCategoriesCollectionBanner
        infoBubbleVisible.value = hasProducts && filters.infoBubblePresent
    }
    
    func listingListVM(_ viewModel: ListingListViewModel, didSelectItemAtIndex index: Int,
                       thumbnailImage: UIImage?, originFrame: CGRect?) {
        
        guard let listing = viewModel.listingAtIndex(index) else { return }
        let cellModels = viewModel.objects
        let showRelated = searchType == nil && !hasFilters
        let data = ListingDetailData.listingList(listing: listing, cellModels: cellModels,
                                                 requester: listingListRequester, thumbnailImage: thumbnailImage,
                                                 originFrame: originFrame, showRelated: showRelated, index: index)
        if let searchNavigator = searchNavigator {
            searchNavigator.openListing(data, source: listingVisitSource, actionOnFirstAppear: .nonexistent)
        } else {
            navigator?.openListing(data, source: listingVisitSource, actionOnFirstAppear: .nonexistent)
        }
    }
    
    func vmProcessReceivedListingPage(_ listings: [ListingCellModel], page: UInt) -> [ListingCellModel] {
        var totalListings = listings
        totalListings = addCollections(to: totalListings, page: page)
        totalListings = addRealEstatePromoItem(to: totalListings)
        totalListings = addCarPromoItem(to: totalListings)
        totalListings = addServicesPromoItem(to: totalListings)
        
        let myUserCreationDate: Date? = myUserRepository.myUser?.creationDate
        if featureFlags.showAdsInFeedWithRatio.isActive ||
            adsImpressionConfigurable.shouldShowAdsForUser {
            totalListings = addAds(to: totalListings, page: page)
        }
        return totalListings
    }
    
    func vmDidSelectCollection(_ type: CollectionCellType){
        tracker.trackEvent(TrackerEvent.exploreCollection(type.rawValue))
        let query = queryForCollection(type)
        delegate?.vmDidSearch()
        navigator?.openMainListings(withSearchType: .collection(type: type, query: query), listingFilters: filters)
    }

    func vmUserDidTapInvite() {
        navigator?.openAppInvite(myUserId: myUserId, myUserName: myUserName)
    }

    func vmUserDidTapCommunity() {
        navigator?.openCommunity()
    }

    func vmUserDidTapUserProfile() {
        navigator?.openPrivateUserProfile()
    }
    
    func vmDidSelectSellBanner(_ type: String) {}
    
    private func addCollections(to listings: [ListingCellModel], page: UInt) -> [ListingCellModel] {
        guard searchType == nil else { return listings }
        guard listings.count > bannerCellPosition else { return listings }
        var cellModels = listings
        if !collections.isEmpty && featureFlags.collectionsAllowedFor(countryCode: listingListRequester.countryCode) {
            let collectionType = collections[Int(page) % collections.count]
            let collectionModel = ListingCellModel.collectionCell(type: collectionType)
            cellModels.insert(collectionModel, at: bannerCellPosition)
        }
        return cellModels
    }
    
    private func setupAdsCellModelForGoogleAdx(adsDelegate: MainListingsAdsDelegate) -> ListingCellModel? {
        guard var feedAdUnitId = featureFlags.feedAdUnitId else { return nil }
        var adTypes: [GADAdLoaderAdType] = [.nativeContent]
        if featureFlags.appInstallAdsInFeed.isActive {
            guard let appInstallAdUnit = featureFlags.appInstallAdsInFeedAdUnit else { return nil }
            feedAdUnitId = appInstallAdUnit
            adTypes.append(.nativeAppInstall)
        }
        let adLoader = GADAdLoader(adUnitID: feedAdUnitId,
                                   rootViewController: adsDelegate.rootViewControllerForAds(),
                                   adTypes: adTypes,
                                   options: nil)
        let adData = AdvertisementAdxData(adUnitId: feedAdUnitId,
                                          rootViewController: adsDelegate.rootViewControllerForAds(),
                                          adPosition: lastAdPosition,
                                          bannerHeight: LGUIKitConstants.advertisementCellDefaultHeight,
                                          adRequested: false,
                                          categories: filters.selectedCategories,
                                          adLoader: adLoader,
                                          adxNativeView: NativeAdBlankStateView())
        return ListingCellModel.adxAdvertisement(data: adData)
    }
    
    private func addAds(to listings: [ListingCellModel], page: UInt) -> [ListingCellModel] {
        if page == 0 {
            lastAdPosition = MainListingsViewModel.adInFeedInitialPosition
            previousPagesAdsOffset = 0
        }
        guard let adsDelegate = adsDelegate else { return listings }
        var cellModels = listings
        var canInsertAds = true

        guard featureFlags.feedAdUnitId != nil else { return listings }
        while canInsertAds {
            
            let adPositionInPage = lastAdPosition-previousPagesAdsOffset
            guard let adRelativePosition = adPositionRelativeToPage(page: page,
                                                                    itemsInPage: cellModels.count,
                                                                    pageSize: listingListRequester.itemsPerPage,
                                                                    adPosition: adPositionInPage) else { break }

            let adsCellModel = setupAdsCellModelForGoogleAdx(adsDelegate: adsDelegate)

            guard let listingCellModel = adsCellModel else { return listings }
            cellModels.insert(listingCellModel, at: adRelativePosition)
            lastAdPosition = adAbsolutePosition()
            canInsertAds = adRelativePosition < cellModels.count
        }
        previousPagesAdsOffset += (cellModels.count - listings.count + collections.count)
        return cellModels
    }
    
    private func addRealEstatePromoItem(to listings: [ListingCellModel]) -> [ListingCellModel] {
        guard filters.isRealEstateSearch, !listings.isEmpty
            else { return listings }
        
        guard (!filters.hasAnyRealEstateAttributes && listingListRequester.multiIsFirstPage) ||
            (filters.hasAnyRealEstateAttributes && listingListRequester.isFirstPageInLastRequester) else { return listings }
        
        var cellModels = listings
        let configuration =  RealEstatePromoCellConfiguration.createRandomCellData(showNewDesign: featureFlags.realEstatePromoCells.isActive)
        cellModels.insert(ListingCellModel.promo(data: configuration, delegate: self), at: 0)
        return cellModels
    }
    
    private func addCarPromoItem(to listings: [ListingCellModel]) -> [ListingCellModel] {
        guard canShowCarPromoCells,
            !listings.isEmpty
            else { return listings }
        
        guard let carPromoCellModel = featureFlags.carPromoCells.newCarPromoCellModel(withDelegate: self),
            (!filters.hasAnyCarAttributes && listingListRequester.multiIsFirstPage) ||
            (filters.hasAnyCarAttributes && listingListRequester.isFirstPageInLastRequester) else { return listings }
        
        return [carPromoCellModel] + listings
    }

    private func addServicesPromoItem(to listings: [ListingCellModel]) -> [ListingCellModel] {
        guard canShowServicePromoCells,
            !listings.isEmpty
            else { return listings }
        
        guard let servicesPromoCellModel = featureFlags.servicesPromoCells.newServicesPromoCellModel(withDelegate: self),
            (!filters.hasAnyServicesAttributes && listingListRequester.multiIsFirstPage) ||
                (filters.hasAnyServicesAttributes && listingListRequester.isFirstPageInLastRequester) else { return listings }
        
        return [servicesPromoCellModel] + listings
    }
    
    private func adAbsolutePosition() -> Int {
        var adPosition = 0
        if lastAdPosition == 0 {
            adPosition = MainListingsViewModel.adInFeedInitialPosition
        } else {
            let ratio: Int
            if featureFlags.showAdsInFeedWithRatio.isActive {
                ratio = featureFlags.showAdsInFeedWithRatio.ratio
            } else {
                ratio = MainListingsViewModel.adsInFeedRatio
            }
            adPosition = lastAdPosition + ratio
        }
        return adPosition
    }
    
    private func adPositionRelativeToPage(page: UInt, itemsInPage: Int, pageSize: Int, adPosition: Int) -> Int? {
        let pageInt = Int(page)
        let adRelativePosition = adPosition - (pageInt*pageSize)
        if 0..<itemsInPage ~= adRelativePosition {
            return adRelativePosition
        }
        return nil
    }
    
    private func filterTitleString(forRequesterType type: RequesterType) -> String? {
        switch type {
        case .nonFilteredFeed:
            return R.Strings.productPopularNearYou
        case .similarProducts:
            return R.Strings.listingShowSimilarResults
        case .search: return nil
        }
    }
}


// MARK: - Session & Location handling

extension MainListingsViewModel {
    fileprivate func setupSessionAndLocation() {
        sessionManager.sessionEvents.bind { [weak self] _ in self?.sessionDidChange() }.disposed(by: disposeBag)
        locationManager.locationEvents.filter { $0 == .locationUpdate }.bind { [weak self] _ in
            self?.locationDidChange()
            }.disposed(by: disposeBag)
    }
    
    fileprivate func sessionDidChange() {
        guard listViewModel.canRetrieveListings else {
            shouldRetryLoad = true
            return
        }
        listViewModel.retrieveListings()
    }
    
    private func locationDidChange() {
        guard let newLocation = locationManager.currentLocation else { return }
        
        // Tracking: when a new location is received and has different type than previous one
        if lastReceivedLocation?.type != newLocation.type {
            let trackerEvent = TrackerEvent.location(locationType: newLocation.type,
                                                     locationServiceStatus: locationManager.locationServiceStatus,
                                                     typePage: .automatic,
                                                     zipCodeFilled: nil,
                                                     distanceRadius: filters.distanceRadius)
            tracker.trackEvent(trackerEvent)
        }
        
        
        // Retrieve products (should be place after tracking, as it updates lastReceivedLocation)
        retrieveProductsIfNeededWithNewLocation(newLocation)
        retrieveLastUserSearch()
        retrieveTrendingSearches()
    }
    
    fileprivate func retrieveProductsIfNeededWithNewLocation(_ newLocation: LGLocation) {
        if shouldFetchCache {
            listViewModel.fetchFromCache()
        }
        
        var shouldUpdate = false
        if listViewModel.canRetrieveListings {
            if listViewModel.numberOfListings == 0 {
                // 👆🏾 If there are no products, then refresh
                shouldUpdate = true
            } else if newLocation.type == .manual || lastReceivedLocation?.type == .manual {
                //👆🏾 If new location is manual OR last location was manual, and location has changed then refresh"
                if let lastReceivedLocation = lastReceivedLocation, newLocation != lastReceivedLocation {
                    shouldUpdate = true
                }
            } else if lastReceivedLocation?.type != .sensor && newLocation.type == .sensor {
                // 👆🏾 If new location is not manual and we improved the location type to sensors
                shouldUpdate = true
            } else if let newCountryCode = newLocation.countryCode, lastReceivedLocation?.countryCode != newCountryCode {
                // in case list loaded with older country code and new location is retrieved with new country code"
                shouldUpdate = true
            }
        } else if listViewModel.numberOfListings == 0 {
            if lastReceivedLocation?.type != .sensor && newLocation.type == .sensor {
                // in case the user allows sensors while loading the product list with the iplookup parameters"
                shouldRetryLoad = true
            } else if let newCountryCode = newLocation.countryCode, lastReceivedLocation?.countryCode != newCountryCode {
                // in case the list is loading with older country code and new location is received with new country code
                shouldRetryLoad = true
            }
        }
        
        if shouldUpdate {
            infoBubbleText.value = defaultBubbleText
            listViewModel.retrieveListings()
        }
        
        // Track the received location
        lastReceivedLocation = newLocation
    }
}


// MARK: - Suggestions searches

extension MainListingsViewModel {
    
    func selected(type: SearchSuggestionType, row: Int) {
        switch type {
        case .suggestive:
            selectedSuggestiveSearchAtIndex(row)
        case .lastSearch:
            selectedLastSearchAtIndex(row)
        case .trending:
            selectedTrendingSearchAtIndex(row)
        }
    }
    
    func trendingSearchAtIndex(_ index: Int) -> String? {
        guard  0..<trendingSearches.value.count ~= index else { return nil }
        return trendingSearches.value[index]
    }
    
    func suggestiveSearchAtIndex(_ index: Int) -> (suggestiveSearch: SuggestiveSearch, sourceText: String)? {
        guard  0..<suggestiveSearchInfo.value.count ~= index else { return nil }
        return (suggestiveSearchInfo.value.suggestiveSearches[index], suggestiveSearchInfo.value.sourceText)
    }
    
    func lastSearchAtIndex(_ index: Int) -> SuggestiveSearch? {
        guard 0..<lastSearches.value.count ~= index else { return nil }
        return lastSearches.value[index].suggestiveSearch
    }
    
    private func selectedTrendingSearchAtIndex(_ index: Int) {
        guard let trendingSearch = trendingSearchAtIndex(index), !trendingSearch.isEmpty else { return }
        delegate?.vmDidSearch()
        guard let safeNavigator = navigator else { return }
        wireframe?.openClassicFeed(navigator: safeNavigator,
                                   withSearchType: .trending(query: trendingSearch),
                                   listingFilters: filters)
    }
    
    private func selectedSuggestiveSearchAtIndex(_ index: Int) {
        guard let (suggestiveSearch, _) = suggestiveSearchAtIndex(index) else { return }
        delegate?.vmDidSearch()
        
        let newFilters: ListingFilters
        if let category = suggestiveSearch.category {
            newFilters = filters.updating(selectedCategories: [category])
        } else {
            newFilters = filters
        }
        guard let safeNavigator = navigator else { return }
        wireframe?.openClassicFeed(navigator: safeNavigator,
                                   withSearchType: .suggestive(
                                    search: suggestiveSearch,
                                    indexSelected: index),
                                   listingFilters: newFilters)
    }
    
    private func selectedLastSearchAtIndex(_ index: Int) {
        guard let lastSearch = lastSearchAtIndex(index), let name = lastSearch.name, !name.isEmpty else { return }
        delegate?.vmDidSearch()
        guard let safeNavigator = navigator else { return }
        wireframe?.openClassicFeed(navigator: safeNavigator,
                                   withSearchType: .lastSearch(search: lastSearch),
                                   listingFilters: filters)
    }
    
    func cleanUpLastSearches() {
        keyValueStorage[.lastSuggestiveSearches] = []
        lastSearches.value = keyValueStorage[.lastSuggestiveSearches]
    }
    
    func retrieveLastUserSearch() {
        // We saved up to lastSearchesSavedMaximum(10) but we show only lastSearchesShowMaximum(3)
        var searchesToShow = [LocalSuggestiveSearch]()
        let allSearchesSaved = keyValueStorage[.lastSuggestiveSearches]
        if allSearchesSaved.count > lastSearchesShowMaximum {
            searchesToShow = Array(allSearchesSaved.suffix(lastSearchesShowMaximum))
        } else {
            searchesToShow = keyValueStorage[.lastSuggestiveSearches]
        }
        lastSearches.value = searchesToShow.reversed()
    }
    
    func retrieveTrendingSearches() {
        guard let currentCountryCode = locationManager.currentLocation?.countryCode else { return }
        
        searchRepository.index(countryCode: currentCountryCode) { [weak self] result in
            self?.trendingSearches.value = result.value ?? []
        }
    }
    
    func searchTextFieldDidUpdate(text: String) {
        let charactersCount = text.count
        if charactersCount > 0 {
            retrieveSuggestiveSearches(term: text)
        } else {
            cleanUpSuggestiveSearches()
        }
    }
    
    private func retrieveSuggestiveSearches(term: String) {
        guard let languageCode = Locale.current.languageCode else { return }
        
        searchRepository.retrieveSuggestiveSearches(language: languageCode,
                                                    limit: SharedConstants.listingsSearchSuggestionsMaxResults,
                                                    term: term) { [weak self] result in
                                                        // prevent showing results when deleting the search text
                                                        guard let sourceText = self?.searchText.value else { return }
                                                        self?.suggestiveSearchInfo.value = SuggestiveSearchInfo(suggestiveSearches: result.value ?? [],
                                                                                                                sourceText: sourceText)
        }
    }
    
    private func cleanUpSuggestiveSearches() {
        suggestiveSearchInfo.value = SuggestiveSearchInfo.empty()
    }
    
    fileprivate func updateLastSearchStored(lastSearch: SearchType) {
        guard let suggestiveSearch = getSuggestiveSearchFrom(searchType: lastSearch) else { return }
        // We save up to lastSearchesSavedMaximum items
        var searchesSaved = keyValueStorage[.lastSuggestiveSearches]
        // Check if already the search exists and if so then move the search to front.
        if let index = searchesSaved.index(of: suggestiveSearch) {
            searchesSaved.remove(at: index)
        }
        searchesSaved.append(suggestiveSearch)
        if searchesSaved.count > lastSearchesSavedMaximum {
            searchesSaved.removeFirst()
        }
        keyValueStorage[.lastSuggestiveSearches] = searchesSaved
        retrieveLastUserSearch()
    }
    
    fileprivate func getSuggestiveSearchFrom(searchType: SearchType) -> LocalSuggestiveSearch? {
        let suggestiveSearch: SuggestiveSearch?
        switch searchType {
        case let .user(query):
            suggestiveSearch = SuggestiveSearch.term(name: query)
        case let .trending(query):
            suggestiveSearch = SuggestiveSearch.term(name: query)
        case let .suggestive(search, _):
            suggestiveSearch = search
        case let .lastSearch(search):
            suggestiveSearch = search
        case .collection, .feed:
            suggestiveSearch = nil
        }
        if let suggestiveSearch = suggestiveSearch {
            return LocalSuggestiveSearch(suggestiveSearch: suggestiveSearch)
        } else {
            return nil
        }
    }
}

// MARK: Push Permissions

extension MainListingsViewModel {
    
    var showCategoriesCollectionBanner: Bool {
        let isSearchAlertsBannerHidden = !shouldShowSearchAlertBanner
        let isShowingListings = !listViewModel.isListingListEmpty.value
        return tags.isEmpty && isShowingListings && isSearchAlertsBannerHidden
    }
    
    func pushPermissionsHeaderPressed() {
        openPushPermissionsAlert()
    }
    
    fileprivate func setupPermissionsNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(updatePermissionsWarning),
                                               name: NSNotification.Name(rawValue: PushManager.Notification.DidRegisterUserNotificationSettings.rawValue), object: nil)
    }
    
    @objc fileprivate dynamic func updatePermissionsWarning() {
        var currentHeader = mainListingsHeader.value
        if UIApplication.shared.areRemoteNotificationsEnabled {
            currentHeader.remove(MainListingsHeader.PushPermissions)
        } else {
            currentHeader.insert(MainListingsHeader.PushPermissions)
        }
        guard mainListingsHeader.value != currentHeader else { return }
        mainListingsHeader.value = currentHeader
    }
    
    @objc fileprivate dynamic func updateCategoriesHeader() {
        var currentHeader = mainListingsHeader.value
        if showCategoriesCollectionBanner {
            currentHeader.insert(MainListingsHeader.CategoriesCollectionBanner)
        } else {
            currentHeader.remove(MainListingsHeader.CategoriesCollectionBanner)
        }
        guard mainListingsHeader.value != currentHeader else { return }
        mainListingsHeader.value = currentHeader
    }
    
    private func updateSearchAlertsHeader() {
        var currentHeader = mainListingsHeader.value
        if !showCategoriesCollectionBanner {
            currentHeader.insert(MainListingsHeader.SearchAlerts)
        } else {
            currentHeader.remove(MainListingsHeader.SearchAlerts)
        }
        mainListingsHeader.value = currentHeader
    }
    
    private func openPushPermissionsAlert() {
        trackPushPermissionStart()
        let positive = UIAction(interface: .styledText(R.Strings.profilePermissionsAlertOk, .standard),
                                action: { [weak self] in
                                    self?.trackPushPermissionComplete()
                                    LGPushPermissionsManager.sharedInstance.showPushPermissionsAlert(prePermissionType: .listingListBanner)
            },
                                accessibility: AccessibilityId.userPushPermissionOK)
        let negative = UIAction(interface: .styledText(R.Strings.profilePermissionsAlertCancel, .cancel),
                                action: { [weak self] in
                                    self?.trackPushPermissionCancel()
            },
                                accessibility: AccessibilityId.userPushPermissionCancel)
        delegate?.vmShowAlertWithTitle(R.Strings.profilePermissionsAlertTitle,
                                       text: R.Strings.profilePermissionsAlertMessage,
                                       alertType: .iconAlert(icon: R.Asset.IconsButtons.customPermissionProfile.image),
                                       actions: [negative, positive])
    }
}


// MARK: - Filters & bubble

fileprivate extension ListingFilters {
    var infoBubblePresent: Bool {
        guard let selectedOrdering = selectedOrdering else { return true }
        switch (selectedOrdering) {
        case .distance, .creation:
            return true
        case .priceAsc, .priceDesc:
            return false
        }
    }
}


// MARK: - Queries for Collections

fileprivate extension MainListingsViewModel {
    func queryForCollection(_ type: CollectionCellType) -> String {
        var query: String
        switch type {
        case .selectedForYou:
            query = keyValueStorage[.lastSuggestiveSearches]
                .compactMap { $0.suggestiveSearch.name }
                .reversed()
                .joined(separator: " ")
                .clipMoreThan(wordCount: SharedConstants.maxSelectedForYouQueryTerms)
        }
        return query
    }
}


// MARK: - Tracking

fileprivate extension MainListingsViewModel {
    
    var listingVisitSource: EventParameterListingVisitSource {
        if let searchType = searchType {
            switch searchType {
            case .collection, .feed:
                return .collection
            case .user, .trending, .suggestive, .lastSearch:
                if !hasFilters {
                    return .search
                } else {
                    return .searchAndFilter
                }
            }
        }
        
        if hasFilters {
            if filters.selectedCategories.isEmpty {
                return .filter
            } else {
                return .category
            }
        }
        
        return .listingList
    }
    
    var feedSource: EventParameterFeedSource {
        if let search = searchType, search.isCollection {
            return .collection
        }
        if searchType == nil {
            if hasFilters {
                return .filter
            }
        } else {
            if hasFilters {
                return .searchAndFilter
            } else {
                return .search
            }
        }
        return .home
    }

    private func trackRequestSuccess(page: UInt,
                                     resultsCount: Int,
                                     hasListings: Bool,
                                     searchRelatedItems: Bool,
                                     recentItems: Bool) {
        guard page == 0 else { return }
        let successParameter: EventParameterBoolean = hasListings ? .trueParameter : .falseParameter
        let recentItemsParameter: EventParameterBoolean = recentItems ? .trueParameter : .falseParameter
        let trackerEvent = TrackerEvent.listingList(myUserRepository.myUser,
                                                    categories: filters.selectedCategories,
                                                    searchQuery: queryString,
                                                    resultsCount: resultsCount,
                                                    feedSource: feedSource,
                                                    success: successParameter,
                                                    recentItems: recentItemsParameter)

        tracker.trackEvent(trackerEvent)
        
        if let searchType = searchType, let searchQuery = searchType.query, shouldTrackSearch {
            shouldTrackSearch = false
            let successValue = searchRelatedItems || !hasListings ? EventParameterSearchCompleteSuccess.fail : EventParameterSearchCompleteSuccess.success
            tracker.trackEvent(TrackerEvent.searchComplete(myUserRepository.myUser, searchQuery: searchQuery,
                                                           isTrending: searchType.isTrending,
                                                           success: successValue,
                                                           isLastSearch: searchType.isLastSearch,
                                                           isSuggestiveSearch: searchType.isSuggestive,
                                                           suggestiveSearchIndex: searchType.indexSelected,
                                                           searchRelatedItems: searchRelatedItems))
        }
    }
    
    func trackPushPermissionStart() {
        let goToSettings: EventParameterBoolean =
            LGPushPermissionsManager.sharedInstance.pushPermissionsSettingsMode ? .trueParameter : .notAvailable
        let trackerEvent = TrackerEvent.permissionAlertStart(.push, typePage: .listingListBanner, alertType: .custom,
                                                             permissionGoToSettings: goToSettings)
        tracker.trackEvent(trackerEvent)
    }
    
    func trackPushPermissionComplete() {
        let goToSettings: EventParameterBoolean =
            LGPushPermissionsManager.sharedInstance.pushPermissionsSettingsMode ? .trueParameter : .notAvailable
        let trackerEvent = TrackerEvent.permissionAlertComplete(.push, typePage: .listingListBanner, alertType: .custom,
                                                                permissionGoToSettings: goToSettings)
        tracker.trackEvent(trackerEvent)
    }
    
    func trackPushPermissionCancel() {
        let goToSettings: EventParameterBoolean =
            LGPushPermissionsManager.sharedInstance.pushPermissionsSettingsMode ? .trueParameter : .notAvailable
        let trackerEvent = TrackerEvent.permissionAlertCancel(.push, typePage: .listingListBanner, alertType: .custom,
                                                              permissionGoToSettings: goToSettings)
        tracker.trackEvent(trackerEvent)
    }

    private func trackStartSelling(source: PostingSource, category: PostCategory) {
        tracker.trackEvent(TrackerEvent.listingSellStart(typePage: source.typePage,
                                                         buttonName: source.buttonName,
                                                         sellButtonPosition: source.sellButtonPosition,
                                                         category: category.listingCategory))
    }
    
    func trackShowNewItemsBadge() {
        let trackerEvent = TrackerEvent.showNewItemsBadge()
        tracker.trackEvent(trackerEvent)
    }
}


extension MainListingsViewModel: EditLocationDelegate {
    func editLocationDidSelectPlace(_ place: Place, distanceRadius: Int?) {
        filters.place = place
        filters.distanceRadius = distanceRadius
        updateListView()
        delegate?.vmFiltersChanged()
    }
}


//MARK: CategoriesHeaderCollectionViewDelegate

extension MainListingsViewModel: CategoriesHeaderCollectionViewDelegate {
    func categoryHeaderDidSelect(categoryHeaderInfo: CategoryHeaderInfo) {
        // Do nothing in this case, function is needed by the new sectioned feed
        // This feed uses the `selectedCategory` variable in the CategoriesHeaderView
        // To handle this functionality
    }
}


// MARK: ListingCellDelegate

extension MainListingsViewModel: ListingCellDelegate {
    
    func interestedActionFor(_ listing: Listing, userListing: LocalUser?, completion: @escaping (InterestedState) -> Void) {
        let interestedAction: () -> () = { [weak self] in
            self?.interestedHandler.interestedActionFor(listing,
                                                        userListing: userListing,
                                                        stateCompletion: completion) { [weak self] interestedAction in
                switch interestedAction {
                case .openChatProUser:
                    guard let interlocutor = userListing else { return }
                    self?.navigator?.openListingChat(listing,
                                                     source: .listingList,
                                                     interlocutor: interlocutor)
                case .askPhoneProUser:
                    guard let interlocutor = userListing else { return }
                    self?.navigator?.openAskPhoneFromMainFeedFor(listing: listing, interlocutor: interlocutor)
                case .openChatNonProUser:
                    let chatDetailData = ChatDetailData.listingAPI(listing: listing)
                    self?.navigator?.openChat(chatDetailData,
                                              source: .listingListFeatured,
                                              predefinedMessage: nil)
                case .triggerInterestedAction:
                    let (cancellable, timer) = LGTimer.cancellableWait(5)
                    self?.showUndoBubble(withMessage: R.Strings.productInterestedBubbleMessage,
                                         duration: InterestedHandler.undoTimeout) {
                                            cancellable.cancel()
                    }
                    self?.interestedHandler.handleCancellableInterestedAction(listing, timer: timer,  completion: completion)
                }
            }
        }
        navigator?.openLoginIfNeeded(infoMessage: R.Strings.chatLoginPopupText, then: interestedAction)
    }
    
    private func showUndoBubble(withMessage message: String,
                                duration: TimeInterval,
                                then action: @escaping () -> ()) {
        navigator?.showUndoBubble(withMessage: message,
                                  duration: duration,
                                  withAction: action)
    }
    
    func chatButtonPressedFor(listing: Listing) {
        navigator?.openChat(.listingAPI(listing: listing),
                            source: .listingListFeatured,
                            predefinedMessage: nil)
    }
    
    // Discarded listings are never shown in the main feed
    func editPressedForDiscarded(listing: Listing) {}
    
    // Discarded listings are never shown in the main feed
    func moreOptionsPressedForDiscarded(listing: Listing) {}
    
    func postNowButtonPressed(_ view: UIView,
                              category: PostCategory,
                              source: PostingSource) {
        navigator?.openSell(source: source, postCategory: category)
        trackStartSelling(source: source, category: category)
    }
    
    func openAskPhoneFor(_ listing: Listing, interlocutor: LocalUser) {
        let action: () -> () = { [weak self] in
            guard let strSelf = self else { return }
            if let listingId = listing.objectId,
                strSelf.keyValueStorage.proSellerAlreadySentPhoneInChat.contains(listingId) {
                let trackHelper = ProductVMTrackHelper(tracker: strSelf.tracker, listing: listing, featureFlags: strSelf.featureFlags)
                trackHelper.trackChatWithSeller(.feed)
                strSelf.navigator?.openListingChat(listing, source: .listingList, interlocutor: interlocutor)
            } else {
                strSelf.navigator?.openAskPhoneFromMainFeedFor(listing: listing, interlocutor: interlocutor)
            }
        }
        navigator?.openLoginIfNeeded(infoMessage: R.Strings.chatLoginPopupText, then: action)
    }
    
    func getUserInfoFor(_ listing: Listing, completion: @escaping (User?) -> Void) {
        guard let userId = listing.user.objectId else {
            completion(nil)
            return
        }
        userRepository.show(userId) { result in
            completion(result.value)
        }
    }

    func bumpUpPressedFor(listing: Listing) { }
}

private extension ListingFilters {
    
    var isRealEstateSearch: Bool {
        return selectedCategories == [.realEstate]
    }
    
    var isCarSearch: Bool {
        return selectedCategories == [.cars]
    }
    
    var isJobsAndServicesSearch: Bool {
        return selectedCategories == [.services]
    }
}

private extension ServicesPromoCells {
    
    func newServicesPromoCellModel(withDelegate delegate: ListingCellDelegate) -> ListingCellModel? {
        switch self {
        case .control, .baseline:
            return nil
        case .activeWithCallToAction:
            return ListingCellModel.promo(data: ServicesPromoCellConfiguration.createRandomCellData(showsPostButton: true),
                                          delegate: delegate)
        case .activeWithoutCallToAction:
            return ListingCellModel.promo(data: ServicesPromoCellConfiguration.createRandomCellData(showsPostButton: false),
                                          delegate: delegate)
        }
    }
}

private extension CarPromoCells {
    
    func newCarPromoCellModel(withDelegate delegate: ListingCellDelegate) -> ListingCellModel? {
        switch self {
        case .control, .baseline:
            return nil
        case .variantA:
            return ListingCellModel.promo(data: CarPromoCellConfiguration.createRandomCellData(showsPostButton: true),
                                          delegate: delegate)
        case .variantB:
            return ListingCellModel.promo(data: CarPromoCellConfiguration.createRandomCellData(showsPostButton: false),
                                          delegate: delegate)
        }
    }
}
