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
            resultTags.append(.category(prodCat))
        }
        if let place = filters.place {
            resultTags.append(.location(place))
        }
        if filters.selectedWithin != ProductTimeCriteria.defaultOption {
            resultTags.append(.within(filters.selectedWithin))
        }
        if let selectedOrdering = filters.selectedOrdering, selectedOrdering != ProductSortCriteria.defaultOption {
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
        
        if let distance = filters.distanceRadius {
            resultTags.append(.distance(distance: distance))
        }
        
        return resultTags
    }

    var shouldShowInviteButton: Bool {
        return navigator?.canOpenAppInvite() ?? false
    }

    let mainProductsHeader = Variable<MainProductsHeader>([])

    // Manager & repositories
    fileprivate let sessionManager: SessionManager
    fileprivate let myUserRepository: MyUserRepository
    fileprivate let trendingSearchesRepository: TrendingSearchesRepository
    fileprivate let listingRepository: ListingRepository
    fileprivate let locationManager: LocationManager
    fileprivate let currencyHelper: CurrencyHelper

    fileprivate let tracker: Tracker
    fileprivate let searchType: SearchType? // The initial search
    private let generalCollectionsShuffled: [CollectionCellType]
    fileprivate var collections: [CollectionCellType] {
        guard keyValueStorage[.lastSearches].count >= minimumSearchesSavedToShowCollection else { return generalCollectionsShuffled }
        return [.You] + generalCollectionsShuffled
    }
    fileprivate let keyValueStorage: KeyValueStorageable
    fileprivate let featureFlags: FeatureFlaggeable
    
    // > Delegate
    weak var delegate: MainProductsViewModelDelegate?

    // > Navigator
    weak var navigator: MainTabNavigator?
    
    // List VM
    let listViewModel: ProductListViewModel
    fileprivate let productListRequester: FilteredProductListRequester
    var currentActiveFilters: ProductFilters? {
        return productListRequester.filters
    }
    var userActiveFilters: ProductFilters? {
        return filters
    }
    fileprivate var shouldRetryLoad = false
    fileprivate var lastReceivedLocation: LGLocation?
    fileprivate var bubbleDistance: Float = 1

    // Search tracking state
    fileprivate var shouldTrackSearch = false

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

    fileprivate let disposeBag = DisposeBag()
    
    
    // MARK: - Lifecycle
    
    init(sessionManager: SessionManager, myUserRepository: MyUserRepository, trendingSearchesRepository: TrendingSearchesRepository,
         listingRepository: ListingRepository, locationManager: LocationManager, currencyHelper: CurrencyHelper, tracker: Tracker,
         searchType: SearchType? = nil, filters: ProductFilters, keyValueStorage: KeyValueStorageable, featureFlags: FeatureFlaggeable) {
        
        self.sessionManager = sessionManager
        self.myUserRepository = myUserRepository
        self.trendingSearchesRepository = trendingSearchesRepository
        self.listingRepository = listingRepository
        self.locationManager = locationManager
        self.currencyHelper = currencyHelper
        self.tracker = tracker
        self.searchType = searchType
        self.generalCollectionsShuffled = CollectionCellType.generalCollections.shuffled()
        self.filters = filters
        self.keyValueStorage = keyValueStorage
        self.featureFlags = featureFlags
        let show3Columns = DeviceFamily.current.isWiderOrEqualThan(.iPhone6Plus)
        let columns = show3Columns ? 3 : 2
        let itemsPerPage = show3Columns ? Constants.numProductsPerPageBig : Constants.numProductsPerPageDefault
        self.productListRequester = FilteredProductListRequester(itemsPerPage: itemsPerPage)
        self.listViewModel = ProductListViewModel(requester: self.productListRequester, products: nil,
                                                  numberOfColumns: columns, tracker: tracker)
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
        let listingRepository = Core.listingRepository
        let locationManager = Core.locationManager
        let currencyHelper = Core.currencyHelper
        let tracker = TrackerProxy.sharedInstance
        let keyValueStorage = KeyValueStorage.sharedInstance
        let featureFlags = FeatureFlags.sharedInstance
        self.init(sessionManager: sessionManager,myUserRepository: myUserRepository, trendingSearchesRepository: trendingSearchesRepository,
                  listingRepository: listingRepository, locationManager: locationManager, currencyHelper: currencyHelper, tracker: tracker,
                  searchType: searchType, filters: filters, keyValueStorage: keyValueStorage, featureFlags: featureFlags)
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
        var distance: Int? = nil

        for filterTag in tags {
            switch filterTag {
            case .location(let thePlace):
                place = thePlace
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
            case .distance(let distanceFilter):
                distance = distanceFilter
            }
           
        }

        filters.place = place
        filters.selectedCategories = categories.flatMap{ filterCategoryItem in
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
        
        filters.distanceRadius = distance
    
        updateListView()
    }

    
    // MARK: - Private methods

    private func setup() {
        setupProductList()
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
    
    fileprivate func updateListView() {
        if filters.selectedOrdering == ProductSortCriteria.defaultOption {
            infoBubbleText.value = LGLocalizedString.productPopularNearYou
        }

        productListRequester.filters = filters
        infoBubbleVisible.value = false
        errorMessage.value = nil
        listViewModel.resetUI()
        listViewModel.refresh()
    }
    
    fileprivate func bubbleInfoTextForDistance(_ distance: Int, type: DistanceType) -> String {
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


// MARK: - ProductListView

extension MainProductsViewModel: ProductListViewModelDataDelegate, ProductListViewCellsDelegate {

    func setupProductList() {
        listViewModel.dataDelegate = self

        productListRequester.filters = filters
        productListRequester.queryString = searchType?.query

        listingRepository.events.bindNext { [weak self] event in
            switch event {
            case let .update(listing):
                switch listing {
                case .product(let product):
                    self?.listViewModel.update(product: product)
                case .car:
                    break
                }
            case let .create(listing):
                switch listing {
                case .product(let product):
                    self?.listViewModel.prepend(product: product)
                case .car:
                    break
                }
            case let .delete(productId):
                self?.listViewModel.delete(productId: productId)
            case .favorite, .unFavorite, .sold, .unSold:
                break
            }
        }.addDisposableTo(disposeBag)
    }

    // MARK: > ProductListViewCellsDelegate

    func visibleTopCellWithIndex(_ index: Int, whileScrollingDown scrollingDown: Bool) {
        guard let sortCriteria = filters.selectedOrdering else { return }

        switch (sortCriteria) {
        case .distance:
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
        case .creation:
            infoBubbleText.value = LGLocalizedString.productPopularNearYou
        case .priceAsc, .priceDesc:
            break
        }
    }

    func visibleBottomCell(_ index: Int) { }


    // MARK: > ProductListViewModelDataDelegate

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
                                                  action: nil, secondaryButtonTitle: nil, secondaryAction: nil, emptyReason: nil)
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
            case .network:
                errorString = LGLocalizedString.toastNoNetwork
            case .internalError, .notFound, .forbidden, .tooManyRequests, .userNotVerified, .serverError:
                errorString = LGLocalizedString.toastErrorInternal
            case .unauthorized:
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
        let showRelated = searchType == nil && filters.isDefault()
        let data = ProductDetailData.productList(product: product, cellModels: cellModels,
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
    fileprivate func setupSessionAndLocation() {
        sessionManager.sessionEvents.bindNext { [weak self] _ in self?.sessionDidChange() }.addDisposableTo(disposeBag)
        locationManager.locationEvents.filter { $0 == .locationUpdate }.bindNext { [weak self] _ in
            self?.locationDidChange()
        }.addDisposableTo(disposeBag)
    }

    fileprivate func sessionDidChange() {
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

    fileprivate func retrieveProductsIfNeededWithNewLocation(_ newLocation: LGLocation) {

        var shouldUpdate = false
        if listViewModel.canRetrieveProducts {
            if listViewModel.numberOfProducts == 0 {
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
        } else if listViewModel.numberOfProducts == 0 {
            if lastReceivedLocation?.type != .sensor && newLocation.type == .sensor {
                // in case the user allows sensors while loading the product list with the iplookup parameters"
                shouldRetryLoad = true
            } else if let newCountryCode = newLocation.countryCode, lastReceivedLocation?.countryCode != newCountryCode {
                // in case the list is loading with older country code and new location is received with new country code
                shouldRetryLoad = true
            }
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

    fileprivate func retrieveTrendingSearches() {
        guard let currentCountryCode = locationManager.currentLocation?.countryCode else { return }

        trendingSearchesRepository.index(currentCountryCode) { [weak self] result in
            self?.trendingSearches.value = result.value ?? []
        }
    }
    
    fileprivate func updateLastSearchStoraged(_ query: String) {
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

    fileprivate func setupPermissionsNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(updatePermissionsWarning),
                         name: NSNotification.Name(rawValue: PushManager.Notification.DidRegisterUserNotificationSettings.rawValue), object: nil)
    }

    fileprivate dynamic func updatePermissionsWarning() {
        var currentHeader = mainProductsHeader.value
        if UIApplication.shared.areRemoteNotificationsEnabled {
            currentHeader.remove(MainProductsHeader.PushPermissions)
        } else {
            currentHeader.insert(MainProductsHeader.PushPermissions)
        }
        guard mainProductsHeader.value != currentHeader else { return }
        mainProductsHeader.value = currentHeader
    }

    private func openPushPermissionsAlert() {
        trackPushPermissionStart()
        let positive = UIAction(interface: .styledText(LGLocalizedString.profilePermissionsAlertOk, .standard),
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

fileprivate extension ProductFilters {
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

fileprivate extension MainProductsViewModel {
    func queryForCollection(_ type: CollectionCellType) -> String {
        var query: String
        switch type {
        case .You:
            query = keyValueStorage[.lastSearches].reversed().joined(separator: " ")
        case .Transport:
            query = "car motorcycle boat scooter kayak trailer atv truck bike jeep rims camper cart dirtbike jetski gokart four wheeler bicycle quad bike tractor bmw wheels canoe hoverboard Toyota bmx rv Chevy sub ford paddle Harley yamaha Jeep Honda mustang corvette dodge"
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

fileprivate extension MainProductsViewModel {

    var productVisitSource: EventParameterProductVisitSource {
        if let searchType = searchType {
            switch searchType {
            case .collection:
                return .collection
            case .user, .trending, .lastSearch:
                if filters.isDefault() {
                    return .search
                } else {
                    return .searchAndFilter
                }
            }
        }

        if !filters.isDefault() {
            if filters.selectedCategories.isEmpty {
                return .filter
            } else {
                return .category
            }
        }

        return .productList
    }
    
    var feedSource: EventParameterFeedSource {
        if let search = searchType, search.isCollection {
            return .collection
        }
        if searchType.isEmpty() {
            if productListRequester.hasFilters() {
                return .filter
            }
        } else {
            if productListRequester.hasFilters() {
                return .searchAndFilter
            } else {
                return .search
            }
        }
        return .home
    }
    

    func trackRequestSuccess(page: UInt, hasProducts: Bool) {
        guard page == 0 else { return }
        let successParameter: EventParameterBoolean = hasProducts ? .trueParameter : .falseParameter
        let trackerEvent = TrackerEvent.productList(myUserRepository.myUser,
                                                    categories: productListRequester.filters?.selectedCategories,
                                                    searchQuery: productListRequester.queryString, feedSource: feedSource, success: successParameter)
        tracker.trackEvent(trackerEvent)

        if let searchType = searchType, shouldTrackSearch {
            shouldTrackSearch = false
            let successValue = hasProducts ? EventParameterSearchCompleteSuccess.success : EventParameterSearchCompleteSuccess.fail
            tracker.trackEvent(TrackerEvent.searchComplete(myUserRepository.myUser, searchQuery: searchType.query,
                                                           isTrending: searchType.isTrending,
                                                           success: successValue, isLastSearch: searchType.isLastSearch))
        }
    }

    func trackPushPermissionStart() {
        let goToSettings: EventParameterBoolean =
            PushPermissionsManager.sharedInstance.pushPermissionsSettingsMode ? .trueParameter : .notAvailable
        let trackerEvent = TrackerEvent.permissionAlertStart(.push, typePage: .productListBanner, alertType: .custom,
                                                             permissionGoToSettings: goToSettings)
        tracker.trackEvent(trackerEvent)
    }

    func trackPushPermissionComplete() {
        let goToSettings: EventParameterBoolean =
            PushPermissionsManager.sharedInstance.pushPermissionsSettingsMode ? .trueParameter : .notAvailable
        let trackerEvent = TrackerEvent.permissionAlertComplete(.push, typePage: .productListBanner, alertType: .custom,
                                                                permissionGoToSettings: goToSettings)
        tracker.trackEvent(trackerEvent)
    }

    func trackPushPermissionCancel() {
        let goToSettings: EventParameterBoolean =
            PushPermissionsManager.sharedInstance.pushPermissionsSettingsMode ? .trueParameter : .notAvailable
        let trackerEvent = TrackerEvent.permissionAlertCancel(.push, typePage: .productListBanner, alertType: .custom,
                                                              permissionGoToSettings: goToSettings)
        tracker.trackEvent(trackerEvent)
    }
}
