//
//  ProductListViewModel.swift
//  LetGo
//
//  Created by AHL on 9/7/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import CoreLocation
import Curry
import LGCoreKit
import Result

public protocol ProductListViewModelDelegate: class {
    func vmRefresh()
    func vmReloadData()
    func vmDidUpdateState(state: ProductListViewState)
    func vmDidStartRetrievingProductsPage(page: UInt)
    func vmDidFailRetrievingProductsPage(page: UInt, hasProducts: Bool, error: RepositoryError)
    func vmDidSucceedRetrievingProductsPage(page: UInt, hasProducts: Bool, atIndexPaths indexPaths: [NSIndexPath])
    func vmDidUpdateProductDataAtIndex(index: Int)
}

public protocol ProductListViewModelDataDelegate: class {
    func productListMV(viewModel: ProductListViewModel, didFailRetrievingProductsPage page: UInt, hasProducts: Bool,
                         error: RepositoryError)
    func productListVM(viewModel: ProductListViewModel, didSucceedRetrievingProductsPage page: UInt, hasProducts: Bool)
    func productListVM(viewModel: ProductListViewModel, didSelectItemAtIndex index: Int, thumbnailImage: UIImage?)
}

public protocol TopProductInfoDelegate: class {
    func productListViewModel(productListViewModel: ProductListViewModel, dateForTopProduct date: NSDate)
    func productListViewModel(productListViewModel: ProductListViewModel, distanceForTopProduct distance: Int)
    func productListViewModel(productListViewModel: ProductListViewModel, pullToRefreshInProggress refreshing: Bool)
    func productListViewModel(productListViewModel: ProductListViewModel, showingItemAtIndex index: Int)
}

public protocol ProductListActionsDelegate: class {
    func productListViewModel(productListViewModel: ProductListViewModel,
        requiresLoginWithSource source: EventParameterLoginSourceValue, completion: () -> Void)
    func productListViewModel(productListViewModel: ProductListViewModel, didTapChatOnProduct product: Product)
    func productListViewModel(productListViewModel: ProductListViewModel, didTapShareOnProduct product: Product)
}

public enum ProductListViewState {
    case FirstLoadView
    case DataView
    case ErrorView(errBgColor: UIColor?, errBorderColor: UIColor?, errContainerColor: UIColor?, errImage: UIImage?,
        errTitle: String?, errBody: String?, errButTitle: String?, errButAction: (() -> Void)?)
}

protocol ProductListRequester: class {
    func productsRetrieval(offset offset: Int, completion: ProductsCompletion?)
    func isLastPage(resultCount: Int) -> Bool
}

public class ProductListViewModel: BaseViewModel {
    
    // MARK: - Constants
    private static let columnCount: CGFloat = 2.0
    
    private static let cellMinHeight: CGFloat = 160.0
    private static let cellAspectRatio: CGFloat = 198.0 / cellMinHeight
    private static let cellMaxThumbFactor: CGFloat = 2.0
    private static let cellWidth: CGFloat = (UIScreen.mainScreen().bounds.size.width - (Constants.productListFixedInsets*2)) / columnCount
    
    private static let itemsPagingThresholdPercentage: Float = 0.7    // when we should start ask for a new page
    
    
    // MARK: - iVars
    
    // Input (query)
    public var queryString: String?
    public var place: Place?

    var queryCoordinates: LGLocationCoordinates2D? {
        if let coordinates = place?.location {
            return coordinates
        } else if let currentLocation = locationManager.currentLocation {
            return LGLocationCoordinates2D(location: currentLocation)
        }
        return nil
    }
    var countryCode: String? {
        if let countryCode = place?.postalAddress?.countryCode {
            return countryCode
        }
        return locationManager.currentPostalAddress?.countryCode
    }
    public var categories: [ProductCategory]?
    public var timeCriteria: ProductTimeCriteria?
    public var sortCriteria: ProductSortCriteria?
    public var statuses: [ProductStatus]?
    public var maxPrice: Int?
    public var minPrice: Int?
    public var userObjectId: String?
    public var distanceType: DistanceType?
    public var distanceRadius: Int?
    
    // Delegates
    public weak var delegate: ProductListViewModelDelegate?
    public weak var dataDelegate: ProductListViewModelDataDelegate?
    public weak var topProductInfoDelegate: TopProductInfoDelegate?
    public weak var actionsDelegate: ProductListActionsDelegate?
    
    // Requester & Repositories
    private weak var productListRequester: ProductListRequester? //weak var to avoid retain cycles
    private let locationManager: LocationManager
    private let productRepository: ProductRepository
    private let myUserRepository: MyUserRepository
    
    // Data
    private var products: [Product]
    public private(set) var pageNumber: UInt
    private var maxDistance: Float
    public var refreshing: Bool
    var state: ProductListViewState {
        didSet {
            delegate?.vmDidUpdateState(state)
        }
    }

    // UI
    public private(set) var defaultCellSize: CGSize!
    let cellDrawer: ProductCellDrawer
    
    public var isLastPage: Bool = false
    public var isLoading: Bool = false
    public var isOnErrorState: Bool = false
    
    var canRetrieveProducts: Bool {
        return !isLoading
    }
    
    var canRetrieveProductsNextPage: Bool {
        return !isLastPage && !isLoading
    }
    

    // MARK: - Computed iVars
    
    public var numberOfProducts: Int {
        return products.count
    }
    
    public var numberOfColumns: Int {
        return Int(ProductListViewModel.columnCount)
    }

    public var hasFilters: Bool {
        return categories != nil || timeCriteria != nil || distanceRadius != nil
    }
    
    internal var retrieveProductsParams: RetrieveProductsParams {
        
        var params: RetrieveProductsParams = RetrieveProductsParams()
        params.coordinates = queryCoordinates
        params.queryString = queryString
        params.countryCode = countryCode
        var categoryIds: [Int]?
        if let actualCategories = categories {
            categoryIds = []
            for category in actualCategories {
                categoryIds?.append(category.rawValue)
            }
        }
        params.categoryIds = categoryIds
        params.timeCriteria = timeCriteria
        params.sortCriteria = sortCriteria
        params.statuses = statuses
        params.maxPrice = maxPrice
        params.minPrice = minPrice
        params.userObjectId = userObjectId
        params.distanceRadius = distanceRadius
        params.distanceType = distanceType
        return params
    }
    
    
    // MARK: - Lifecycle

    convenience init(requester: ProductListRequester?) {
        let locationManager = Core.locationManager
        let productRepository = Core.productRepository
        let myUserRepository = Core.myUserRepository
        let cellDrawer = ProductCellDrawerFactory.drawerForProduct(true)

        self.init(requester: requester, locationManager: locationManager, productRepository: productRepository,
            myUserRepository: myUserRepository, cellDrawer: cellDrawer)
    }
    
    init(requester: ProductListRequester?, locationManager: LocationManager, productRepository: ProductRepository,
        myUserRepository: MyUserRepository, cellDrawer: ProductCellDrawer) {
            self.productListRequester = requester
            self.locationManager = locationManager
            self.productRepository = productRepository
            self.myUserRepository = myUserRepository
            self.cellDrawer = cellDrawer
            
            self.products = []
            self.pageNumber = 0
            self.maxDistance = 1
            self.refreshing = false
            self.state = .FirstLoadView
            
            let cellHeight = ProductListViewModel.cellWidth * ProductListViewModel.cellAspectRatio
            self.defaultCellSize = CGSizeMake(ProductListViewModel.cellWidth, cellHeight)
            super.init()
    }
    
    
    // MARK: - Public methods
    // MARK: > Requests

    public func refresh() { //TODO: THIS SEEMS TEMPORARY UNTIL THE REFACTOR IS COMPLETED!
        delegate?.vmRefresh()
    }

    public func reloadData() {
        products = productRepository.updateFavoritesInfo(products)
        delegate?.vmReloadData()
    }
    
    public func retrieveProducts() {
        if canRetrieveProducts {
            retrieveProductsWithOffset(0)
        }
    }
    
    public func retrieveProductsNextPage() {
        if canRetrieveProductsNextPage {
            retrieveProductsWithOffset(products.count)
        }
    }

    func reset() {
        products = []
        pageNumber = 0
        maxDistance = 1
        refreshing = false
        state = .FirstLoadView
        isLastPage = false
        isLoading = false
        isOnErrorState = false
    }

    private func retrieveProductsWithOffset(offset: Int) {

        isLoading = true
        isOnErrorState = false
        
        let currentCount = numberOfProducts
        var nextPageNumber = (offset == 0 ? 0 : pageNumber + 1)

        delegate?.vmDidStartRetrievingProductsPage(nextPageNumber)

        if let productListRequester = productListRequester {
            productListRequester.productsRetrieval(offset: offset) { [weak self] result in
                guard let strongSelf = self else { return }
                if let newProducts = result.value {
                    if offset == 0 {
                        strongSelf.products = newProducts
                        strongSelf.maxDistance = 1
                        strongSelf.pageNumber = 0
                        nextPageNumber = 0
                    } else {
                        strongSelf.products += newProducts
                        strongSelf.pageNumber += 1
                    }

                    let hasProducts = strongSelf.products.count > 0
                    let indexPaths = IndexPathHelper.indexPathsFromIndex(currentCount, count: newProducts.count)
                    strongSelf.isLastPage = strongSelf.productListRequester?.isLastPage(newProducts.count) ?? true
                    strongSelf.delegate?.vmDidSucceedRetrievingProductsPage(nextPageNumber, hasProducts: hasProducts,
                                                                            atIndexPaths: indexPaths)
                    strongSelf.dataDelegate?.productListVM(strongSelf, didSucceedRetrievingProductsPage: nextPageNumber,
                                                           hasProducts: hasProducts)
                    strongSelf.didSucceedRetrievingProducts()
                } else if let error = result.error {
                    strongSelf.isOnErrorState = true
                    let hasProducts = strongSelf.products.count > 0
                    strongSelf.delegate?.vmDidFailRetrievingProductsPage(nextPageNumber, hasProducts: hasProducts,
                                                                         error: error)
                    strongSelf.dataDelegate?.productListMV(strongSelf, didFailRetrievingProductsPage: nextPageNumber,
                                                           hasProducts: hasProducts, error: error)
                }
                self?.isLoading = false
            }
        } else { //TODO: ¡IF-ELSE JUST TEMPORAL UNTIL ALL REFACTOR TO PRODUCT REQUESTER IS COMPLETED!
            productsRetrieval(offset: offset) { [weak self] result in
                guard let strongSelf = self else { return }
                if let newProducts = result.value {
                    if offset == 0 {
                        strongSelf.products = newProducts
                        strongSelf.maxDistance = 1
                        strongSelf.pageNumber = 0
                        nextPageNumber = 0
                    } else {
                        strongSelf.products += newProducts
                        strongSelf.pageNumber += 1
                    }

                    let hasProducts = strongSelf.products.count > 0
                    let indexPaths = IndexPathHelper.indexPathsFromIndex(currentCount, count: newProducts.count)
                    strongSelf.isLastPage = newProducts.count == 0
                    strongSelf.delegate?.vmDidSucceedRetrievingProductsPage(nextPageNumber, hasProducts: hasProducts,
                                                                            atIndexPaths: indexPaths)
                    strongSelf.dataDelegate?.productListVM(strongSelf, didSucceedRetrievingProductsPage: nextPageNumber,
                                                           hasProducts: hasProducts)
                    strongSelf.didSucceedRetrievingProducts()
                } else if let error = result.error {
                    strongSelf.isOnErrorState = true
                    let hasProducts = strongSelf.products.count > 0
                    strongSelf.delegate?.vmDidFailRetrievingProductsPage(nextPageNumber, hasProducts: hasProducts,
                                                                         error: error)
                    strongSelf.dataDelegate?.productListMV(strongSelf, didFailRetrievingProductsPage: nextPageNumber,
                                                           hasProducts: hasProducts, error: error)
                }
                self?.isLoading = false
            }
        }
    }

    //TODO: ¡TO BE REMOVED WHEN ALL REFACTOR TO PRODUCT REQUESTER IS COMPLETED!
    func productsRetrieval(offset offset: Int, completion: ProductsCompletion?) {
        productRepository.index(retrieveProductsParams, pageOffset: offset, completion: completion)
    }

    
    /**
        Calculates the distance from the product to the point sent on the last query
        
        - Parameter productCoords: coordinates of the product
        - returns: the distance in the system distance type
    */
    public func distanceFromProductCoordinates(productCoords: LGLocationCoordinates2D) -> Double {
        
        var meters = 0.0
        
        if let coordinates = retrieveProductsParams.coordinates {
            let quadKeyStr = coordinates.coordsToQuadKey(LGCoreKitConstants.defaultQuadKeyPrecision)
            let actualQueryCoords = LGLocationCoordinates2D(fromCenterOfQuadKey: quadKeyStr)
            let queryLocation = CLLocation(latitude: actualQueryCoords.latitude, longitude: actualQueryCoords.longitude)
            let productLocation = CLLocation(latitude: productCoords.latitude, longitude: productCoords.longitude)
            
            meters = queryLocation.distanceFromLocation(productLocation)
        }
        
        let distanceType = DistanceType.systemDistanceType()
        switch (distanceType) {
        case .Km:
            return meters * 0.001
        case .Mi:
            return meters * 0.000621371
        }
    }

    /**
        Calls the appropiate topProductInfoDelegate method for each cell.
        
        - Parameter index: index of the topmost cell
        - Parameter whileScrollingDown: true if the user is scrolling down
    */
    public func visibleTopCellWithIndex(index: Int, whileScrollingDown scrollingDown: Bool) {

        guard let topProduct = productAtIndex(index) else { return }
        let distance = Float(self.distanceFromProductCoordinates(topProduct.location))
        
        // instance var max distance or MIN distance to avoid updating the label everytime
        if scrollingDown && distance > maxDistance {
            maxDistance = distance
        } else if !scrollingDown && distance < maxDistance {
            maxDistance = distance
        } else if refreshing {
            maxDistance = distance
        }
        
        guard let sortCriteria = sortCriteria else { return }
        
        switch (sortCriteria) {
        case .Distance:
            topProductInfoDelegate?.productListViewModel(self, distanceForTopProduct: max(1,Int(round(maxDistance))))
        case .Creation:
            guard let date = topProduct.createdAt else { return }
            topProductInfoDelegate?.productListViewModel(self, dateForTopProduct: date)
        case .PriceAsc, .PriceDesc:
            break
        }
    }

    public func selectedItemAtIndex(index: Int, thumbnailImage: UIImage?) {
        dataDelegate?.productListVM(self, didSelectItemAtIndex: index, thumbnailImage: thumbnailImage)
    }

    public func cellDidTapFavorite(index: Int) {
        guard let product = productAtIndex(index) else { return }
        let loggedInAction = { [weak self] in
            if product.favorite {
                self?.productRepository.deleteFavorite(product) { [weak self] result in
                    guard let product = result.value else { return }
                    self?.updateProduct(product, atIndex: index)
                }
            } else {
                self?.productRepository.saveFavorite(product) { [weak self] result in
                    guard let product = result.value else { return }
                    self?.updateProduct(product, atIndex: index)

                    let trackerEvent = TrackerEvent.productFavorite(product, typePage: .ProductList)
                    TrackerProxy.sharedInstance.trackEvent(trackerEvent)
                }
            }
        }
        actionsDelegate?.productListViewModel(self, requiresLoginWithSource: .Favourite, completion: loggedInAction)
    }

    public func cellDidTapChat(index: Int) {
        guard let product = productAtIndex(index) else { return }
        actionsDelegate?.productListViewModel(self, didTapChatOnProduct: product)
    }

    public func cellDidTapShare(index: Int) {
        guard let product = productAtIndex(index) else { return }
        actionsDelegate?.productListViewModel(self, didTapShareOnProduct: product)
    }


    // MARK: > UI

    public func clearList() {
        products = []
        delegate?.vmReloadData()
    }
    
    /**
        Returns the product at the given index.
    
        - parameter index: The index of the product.
        - returns: The product.
    */
    public func productAtIndex(index: Int) -> Product? {
        guard 0..<numberOfProducts ~= index else { return nil }
        return products[index]
    }

    func productViewModelForProductAtIndex(index: Int, thumbnailImage: UIImage?) -> ProductViewModel? {
        guard let product = productAtIndex(index) else { return nil }
        let productVM = ProductViewModel(product: product, thumbnailImage: thumbnailImage)
        return productVM
    }

    func productCellDataAtIndex(index: Int) -> ProductCellData? {
        guard let product = productAtIndex(index) else { return nil }

        var isMine = false
        if let productUserId = product.user.objectId, myUserId = myUserRepository.myUser?.objectId
            where productUserId == myUserId {
                isMine = true
        }
        return ProductCellData(title: product.name, price: product.priceString(),
            thumbUrl: product.thumbnail?.fileURL, status: product.status, date: product.createdAt,
            isFavorite: product.favorite, isMine: isMine, cellWidth: ProductListViewModel.cellWidth,
            indexPath: NSIndexPath(forRow: index, inSection: 0))
    }
    
    /**
        Returns the product object id for the product at the given index.
    
        - parameter index: The index of the product.
        - returns: The product object id.
    */
    public func productObjectIdForProductAtIndex(index: Int) -> String? {
        return productAtIndex(index)?.objectId
    }
    
    /**
        Returns the size of the cell at the given index path.
    
        - parameter index: The index of the product.
        - returns: The cell size.
    */
    public func sizeForCellAtIndex(index: Int) -> CGSize {
        guard let product = productAtIndex(index) else { return defaultCellSize }

        guard let thumbnailSize = product.thumbnailSize where thumbnailSize.height != 0 && thumbnailSize.width != 0
            else { return defaultCellSize }

        let thumbFactor = min(ProductListViewModel.cellMaxThumbFactor,
            CGFloat(thumbnailSize.height / thumbnailSize.width))
        let imageFinalHeight = max(ProductListViewModel.cellMinHeight, round(defaultCellSize.width * thumbFactor))
        return CGSize(
            width: defaultCellSize.width,
            height: cellDrawer.cellHeightForThumbnailHeight(imageFinalHeight)
        )
    }
        
    /**
        Sets which item is currently visible on screen. If it exceeds a certain threshold then it loads next page,
        if possible.
    
        - parameter index: The index of the product currently visible on screen.
    */
    public func setCurrentItemIndex(index: Int) {

        topProductInfoDelegate?.productListViewModel(self, showingItemAtIndex: index)

        let threshold = Int(Float(numberOfProducts) * ProductListViewModel.itemsPagingThresholdPercentage)
        let shouldRetrieveProductsNextPage = index >= threshold && !isOnErrorState
        if shouldRetrieveProductsNextPage {
            retrieveProductsNextPage()
        }
    }
    
    /**
        Informs its delegate that the list is trying to refresh
    
        - parameter refreshing: The index of the product currently visible on screen.
    */
    public func pullingToRefresh(refreshing: Bool) {
        topProductInfoDelegate?.productListViewModel(self, pullToRefreshInProggress: refreshing)
    }
    
    
    // MARK: - Internal methods
    
    internal func didSucceedRetrievingProducts() {
        //TODO REMOVE!!!
    }


    // MARK: - Private methods

    private func updateProduct(product: Product, atIndex index: Int) {
        guard 0..<numberOfProducts ~= index else { return }
        products[index] = product
        delegate?.vmDidUpdateProductDataAtIndex(index)
    }
}
