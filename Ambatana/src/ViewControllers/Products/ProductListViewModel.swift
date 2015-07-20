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

protocol ProductListViewModelDelegate: class {
    func viewModel(viewModel: ProductListViewModel, didStartRetrievingProductsPage page: UInt)
    func viewModel(viewModel: ProductListViewModel, didFailRetrievingProductsPage page: UInt, error: ProductsRetrieveServiceError)
    func viewModel(viewModel: ProductListViewModel, didSucceedRetrievingProductsPage page: UInt, atIndexPaths indexPaths: [NSIndexPath])
}

class ProductListViewModel: BaseViewModel {
    
    // MARK: - Constants
    private static let columnCount: CGFloat = 2.0
    
    private static let cellMinHeight: CGFloat = 160.0
    private static let cellAspectRatio: CGFloat = 198.0 / cellMinHeight
    private static let cellWidth: CGFloat = UIScreen.mainScreen().bounds.size.width * (1 / columnCount)
    
    private static let itemsPagingThresholdPercentage: Float = 0.7    // when we should start ask for a new page
    
    // MARK: - iVars
    // > Delegate
    weak var delegate: ProductListViewModelDelegate?
    
    // > Input (query)
    var queryString: String?
    var coordinates: LGLocationCoordinates2D?
    var categories: [ProductCategory]?
    var sortCriteria: ProductSortCriteria?
    var maxPrice: Int?
    var minPrice: Int?
    var userObjectId: String?
    
    // > Manager
    private let productsManager: ProductsManager
    
    // > Data
    private var products: NSArray
    private(set) var pageNumber: UInt
    
    // > UI
    private(set) var defaultCellSize: CGSize!
    
    // MARK: - Computed iVars
    
    var numberOfProducts: Int {
        return products.count
    }
    
    var numberOfColumns: Int {
        return Int(ProductListViewModel.columnCount)
    }
    
    var canRetrieveProducts: Bool {
        return productsManager.canRetrieveProducts
    }
    
    private var canRetrieveProductsNextPage: Bool {
        return productsManager.canRetrieveProductsNextPage
    }
    
    // MARK: - Lifecycle
    
    override init() {
        let productsRetrieveService = LGProductsRetrieveService()
        self.productsManager = ProductsManager(productsRetrieveService: productsRetrieveService)
        
        self.products = []
        self.pageNumber = 0
        
        let cellHeight = ProductListViewModel.cellWidth * ProductListViewModel.cellAspectRatio
        self.defaultCellSize = CGSizeMake(ProductListViewModel.cellWidth, cellHeight)
    }
    
    // MARK: > Overriden methods
    
    internal override func didSetActive() {
        super.didSetActive()
        // If there are no products, then reload if possible
        if numberOfProducts == 0 && canRetrieveProducts {
            retrieveProductsFirstPage()
        }
    }
    
    // MARK: - Internal methods
    
    // MARK: > Requests
    
    /**
        Retrieve the products first page, with the current query parameters.
    */
    func retrieveProductsFirstPage() {
        
        var params: RetrieveProductsParams = RetrieveProductsParams()
        params.coordinates = coordinates
        params.queryString = queryString
        var categoryIds: [Int]?
        if let actualCategories = categories {
            categoryIds = []
            for category in actualCategories {
                categoryIds?.append(category.rawValue)
            }
        }
        params.categoryIds = categoryIds
        params.sortCriteria = sortCriteria
        params.maxPrice = maxPrice
        params.minPrice = minPrice
        params.userObjectId = userObjectId
        if let usesMetric = NSLocale.currentLocale().objectForKey(NSLocaleUsesMetricSystem)?.boolValue {
            params.distanceType = usesMetric ? .Km : .Mi
        }
        
        delegate?.viewModel(self, didStartRetrievingProductsPage: 0)
        
        let currentCount = numberOfProducts
        
        let myResult = { [weak self] (result: Result<ProductsResponse, ProductsRetrieveServiceError>) -> Void in
            if let strongSelf = self {
                let delegate = strongSelf.delegate
                
                // Success
                if let productsResponse = result.value {
                    // Update the products & the current page number
                    let products = productsResponse.products
                    strongSelf.products = products
                    strongSelf.pageNumber = 0
                    
                    // Tracking
                    TrackingHelper.trackEvent(.ProductList, parameters: strongSelf.trackingParamsForEventType(.ProductList))
                    
                    // Notify the delegate
                    let indexPaths = IndexPathHelper.indexPathsFromIndex(currentCount, count: products.count)
                    delegate?.viewModel(strongSelf, didSucceedRetrievingProductsPage: 0, atIndexPaths: indexPaths)
                }
                // Error
                else if let error = result.error {
                    // Notify the delegate
                    delegate?.viewModel(strongSelf, didFailRetrievingProductsPage: 0, error: error)
                }
            }
        }
        productsManager.retrieveProductsWithParams(params, result: myResult)
    }    

    /**
        Retrieve the products next page, with the last query parameters.
    */
    func retrieveProductsNextPage() {
        
        let currentCount = numberOfProducts
        let nextPageNumber = pageNumber + 1
        
        delegate?.viewModel(self, didStartRetrievingProductsPage: nextPageNumber)
        
        let myResult = { [weak self] (result: Result<ProductsResponse, ProductsRetrieveServiceError>) -> Void in
            if let strongSelf = self {
                let delegate = strongSelf.delegate
                
                // Success
                if let productsResponse = result.value {
                    // Add the new products & update the page number
                    let newProducts = productsResponse.products
                    strongSelf.products = strongSelf.products.arrayByAddingObjectsFromArray(newProducts as [AnyObject])
                    strongSelf.pageNumber = nextPageNumber
                    
                    // Tracking
                    TrackingHelper.trackEvent(.ProductList, parameters: strongSelf.trackingParamsForEventType(.ProductList))
                    
                    // Notify the delegate
                    let indexPaths = IndexPathHelper.indexPathsFromIndex(currentCount, count: newProducts.count)
                    delegate?.viewModel(strongSelf, didSucceedRetrievingProductsPage: nextPageNumber, atIndexPaths: indexPaths)
                }
                // Error
                else if let error = result.error {
                    delegate?.viewModel(strongSelf, didFailRetrievingProductsPage: nextPageNumber, error: error)
                }
            }
        }
        productsManager.retrieveProductsNextPageWithResult(myResult)
    }
    
    // MARK: > UI
    
    /**
        Returns the product at the given index.
    
        :param: index The index of the product.
        :returns: The product.
    */
    func productAtIndex(index: Int) -> Product {
        return products.objectAtIndex(index) as! Product
    }
    
    /**
    Returns the product object id for the product at the given index.
    
    :param: index The index of the product.
    :returns: The product object id.
    */
    func productObjectIdForProductAtIndex(index: Int) -> String? {
        return productAtIndex(index).objectId
    }
    
    /**
    Returns the size of the cell at the given index path.
    
    :param: index The index of the product.
    :returns: The cell size.
    */
    func sizeForCellAtIndex(index: Int) -> CGSize {
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
    
        :param: index The index of the product currently visible on screen.
    */
    func setCurrentItemIndex(index: Int) {
        let threshold = Int(Float(numberOfProducts) * ProductListViewModel.itemsPagingThresholdPercentage)
        let shouldRetrieveProductsNextPage = index >= threshold
        if shouldRetrieveProductsNextPage && canRetrieveProductsNextPage {
            retrieveProductsNextPage()
        }
    }
    
    // MARK: > Tracking 
    
    /**
        Returns the tracking parameters key-value for the given tracking event type.
    
        :param: eventType The tracking event type.
        :return: The tracking parameters key-value for the given tracking event type.
    */
    func trackingParamsForEventType(eventType: TrackingEvent) -> [TrackingParameter: AnyObject] {
        var properties: [TrackingParameter: AnyObject] = [:]
        
        // Common
        // > categories
        var categoryIds: [String] = []
        var categoryNames: [String] = []
        if let actualCategories = categories {
            for category in actualCategories {
                categoryIds.append(String(category.rawValue))
                categoryNames.append(category.name())
            }
        }
        properties[.CategoryId] = categoryIds.isEmpty ? "0" : ",".join(categoryIds)
        properties[.CategoryName] = categoryNames.isEmpty ? "none" : ",".join(categoryNames)
        // > current user data
        if let currentUser = MyUserManager.sharedInstance.myUser() {
            if let userCity = currentUser.postalAddress.city {
                properties[.UserCity] = userCity
            }
            if let userCountry = currentUser.postalAddress.countryCode {
                properties[.UserCountry] = userCountry
            }
            if let userZipCode = currentUser.postalAddress.zipCode {
                properties[.UserZipCode] = userZipCode
            }
        }
        // > search query
        if let actualSearchQuery = queryString {
            properties[.SearchString] = actualSearchQuery
        }
        
        // ProductList
        if eventType == .ProductList {
            // > page number
            properties[.PageNumber] = pageNumber
        }
        
        return properties
    }
}
