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

public protocol ProductListActionsDelegate: class {
    func productListViewModel(productListViewModel: ProductListViewModel,
        requiresLoginWithSource source: EventParameterLoginSourceValue, completion: () -> Void)
    func productListViewModel(productListViewModel: ProductListViewModel, didTapChatOnProduct product: Product)
    func productListViewModel(productListViewModel: ProductListViewModel, didTapShareOnProduct product: Product)
}

public enum ProductListViewState {
    case FirstLoad
    case Data
    case Error(errImage: UIImage?, errTitle: String?, errBody: String?, errButTitle: String?, errButAction: (() -> Void)?)
}

protocol ProductListRequester: class {
    func canRetrieve() -> Bool 
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

    // Delegates
    public weak var delegate: ProductListViewModelDelegate?
    public weak var dataDelegate: ProductListViewModelDataDelegate?
    public weak var actionsDelegate: ProductListActionsDelegate?
    
    // Requester & Repositories
    private weak var productListRequester: ProductListRequester? //weak var to avoid retain cycles
    private let locationManager: LocationManager
    private let productRepository: ProductRepository
    private let myUserRepository: MyUserRepository
    
    // Data
    private var products: [Product]
    public private(set) var pageNumber: UInt
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
        let requesterCanRetrieve = productListRequester?.canRetrieve() ?? false
        return requesterCanRetrieve && !isLoading
    }
    
    var canRetrieveProductsNextPage: Bool {
        return !isLastPage && canRetrieveProducts
    }
    

    // MARK: - Computed iVars
    
    public var numberOfProducts: Int {
        return products.count
    }
    
    public var numberOfColumns: Int {
        return Int(ProductListViewModel.columnCount)
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
            self.refreshing = false
            self.state = .FirstLoad
            
            let cellHeight = ProductListViewModel.cellWidth * ProductListViewModel.cellAspectRatio
            self.defaultCellSize = CGSizeMake(ProductListViewModel.cellWidth, cellHeight)
            super.init()
    }
    
    
    // MARK: - Public methods
    // MARK: > Requests

    public func refresh() { //TODO: REMOVE WHEN USAGE OF PRODUCTLISTVIEW INHERITANCE WILL BE REMOVED TOO
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
        refreshing = false
        state = .FirstLoad
        isLastPage = false
        isLoading = false
        isOnErrorState = false
    }

    private func retrieveProductsWithOffset(offset: Int) {
        guard let productListRequester = productListRequester else { return } //Should not happen

        isLoading = true
        isOnErrorState = false
        let currentCount = numberOfProducts
        var nextPageNumber = (offset == 0 ? 0 : pageNumber + 1)

        delegate?.vmDidStartRetrievingProductsPage(nextPageNumber)
        productListRequester.productsRetrieval(offset: offset) { [weak self] result in
            guard let strongSelf = self else { return }
            if let newProducts = result.value {
                if offset == 0 {
                    strongSelf.products = newProducts
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
            } else if let error = result.error {
                strongSelf.processError(error, nextPageNumber: nextPageNumber)
            }
            self?.isLoading = false
        }
    }

    private func processError(error: RepositoryError, nextPageNumber: UInt) {
        isOnErrorState = true
        let hasProducts = products.count > 0
        delegate?.vmDidFailRetrievingProductsPage(nextPageNumber, hasProducts: hasProducts,
                                                             error: error)
        dataDelegate?.productListMV(self, didFailRetrievingProductsPage: nextPageNumber,
                                               hasProducts: hasProducts, error: error)
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
        let threshold = Int(Float(numberOfProducts) * ProductListViewModel.itemsPagingThresholdPercentage)
        let shouldRetrieveProductsNextPage = index >= threshold && !isOnErrorState
        if shouldRetrieveProductsNextPage {
            retrieveProductsNextPage()
        }
    }


    // MARK: - Private methods

    private func updateProduct(product: Product, atIndex index: Int) {
        guard 0..<numberOfProducts ~= index else { return }
        products[index] = product
        delegate?.vmDidUpdateProductDataAtIndex(index)
    }
}
