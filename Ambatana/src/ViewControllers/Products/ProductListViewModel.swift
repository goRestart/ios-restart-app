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
    func vmReloadData(_ vm: ProductListViewModel)
    func vmDidUpdateState(_ vm: ProductListViewModel, state: ViewState)
    func vmDidFinishLoading(_ vm: ProductListViewModel, page: UInt, indexes: [Int])
}

protocol ProductListViewModelDataDelegate: class {
    func productListMV(_ viewModel: ProductListViewModel, didFailRetrievingProductsPage page: UInt, hasProducts: Bool,
                         error: RepositoryError)
    func productListVM(_ viewModel: ProductListViewModel, didSucceedRetrievingProductsPage page: UInt, hasProducts: Bool)
    func productListVM(_ viewModel: ProductListViewModel, didSelectItemAtIndex index: Int, thumbnailImage: UIImage?,
                       originFrame: CGRect?)
    func vmProcessReceivedProductPage(_ products: [ProductCellModel], page: UInt) -> [ProductCellModel]
    func vmDidSelectSellBanner(_ type: String)
    func vmDidSelectCollection(_ type: CollectionCellType)
}

extension ProductListViewModelDataDelegate {
    func vmProcessReceivedProductPage(_ products: [ProductCellModel], page: UInt) -> [ProductCellModel] { return products }
    func vmDidSelectSellBanner(_ type: String) {}
    func vmDidSelectCollection(_ type: CollectionCellType) {}
}

protocol ProductListRequester: class {
    var itemsPerPage: Int { get }
    func canRetrieve() -> Bool
    func retrieveFirstPage(_ completion: ListingsCompletion?)
    func retrieveNextPage(_ completion: ListingsCompletion?)
    func isLastPage(_ resultCount: Int) -> Bool
    func updateInitialOffset(_ newOffset: Int)
    func duplicate() -> ProductListRequester
}


class ProductListViewModel: BaseViewModel {
    
    // MARK: - Constants
    private static let cellMinHeight: CGFloat = 80.0
    private static let cellAspectRatio: CGFloat = 198.0 / cellMinHeight
    private static let cellBannerAspectRatio: CGFloat = 1.3
    private static let cellMaxThumbFactor: CGFloat = 2.0
    
    var cellWidth: CGFloat {
        return (UIScreen.main.bounds.size.width - (productListFixedInset*2)) / CGFloat(numberOfColumns)
    }

    var cellStyle: CellStyle {
        return numberOfColumns > 2 ? .small : .big
    }
    
    var productListFixedInset: CGFloat = 10.0
    
    // MARK: - iVars 

    // Delegates
    weak var delegate: ProductListViewModelDelegate?
    weak var dataDelegate: ProductListViewModelDataDelegate?
    
    // Requester
    let productListRequester: ProductListRequester?

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
    
    // Tracking
    
    fileprivate let tracker: Tracker

    // MARK: - Computed iVars
    
    var numberOfProducts: Int {
        return objects.count
    }
    
    let numberOfColumns: Int

    
    // MARK: - Lifecycle

    init(requester: ProductListRequester?, products: [Product]? = nil, numberOfColumns: Int = 2,
         tracker: Tracker = TrackerProxy.sharedInstance) {
        self.objects = (products ?? []).map(ProductCellModel.init)
        self.pageNumber = 0
        self.refreshing = false
        self.state = .loading
        self.numberOfColumns = numberOfColumns
        self.productListRequester = requester
        self.defaultCellSize = CGSize.zero
        self.tracker = tracker
        super.init()
        let cellHeight = cellWidth * ProductListViewModel.cellAspectRatio
        self.defaultCellSize = CGSize(width: cellWidth, height: cellHeight)
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
            delegate?.vmDidFinishLoading(self, page: 0, indexes: [])
        }
    }

    func setErrorState(_ viewModel: LGEmptyViewModel) {
        state = .error(viewModel)
        if let errorReason = viewModel.emptyReason {
             trackErrorStateShown(reason: errorReason)
        }
    }

    func setEmptyState(_ viewModel: LGEmptyViewModel) {
        state = .empty(viewModel)
        objects = [ProductCellModel.emptyCell(vm: viewModel)]
    }

    func refreshControlTriggered() {
        refresh()
    }

    func reloadData() {
        delegate?.vmReloadData(self)
    }
    
    @discardableResult func retrieveProducts() -> Bool {
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
        pageNumber = 0
        refreshing = false
        state = .loading
        isLastPage = false
        isLoading = false
        isOnErrorState = false
        clearList()
    }

    func update(product: Product) {
        guard state.isData, let productId = product.objectId else { return }
        guard let index = indexFor(productId: productId) else { return }
        objects[index] = ProductCellModel(product: product)
        delegate?.vmReloadData(self)
    }

    func prepend(product: Product) {
        guard state.isData else { return }
        objects.insert(ProductCellModel(product: product), at: 0)
        delegate?.vmReloadData(self)
    }

    func delete(productId: String) {
        guard state.isData else { return }
        guard let index = indexFor(productId: productId) else { return }
        objects.remove(at: index)
        delegate?.vmReloadData(self)
    }

    private func retrieveProducts(firstPage: Bool) {
        guard let productListRequester = productListRequester else { return } //Should not happen

        isLoading = true
        isOnErrorState = false

        if firstPage && numberOfProducts == 0 {
            state = .loading
        }
        
        let completion: ListingsCompletion = { [weak self] result in
            guard let strongSelf = self else { return }
            let nextPageNumber = firstPage ? 0 : strongSelf.pageNumber + 1
            self?.isLoading = false
            if let newProducts = result.value?.flatMap({ $0.product }) {
                let productCellModels = newProducts.map(ProductCellModel.init)
                let cellModels = self?.dataDelegate?.vmProcessReceivedProductPage(productCellModels, page: nextPageNumber) ?? productCellModels
                let indexes: [Int]
                if firstPage {
                    strongSelf.objects = cellModels
                    strongSelf.refreshing = false
                    indexes = [Int](0 ..< cellModels.count)
                } else {
                    let currentCount = strongSelf.numberOfProducts
                    strongSelf.objects += cellModels
                    indexes = [Int](currentCount ..< (currentCount+cellModels.count))
                }
                strongSelf.pageNumber = nextPageNumber
                let hasProducts = strongSelf.numberOfProducts > 0
                strongSelf.isLastPage = strongSelf.productListRequester?.isLastPage(newProducts.count) ?? true
                //This assignment should be ALWAYS before calling the delegates to give them the option to re-set the state
                strongSelf.state = .data
                strongSelf.delegate?.vmDidFinishLoading(strongSelf, page: nextPageNumber, indexes: indexes)
                strongSelf.dataDelegate?.productListVM(strongSelf, didSucceedRetrievingProductsPage: nextPageNumber,
                                                       hasProducts: hasProducts)
            } else if let error = result.error {
                strongSelf.processError(error, nextPageNumber: nextPageNumber)
            }
        }

        if firstPage {
            productListRequester.retrieveFirstPage(completion)
        } else {
            productListRequester.retrieveNextPage(completion)
        }
    }

    private func processError(_ error: RepositoryError, nextPageNumber: UInt) {
        isOnErrorState = true
        let hasProducts = objects.count > 0
        delegate?.vmDidFinishLoading(self, page: nextPageNumber, indexes: [])
        dataDelegate?.productListMV(self, didFailRetrievingProductsPage: nextPageNumber,
                                               hasProducts: hasProducts, error: error)
    }

    func selectedItemAtIndex(_ index: Int, thumbnailImage: UIImage?, originFrame: CGRect?) {
        guard let item = itemAtIndex(index) else { return }        
        switch item {
        case .productCell:
            dataDelegate?.productListVM(self, didSelectItemAtIndex: index, thumbnailImage: thumbnailImage,
                                        originFrame: originFrame)
        case .collectionCell(let type):
            dataDelegate?.vmDidSelectCollection(type)
        case .emptyCell:
            return
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
    func itemAtIndex(_ index: Int) -> ProductCellModel? {
        guard 0..<numberOfProducts ~= index else { return nil }
        return objects[index]
    }

    func productAtIndex(_ index: Int) -> Product? {
        guard 0..<numberOfProducts ~= index else { return nil }
        let item = objects[index]
        switch item {
        case .productCell(let product):
            return product
        case .collectionCell, .emptyCell:
            return nil
        }
    }

    func indexFor(productId: String) -> Int? {
        return objects.index(where: { cellModel in
            switch cellModel {
            case let .productCell(cellProduct):
                return cellProduct.objectId == productId
            case .collectionCell, .emptyCell:
                return false
            }
        })
    }

    /**
        Returns the size of the cell at the given index path.
    
        - parameter index: The index of the product.
        - returns: The cell size.
    */
    func sizeForCellAtIndex(_ index: Int) -> CGSize {
        guard let item = itemAtIndex(index) else { return defaultCellSize }
        switch item {
        case .productCell(let product):
            guard let thumbnailSize = product.thumbnailSize, thumbnailSize.height != 0 && thumbnailSize.width != 0
                else { return defaultCellSize }
            
            let thumbFactor = min(ProductListViewModel.cellMaxThumbFactor,
                                  CGFloat(thumbnailSize.height / thumbnailSize.width))
            let imageFinalHeight = max(ProductListViewModel.cellMinHeight, round(defaultCellSize.width * thumbFactor))
            return CGSize(width: defaultCellSize.width, height: imageFinalHeight)

        case .collectionCell:
            let height = defaultCellSize.width*ProductListViewModel.cellBannerAspectRatio
            return CGSize(width: defaultCellSize.width, height: height)
        case .emptyCell:
            return CGSize(width: defaultCellSize.width, height: 1)
        }
    }
        
    /**
        Sets which item is currently visible on screen. If it exceeds a certain threshold then it loads next page,
        if possible.
    
        - parameter index: The index of the product currently visible on screen.
    */
    func setCurrentItemIndex(_ index: Int) {
        guard let itemsPerPage = productListRequester?.itemsPerPage, numberOfProducts > 0 else { return }
        let threshold = numberOfProducts - Int(Float(itemsPerPage)*Constants.productsPagingThresholdPercentage)
        let shouldRetrieveProductsNextPage = index >= threshold && !isOnErrorState
        if shouldRetrieveProductsNextPage {
            retrieveProductsNextPage()
        }
    }
}


// MARK: - Tracking

extension ProductListViewModel {
    func trackErrorStateShown(reason: EventParameterEmptyReason) {
        let event = TrackerEvent.emptyStateVisit(typePage: .productList , reason: reason)
        tracker.trackEvent(event)
    }
}

