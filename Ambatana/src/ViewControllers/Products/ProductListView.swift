//
//  ProductListView.swift
//  LetGo
//
//  Created by AHL on 9/7/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import UIKit

protocol ProductListViewDataDelegate: class {
    func productListView(productListView: ProductListView, didFailRetrievingProductsPage page: UInt, error: ProductsRetrieveServiceError)
    func productListView(productListView: ProductListView, didSucceedRetrievingProductsPage page: UInt)
    func productListView(productListView: ProductListView, didSelectItemAtIndexPath indexPath: NSIndexPath)
}

enum ProductListViewState {
    case FirstLoadView
    case DataView
    case ErrorView(errImage: UIImage?, errTitle: String?, errBody: String?, errButTitle: String?, errButAction: () -> Void)
}

class ProductListView: BaseView, CHTCollectionViewDelegateWaterfallLayout, ProductListViewModelDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // Constants
    
    // UI
    @IBOutlet weak private var contentView: UIView!
    
    // > First load
    @IBOutlet weak var firstLoadView: UIView!
    @IBOutlet weak var firstLoadActivityIndicator: UIActivityIndicatorView!
    
    // > Data
    @IBOutlet weak var dataView: UIView!
    var refreshControl: UIRefreshControl!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // > Error
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorImageView: UIImageView!
    @IBOutlet weak var errorTitleLabel: UILabel!
    @IBOutlet weak var errorBodyLabel: UILabel!
    @IBOutlet weak var errorButton: UIButton!

    // Data
    internal(set) var productListViewModel: ProductListViewModel
    
    var state: ProductListViewState {
        didSet {
            switch (state) {
            case .FirstLoadView:
                // Show/hide views
                firstLoadView.hidden = false
                dataView.hidden = true
                errorView.hidden = true
            case .DataView:
                // Show/hide views
                firstLoadView.hidden = true
                dataView.hidden = false
                errorView.hidden = true
            case .ErrorView(let errImage, let errTitle, let errBody, let errButTitle, let errButAction):
                // UI
                // > Labels
                errorTitleLabel.text = errTitle
                errorBodyLabel.text = errBody
                errorButton.setTitle(errButTitle, forState: .Normal)
                
                // Show/hide views
                firstLoadView.hidden = true
                dataView.hidden = true
                errorView.hidden = false
            }
        }
    }
    
    // Delegate
    var delegate: ProductListViewDataDelegate?
    
    // MARK: - Lifecycle
    
    init(viewModel: ProductListViewModel, frame: CGRect) {
        self.state = .FirstLoadView
        self.productListViewModel = viewModel
        super.init(viewModel: viewModel, frame: frame)
        
        viewModel.delegate = self
        setupUI()
    }
    
    init(viewModel: ProductListViewModel, coder aDecoder: NSCoder) {
        self.state = .FirstLoadView
        self.productListViewModel = viewModel
        super.init(viewModel: viewModel, coder: aDecoder)

        viewModel.delegate = self
        setupUI()
    }

    required convenience init(coder aDecoder: NSCoder) {
        self.init(viewModel: ProductListViewModel(), coder: aDecoder)
    }
    
    // MARK: Public methods

    // MARK: > Computed variables
   
    var queryString: String? {
        get {
            return productListViewModel.queryString
        }
        set {
            productListViewModel.queryString = newValue
        }
    }
    var coordinates: LGLocationCoordinates2D? {
        get {
            return productListViewModel.coordinates
        }
        set {
            productListViewModel.coordinates = newValue
        }
    }
    var categories: [ProductCategory]? {
        get {
            return productListViewModel.categories
        }
        set {
            productListViewModel.categories = newValue
        }
    }
    var sortCriteria: ProductSortCriteria? {
        get {
            return productListViewModel.sortCriteria
        }
        set {
            productListViewModel.sortCriteria = newValue
        }
    }
    var maxPrice: Int? {
        get {
            return productListViewModel.maxPrice
        }
        set {
            productListViewModel.maxPrice = newValue
        }
    }
    var minPrice: Int? {
        get {
            return productListViewModel.minPrice
        }
        set {
            productListViewModel.minPrice = newValue
        }
    }
    var userObjectId: String? {
        get {
            return productListViewModel.userObjectId
        }
        set {
            productListViewModel.userObjectId = newValue
        }
    }
    
    // MARK: > Actions
    
    func refresh() {
        if productListViewModel.canRetrieveProducts {
            productListViewModel.retrieveProductsFirstPage()
        }
        else {
            refreshControl.endRefreshing()
        }
    }
    
    func retrieveProductsNextPage() {
        productListViewModel.retrieveProductsNextPage()
    }
    
    // MARK: > Data
    
    /**
        Returns the product at the given index.
    
        :param: index The index of the product.
        :returns: The product.
    */
    func productAtIndex(index: Int) -> Product {
        return productListViewModel.productAtIndex(index)
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return productListViewModel.sizeForCellAtIndex(indexPath.row)
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, columnCountForSection section: Int) -> Int {
        return productListViewModel.numberOfColumns
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productListViewModel.numberOfProducts
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let product = productListViewModel.productAtIndex(indexPath.row)
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ProductCell", forIndexPath: indexPath) as! ProductCell
        cell.tag = indexPath.hash
        
        // TODO: VC should not handle data -> ask to VM about title etc etc...
        cell.setupCellWithProduct(product, indexPath: indexPath)
        
        productListViewModel.setCurrentItemIndex(indexPath.row)
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        delegate?.productListView(self, didSelectItemAtIndexPath: indexPath)
    }
    
    // MARK: - ProductListViewModelDelegate
    
    func viewModel(viewModel: ProductListViewModel, didStartRetrievingProductsPage page: UInt) {
        // If it's the first page & there are no products, then set the loading state
        if page == 0 && viewModel.numberOfProducts == 0 {
            state = .FirstLoadView
        }
    }
    
    func viewModel(viewModel: ProductListViewModel, didFailRetrievingProductsPage page: UInt, error: ProductsRetrieveServiceError) {
        // IMPORTANT: Update of the UI should be done via delegate or in a subclass of ProductListView
        
        // Notify the delegate
        delegate?.productListView(self, didFailRetrievingProductsPage: page, error: error)
    }
    
    func viewModel(viewModel: ProductListViewModel, didSucceedRetrievingProductsPage page: UInt, atIndexPaths indexPaths: [NSIndexPath]) {
        
        // Update the UI
        if page == 0 {
            state = .DataView

            refreshControl.endRefreshing()
            collectionView.reloadSections(NSIndexSet(index: 0))
        }
        else {
            collectionView.insertItemsAtIndexPaths(indexPaths)
        }
        
        // Notify the delegate
        delegate?.productListView(self, didSucceedRetrievingProductsPage: page)
    }
    
    // MARK: - Private methods
    
    // MARK: > UI
    
    /**
        Sets up the UI.
    */
    private func setupUI() {
        // Load the view, and add it as Subview
        NSBundle.mainBundle().loadNibNamed("ProductListView", owner: self, options: nil)
        contentView.frame = self.bounds
        contentView.autoresizingMask = .FlexibleHeight | .FlexibleWidth
        self.addSubview(contentView)
        
        // Setup UI
        // > Data
        var layout = CHTCollectionViewWaterfallLayout()
        layout.minimumColumnSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        self.collectionView.autoresizingMask = UIViewAutoresizing.FlexibleHeight // | UIViewAutoresizing.FlexibleWidth
        collectionView.alwaysBounceVertical = true
        collectionView.collectionViewLayout = layout
        
        let cellNib = UINib(nibName: "ProductCell", bundle: nil)
        self.collectionView.registerNib(cellNib, forCellWithReuseIdentifier: "ProductCell")
        
        // >> Pull to refresh
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.collectionView.addSubview(refreshControl)
        
        // > Error View
        errorButton.addTarget(self, action: Selector("errorButtonPressed"), forControlEvents: .TouchUpInside)
        
        // Initial UI state is Loading (by xib)
    }
    
    /**
        Called when the error button is pressed.
    */
    @objc private func errorButtonPressed() {
        switch state {
        case .ErrorView(_, _, _, _, let errButAction):
            errButAction()
        default:
            break
        }
    }
}
