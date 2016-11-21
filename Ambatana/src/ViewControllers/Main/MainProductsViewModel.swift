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
    func vmDidSearch(searchViewModel: MainProductsViewModel)
    func vmShowFilters(filtersVM: FiltersViewModel)
    func vmShowTags(tags: [FilterTag])
}

protocol PermissionsDelegate: class {
    func mainProductsViewModelShowPushPermissionsAlert(mainProductsViewModel: MainProductsViewModel)
}

struct MainProductsHeader: OptionSetType {
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
        case .Collection:
            return true
        case .User, .Trending, .LastSearch:
            return false
        }
    }
    let bannerCellPosition: Int = 8
    var filters: ProductFilters

    let infoBubbleVisible = Variable<Bool>(false)
    let infoBubbleText = Variable<String>(LGLocalizedString.productPopularNearYou)
    let errorMessage = Variable<String?>(nil)

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
        if let selectedOrdering = filters.selectedOrdering where selectedOrdering != ProductSortCriteria.defaultOption {
            resultTags.append(.OrderBy(selectedOrdering))
        }

        switch filters.priceRange {
        case .FreePrice:
            resultTags.append(.FreeStuff)
        case let .PriceRange(min, max):
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
        return tabNavigator?.canOpenAppInvite() ?? false
    }

    let mainProductsHeader = Variable<MainProductsHeader>([])

    // Manager & repositories
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
    private let keyValueStorage: KeyValueStorage
    
    // > Delegate
    weak var delegate: MainProductsViewModelDelegate?
    weak var permissionsDelegate: PermissionsDelegate?

    // > Navigator
    weak var tabNavigator: TabNavigator?
    
    // List VM
    let listViewModel: ProductListViewModel
    private let productListRequester: FilteredProductListRequester
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
    
    
    // MARK: - Lifecycle
    
    init(myUserRepository: MyUserRepository, trendingSearchesRepository: TrendingSearchesRepository,
         locationManager: LocationManager, currencyHelper: CurrencyHelper, tracker: Tracker, searchType: SearchType? = nil,
         filters: ProductFilters, tabNavigator: TabNavigator?, keyValueStorage: KeyValueStorage) {
        self.myUserRepository = myUserRepository
        self.trendingSearchesRepository = trendingSearchesRepository
        self.locationManager = locationManager
        self.currencyHelper = currencyHelper
        self.tracker = tracker
        self.searchType = searchType
        self.generalCollectionsShuffled = CollectionCellType.generalCollections.shuffle()
        self.filters = filters
        self.tabNavigator = tabNavigator
        self.keyValueStorage = keyValueStorage
        let show3Columns = DeviceFamily.current.isWiderOrEqualThan(.iPhone6Plus)
        let columns = show3Columns ? 3 : 2
        let itemsPerPage = show3Columns ? Constants.numProductsPerPageBig : Constants.numProductsPerPageDefault
        self.productListRequester = FilteredProductListRequester(itemsPerPage: itemsPerPage)
        self.listViewModel = ProductListViewModel(requester: self.productListRequester, products: nil,
                                                  numberOfColumns: columns)
        self.listViewModel.productListFixedInset = show3Columns ? 6 : 10

        if let search = searchType where !search.isCollection && !search.query.isEmpty {
            self.shouldTrackSearch = true
        }
        
        super.init()

        setup()
    }
    
    convenience init(searchType: SearchType? = nil, filters: ProductFilters, tabNavigator: TabNavigator?) {
        let myUserRepository = Core.myUserRepository
        let trendingSearchesRepository = Core.trendingSearchesRepository
        let locationManager = Core.locationManager
        let currencyHelper = Core.currencyHelper
        let tracker = TrackerProxy.sharedInstance
        let keyValueStorage = KeyValueStorage.sharedInstance
        self.init(myUserRepository: myUserRepository, trendingSearchesRepository: trendingSearchesRepository,
                  locationManager: locationManager, currencyHelper: currencyHelper, tracker: tracker, searchType: searchType,
                  filters: filters, tabNavigator: tabNavigator, keyValueStorage: keyValueStorage)
    }
    
    convenience init(searchType: SearchType? = nil, tabNavigator: TabNavigator?) {
        let filters = ProductFilters()
        self.init(searchType: searchType, filters: filters, tabNavigator: tabNavigator)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didBecomeActive(firstTime: Bool) {
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
    func search(query: String) {
        guard !query.characters.isEmpty else { return }
        delegate?.vmDidSearch(viewModelForSearch(.User(query: query)))
    }

    func showFilters() {
        let filtersVM = FiltersViewModel(currentFilters: filters ?? ProductFilters())
        filtersVM.dataDelegate = self
        delegate?.vmShowFilters(filtersVM)
        
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
    func updateFiltersFromTags(tags: [FilterTag]) {

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
            case .FreeStuff:
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
            filters.priceRange = .FreePrice
        } else {
            filters.priceRange = .PriceRange(min: minPrice, max: maxPrice)
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
    private func viewModelForSearch(searchType: SearchType) -> MainProductsViewModel {
        return MainProductsViewModel(searchType: searchType, filters: filters, tabNavigator: tabNavigator)
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
    
    private func bubbleInfoTextForDistance(distance: Int, type: DistanceType) -> String {
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

    func viewModelDidUpdateFilters(viewModel: FiltersViewModel, filters: ProductFilters) {
        self.filters = filters
        delegate?.vmShowTags(tags)
        updateListView()
    }
}


// MARK: - ProductListViewCellsDelegate 

extension MainProductsViewModel: ProductListViewCellsDelegate {
    func visibleTopCellWithIndex(index: Int, whileScrollingDown scrollingDown: Bool) {
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

    func visibleBottomCell(index: Int) {
        guard index == Constants.itemIndexPushPermissionsTrigger else { return }
        permissionsDelegate?.mainProductsViewModelShowPushPermissionsAlert(self)
    }
}


// MARK: - ProductListViewModelDataDelegate

extension MainProductsViewModel: ProductListViewModelDataDelegate {
    func productListVM(viewModel: ProductListViewModel, didSucceedRetrievingProductsPage page: UInt,
                              hasProducts: Bool) {
        
        trackRequestSuccess(page: page, hasProducts: hasProducts)
        // Only save the string when there is products and we are not searching a collection
        if let queryString = productListRequester.queryString where hasProducts {
            if let searchType = searchType where !searchType.isCollection {
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

    func productListMV(viewModel: ProductListViewModel, didFailRetrievingProductsPage page: UInt,
                              hasProducts: Bool, error: RepositoryError) {
        if shouldRetryLoad {
            shouldRetryLoad = false
            listViewModel.retrieveProducts()
            return
        }

        if page == 0 && !hasProducts {
            let emptyViewModel = LGEmptyViewModel.respositoryErrorWithRetry(error,
                                        action:  { [weak viewModel] in viewModel?.refresh() })
            listViewModel.setErrorState(emptyViewModel)
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

    func productListVM(viewModel: ProductListViewModel, didSelectItemAtIndex index: Int,
                       thumbnailImage: UIImage?, originFrame: CGRect?) {
        
        guard let product = viewModel.productAtIndex(index) else { return }
        let cellModels = viewModel.objects
        let showRelated = searchType == nil
        let data = ProductDetailData.ProductList(product: product, cellModels: cellModels,
                                                 requester: productListRequester, thumbnailImage: thumbnailImage,
                                                 originFrame: originFrame, showRelated: showRelated, index: index)
        tabNavigator?.openProduct(data, source: productVisitSource)
    }
    
    func vmProcessReceivedProductPage(products: [ProductCellModel], page: UInt) -> [ProductCellModel] {
        guard searchType == nil else { return products }
        guard products.count > bannerCellPosition else { return products }
        var cellModels = products
        if !collections.isEmpty && productListRequester.countryCode == "US" {
            let collectionType = collections[Int(page) % collections.count]
            let collectionModel = ProductCellModel.CollectionCell(type: collectionType)
            cellModels.insert(collectionModel, atIndex: bannerCellPosition)
        }
        return cellModels
    }

    func vmDidSelectCollection(type: CollectionCellType){
        tracker.trackEvent(TrackerEvent.exploreCollection(type.rawValue))
        var query: String
        switch type {
        case .You:
            query = keyValueStorage[.lastSearches].reverse().joinWithSeparator(" ")
        case .Apple, .Furniture, .Gaming, .Transport:
            guard let searchText =  type.searchTextUS else { return }
            query =  searchText
        }
        delegate?.vmDidSearch(viewModelForSearch(.Collection(type: type, query: query)))
    }
    
    func vmUserDidTapInvite() {
        tabNavigator?.openAppInvite()
    }
}


// MARK: - Session & Location handling

extension MainProductsViewModel {
    private func setupSessionAndLocation() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(sessionDidChange),
                                                         name: SessionNotification.Login.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(sessionDidChange),
                                                         name: SessionNotification.Logout.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(locationDidChange),
                                                         
                                                         name: LocationNotification.LocationUpdate.rawValue, object: nil)
    }

    dynamic private func sessionDidChange() {
        guard listViewModel.canRetrieveProducts else {
            shouldRetryLoad = true
            return
        }
        listViewModel.retrieveProducts()
    }

    dynamic private func locationDidChange() {
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

    private func retrieveProductsIfNeededWithNewLocation(newLocation: LGLocation) {

        var shouldUpdate = false
        if listViewModel.canRetrieveProducts {
            // If there are no products, then refresh
            if listViewModel.numberOfProducts == 0 {
                shouldUpdate = true
            }
            // If new location is manual OR last location was manual, and location has changed then refresh
            else if newLocation.type == .Manual || lastReceivedLocation?.type == .Manual {
                if let lastReceivedLocation = lastReceivedLocation where newLocation != lastReceivedLocation {
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

    func trendingSearchAtIndex(index: Int) -> String? {
        guard  0..<trendingSearches.value.count ~= index else { return nil }
        return trendingSearches.value[index]
    }
    
    func lastSearchAtIndex(index: Int) -> String? {
        guard 0..<lastSearches.value.count ~= index else { return nil }
        return lastSearches.value[index]
    }

    func selectedTrendingSearchAtIndex(index: Int) {
        guard let trendingSearch = trendingSearchAtIndex(index) where !trendingSearch.isEmpty else { return }
        delegate?.vmDidSearch(viewModelForSearch(.Trending(query: trendingSearch)))
    }
    
    func selectedLastSearchAtIndex(index: Int) {
        guard let lastSearch = lastSearchAtIndex(index) where !lastSearch.isEmpty else { return }
        delegate?.vmDidSearch(viewModelForSearch(.LastSearch(query: lastSearch)))
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
        lastSearches.value = searchesToShow.reverse()
    }

    private func retrieveTrendingSearches() {
        guard let currentCountryCode = locationManager.currentPostalAddress?.countryCode else { return }

        trendingSearchesRepository.index(currentCountryCode) { [weak self] result in
            self?.trendingSearches.value = result.value ?? []
        }
    }
    
    private func updateLastSearchStoraged(query: String) {
        // We save up to lastSearchesSavedMaximum(10)
        var searchesSaved = keyValueStorage[.lastSearches]
        // Check if already exists and move to front.
        if let index = searchesSaved.indexOf(query) {
            searchesSaved.removeAtIndex(index)
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updatePermissionsWarning),
                         name: PushManager.Notification.DidRegisterUserNotificationSettings.rawValue, object: nil)
    }

    private dynamic func updatePermissionsWarning() {
        var currentHeader = mainProductsHeader.value
        if UIApplication.sharedApplication().areRemoteNotificationsEnabled {
            currentHeader.remove(MainProductsHeader.PushPermissions)
        } else {
            currentHeader.insert(MainProductsHeader.PushPermissions)
        }
        mainProductsHeader.value = currentHeader
    }

    private func openPushPermissionsAlert() {
        trackPushPermissionStart()
        let positive = UIAction(interface: .StyledText(LGLocalizedString.profilePermissionsAlertOk, .Default),
                                action: { [weak self] in
                                    self?.trackPushPermissionComplete()
                                    PushPermissionsManager.sharedInstance.showPushPermissionsAlert(prePermissionType: .ProductListBanner)
            },
                                accessibilityId: .UserPushPermissionOK)
        let negative = UIAction(interface: .StyledText(LGLocalizedString.profilePermissionsAlertCancel, .Cancel),
                                action: { [weak self] in
                                    self?.trackPushPermissionCancel()
            },
                                accessibilityId: .UserPushPermissionCancel)
        delegate?.vmShowAlertWithTitle(LGLocalizedString.profilePermissionsAlertTitle,
                                       text: LGLocalizedString.profilePermissionsAlertMessage,
                                       alertType: .IconAlert(icon: UIImage(named: "custom_permission_profile")),
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


// MARK: - Tracking

private extension MainProductsViewModel {

    var productVisitSource: EventParameterProductVisitSource {
        if let searchType = searchType {
            switch searchType {
            case .Collection:
                return .Collection
            case .User, .Trending, .LastSearch:
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

    func trackRequestSuccess(page page: UInt, hasProducts: Bool) {
        guard page == 0 else { return }

        let trackerEvent = TrackerEvent.productList(myUserRepository.myUser,
                                                    categories: productListRequester.filters?.selectedCategories,
                                                    searchQuery: productListRequester.queryString)
        tracker.trackEvent(trackerEvent)

        if let searchType = searchType where shouldTrackSearch && filters.isDefault() {
            shouldTrackSearch = false
            tracker.trackEvent(TrackerEvent.searchComplete(myUserRepository.myUser, searchQuery: searchType.query,
                                                           isTrending: searchType.isTrending,
                                                           success: hasProducts ? .Success : .Failed, isLastSearch: searchType.isLastSearch))
        }
    }

    private func trackPushPermissionStart() {
        let goToSettings: EventParameterPermissionGoToSettings =
            PushPermissionsManager.sharedInstance.pushPermissionsSettingsMode ? .True : .NotAvailable
        let trackerEvent = TrackerEvent.permissionAlertStart(.Push, typePage: .ProductListBanner, alertType: .Custom,
                                                             permissionGoToSettings: goToSettings)
        tracker.trackEvent(trackerEvent)
    }

    private func trackPushPermissionComplete() {
        let goToSettings: EventParameterPermissionGoToSettings =
            PushPermissionsManager.sharedInstance.pushPermissionsSettingsMode ? .True : .NotAvailable
        let trackerEvent = TrackerEvent.permissionAlertComplete(.Push, typePage: .ProductListBanner, alertType: .Custom,
                                                                permissionGoToSettings: goToSettings)
        tracker.trackEvent(trackerEvent)
    }

    private func trackPushPermissionCancel() {
        let goToSettings: EventParameterPermissionGoToSettings =
            PushPermissionsManager.sharedInstance.pushPermissionsSettingsMode ? .True : .NotAvailable
        let trackerEvent = TrackerEvent.permissionAlertCancel(.Push, typePage: .ProductListBanner, alertType: .Custom,
                                                              permissionGoToSettings: goToSettings)
        tracker.trackEvent(trackerEvent)
    }
}
