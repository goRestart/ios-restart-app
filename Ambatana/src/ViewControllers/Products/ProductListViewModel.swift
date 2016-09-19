//
//  ProductListViewModel.swift
//  LetGo
//
//  Created by AHL on 9/7/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import Result

protocol ProductListViewModelDelegate: class {
    func vmReloadData(vm: ProductListViewModel)
    func vmDidUpdateState(vm: ProductListViewModel, state: ViewState)
    func vmDidFailRetrievingProducts(vm: ProductListViewModel, page: UInt)
    func vmDidSucceedRetrievingProductsPage(vm: ProductListViewModel, page: UInt, indexes: [Int])
}

protocol ProductListViewModelDataDelegate: class {
    func productListMV(viewModel: ProductListViewModel, didFailRetrievingProductsPage page: UInt, hasProducts: Bool,
                         error: RepositoryError)
    func productListVM(viewModel: ProductListViewModel, didSucceedRetrievingProductsPage page: UInt, hasProducts: Bool)
    func productListVM(viewModel: ProductListViewModel, didSelectItemAtIndex index: Int, thumbnailImage: UIImage?,
                       originFrame: CGRect?)
    func vmProcessReceivedProductPage(products: [ProductCellModel], page: UInt) -> [ProductCellModel]
    func vmDidSelectSellBanner(type: String)
    func vmDidSelectCollection(type: CollectionCellType)
}

extension ProductListViewModelDataDelegate {
    func vmProcessReceivedProductPage(products: [ProductCellModel], page: UInt) -> [ProductCellModel] { return products }
    func vmDidSelectSellBanner(type: String) {}
    func vmDidSelectCollection(type: CollectionCellType) {}
}

protocol ProductListRequester: class {
    func canRetrieve() -> Bool
    func retrieveFirstPage(completion: ProductsCompletion?)
    func retrieveNextPage(completion: ProductsCompletion?)
    func isLastPage(resultCount: Int) -> Bool
    func updateInitialOffset(newOffset: Int)
    func duplicate() -> ProductListRequester
}


class ProductListViewModel: BaseViewModel {
    
    // MARK: - Constants
    private static let cellMinHeight: CGFloat = 80.0
    private static let cellAspectRatio: CGFloat = 198.0 / cellMinHeight
    private static let cellBannerAspectRatio: CGFloat = 1.3
    private static let cellMaxThumbFactor: CGFloat = 2.0

    
    private static let itemsPagingThresholdPercentage: Float = 0.7    // when we should start ask for a new page
    
    var cellWidth: CGFloat {
        return (UIScreen.mainScreen().bounds.size.width - (productListFixedInset*2)) / CGFloat(numberOfColumns)
    }

    var cellStyle: CellStyle {
        return numberOfColumns > 2 ? .Small : .Big
    }
    
    var productListFixedInset: CGFloat = 10.0
    
    // MARK: - iVars 

    // Delegates
    weak var delegate: ProductListViewModelDelegate?
    weak var dataDelegate: ProductListViewModelDataDelegate?
    
    // Requester
    var productListRequester: ProductListRequester?

    //State
    private(set) var pageNumber: UInt
    private(set) var refreshing: Bool
    private(set) var state: ViewState {
        didSet {
            delegate?.vmDidUpdateState(self, state: state)
        }
    }

    // Data
    private(set) var objects: [ProductCellModel]

    // UI
    private(set) var defaultCellSize: CGSize
    
    private(set) var isLastPage: Bool = false
    private(set) var isLoading: Bool = false
    private(set) var isOnErrorState: Bool = false
    
    var canRetrieveProducts: Bool {
        let requesterCanRetrieve = productListRequester?.canRetrieve() ?? false
        return requesterCanRetrieve && !isLoading
    }
    
    var canRetrieveProductsNextPage: Bool {
        return !isLastPage && canRetrieveProducts
    }
    

    // MARK: - Computed iVars
    
    var numberOfProducts: Int {
        return objects.count
    }
    
    let numberOfColumns: Int

    
    // MARK: - Lifecycle

    init(requester: ProductListRequester?, products: [Product]? = nil, numberOfColumns: Int = 2) {
        self.objects = (products ?? []).map(ProductCellModel.init)
        self.pageNumber = 0
        self.refreshing = false
        self.state = .Loading
        self.numberOfColumns = numberOfColumns
        self.productListRequester = requester
        self.defaultCellSize = CGSize.zero
        super.init()
        let cellHeight = cellWidth * ProductListViewModel.cellAspectRatio
        self.defaultCellSize = CGSizeMake(cellWidth, cellHeight)
    }
    
    convenience init(listViewModel: ProductListViewModel) {
        self.init(requester: listViewModel.productListRequester)
        self.pageNumber = listViewModel.pageNumber
        self.state = listViewModel.state
        self.objects = listViewModel.objects
    }

    
    // MARK: - Public methods
    // MARK: > Requests

    func refresh() {
        refreshing = true
        if !retrieveProducts() {
            refreshing = false
            delegate?.vmDidFailRetrievingProducts(self, page: 0)
        }
    }

    func setErrorState(viewModel: LGEmptyViewModel) {
        state = .Error(viewModel)
    }

    func setEmptyState(viewModel: LGEmptyViewModel) {
        state = .Empty(viewModel)
    }

    func refreshControlTriggered() {
        refresh()
    }

    func reloadData() {
        delegate?.vmReloadData(self)
    }
    
    func retrieveProducts() -> Bool {
        guard canRetrieveProducts else { return false }
        retrieveProducts(firstPage: true)
        return true
    }
    
    func retrieveProductsNextPage() {
        if canRetrieveProductsNextPage {
            retrieveProducts(firstPage: false)
        }
    }

    func resetUI() {
        objects = []
        pageNumber = 0
        refreshing = false
        state = .Loading
        isLastPage = false
        isLoading = false
        isOnErrorState = false
    }
 

    private func retrieveProducts(firstPage firstPage: Bool) {
        guard let productListRequester = productListRequester else { return } //Should not happen

        isLoading = true
        isOnErrorState = false
        let currentCount = numberOfProducts
        let nextPageNumber = firstPage ? 0 : pageNumber + 1

        if nextPageNumber == 0 && currentCount == 0 {
            state = .Loading
        }
        
        let completion: ProductsCompletion = { [weak self] result in
            guard let strongSelf = self else { return }
            if let newProducts = result.value {
                let productCellModels = newProducts.map(ProductCellModel.init)
                let cellModels = self?.dataDelegate?.vmProcessReceivedProductPage(productCellModels, page: nextPageNumber) ?? productCellModels
                let indexes: [Int]
                if firstPage {
                    strongSelf.objects = cellModels
                    strongSelf.refreshing = false
                    indexes = [Int](0 ..< cellModels.count)
                } else {
                    strongSelf.objects += cellModels
                    indexes = [Int](currentCount ..< (currentCount+cellModels.count))
                }
                strongSelf.pageNumber = nextPageNumber
                let hasProducts = strongSelf.objects.count > 0
                strongSelf.isLastPage = strongSelf.productListRequester?.isLastPage(newProducts.count) ?? true
                //This assignment should be ALWAYS before calling the delegates to give them the option to re-set the state
                strongSelf.state = .Data
                strongSelf.delegate?.vmDidSucceedRetrievingProductsPage(strongSelf, page: nextPageNumber, indexes: indexes)
                strongSelf.dataDelegate?.productListVM(strongSelf, didSucceedRetrievingProductsPage: nextPageNumber,
                                                       hasProducts: hasProducts)
            } else if let error = result.error {
                strongSelf.processError(error, nextPageNumber: nextPageNumber)
            }
            self?.isLoading = false
        }

        if firstPage {
            productListRequester.retrieveFirstPage(completion)
        } else {
            productListRequester.retrieveNextPage(completion)
        }
    }

    private func processError(error: RepositoryError, nextPageNumber: UInt) {
        isOnErrorState = true
        let hasProducts = objects.count > 0
        delegate?.vmDidFailRetrievingProducts(self, page: nextPageNumber)
        dataDelegate?.productListMV(self, didFailRetrievingProductsPage: nextPageNumber,
                                               hasProducts: hasProducts, error: error)
    }

    func selectedItemAtIndex(index: Int, thumbnailImage: UIImage?, originFrame: CGRect?) {
        guard let item = itemAtIndex(index) else { return }        
        switch item {
        case .ProductCell:
            dataDelegate?.productListVM(self, didSelectItemAtIndex: index, thumbnailImage: thumbnailImage,
                                        originFrame: originFrame)
        case .CollectionCell(let type):
            dataDelegate?.vmDidSelectCollection(type)
        }
    }


    // MARK: > UI

    func clearList() {
        objects = []
        delegate?.vmReloadData(self)
    }
    
    /**
        Returns the product at the given index.
    
        - parameter index: The index of the product.
        - returns: The product.
    */
    func itemAtIndex(index: Int) -> ProductCellModel? {
        guard 0..<numberOfProducts ~= index else { return nil }
        return objects[index]
    }

    func productAtIndex(index: Int) -> Product? {
        guard 0..<numberOfProducts ~= index else { return nil }
        let item = objects[index]
        switch item {
        case .ProductCell(let product):
            return product
        case .CollectionCell:
            return nil
        }
    }
    
    /**
        Returns the size of the cell at the given index path.
    
        - parameter index: The index of the product.
        - returns: The cell size.
    */
    func sizeForCellAtIndex(index: Int) -> CGSize {
        guard let item = itemAtIndex(index) else { return defaultCellSize }
        switch item {
        case .ProductCell(let product):
            guard let thumbnailSize = product.thumbnailSize where thumbnailSize.height != 0 && thumbnailSize.width != 0
                else { return defaultCellSize }
            
            let thumbFactor = min(ProductListViewModel.cellMaxThumbFactor,
                                  CGFloat(thumbnailSize.height / thumbnailSize.width))
            let imageFinalHeight = max(ProductListViewModel.cellMinHeight, round(defaultCellSize.width * thumbFactor))
            return CGSize(width: defaultCellSize.width, height: imageFinalHeight)

        case .CollectionCell:
            let height = defaultCellSize.width*ProductListViewModel.cellBannerAspectRatio
            return CGSize(width: defaultCellSize.width, height: height)
        }
    }
        
    /**
        Sets which item is currently visible on screen. If it exceeds a certain threshold then it loads next page,
        if possible.
    
        - parameter index: The index of the product currently visible on screen.
    */
    func setCurrentItemIndex(index: Int) {
        let threshold = Int(Float(numberOfProducts) * ProductListViewModel.itemsPagingThresholdPercentage)
        let shouldRetrieveProductsNextPage = index >= threshold && !isOnErrorState
        if shouldRetrieveProductsNextPage {
            retrieveProductsNextPage()
        }
    }
}
