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
     func mainProductSViewModel(viewMode: MainProductsViewModel, showShare shareText: String,
        delegate: NativeShareDelegate)
    func mainProductSViewModel(viewMode: MainProductsViewModel, showChatWithViewModel chatVM: ChatViewModel)
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
    public var filters : ProductFilters
    
    public var infoBubblePresent : Bool {
        switch (filters.selectedOrdering) {
        case .Distance, .Creation:
            return true
        case .PriceAsc, .PriceDesc:
            return false
        }
    }
    
    public var tags: [FilterTag] {
        
        var resultTags : [FilterTag] = []
        for prodCat in filters.selectedCategories {
            resultTags.append(.Category(prodCat))
        }
        
        if(filters.selectedWithin != ProductTimeCriteria.defaultOption) {
            resultTags.append(.Within(filters.selectedWithin))
        }
        
        if(filters.selectedOrdering != ProductSortCriteria.defaultOption) {
            resultTags.append(.OrderBy(filters.selectedOrdering))
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
    
    // MARK: - Lifecycle
    
    public init(myUserRepository: MyUserRepository, tracker: Tracker, searchString: String? = nil,
        filters: ProductFilters) {
            self.myUserRepository = myUserRepository
            self.tracker = tracker
            self.searchString = searchString
            self.filters = filters
            
            super.init()
    }
    
    public convenience init(searchString: String? = nil, filters: ProductFilters) {
        let myUserRepository = MyUserRepository.sharedInstance
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
                
                // Tracking
                tracker.trackEvent(TrackerEvent.searchComplete(myUserRepository.myUser, searchQuery: searchString ?? ""))
                
                // Notify the delegate
                delegate?.mainProductsViewModel(self, didSearchWithViewModel: viewModelForSearch())
            }
        }
    }
    
    public func showFilters() {

        let filtersVM = FiltersViewModel(currentFilters: filters ?? ProductFilters())
        filtersVM.dataDelegate = self
        
        delegate?.mainProductsViewModel(self, showFilterWithViewModel: filtersVM)
        
        // Tracking
        tracker.trackEvent(TrackerEvent.filterStart())
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
        
        var categories : [ProductCategory] = []
        var orderBy = ProductSortCriteria.defaultOption
        var within = ProductTimeCriteria.defaultOption
        
        for filterTag in tags {
            switch filterTag {
            case .Category(let prodCategory):
                categories.append(prodCategory)
            case .OrderBy(let prodSortOption):
                orderBy = prodSortOption
            case .Within(let prodTimeOption):
                within = prodTimeOption
            }
        }
        
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
    - Parameter dateForTopProduct: the creation date of the upmost product in the list
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


// MARK: - ProductListActionsDelegate

extension MainProductsViewModel: ProductListActionsDelegate {
    public func productListViewModel(productListViewModel: ProductListViewModel,
        didTapChatOnProduct product: Product) {
            guard let myUser = myUserRepository.myUser else { return }
            // Retrieve the chat
            //TODO SHOW LOADING??
            ChatManager.sharedInstance.retrieveChatWithProduct(product, buyer: myUser) { [weak self] retrieveResult in
                guard let strongSelf = self else { return }

                if let chat = retrieveResult.value, let viewModel = ChatViewModel(chat: chat) {
                    //TODO CHANGE BY ANOTHER SOURCE
                    viewModel.askQuestion = true
                    strongSelf.delegate?.mainProductSViewModel(strongSelf, showChatWithViewModel: viewModel)
                }
                else if let error = retrieveResult.error where error == .NotFound {
                    //TODO CHANGE BY ANOTHER SOURCE
                    if let viewModel = ChatViewModel(product: product, askQuestion: true) {
                        strongSelf.delegate?.mainProductSViewModel(strongSelf, showChatWithViewModel: viewModel)
                    }
                }
            }
    }

    public func productListViewModel(productListViewModel: ProductListViewModel,
        didTapShareOnProduct product: Product) {
            let socialMessage = SocialHelper.socialMessageWithTitle(LGLocalizedString.productShareBody, product: product)
            delegate?.mainProductSViewModel(self, showShare: socialMessage.shareText, delegate: self)
    }
}


//MARK: - NativeShareDelegate

extension MainProductsViewModel: NativeShareDelegate {
    func nativeShareInFacebook() {

    }

    func nativeShareInTwitter() {

    }

    func nativeShareInEmail() {

    }

    func nativeShareInWhatsApp() {

    }
}
