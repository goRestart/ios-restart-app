//
//  ProductsViewModel.swift
//  letgo
//
//  Created by AHL on 3/5/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import CoreLocation
import LGCoreKit
import Result
import RxSwift

protocol MainProductsViewModelDelegate: BaseViewModelDelegate {
    func vmDidSearch()
    func vmShowTags(_ tags: [FilterTag])
}

struct MainProductsHeader: OptionSet {
    let rawValue : Int
    init(rawValue:Int){ self.rawValue = rawValue}

    static let PushPermissions  = MainProductsHeader(rawValue:1)
    static let SellButton = MainProductsHeader(rawValue:2)
}

class MainProductsViewModel: BaseViewModel {
    
    // > Input
    var searchString: String? {
        return searchType?.text
    }
    var clearTextOnSearch: Bool {
        guard let searchType = searchType else { return false }
        switch searchType {
        case .collection:
            return true
        case .user, .trending, .lastSearch:
            return false
        }
    }
    let bannerCellPosition: Int = 8
    var filters: ProductFilters

    let infoBubbleVisible = Variable<Bool>(false)
    let infoBubbleText = Variable<String>(LGLocalizedString.productPopularNearYou)
    let errorMessage = Variable<String?>(nil)
    
    private static let firstVersionNumber = 1

    var tags: [FilterTag] {
        
        var resultTags : [FilterTag] = []
        for prodCat in filters.selectedCategories {
            resultTags.append(.Category(prodCat))
        }
        if let place = filters.place {
            resultTags.append(.Location(place))
        }
        if filters.selectedWithin != ProductTimeCriteria.defaultOption {
            resultTags.append(.Within(filters.selectedWithin))
        }
        if let selectedOrdering = filters.selectedOrdering, selectedOrdering != ProductSortCriteria.defaultOption {
            resultTags.append(.OrderBy(selectedOrdering))
        }

        switch filters.priceRange {
        case .freePrice:
            resultTags.append(.freeStuff)
        case let .priceRange(min, max):
            if min != nil || max != nil {
                var currency: Currency? = nil
                if let countryCode = locationManager.currentPostalAddress?.countryCode {
                    currency = currencyHelper.currencyWithCountryCode(countryCode)
                }
                resultTags.append(.PriceRange(from: filters.priceRange.min, to: filters.priceRange.max, currency: currency))
            }
        }
        
        return resultTags
    }

    var shouldShowInviteButton: Bool {
        return navigator?.canOpenAppInvite() ?? false
    }
    
    var shouldUseNavigationBarFilterIconWithLetters: Bool {
        return featureFlags.filterIconWithLetters
    }

    let mainProductsHeader = Variable<MainProductsHeader>([])

    // Manager & repositories
    private let sessionManager: SessionManager
    private let myUserRepository: MyUserRepository
    private let trendingSearchesRepository: TrendingSearchesRepository
    private let locationManager: LocationManager
    private let currencyHelper: CurrencyHelper

    private let tracker: Tracker
    private let searchType: SearchType? // The initial search
    private let generalCollectionsShuffled: [CollectionCellType]
    private var collections: [CollectionCellType] {
        guard keyValueStorage[.lastSearches].count >= minimumSearchesSavedToShowCollection else { return generalCollectionsShuffled }
        return [.You] + generalCollectionsShuffled
    }
    private let keyValueStorage: KeyValueStorageable
    private let featureFlags: FeatureFlaggeable
    
    // > Delegate
    weak var delegate: MainProductsViewModelDelegate?

    // > Navigator
    weak var navigator: MainTabNavigator?
    
    // List VM
    let listViewModel: ProductListViewModel
    private let productListRequester: FilteredProductListRequester
    var currentActiveFilters: ProductFilters? {
        return productListRequester.filters
    }
    var userActiveFilters: ProductFilters? {
        return filters
    }
    private var shouldRetryLoad = false
    private var lastReceivedLocation: LGLocation?
    private var bubbleDistance: Float = 1

    // Search tracking state
    private var shouldTrackSearch = false

    // Suggestion searches
    let minimumSearchesSavedToShowCollection = 3
    let lastSearchesSavedMaximum = 10
    let lastSearchesShowMaximum = 3
    let trendingSearches = Variable<[String]>([])
    let lastSearches = Variable<[String]>([])
    var lastSearchesCounter: Int {
        return lastSearches.value.count
    }
    var trendingCounter: Int {
        return trendingSearches.value.count
    }

    private let disposeBag = DisposeBag()
    
    
    // MARK: - Lifecycle
    
    init(sessionManager: SessionManager, myUserRepository: MyUserRepository, trendingSearchesRepository: TrendingSearchesRepository,
         locationManager: LocationManager, currencyHelper: CurrencyHelper, tracker: Tracker, searchType: SearchType? = nil,
         filters: ProductFilters, keyValueStorage: KeyValueStorageable,
         featureFlags: FeatureFlaggeable) {
        
        self.sessionManager = sessionManager
        self.myUserRepository = myUserRepository
        self.trendingSearchesRepository = trendingSearchesRepository
        self.locationManager = locationManager
        self.currencyHelper = currencyHelper
        self.tracker = tracker
        self.searchType = searchType
        self.generalCollectionsShuffled = CollectionCellType.generalCollections.shuffle()
        self.filters = filters
        self.keyValueStorage = keyValueStorage
        self.featureFlags = featureFlags
        let show3Columns = DeviceFamily.current.isWiderOrEqualThan(.iPhone6Plus)
        let columns = show3Columns ? 3 : 2
        let itemsPerPage = show3Columns ? Constants.numProductsPerPageBig : Constants.numProductsPerPageDefault
        self.productListRequester = FilteredProductListRequester(itemsPerPage: itemsPerPage)
        self.listViewModel = ProductListViewModel(requester: self.productListRequester, products: nil,
                                                  numberOfColumns: columns)
        self.listViewModel.productListFixedInset = show3Columns ? 6 : 10

        if let search = searchType, !search.isCollection && !search.query.isEmpty {
            self.shouldTrackSearch = true
        }
        
        super.init()

        setup()
    }
    
    convenience init(searchType: SearchType? = nil, filters: ProductFilters) {
        let sessionManager = Core.sessionManager
        let myUserRepository = Core.myUserRepository
        let trendingSearchesRepository = Core.trendingSearchesRepository
        let locationManager = Core.locationManager
        let currencyHelper = Core.currencyHelper
        let tracker = TrackerProxy.sharedInstance
        let keyValueStorage = KeyValueStorage.sharedInstance
        let featureFlags = FeatureFlags.sharedInstance
        self.init(sessionManager: sessionManager,myUserRepository: myUserRepository, trendingSearchesRepository: trendingSearchesRepository,
                  locationManager: locationManager, currencyHelper: currencyHelper, tracker: tracker, searchType: searchType,
                  filters: filters, keyValueStorage: keyValueStorage, featureFlags: featureFlags)
    }
    
    convenience init(searchType: SearchType? = nil, tabNavigator: TabNavigator?) {
        let filters = ProductFilters()
        self.init(searchType: searchType, filters: filters)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func didBecomeActive(_ firstTime: Bool) {
        updatePermissionsWarning()
        if let currentLocation = locationManager.currentLocation {
            retrieveProductsIfNeededWithNewLocation(currentLocation)
            retrieveLastUserSearch()
            retrieveTrendingSearches()
        }
    }

    
    // MARK: - Public methods
    
    /**
        Search action.
    */
    func search(_ query: String) {
        guard !query.characters.isEmpty else { return }
    
        delegate?.vmDidSearch()
        navigator?.openMainProduct(withSearchType: .user(query: query), productFilters: filters)
    }

    func showFilters() {
        navigator?.showFilters(with: filters, filtersVMDataDelegate: self)
        // Tracking
        tracker.trackEvent(TrackerEvent.filterStart())
    }

    /**
        Called when search button is pressed.
    */
    func searchBegan() {
        // Tracking
        tracker.trackEvent(TrackerEvent.searchStart(myUserRepository.myUser))
    }
    
    /**
        Called when a filter gets removed
    */
    func updateFiltersFromTags(_ tags: [FilterTag]) {

        var place: Place? = nil
        var categories: [FilterCategoryItem] = []
        var orderBy = ProductSortCriteria.defaultOption
        var within = ProductTimeCriteria.defaultOption
        var minPrice: Int? = nil
        var maxPrice: Int? = nil
        var free: Bool = false

        for filterTag in tags {
            switch filterTag {
            case .Location(let thePlace):
                place = thePlace
            case .Category(let prodCategory):
                categories.append(FilterCategoryItem(category: prodCategory))
            case .OrderBy(let prodSortOption):
                orderBy = prodSortOption
            case .Within(let prodTimeOption):
                within = prodTimeOption
            case .PriceRange(let minPriceOption, let maxPriceOption, _):
                minPrice = minPriceOption
                maxPrice = maxPriceOption
            case .freeStuff:
                free = true
            }
        }

        filters.place = place
        filters.selectedCategories = categories.flatMap{ filterCategoryItem in
            switch filterCategoryItem {
            case .Free:
                return nil
            case .Category(let cat):
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

        updateListView()
    }

    
    // MARK: - Private methods

    private func setup() {
        listViewModel.dataDelegate = self
        productListRequester.filters = filters

        productListRequester.queryString = searchType?.query
        setupSessionAndLocation()
        setupPermissionsNotification()
    }
   
    
    /**
        Returns a view model for search.
    
        - returns: A view model for search.
    */
    private func viewModelForSearch(_ searchType: SearchType) -> MainProductsViewModel {
        return MainProductsViewModel(searchType: searchType, filters: filters)
    }
    
    private func updateListView() {
        if filters.selectedOrdering == ProductSortCriteria.defaultOption {
            infoBubbleText.value = LGLocalizedString.productPopularNearYou
        }

        productListRequester.filters = filters
        infoBubbleVisible.value = false
        errorMessage.value = nil
        listViewModel.resetUI()
        listViewModel.refresh()
    }
    
    private func bubbleInfoTextForDistance(_ distance: Int, type: DistanceType) -> String {
        let distanceString = String(format: "%d %@", arguments: [min(Constants.productListMaxDistanceLabel, distance),
            type.string])
        if distance <= Constants.productListMaxDistanceLabel {
            return LGLocalizedString.productDistanceXFromYou(distanceString)
        } else {
            return LGLocalizedString.productDistanceMoreThanFromYou(distanceString)
        }
    }
}


// MARK: - FiltersViewModelDataDelegate

extension MainProductsViewModel: FiltersViewModelDataDelegate {

    func viewModelDidUpdateFilters(_ viewModel: FiltersViewModel, filters: ProductFilters) {
        self.filters = filters
        delegate?.vmShowTags(tags)
        updateListView()
    }
}


// MARK: - ProductListViewCellsDelegate 

extension MainProductsViewModel: ProductListViewCellsDelegate {
    func visibleTopCellWithIndex(_ index: Int, whileScrollingDown scrollingDown: Bool) {
        guard let sortCriteria = filters.selectedOrdering else { return }

        switch (sortCriteria) {
        case .Distance:
            guard let topProduct = listViewModel.productAtIndex(index) else { return }
            let distance = Float(productListRequester.distanceFromProductCoordinates(topProduct.location))

            // instance var max distance or MIN distance to avoid updating the label everytime
            if (scrollingDown && distance > bubbleDistance) || (!scrollingDown && distance < bubbleDistance) ||
                listViewModel.refreshing {
                bubbleDistance = distance
            }
            let distanceString = bubbleInfoTextForDistance(max(1,Int(round(bubbleDistance))),
                                                           type: DistanceType.systemDistanceType())
            infoBubbleText.value = distanceString
        case .Creation:
            infoBubbleText.value = LGLocalizedString.productPopularNearYou
        case .PriceAsc, .PriceDesc:
            break
        }
    }

    func visibleBottomCell(_ index: Int) { }
}


// MARK: - ProductListViewModelDataDelegate

extension MainProductsViewModel: ProductListViewModelDataDelegate {
    func productListVM(_ viewModel: ProductListViewModel, didSucceedRetrievingProductsPage page: UInt,
                              hasProducts: Bool) {
        
        trackRequestSuccess(page: page, hasProducts: hasProducts)
        // Only save the string when there is products and we are not searching a collection
        if let queryString = productListRequester.queryString, hasProducts {
            if let searchType = searchType, !searchType.isCollection {
                updateLastSearchStoraged(queryString)
            }
        }
    
        if shouldRetryLoad {
            shouldRetryLoad = false
            listViewModel.retrieveProducts()
            return
        }

        if page == 0 && !hasProducts {
            let errImage: UIImage?
            let errTitle: String?
            let errBody: String?

            // Search
            if productListRequester.queryString != nil || productListRequester.hasFilters() {
                errImage = UIImage(named: "err_search_no_products")
                errTitle = LGLocalizedString.productSearchNoProductsTitle
                errBody = LGLocalizedString.productSearchNoProductsBody
            } else {
                // Listing
                errImage = UIImage(named: "err_list_no_products")
                errTitle = LGLocalizedString.productListNoProductsTitle
                errBody = LGLocalizedString.productListNoProductsBody
            }

            let emptyViewModel = LGEmptyViewModel(icon: errImage, title: errTitle, body: errBody, buttonTitle: nil,
                                                  action: nil, secondaryButtonTitle: nil, secondaryAction: nil)
            listViewModel.setEmptyState(emptyViewModel)
        }

        errorMessage.value = nil
        infoBubbleVisible.value = hasProducts && filters.infoBubblePresent
        if(page == 0) {
            bubbleDistance = 1
        }
    }

    func productListMV(_ viewModel: ProductListViewModel, didFailRetrievingProductsPage page: UInt,
                              hasProducts: Bool, error: RepositoryError) {
        if shouldRetryLoad {
            shouldRetryLoad = false
            listViewModel.retrieveProducts()
            return
        }

        if page == 0 && !hasProducts {
            if let emptyViewModel = LGEmptyViewModel.respositoryErrorWithRetry(error,
                                                                               action:  { [weak viewModel] in viewModel?.refresh() }) {
                listViewModel.setErrorState(emptyViewModel)
            }
        }

        var errorString: String? = nil
        if hasProducts && page > 0 {
            switch error {
            case .Network:
                errorString = LGLocalizedString.toastNoNetwork
            case .Internal, .NotFound, .Forbidden, .TooManyRequests, .UserNotVerified, .ServerError:
                errorString = LGLocalizedString.toastErrorInternal
            case .Unauthorized:
                errorString = nil
            }
        }
        errorMessage.value = errorString
        infoBubbleVisible.value = hasProducts && filters.infoBubblePresent
    }

    func productListVM(_ viewModel: ProductListViewModel, didSelectItemAtIndex index: Int,
                       thumbnailImage: UIImage?, originFrame: CGRect?) {
        
        guard let product = viewModel.productAtIndex(index) else { return }
        let cellModels = viewModel.objects
        let showRelated = searchType == nil
        let data = ProductDetailData.ProductList(product: product, cellModels: cellModels,
                                                 requester: productListRequester, thumbnailImage: thumbnailImage,
                                                 originFrame: originFrame, showRelated: showRelated, index: index)
        navigator?.openProduct(data, source: productVisitSource,
                               showKeyboardOnFirstAppearIfNeeded: false)
    }

    func vmProcessReceivedProductPage(_ products: [ProductCellModel], page: UInt) -> [ProductCellModel] {
        guard searchType == nil else { return products }
        guard products.count > bannerCellPosition else { return products }
        var cellModels = products
        if !collections.isEmpty && productListRequester.countryCode == "US" {
            let collectionType = collections[Int(page) % collections.count]
            let collectionModel = ProductCellModel.collectionCell(type: collectionType)
            cellModels.insert(collectionModel, at: bannerCellPosition)
        }
        return cellModels
    }

    func vmDidSelectCollection(_ type: CollectionCellType){
        tracker.trackEvent(TrackerEvent.exploreCollection(type.rawValue))
        let query = queryForCollection(type)
        delegate?.vmDidSearch()
        navigator?.openMainProduct(withSearchType: .collection(type: type, query: query), productFilters: filters)
    }
    
    func vmUserDidTapInvite() {
        navigator?.openAppInvite()
    }
}


// MARK: - Session & Location handling

extension MainProductsViewModel {
    private func setupSessionAndLocation() {
        sessionManager.sessionEvents.bindNext { [weak self] _ in self?.sessionDidChange() }.addDisposableTo(disposeBag)
        locationManager.locationEvents.filter { $0 == .LocationUpdate }.bindNext { [weak self] _ in
            self?.locationDidChange()
        }.addDisposableTo(disposeBag)
    }

    private func sessionDidChange() {
        guard listViewModel.canRetrieveProducts else {
            shouldRetryLoad = true
            return
        }
        listViewModel.retrieveProducts()
    }

    private func locationDidChange() {
        guard let newLocation = locationManager.currentLocation else { return }

        // Tracking: when a new location is received and has different type than previous one
        if lastReceivedLocation?.type != newLocation.type {
            let locationServiceStatus = locationManager.locationServiceStatus
            let trackerEvent = TrackerEvent.location(newLocation, locationServiceStatus: locationServiceStatus)
            tracker.trackEvent(trackerEvent)
        }

        // Retrieve products (should be place after tracking, as it updates lastReceivedLocation)
        retrieveProductsIfNeededWithNewLocation(newLocation)
        retrieveLastUserSearch()
        retrieveTrendingSearches()
    }

    private func retrieveProductsIfNeededWithNewLocation(_ newLocation: LGLocation) {

        var shouldUpdate = false
        if listViewModel.canRetrieveProducts {
            // If there are no products, then refresh
            if listViewModel.numberOfProducts == 0 {
                shouldUpdate = true
            }
            // If new location is manual OR last location was manual, and location has changed then refresh
            else if newLocation.type == .Manual || lastReceivedLocation?.type == .Manual {
                if let lastReceivedLocation = lastReceivedLocation, newLocation != lastReceivedLocation {
                    shouldUpdate = true
                }
            }
            // If new location is not manual and we improved the location type to sensors
            else if lastReceivedLocation?.type != .Sensor && newLocation.type == .Sensor {
                shouldUpdate = true
            }
        } else if listViewModel.numberOfProducts == 0 && lastReceivedLocation?.type != .Sensor && newLocation.type == .Sensor {
            // in case the user allows sensors while loading the product list with the iplookup parameters
            shouldRetryLoad = true
        }

        if shouldUpdate {
            listViewModel.retrieveProducts()
        }

        // Track the received location
        lastReceivedLocation = newLocation
    }
}


// MARK: - Suggestions searches

extension MainProductsViewModel {

    func trendingSearchAtIndex(_ index: Int) -> String? {
        guard  0..<trendingSearches.value.count ~= index else { return nil }
        return trendingSearches.value[index]
    }
    
    func lastSearchAtIndex(_ index: Int) -> String? {
        guard 0..<lastSearches.value.count ~= index else { return nil }
        return lastSearches.value[index]
    }

    func selectedTrendingSearchAtIndex(_ index: Int) {
        guard let trendingSearch = trendingSearchAtIndex(index), !trendingSearch.isEmpty else { return }
        delegate?.vmDidSearch()
        navigator?.openMainProduct(withSearchType: .trending(query: trendingSearch), productFilters: filters)
    }
    
    func selectedLastSearchAtIndex(_ index: Int) {
        guard let lastSearch = lastSearchAtIndex(index), !lastSearch.isEmpty else { return }
        delegate?.vmDidSearch()
        navigator?.openMainProduct(withSearchType: .lastSearch(query: lastSearch), productFilters: filters)
    }
    
    func cleanUpLastSearches() {
        keyValueStorage[.lastSearches] = []
        lastSearches.value = keyValueStorage[.lastSearches]
    }
    
    func retrieveLastUserSearch() {
        // We saved up to lastSearchesSavedMaximum(10) but we show only lastSearchesShowMaximum(3)
        var searchesToShow = [String]()
        let allSearchesSaved = keyValueStorage[.lastSearches]
        if allSearchesSaved.count > lastSearchesShowMaximum {
            searchesToShow = Array(allSearchesSaved.suffix(lastSearchesShowMaximum))
        } else {
            searchesToShow = keyValueStorage[.lastSearches]
        }
        lastSearches.value = searchesToShow.reversed()
    }

    private func retrieveTrendingSearches() {
        guard let currentCountryCode = locationManager.currentPostalAddress?.countryCode else { return }

        trendingSearchesRepository.index(currentCountryCode) { [weak self] result in
            self?.trendingSearches.value = result.value ?? []
        }
    }
    
    private func updateLastSearchStoraged(_ query: String) {
        // We save up to lastSearchesSavedMaximum(10)
        var searchesSaved = keyValueStorage[.lastSearches]
        // Check if already exists and move to front.
        if let index = searchesSaved.index(of: query) {
            searchesSaved.remove(at: index)
        }
        searchesSaved.append(query)
        if searchesSaved.count > lastSearchesSavedMaximum {
            searchesSaved.removeFirst()
        }
        keyValueStorage[.lastSearches] = searchesSaved
        retrieveLastUserSearch()
    }
}

// MARK: Push Permissions

extension MainProductsViewModel {

    func pushPermissionsHeaderPressed() {
        openPushPermissionsAlert()
    }

    private func setupPermissionsNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(updatePermissionsWarning),
                         name: NSNotification.Name(rawValue: PushManager.Notification.DidRegisterUserNotificationSettings.rawValue), object: nil)
    }

    private dynamic func updatePermissionsWarning() {
        var currentHeader = mainProductsHeader.value
        if UIApplication.shared.areRemoteNotificationsEnabled {
            currentHeader.remove(MainProductsHeader.PushPermissions)
        } else {
            currentHeader.insert(MainProductsHeader.PushPermissions)
        }
        mainProductsHeader.value = currentHeader
    }

    private func openPushPermissionsAlert() {
        trackPushPermissionStart()
        let positive = UIAction(interface: .styledText(LGLocalizedString.profilePermissionsAlertOk, .default),
                                action: { [weak self] in
                                    self?.trackPushPermissionComplete()
                                    PushPermissionsManager.sharedInstance.showPushPermissionsAlert(prePermissionType: .productListBanner)
            },
                                accessibilityId: .userPushPermissionOK)
        let negative = UIAction(interface: .styledText(LGLocalizedString.profilePermissionsAlertCancel, .cancel),
                                action: { [weak self] in
                                    self?.trackPushPermissionCancel()
            },
                                accessibilityId: .userPushPermissionCancel)
        delegate?.vmShowAlertWithTitle(LGLocalizedString.profilePermissionsAlertTitle,
                                       text: LGLocalizedString.profilePermissionsAlertMessage,
                                       alertType: .iconAlert(icon: UIImage(named: "custom_permission_profile")),
                                       actions: [negative, positive])
    }
}


// MARK: - Filters & bubble

private extension ProductFilters {
    var infoBubblePresent: Bool {
        guard let selectedOrdering = selectedOrdering else { return true }
        switch (selectedOrdering) {
        case .Distance, .Creation:
            return true
        case .PriceAsc, .PriceDesc:
            return false
        }
    }
}


// MARK: - Queries for Collections

private extension MainProductsViewModel {
    func queryForCollection(_ type: CollectionCellType) -> String {
        var query: String
        switch type {
        case .You:
            query = keyValueStorage[.lastSearches].reversed().joined(separator: " ")
        case .Transport:
            switch featureFlags.keywordsTravelCollection {
            case .Standard:
                query = "bike boat motorcycle car kayak trailer atv truck jeep rims camper cart scooter dirtbike jetski gokart four wheeler bicycle quad bike tractor bmw wheels canoe hoverboard Toyota bmx rv Chevy sub ford paddle Harley yamaha Jeep Honda mustang corvette dodge"
            case .CarsPrior:
                query = "car motorcycle boat scooter kayak trailer atv truck bike jeep rims camper cart dirtbike jetski gokart four wheeler bicycle quad bike tractor bmw wheels canoe hoverboard Toyota bmx rv Chevy sub ford paddle Harley yamaha Jeep Honda mustang corvette dodge"
            case .BrandsPrior:
                query = "mustang Honda Harley corvette dodge Toyota yamaha motorcycle Jeep atv bike boat car kayak trailer truck jeep rims camper cart scooter dirtbike jetski gokart four wheeler bicycle quad bike tractor bmw wheels canoe hoverboard bmx rv Chevy sub ford paddle"
            }
        case .Gaming:
            query = "ps4 xbox pokemon nintendo PS3 game boy Wii atari sega"
        case .Apple:
            query = "iphone apple iPad MacBook iPod Mac iMac"
        case .Furniture:
            query = "dresser couch furniture desk table patio bed stand chair sofa rug mirror futon bench stool frame recliner lamp cabinet ikea shelf antique bedroom book shelf tables end table bunk beds night stand canopy"
        }
        return query
    }
}


// MARK: - Tracking

private extension MainProductsViewModel {

    var productVisitSource: EventParameterProductVisitSource {
        if let searchType = searchType {
            switch searchType {
            case .collection:
                return .Collection
            case .user, .trending, .lastSearch:
                if filters.isDefault() {
                    return .Search
                } else {
                    return .SearchAndFilter
                }
            }
        }

        if !filters.isDefault() {
            if filters.selectedCategories.isEmpty {
                return .Filter
            } else {
                return .Category
            }
        }

        return .ProductList
    }

    func trackRequestSuccess(page: UInt, hasProducts: Bool) {
        guard page == 0 else { return }

        let trackerEvent = TrackerEvent.productList(myUserRepository.myUser,
                                                    categories: productListRequester.filters?.selectedCategories,
                                                    searchQuery: productListRequester.queryString)
        tracker.trackEvent(trackerEvent)

        if let searchType = searchType, shouldTrackSearch && filters.isDefault() {
            shouldTrackSearch = false
            tracker.trackEvent(TrackerEvent.searchComplete(myUserRepository.myUser, searchQuery: searchType.query,
                                                           isTrending: searchType.isTrending,
                                                           success: hasProducts ? .Success : .Failed, isLastSearch: searchType.isLastSearch))
        }
    }

    func trackPushPermissionStart() {
        let goToSettings: EventParameterPermissionGoToSettings =
            PushPermissionsManager.sharedInstance.pushPermissionsSettingsMode ? .True : .notAvailable
        let trackerEvent = TrackerEvent.permissionAlertStart(.Push, typePage: .ProductListBanner, alertType: .Custom,
                                                             permissionGoToSettings: goToSettings)
        tracker.trackEvent(trackerEvent)
    }

    func trackPushPermissionComplete() {
        let goToSettings: EventParameterPermissionGoToSettings =
            PushPermissionsManager.sharedInstance.pushPermissionsSettingsMode ? .True : .notAvailable
        let trackerEvent = TrackerEvent.permissionAlertComplete(.Push, typePage: .ProductListBanner, alertType: .Custom,
                                                                permissionGoToSettings: goToSettings)
        tracker.trackEvent(trackerEvent)
    }

    func trackPushPermissionCancel() {
        let goToSettings: EventParameterPermissionGoToSettings =
            PushPermissionsManager.sharedInstance.pushPermissionsSettingsMode ? .True : .notAvailable
        let trackerEvent = TrackerEvent.permissionAlertCancel(.Push, typePage: .ProductListBanner, alertType: .Custom,
                                                              permissionGoToSettings: goToSettings)
        tracker.trackEvent(trackerEvent)
    }
}
