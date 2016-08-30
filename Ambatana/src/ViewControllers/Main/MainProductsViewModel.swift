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
    func vmDidFailRetrievingProducts(hasProducts hasProducts: Bool, error: String?)
    func vmDidSuceedRetrievingProducts(hasProducts hasProducts: Bool, isFirstPage: Bool)
}

protocol InfoBubbleDelegate: class {
    func mainProductsViewModel(mainProductsViewModel: MainProductsViewModel, updatedBubbleInfoString: String)
    func mainProductsViewModel(mainProductsViewModel: MainProductsViewModel, shouldHideBubble hidden: Bool)
}

protocol PermissionsDelegate: class {
    func mainProductsViewModelShowPushPermissionsAlert(mainProductsViewModel: MainProductsViewModel)
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
        case .User, .Trending:
            return false
        }
    }
    let bannerCellPosition: Int = 8
    var filters: ProductFilters
    
    var infoBubblePresent: Bool {
        guard let selectedOrdering = filters.selectedOrdering else { return true }
        switch (selectedOrdering) {
        case .Distance, .Creation:
            return true
        case .PriceAsc, .PriceDesc:
            return false
        }
    }

    let infoBubbleDefaultText =  LGLocalizedString.productPopularNearYou
    
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
        if filters.minPrice != nil || filters.maxPrice != nil {
            var currency: Currency? = nil
            if let countryCode = Core.locationManager.currentPostalAddress?.countryCode {
                currency = Core.currencyHelper.currencyWithCountryCode(countryCode)
            }
            resultTags.append(.PriceRange(from: filters.minPrice, to: filters.maxPrice, currency: currency))
        }

        return resultTags
    }
    
    // Manager & repositories
    private let myUserRepository: MyUserRepository
    private let trendingSearchesRepository: TrendingSearchesRepository
    private let locationManager: LocationManager

    private let tracker: Tracker
    private let searchType: SearchType? // The initial search
    private let collections: [CollectionCellType]
    
    // > Delegate
    weak var delegate: MainProductsViewModelDelegate?
    weak var bubbleDelegate: InfoBubbleDelegate?
    weak var permissionsDelegate: PermissionsDelegate?

    // > Navigator
    weak var tabNavigator: TabNavigator?
    
    // List VM
    let listViewModel: ProductListViewModel
    private var productListRequester: FilteredProductListRequester
    private var shouldRetryLoad = false
    private var lastReceivedLocation: LGLocation?
    private var bubbleDistance: Float = 1

    // Search tracking state
    private var shouldTrackSearch = false

    // Trending searches
    let trendingSearches = Variable<[String]?>(nil)
    
    // MARK: - Lifecycle
    
    init(myUserRepository: MyUserRepository, trendingSearchesRepository: TrendingSearchesRepository,
         locationManager: LocationManager, tracker: Tracker, searchType: SearchType? = nil, filters: ProductFilters,
         tabNavigator: TabNavigator?) {
        self.myUserRepository = myUserRepository
        self.trendingSearchesRepository = trendingSearchesRepository
        self.locationManager = locationManager
        self.tracker = tracker
        self.searchType = searchType
        self.filters = filters
        self.tabNavigator = tabNavigator
        self.collections = CollectionCellType.allValues.shuffle()
        self.productListRequester = FilteredProductListRequester()
        let show3Columns = DeviceFamily.isWideScreen
        let columns = show3Columns ? 3 : 2
        self.listViewModel = ProductListViewModel(requester: self.productListRequester, products: nil,
                                                  numberOfColumns: columns)
        self.listViewModel.productListFixedInset = show3Columns ? 6 : 10
        
        if let search = searchType where !search.query.isEmpty {
            self.shouldTrackSearch = true
        }
        super.init()

        setup()
    }
    
    convenience init(searchType: SearchType? = nil, filters: ProductFilters, tabNavigator: TabNavigator?) {
        let myUserRepository = Core.myUserRepository
        let trendingSearchesRepository = Core.trendingSearchesRepository
        let locationManager = Core.locationManager
        let tracker = TrackerProxy.sharedInstance
        self.init(myUserRepository: myUserRepository, trendingSearchesRepository: trendingSearchesRepository,
                  locationManager: locationManager, tracker: tracker, searchType: searchType, filters: filters,
                  tabNavigator: tabNavigator)
    }
    
    convenience init(searchType: SearchType? = nil, tabNavigator: TabNavigator?) {
        let filters = ProductFilters()
        self.init(searchType: searchType, filters: filters, tabNavigator: tabNavigator)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didBecomeActive(firstTime: Bool) {
        guard let currentLocation = locationManager.currentLocation else { return }
        retrieveProductsIfNeededWithNewLocation(currentLocation)
        retrieveTrendingSearches()
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

    func shareDelegateForProduct(product: Product) -> MainProductsViewModelShareDelegate? {
        return MainProductsViewModelShareDelegate(product: product, myUser: myUserRepository.myUser)
    }

    func chatViewModelForProduct(product: Product) -> OldChatViewModel? {
        guard let chatVM = OldChatViewModel(product: product, tabNavigator: tabNavigator) else { return nil }
        chatVM.askQuestion = .ProductList
        return chatVM
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
        var categories: [ProductCategory] = []
        var orderBy = ProductSortCriteria.defaultOption
        var within = ProductTimeCriteria.defaultOption
        var minPrice: Int? = nil
        var maxPrice: Int? = nil

        for filterTag in tags {
            switch filterTag {
            case .Location(let thePlace):
                place = thePlace
            case .Category(let prodCategory):
                categories.append(prodCategory)
            case .OrderBy(let prodSortOption):
                orderBy = prodSortOption
            case .Within(let prodTimeOption):
                within = prodTimeOption
            case .PriceRange(let minPriceOption, let maxPriceOption, _):
                minPrice = minPriceOption
                maxPrice = maxPriceOption
            }
        }

        filters.place = place
        filters.selectedCategories = categories
        filters.selectedOrdering = orderBy
        filters.selectedWithin = within
        filters.minPrice = minPrice
        filters.maxPrice = maxPrice

        updateListView()
    }


    // MARK: - Private methods

    private func setup() {
        listViewModel.dataDelegate = self
        productListRequester.filters = filters
        productListRequester.queryString = searchType?.query

        setupSessionAndLocation()
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
            bubbleDelegate?.mainProductsViewModel(self, updatedBubbleInfoString: LGLocalizedString.productPopularNearYou)
        }

        productListRequester.filters = filters
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
            bubbleDelegate?.mainProductsViewModel(self, updatedBubbleInfoString: distanceString)
        case .Creation:
            bubbleDelegate?.mainProductsViewModel(self, updatedBubbleInfoString: LGLocalizedString.productPopularNearYou)
        case .PriceAsc, .PriceDesc:
            break
        }
    }

    func visibleBottomCell(index: Int) {
        guard index == Constants.itemIndexPushPermissionsTrigger else { return }
        permissionsDelegate?.mainProductsViewModelShowPushPermissionsAlert(self)
    }

    func pullingToRefresh(refreshing: Bool) {
        bubbleDelegate?.mainProductsViewModel(self, shouldHideBubble: refreshing)
    }
}


// MARK: - ProductListViewModelDataDelegate

extension MainProductsViewModel: ProductListViewModelDataDelegate {
    func productListVM(viewModel: ProductListViewModel, didSucceedRetrievingProductsPage page: UInt,
                              hasProducts: Bool) {

        trackRequestSuccess(page: page, hasProducts: hasProducts)

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

        delegate?.vmDidSuceedRetrievingProducts(hasProducts: hasProducts, isFirstPage: page == 0)
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
            case .Internal, .NotFound, .Forbidden, .TooManyRequests, .UserNotVerified:
                errorString = LGLocalizedString.toastErrorInternal
            case .Unauthorized:
                errorString = nil
            }
        }
        delegate?.vmDidFailRetrievingProducts(hasProducts: hasProducts, error: errorString)
    }

    func productListVM(viewModel: ProductListViewModel, didSelectItemAtIndex index: Int,
                       thumbnailImage: UIImage?, originFrame: CGRect?) {
        
        guard let product = viewModel.productAtIndex(index) else { return }
        let cellModels = viewModel.objects
        let data = ProductDetailData.ProductList(product: product, cellModels: cellModels,
                                                 requester: productListRequester, thumbnailImage: thumbnailImage,
                                                 originFrame: originFrame,
                                                 showRelated: FeatureFlags.showRelatedProducts)
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
        delegate?.vmDidSearch(viewModelForSearch(.Collection(type: type)))
    }
    
    func vmUserDidTapInvite() {
        tabNavigator?.openAppInvite()
    }
}


// MARK: - Session & Location handling

extension MainProductsViewModel {
    private func setupSessionAndLocation() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(sessionDidChange),
                                                         name: SessionManager.Notification.Login.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(sessionDidChange),
                                                         name: SessionManager.Notification.Logout.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(locationDidChange),
                                                         
                                                         name: LocationManager.Notification.LocationUpdate.rawValue, object: nil)
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

        if shouldUpdate{
            listViewModel.retrieveProducts()
        }

        // Track the received location
        lastReceivedLocation = newLocation
    }
}


// MARK: - Trending searches

extension MainProductsViewModel {

    func trendingSearchAtIndex(index: Int) -> String? {
        guard let trendings = trendingSearches.value where 0..<trendings.count ~= index else { return nil }
        return trendings[index]
    }

    func selectedTrendingSearchAtIndex(index: Int) {
        guard let trendingSearch = trendingSearchAtIndex(index) where !trendingSearch.isEmpty else { return }
        delegate?.vmDidSearch(viewModelForSearch(.Trending(query: trendingSearch)))
    }

    private func retrieveTrendingSearches() {
        guard let currentCountryCode = locationManager.currentPostalAddress?.countryCode else { return }

        trendingSearchesRepository.index(currentCountryCode) { [weak self] result in
            self?.trendingSearches.value = result.value
        }
    }
}


// MARK: - Rating Banner

extension MainProductsViewModel {
    func appRatingBannerClose() {
        RatingManager.sharedInstance.userDidCloseProductListBanner()        
        listViewModel.reloadData()
    }
}


// MARK: - Tracking

private extension MainProductsViewModel {

    var productVisitSource: EventParameterProductVisitSource {
        if let searchType = searchType {
            switch searchType {
            case .Collection:
                return .Collection
            case .User, .Trending:
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
                isTrending: searchType.isTrending, success: hasProducts ? .Success : .Failed))
        }
    }
}


// MARK: - NativeShareDelegate

public class MainProductsViewModelShareDelegate: NativeShareDelegate {

    let sharingProduct: Product

    init(product: Product, myUser: MyUser?) {
        self.sharingProduct = product
    }

    func nativeShareInFacebook() {
        let trackerEvent = TrackerEvent.productShare(sharingProduct, network: .Facebook,
            buttonPosition: .None, typePage: .ProductList)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }

    func nativeShareInTwitter() {
        let trackerEvent = TrackerEvent.productShare(sharingProduct, network: .Twitter,
            buttonPosition: .None, typePage: .ProductList)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }

    func nativeShareInEmail() {
        let trackerEvent = TrackerEvent.productShare(sharingProduct, network: .Email,
            buttonPosition: .None, typePage: .ProductList)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }

    func nativeShareInWhatsApp() {
        let trackerEvent = TrackerEvent.productShare(sharingProduct, network: .Whatsapp,
            buttonPosition: .None, typePage: .ProductList)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
}
