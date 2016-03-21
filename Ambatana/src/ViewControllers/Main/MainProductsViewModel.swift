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

protocol MainProductsViewModelDelegate: class {
    func mainProductsViewModel(viewModel: MainProductsViewModel,
        didSearchWithViewModel searchViewModel: MainProductsViewModel)
    func mainProductsViewModel(viewModel: MainProductsViewModel, showFilterWithViewModel filtersVM: FiltersViewModel)
    func mainProductsViewModel(viewModel: MainProductsViewModel, showTags: [FilterTag])
    func mainProductsViewModelRefresh(viewModel: MainProductsViewModel)
}

protocol InfoBubbleDelegate: class {
    func mainProductsViewModel(mainProductsViewModel: MainProductsViewModel, updatedBubbleInfoString: String)
    func mainProductsViewModel(mainProductsViewModel: MainProductsViewModel, shouldHideBubble hidden: Bool)
}

protocol PermissionsDelegate: class {
    func mainProductsViewModelShowPushPermissionsAlert(mainProductsViewModel: MainProductsViewModel)
}


public class MainProductsViewModel: BaseViewModel {
    
    // > Input
    public var searchString: String?
    public var filters: ProductFilters
    
    public var infoBubblePresent: Bool {
        guard let selectedOrdering = filters.selectedOrdering else { return true }
        switch (selectedOrdering) {
        case .Distance, .Creation:
            return true
        case .PriceAsc, .PriceDesc:
            return false
        }
    }

    public let infoBubbleDefaultText =  LGLocalizedString.productPopularNearYou
    
    public var tags: [FilterTag] {
        
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
        return resultTags
    }
    
    // Manager & repositories
    private let myUserRepository: MyUserRepository
    private let tracker: Tracker

    // Constants
    private static let maxMonthsAgo = 3
    
    // > Delegate
    weak var delegate: MainProductsViewModelDelegate?
    weak var bubbleDelegate: InfoBubbleDelegate?
    weak var permissionsDelegate: PermissionsDelegate?

    // Search tracking state
    private var shouldTrackSearch = false
    
    // MARK: - Lifecycle
    
    public init(myUserRepository: MyUserRepository, tracker: Tracker, searchString: String? = nil,
        filters: ProductFilters) {
            self.myUserRepository = myUserRepository
            self.tracker = tracker
            self.searchString = searchString
            self.filters = filters
            if let search = searchString where !search.isEmpty {
                self.shouldTrackSearch = true
            }
            super.init()
    }
    
    public convenience init(searchString: String? = nil, filters: ProductFilters) {
        let myUserRepository = Core.myUserRepository
        let tracker = TrackerProxy.sharedInstance
        self.init(myUserRepository: myUserRepository, tracker: tracker, searchString: searchString, filters: filters)
    }
    
    public convenience init(searchString: String? = nil) {
        let filters = ProductFilters()
        self.init(searchString: searchString, filters: filters)
    }
    
    
    // MARK: - Public methods
    
    /**
        Search action.
    */
    public func search() {
        if let actualSearchString = searchString {
            if actualSearchString.characters.count > 0 {
                delegate?.mainProductsViewModel(self, didSearchWithViewModel: viewModelForSearch())
            }
        }
    }

    public func productListViewDidSucceedRetrievingProductsForPage(page: UInt, hasProducts: Bool) {
        // Should track search-complete only for the first page and only the first time
        guard let actualSearchString = searchString where shouldTrackSearch && page == 0 && filters.isDefault()
            else { return }
        shouldTrackSearch = false
        tracker.trackEvent(TrackerEvent.searchComplete(myUserRepository.myUser, searchQuery: actualSearchString,
            success: hasProducts ? .Success : .Failed))
    }

    public func showFilters() {

        let filtersVM = FiltersViewModel(currentFilters: filters ?? ProductFilters())
        filtersVM.dataDelegate = self
        
        delegate?.mainProductsViewModel(self, showFilterWithViewModel: filtersVM)
        
        // Tracking
        tracker.trackEvent(TrackerEvent.filterStart())
    }

    public func shareDelegateForProduct(product: Product) -> MainProductsViewModelShareDelegate? {
        return MainProductsViewModelShareDelegate(product: product, myUser: myUserRepository.myUser)
    }

    public func chatViewModelForProduct(product: Product) -> ChatViewModel? {
        guard let chatVM = ChatViewModel(product: product) else { return nil }
        chatVM.askQuestion = .ProductList
        return chatVM
    }
    
    /**
        Called when search button is pressed.
    */
    public func searchBegan() {
        // Tracking
        tracker.trackEvent(TrackerEvent.searchStart(myUserRepository.myUser))
    }
    
    /**
        Called when a filter gets removed
    */
    public func updateFiltersFromTags(tags: [FilterTag]) {

        var place: Place? = nil
        var categories: [ProductCategory] = []
        var orderBy = ProductSortCriteria.defaultOption
        var within = ProductTimeCriteria.defaultOption
        
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
            }
        }

        filters.place = place
        filters.selectedCategories = categories
        filters.selectedOrdering = orderBy
        filters.selectedWithin = within
        
        updateListView()
    }


    // MARK: - Private methods
    
    /**
        Returns a view model for search.
    
        - returns: A view model for search.
    */
    private func viewModelForSearch() -> MainProductsViewModel {
        return MainProductsViewModel(searchString: searchString, filters: filters)
    }
    
    private func updateListView() {
        if filters.selectedOrdering == ProductSortCriteria.defaultOption {
            bubbleDelegate?.mainProductsViewModel(self, updatedBubbleInfoString: LGLocalizedString.productPopularNearYou)
        }

        delegate?.mainProductsViewModelRefresh(self)
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
    
    private func bubbleInfoTextForDate(date: NSDate) -> String {
        
        let time = date.timeIntervalSince1970
        let now = NSDate().timeIntervalSince1970

        let seconds = Float(now - time)

        let second: Float = 1
        let minute: Float = 60.0
        let hour: Float = minute * 60.0
        let hourEnd: Float = hour + hour/2 + 1
        let day: Float = hour * 24.0
        let dayEnd: Float = day + day/2 + 1
        let month: Float = day * 30.0
        let monthEnd: Float = month + month/2 + 1

        let minsAgo = round(seconds/minute)
        let hoursAgo = round(seconds/hour)
        let daysAgo = round(seconds/day)
        let monthsAgo = round(seconds/month)

        switch seconds {
        case second..<minute, minute:
            return LGLocalizedString.productDateOneMinuteAgo
        case minute..<hour:
            return String(format: LGLocalizedString.productDateXMinutesAgo, Int(minsAgo))
        case hour..<hourEnd:
            return LGLocalizedString.productDateOneHourAgo
        case hourEnd..<day:
            return String(format: LGLocalizedString.productDateXHoursAgo, Int(hoursAgo))
        case day..<dayEnd:
            return LGLocalizedString.productDateOneDayAgo
        case dayEnd..<month:
            return String(format: LGLocalizedString.productDateXDaysAgo, Int(daysAgo))
        case month..<monthEnd:
            return LGLocalizedString.productDateOneMonthAgo
        case monthEnd..<month*Float(MainProductsViewModel.maxMonthsAgo):
            return String(format: LGLocalizedString.productDateXMonthsAgo, Int(monthsAgo))
        default:
            return String(format: LGLocalizedString.productDateMoreThanXMonthsAgo, MainProductsViewModel.maxMonthsAgo)
        }
    }
}


// MARK: - FiltersViewModelDataDelegate

extension MainProductsViewModel: FiltersViewModelDataDelegate {

    func viewModelDidUpdateFilters(viewModel: FiltersViewModel, filters: ProductFilters) {
        self.filters = filters
        delegate?.mainProductsViewModel(self, showTags: self.tags)
        updateListView()
    }
}


// MARK: - TopProductInfoDelegate

extension MainProductsViewModel: TopProductInfoDelegate {

    /**
    Called on every distance change to get the info to set on the bubble

    - Parameter productListViewModel: the productListViewModel who called its delegate
    - Parameter distanceForTopProduct: the distance of the upmost product in the list
    */
    public func productListViewModel(productListViewModel: ProductListViewModel, distanceForTopProduct distance: Int) {
        let distanceString = bubbleInfoTextForDistance(distance, type: DistanceType.systemDistanceType())
        bubbleDelegate?.mainProductsViewModel(self, updatedBubbleInfoString: distanceString)
    }

    /**
    Called on every "createdAt" date change to get the info to set on the bubble

    - Parameter productListViewModel: the productListViewModel who called its delegate
    - Parameter dateForTopProduct: the creation date of the upmost product in the list
    */
    public func productListViewModel(productListViewModel: ProductListViewModel, dateForTopProduct date: NSDate) {
        bubbleDelegate?.mainProductsViewModel(self, updatedBubbleInfoString: LGLocalizedString.productPopularNearYou)
    }

    /**
    Called when the products list is pulling to refresh

    - Parameter productListViewModel: the productListViewModel who called its delegate
    - Parameter pullToRefreshInProggress: whether or not the pull to refresh is in progress
    */
    public func productListViewModel(productListViewModel: ProductListViewModel,
        pullToRefreshInProggress refreshing: Bool) {
            bubbleDelegate?.mainProductsViewModel(self, shouldHideBubble: refreshing)
    }

    public func productListViewModel(productListViewModel: ProductListViewModel, showingItemAtIndex index: Int) {

        guard index == Constants.itemIndexPushPermissionsTrigger else { return }
        permissionsDelegate?.mainProductsViewModelShowPushPermissionsAlert(self)
    }
}


//MARK: - NativeShareDelegate

public class MainProductsViewModelShareDelegate: NativeShareDelegate {

    let sharingProduct: Product
    var shareText: String {
        return SocialHelper.socialMessageWithTitle(LGLocalizedString.productShareBody,
            product: sharingProduct).shareText
    }

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
