//
//  ProductListViewModel.swift
//  LetGo
//
//  Created by AHL on 9/7/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import CoreLocation
import LGCoreKit
import Result

public protocol ProductListViewModelDataDelegate: class {
    func viewModel(viewModel: ProductListViewModel, didStartRetrievingProductsPage page: UInt)
    func viewModel(viewModel: ProductListViewModel, didFailRetrievingProductsPage page: UInt, hasProducts: Bool, error: ProductsRetrieveServiceError)
    func viewModel(viewModel: ProductListViewModel, didSucceedRetrievingProductsPage page: UInt, hasProducts: Bool, atIndexPaths indexPaths: [NSIndexPath])
}

public class ProductListViewModel: BaseViewModel {
    
    // MARK: - Constants
    private static let columnCount: CGFloat = 2.0
    
    private static let cellMinHeight: CGFloat = 160.0
    private static let cellAspectRatio: CGFloat = 198.0 / cellMinHeight
    private static let cellWidth: CGFloat = UIScreen.mainScreen().bounds.size.width * (1 / columnCount)
    
    private static let itemsPagingThresholdPercentage: Float = 0.7    // when we should start ask for a new page
    
    // MARK: - iVars
    
    // Input (query)
    public var queryString: String?
    public var coordinates: LGLocationCoordinates2D?
    
    internal var queryCoordinates: LGLocationCoordinates2D? {
        let coords: LGLocationCoordinates2D?
        // If we had specified coordinates
        if let specifiedCoordinates = coordinates {
            coords = specifiedCoordinates
        }
        // Try to use MyUserManager location
        else if let lastKnownLocation = MyUserManager.sharedInstance.currentLocation {
            coords = LGLocationCoordinates2D(location: lastKnownLocation)
        }
        else {
            coords = nil
        }
        return coords
    }

    public var countryCode: String?
    public var categories: [ProductCategory]?
    public var sortCriteria: ProductSortCriteria?
    public var statuses: [ProductStatus]?
    public var maxPrice: Int?
    public var minPrice: Int?
    public var userObjectId: String?
    
    // Delegate
    public weak var dataDelegate: ProductListViewModelDataDelegate?
    
    // Manager
    public var isProfileList: Bool = false
    private let productsManager: ProductsManager
    
    // Data
    private var products: [Product]
    public private(set) var pageNumber: UInt
    
    // UI
    public private(set) var defaultCellSize: CGSize!
    
    // MARK: - Computed iVars
    
    public var numberOfProducts: Int {
        return products.count
    }
    
    public var numberOfColumns: Int {
        return Int(ProductListViewModel.columnCount)
    }
    
    public var isLoading: Bool {
        return productsManager.isLoading
    }
    
    public var canRetrieveProducts: Bool {
        return productsManager.canRetrieveProducts
    }
    
    public var canRetrieveProductsNextPage: Bool {
        return productsManager.canRetrieveProductsNextPage
    }
    
    internal var retrieveProductsFirstPageParams: RetrieveProductsParams {
        var params: RetrieveProductsParams = RetrieveProductsParams()
        params.coordinates = coordinates ?? queryCoordinates
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
        params.sortCriteria = sortCriteria
        params.statuses = statuses
        params.maxPrice = maxPrice
        params.minPrice = minPrice
        params.userObjectId = userObjectId
        return params
    }
    
    // MARK: - Lifecycle
    
    public override init() {
        let productsRetrieveService = LGProductsRetrieveService()
        let userProductsRetrieveService = LGUserProductsRetrieveService()
        self.productsManager = ProductsManager(productsRetrieveService: productsRetrieveService, userProductsRetrieveService: userProductsRetrieveService)
        
        self.products = []
        self.pageNumber = 0
        
        let cellHeight = ProductListViewModel.cellWidth * ProductListViewModel.cellAspectRatio
        self.defaultCellSize = CGSizeMake(ProductListViewModel.cellWidth, cellHeight)
        super.init()
    }
    
    // MARK: - Public methods
    
    // MARK: > Requests

    /**
        Retrieve the products first page, with the current query parameters.
    */
    public func retrieveProductsFirstPage() {
        let params = retrieveProductsFirstPageParams
        dataDelegate?.viewModel(self, didStartRetrievingProductsPage: 0)
        
        let currentCount = numberOfProducts
        
        let completion = { [weak self] (result: ProductsRetrieveServiceResult) -> Void in
            if let strongSelf = self {
                // Success
                if let productsResponse = result.value {
                    // Update the products & the current page number
                    let products = productsResponse.products
                    strongSelf.products = products
                    strongSelf.pageNumber = 0
                    
                    // Notify the delegate
                    let hasProducts = strongSelf.products.count > 0
                    let indexPaths = IndexPathHelper.indexPathsFromIndex(currentCount, count: products.count)
                    strongSelf.dataDelegate?.viewModel(strongSelf, didSucceedRetrievingProductsPage: 0, hasProducts: hasProducts, atIndexPaths: indexPaths)
                    
                    // Notify me
                    strongSelf.didSucceedRetrievingProducts()
                }
                // Error
                else if let error = result.error {
                    // Notify the delegate
                    let hasProducts = strongSelf.products.count > 0
                    strongSelf.dataDelegate?.viewModel(strongSelf, didFailRetrievingProductsPage: 0, hasProducts: hasProducts, error: error)
                }
            }
        }
        
        if isProfileList {
            productsManager.retrieveUserProductsWithParams(params, completion: completion)
        } else {
            productsManager.retrieveProductsWithParams(params, completion: completion)
        }
    }
    
    /**
        Retrieve the products next page, with the last query parameters.
    */
    public func retrieveProductsNextPage() {
        
        let currentCount = numberOfProducts
        let nextPageNumber = pageNumber + 1
        
        dataDelegate?.viewModel(self, didStartRetrievingProductsPage: nextPageNumber)
        
        let completion = { [weak self] (result: ProductsRetrieveServiceResult) -> Void in
            if let strongSelf = self {
                // Success
                if let productsResponse = result.value {
                    // Add the new products & update the page number
                    let newProducts = productsResponse.products
                    strongSelf.products.appendContentsOf(newProducts)
//                    strongSelf.products = strongSelf.products.arrayByAddingObjectsFromArray(newProducts as [AnyObject])
                    strongSelf.pageNumber = nextPageNumber

                    // Notify the delegate
                    let hasProducts = strongSelf.products.count > 0
                    let indexPaths = IndexPathHelper.indexPathsFromIndex(currentCount, count: newProducts.count)
                    strongSelf.dataDelegate?.viewModel(strongSelf, didSucceedRetrievingProductsPage: nextPageNumber, hasProducts: hasProducts, atIndexPaths: indexPaths)
                    
                    // Notify me
                    strongSelf.didSucceedRetrievingProducts()
                }
                // Error
                else if let error = result.error {
                    let hasProducts = strongSelf.products.count > 0
                    strongSelf.dataDelegate?.viewModel(strongSelf, didFailRetrievingProductsPage: nextPageNumber, hasProducts: hasProducts, error: error)
                }
            }
        }
        if isProfileList {
            productsManager.retrieveUserProductsNextPageWithCompletion(completion)
        } else {
            productsManager.retrieveProductsNextPageWithCompletion(completion)
        }
        
    }
    
    
    public func distanceFromProductCoordinates(productCoords: LGLocationCoordinates2D) -> Double {
        
        var meters = 0.0
        
        if let actualQueryCoords = retrieveProductsFirstPageParams.coordinates {
            let queryLocation = CLLocation(latitude: actualQueryCoords.latitude, longitude: actualQueryCoords.longitude)
            let productLocation = CLLocation(latitude: productCoords.latitude, longitude: productCoords.longitude)
            
            meters = queryLocation.distanceFromLocation(productLocation)
        }
        
        let distanceType = queryDistanceType()
        switch (distanceType) {
        case .Km:
            return meters * 0.001
        case .Mi:
            return meters * 0.000621371
        }
        
    }
    
    public func queryDistanceType() -> DistanceType {
        let distanceType: DistanceType
        // use whatever the locale says
        if let usesMetric = NSLocale.currentLocale().objectForKey(NSLocaleUsesMetricSystem)?.boolValue {
            distanceType = usesMetric ? .Km : .Mi
        }
        // fallback: km
        else {
            distanceType = DistanceType.Km
        }
        return distanceType
    }
    
    // MARK: > UI
    
    /**
        Returns the product at the given index.
    
        - parameter index: The index of the product.
        - returns: The product.
    */
    public func productAtIndex(index: Int) -> Product {
        return products[index]
    }
    
    /**
        Returns the product object id for the product at the given index.
    
        - parameter index: The index of the product.
        - returns: The product object id.
    */
    public func productObjectIdForProductAtIndex(index: Int) -> String? {
        return productAtIndex(index).objectId
    }
    
    /**
        Returns the size of the cell at the given index path.
    
        - parameter index: The index of the product.
        - returns: The cell size.
    */
    public func sizeForCellAtIndex(index: Int) -> CGSize {
        let product = productAtIndex(index)
        if let thumbnailSize = product.thumbnailSize {
            if thumbnailSize.height != 0 && thumbnailSize.width != 0 {
                let thumbFactor = thumbnailSize.height / thumbnailSize.width
                var baseSize = defaultCellSize
                baseSize.height = max(ProductListViewModel.cellMinHeight, round(baseSize.height * CGFloat(thumbFactor)))
                return baseSize
            }
        }
        return defaultCellSize
    }
        
    /**
        Sets which item is currently visible on screen. If it exceeds a certain threshold then it loads next page, if possible.
    
        - parameter index: The index of the product currently visible on screen.
    */
    public func setCurrentItemIndex(index: Int) {
        let threshold = Int(Float(numberOfProducts) * ProductListViewModel.itemsPagingThresholdPercentage)
        let shouldRetrieveProductsNextPage = index >= threshold
        if shouldRetrieveProductsNextPage && canRetrieveProductsNextPage {
            retrieveProductsNextPage()
        }
    }
    
    // MARK: - Internal methods
    
    internal func didSucceedRetrievingProducts() {
        
    }
}
