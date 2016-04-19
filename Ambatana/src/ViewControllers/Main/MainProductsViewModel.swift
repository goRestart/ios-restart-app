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

protocol MainProductsViewModelDelegate: BaseViewModelDelegate {
    func mainProductsViewModel(viewModel: MainProductsViewModel,
        didSearchWithViewModel searchViewModel: MainProductsViewModel)
    func mainProductsViewModel(viewModel: MainProductsViewModel, showFilterWithViewModel filtersVM: FiltersViewModel)
    func mainProductsViewModel(viewModel: MainProductsViewModel, showTags: [FilterTag])
    func vmDidFailRetrievingProducts(hasProducts hasProducts: Bool, error: String?)
    func vmDidSuceedRetrievingProducts(hasProducts hasProducts: Bool, isFirstPage: Bool)
    func vmShowProduct(productViewModel viewModel: ProductViewModel)
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

    // List VM
    var productListRequester: MainProductListRequester
    var listViewModel: MainProductListViewModel
    private var bubbleDistance: Float = 1

    // Search tracking state
    private var shouldTrackSearch = false
    
    // MARK: - Lifecycle
    
    public init(myUserRepository: MyUserRepository, tracker: Tracker, searchString: String? = nil,
                filters: ProductFilters) {
        self.myUserRepository = myUserRepository
        self.tracker = tracker
        self.searchString = searchString
        self.filters = filters
        self.productListRequester = MainProductListRequester()
        self.listViewModel = MainProductListViewModel(requester: self.productListRequester)
        if let search = searchString where !search.isEmpty {
            self.shouldTrackSearch = true
        }
        super.init()

        setup()
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

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
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

    private func setup() {
        listViewModel.dataDelegate = self
        applyProductFilters()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(sessionDidChange),
                                                         name: SessionManager.Notification.Login.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(sessionDidChange),
                                                         name: SessionManager.Notification.Logout.rawValue, object: nil)
    }

    private func applyProductFilters() {
        productListRequester.filters = filters
        productListRequester.queryString = searchString
    }

    dynamic private func sessionDidChange() {
        listViewModel.sessionDidChange()
    }
    
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

        applyProductFilters()
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


// MARK: - ProductListViewCellsDelegate 

extension MainProductsViewModel: ProductListViewCellsDelegate {
    public func visibleTopCellWithIndex(index: Int, whileScrollingDown scrollingDown: Bool) {
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

    public func visibleBottomCell(index: Int) {
        guard index == Constants.itemIndexPushPermissionsTrigger else { return }
        permissionsDelegate?.mainProductsViewModelShowPushPermissionsAlert(self)
    }

    public func pullingToRefresh(refreshing: Bool) {
        bubbleDelegate?.mainProductsViewModel(self, shouldHideBubble: refreshing)
    }
}


// MARK: - ProductListViewModelDataDelegate

extension MainProductsViewModel: ProductListViewModelDataDelegate {
    public func productListVM(viewModel: ProductListViewModel, didSucceedRetrievingProductsPage page: UInt,
                              hasProducts: Bool) {
        if page == 0 && !hasProducts {
            let errBgColor = UIColor(patternImage: UIImage(named: "pattern_white")!)
            let errBorderColor = StyleHelper.lineColor
            let errContainerColor: UIColor = StyleHelper.emptyViewContentBgColor
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

            listViewModel.state = .ErrorView(errBgColor: errBgColor, errBorderColor: errBorderColor,
                                                        errContainerColor: errContainerColor, errImage: errImage, errTitle: errTitle,
                                                        errBody: errBody, errButTitle: nil, errButAction: nil)
        }

        // Tracking
        let myUser = myUserRepository.myUser
        let trackerEvent = TrackerEvent.productList(myUser, categories: productListRequester.filters?.selectedCategories,
                                                    searchQuery: productListRequester.queryString, pageNumber: page)
        tracker.trackEvent(trackerEvent)

        listViewModel.didSucceedRetrievingProducts() //TODO: REMOVE WHEN CODE MOVED TO THIS VIEW MODEL
        delegate?.vmDidSuceedRetrievingProducts(hasProducts: hasProducts, isFirstPage: page == 0)
        if(page == 0) {
            bubbleDistance = 1
        }
    }

    public func productListMV(viewModel: ProductListViewModel, didFailRetrievingProductsPage page: UInt,
                              hasProducts: Bool, error: RepositoryError) {


        if page == 0 && !hasProducts {

            //Show error in listView

            let errContainerColor: UIColor = StyleHelper.emptyViewContentBgColor
            let errImage: UIImage?
            let errTitle: String
            let errBody: String
            let errButTitle: String
            switch error {
            case .Network:
                errImage = UIImage(named: "err_network")
                errTitle = LGLocalizedString.commonErrorTitle
                errBody = LGLocalizedString.commonErrorNetworkBody
                errButTitle = LGLocalizedString.commonErrorRetryButton
            case .Internal, .Unauthorized, .NotFound:
                errImage = UIImage(named: "err_generic")
                errTitle = LGLocalizedString.commonErrorTitle
                errBody = LGLocalizedString.commonErrorGenericBody
                errButTitle = LGLocalizedString.commonErrorRetryButton
            }
            let errBgColor = UIColor(patternImage: UIImage(named: "pattern_white")!)
            let errBorderColor = StyleHelper.lineColor

            let errButAction: () -> Void = { [weak self] in
                self?.listViewModel.refresh()
            }

            listViewModel.state = .ErrorView(errBgColor: errBgColor, errBorderColor: errBorderColor,
                                             errContainerColor: errContainerColor,errImage: errImage, errTitle: errTitle,
                                             errBody: errBody, errButTitle: errButTitle, errButAction: errButAction)
        }

        var errorString: String? = nil
        if hasProducts && page > 0 {
            switch error {
            case .Network:
                errorString = LGLocalizedString.toastNoNetwork
            case .Internal, .NotFound:
                errorString = LGLocalizedString.toastErrorInternal
            case .Unauthorized:
                errorString = nil
            }
        }
        delegate?.vmDidFailRetrievingProducts(hasProducts: hasProducts, error: errorString)
    }



    public func productListVM(viewModel: ProductListViewModel, didSelectItemAtIndex index: Int,
                              thumbnailImage: UIImage?) {
        guard let prodViewModel = listViewModel.productViewModelForProductAtIndex(index,
                                                                    thumbnailImage: thumbnailImage) else { return }
        delegate?.vmShowProduct(productViewModel: prodViewModel)
    }
}


//MARK: - NativeShareDelegate

public class MainProductsViewModelShareDelegate: NativeShareDelegate {

    let sharingProduct: Product
    var shareText: String {
        return SocialHelper.socialMessageWithTitle(LGLocalizedString.productShareBody,
            product: sharingProduct).nativeShareText
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
