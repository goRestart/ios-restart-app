//
//  ProductListView.swift
//  LetGo
//
//  Created by AHL on 9/7/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import UIKit

protocol ProductListViewDelegate: class {
    func productListView(productListView: ProductListView, didStartRetrievingProductsPage page: UInt)
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
    private(set) var viewModel: ProductListViewModel
    
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
    var delegate: ProductListViewDelegate?
    
    // MARK: - Lifecycle
    
    required init(frame: CGRect) {
        self.state = .FirstLoadView
        self.viewModel = ProductListViewModel()
        super.init(viewModel: viewModel, frame: frame)
        self.setupUI()
    }
    
    required init(coder aDecoder: NSCoder) {
        self.state = .FirstLoadView
        self.viewModel = ProductListViewModel()
        super.init(viewModel: viewModel, coder: aDecoder)
        self.setupUI()
    }
    
    // MARK: Public methods

    // MARK: > Computed variables
   
    var queryString: String? {
        get {
            return viewModel.queryString
        }
        set {
            viewModel.queryString = newValue
        }
    }
    var coordinates: LGLocationCoordinates2D? {
        get {
            return viewModel.coordinates
        }
        set {
            viewModel.coordinates = newValue
        }
    }
    var categories: [ProductCategory]? {
        get {
            return viewModel.categories
        }
        set {
            viewModel.categories = newValue
        }
    }
    var sortCriteria: ProductSortCriteria? {
        get {
            return viewModel.sortCriteria
        }
        set {
            viewModel.sortCriteria = newValue
        }
    }
    var maxPrice: Int? {
        get {
            return viewModel.maxPrice
        }
        set {
            viewModel.maxPrice = newValue
        }
    }
    var minPrice: Int? {
        get {
            return viewModel.minPrice
        }
        set {
            viewModel.minPrice = newValue
        }
    }
    var userObjectId: String? {
        get {
            return viewModel.userObjectId
        }
        set {
            viewModel.userObjectId = newValue
        }
    }
    
    var isEmpty: Bool {
        get {
            return viewModel.numberOfProducts == 0
        }
    }
    
    // MARK: > Actions
    
    func refresh() {
        if viewModel.canRetrieveProducts {
            viewModel.retrieveProductsFirstPage()
        }
        else {
            refreshControl.endRefreshing()
        }
    }
    
    func retrieveProductsNextPage() {
        viewModel.retrieveProductsNextPage()
    }
    
    // MARK: > Data
    
    /**
        Returns the product at the given index.
    
        :param: index The index of the product.
        :returns: The product.
    */
    func productAtIndex(index: Int) -> Product {
        return viewModel.productAtIndex(index)
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return viewModel.sizeForCellAtIndex(indexPath.row)
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, columnCountForSection section: Int) -> Int {
        return viewModel.numberOfColumns
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfProducts
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let product = viewModel.productAtIndex(indexPath.row)
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ProductCell", forIndexPath: indexPath) as! ProductCell
        cell.tag = indexPath.hash
        
        // TODO: VC should not handle data -> ask to VM about title etc etc...
        cell.setupCellWithProduct(product, indexPath: indexPath)
        
        viewModel.setCurrentItemIndex(indexPath.row)
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        delegate?.productListView(self, didSelectItemAtIndexPath: indexPath)
    }
    
    // MARK: - ProductListViewModelDelegate
    
    func viewModel(viewModel: ProductListViewModel, didStartRetrievingProductsPage page: UInt) {
        delegate?.productListView(self, didStartRetrievingProductsPage: page)
    }
    
    func viewModel(viewModel: ProductListViewModel, didFailRetrievingProductsPage page: UInt, error: ProductsRetrieveServiceError) {
        delegate?.productListView(self, didFailRetrievingProductsPage: page, error: error)
    }
    
    func viewModel(viewModel: ProductListViewModel, didSucceedRetrievingProductsPage page: UInt, atIndexPaths indexPaths: [NSIndexPath]) {
        delegate?.productListView(self, didSucceedRetrievingProductsPage: page)
    }
    
    // MARK: - Private methods
    
    // MARK: > UI
    
    private func setupUI() {
        // Load the view
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
    
    @objc private func errorButtonPressed() {
        switch state {
        case .ErrorView(_, _, _, _, let errButAction):
            errButAction()
        default:
            break
        }
    }
}
