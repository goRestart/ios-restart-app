//
//  ProductListView.swift
//  LetGo
//
//  Created by AHL on 9/7/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import CHTCollectionViewWaterfallLayout
import LGCoreKit
import UIKit

public protocol ProductListViewDataDelegate: class {
    func productListView(productListView: ProductListView, didFailRetrievingProductsPage page: UInt, error: ProductsRetrieveServiceError)
    func productListView(productListView: ProductListView, didSucceedRetrievingProductsPage page: UInt)
    func productListView(productListView: ProductListView, didSelectItemAtIndexPath indexPath: NSIndexPath)
}

public enum ProductListViewState {
    case FirstLoadView
    case DataView
    case ErrorView(errImage: UIImage?, errTitle: String?, errBody: String?, errButTitle: String?, errButAction: (() -> Void)?)
}

public class ProductListView: BaseView, CHTCollectionViewDelegateWaterfallLayout, ProductListViewModelDataDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // Constants
    private static let defaultErrorButtonHeight: CGFloat = 44
    
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
    @IBOutlet weak var errorImageViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var errorTitleLabel: UILabel!
    @IBOutlet weak var errorBodyLabel: UILabel!
    @IBOutlet weak var errorButton: UIButton!
    @IBOutlet weak var errorButtonHeightConstraint: NSLayoutConstraint!
    
    // > Insets
    @IBOutlet var topInsetConstraints: [NSLayoutConstraint]!
    @IBOutlet var leftInsetConstraints: [NSLayoutConstraint]!
    @IBOutlet var bottomInsetConstraints: [NSLayoutConstraint]!
    @IBOutlet var rightInsetConstraints: [NSLayoutConstraint]!
    
    public var contentInset: UIEdgeInsets {
        didSet {
            for constraint in topInsetConstraints {
                constraint.constant = contentInset.top
            }
            for constraint in leftInsetConstraints {
                constraint.constant = contentInset.left
            }
            for constraint in bottomInsetConstraints {
                constraint.constant = contentInset.bottom
            }
            for constraint in rightInsetConstraints {
                constraint.constant = contentInset.right
            }
            firstLoadView.updateConstraintsIfNeeded()
            dataView.updateConstraintsIfNeeded()
            errorView.updateConstraintsIfNeeded()
        }
    }
    
    // Data
    internal(set) var productListViewModel: ProductListViewModel
    
    // > Computed iVars
    
    public var state: ProductListViewState {
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
                errorImageView.image = errImage
                // > If there's no image then hide it
                if let actualErrImage = errImage {
                    errorImageViewHeightConstraint.constant = actualErrImage.size.height
                }
                else {
                    errorImageViewHeightConstraint.constant = 0
                }
                errorTitleLabel.text = errTitle
                errorBodyLabel.text = errBody
                errorButton.setTitle(errButTitle, forState: .Normal)
                // > If there's no button title or action then hide it
                if errButTitle != nil && errButAction != nil {
                    errorButtonHeightConstraint.constant = ProductListView.defaultErrorButtonHeight
                }
                else {
                    errorButtonHeightConstraint.constant = 0
                }
                errorView.updateConstraintsIfNeeded()
                
                // Show/hide views
                firstLoadView.hidden = true
                dataView.hidden = true
                errorView.hidden = false
            }
        }
    }
    
    public var queryString: String? {
        get {
            return productListViewModel.queryString
        }
        set {
            productListViewModel.queryString = newValue
        }
    }
    public var coordinates: LGLocationCoordinates2D? {
        get {
            return productListViewModel.coordinates
        }
        set {
            productListViewModel.coordinates = newValue
        }
    }
    public var categories: [ProductCategory]? {
        get {
            return productListViewModel.categories
        }
        set {
            productListViewModel.categories = newValue
        }
    }
    public var sortCriteria: ProductSortCriteria? {
        get {
            return productListViewModel.sortCriteria
        }
        set {
            productListViewModel.sortCriteria = newValue
        }
    }
    public var maxPrice: Int? {
        get {
            return productListViewModel.maxPrice
        }
        set {
            productListViewModel.maxPrice = newValue
        }
    }
    public var minPrice: Int? {
        get {
            return productListViewModel.minPrice
        }
        set {
            productListViewModel.minPrice = newValue
        }
    }
    public var userObjectId: String? {
        get {
            return productListViewModel.userObjectId
        }
        set {
            productListViewModel.userObjectId = newValue
        }
    }
    public var isEmpty: Bool {
        get {
            return productListViewModel.numberOfProducts == 0
        }
    }
    
    // Delegate
    public var delegate: ProductListViewDataDelegate?
    
    // MARK: - Lifecycle
    
    public init(viewModel: ProductListViewModel, frame: CGRect) {
        self.state = .FirstLoadView
        self.productListViewModel = viewModel
        self.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        super.init(viewModel: viewModel, frame: frame)
        
        viewModel.dataDelegate = self
        setupUI()
    }
    
    public init(viewModel: ProductListViewModel, coder aDecoder: NSCoder) {
        self.state = .FirstLoadView
        self.productListViewModel = viewModel
        self.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        super.init(viewModel: viewModel, coder: aDecoder)

        viewModel.dataDelegate = self
        setupUI()
    }

    public required convenience init(coder aDecoder: NSCoder) {
        self.init(viewModel: ProductListViewModel(), coder: aDecoder)
    }
    
    // MARK: Public methods
    
    // MARK: > Actions
    
    /**
        Retrieves the products first page.
    */
    public func refresh() {
        if productListViewModel.canRetrieveProducts {
            productListViewModel.retrieveProductsFirstPage()
        }
        else {
            refreshControl.endRefreshing()
        }
    }
    
    /**
        Retrieves the products next page.
    */
    public func retrieveProductsNextPage() {
        if productListViewModel.canRetrieveProductsNextPage {
            productListViewModel.retrieveProductsNextPage()
        }
    }
    
    // MARK: > UI
    
    /**
        Refreshes the user interface.
    */
    public func refreshUI() {
        collectionView.reloadSections(NSIndexSet(index: 0))
    }
    
    // MARK: > Data
    
    /**
        Returns the product at the given index.
    
        :param: index The index of the product.
        :returns: The product.
    */
    public func productAtIndex(index: Int) -> Product {
        return productListViewModel.productAtIndex(index)
    }
    
    // MARK: - UICollectionViewDataSource
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return productListViewModel.sizeForCellAtIndex(indexPath.row)
    }
    
    public func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, columnCountForSection section: Int) -> Int {
        return productListViewModel.numberOfColumns
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productListViewModel.numberOfProducts
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let product = productListViewModel.productAtIndex(indexPath.row)
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ProductCell", forIndexPath: indexPath) as! ProductCell
        cell.tag = indexPath.hash
        
        // TODO: VC should not handle data -> ask to VM about title etc etc...
        cell.setupCellWithProduct(product, indexPath: indexPath)
        
        productListViewModel.setCurrentItemIndex(indexPath.row)
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        delegate?.productListView(self, didSelectItemAtIndexPath: indexPath)
    }
    
    // MARK: - ProductListViewModelDataDelegate
    
    public func viewModel(viewModel: ProductListViewModel, didStartRetrievingProductsPage page: UInt) {
        // If it's the first page & there are no products, then set the loading state
        if page == 0 && viewModel.numberOfProducts == 0 {
            state = .FirstLoadView
        }
    }
    
    public func viewModel(viewModel: ProductListViewModel, didFailRetrievingProductsPage page: UInt, error: ProductsRetrieveServiceError) {
        // Notify the delegate
        delegate?.productListView(self, didFailRetrievingProductsPage: page, error: error)
    }
    
    public func viewModel(viewModel: ProductListViewModel, didSucceedRetrievingProductsPage page: UInt, atIndexPaths indexPaths: [NSIndexPath]) {
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
        errorButtonHeightConstraint.constant = ProductListView.defaultErrorButtonHeight
        errorButton.addTarget(self, action: Selector("errorButtonPressed"), forControlEvents: .TouchUpInside)
        
        // Initial UI state is Loading (by xib)
    }
    
    /**
        Called when the error button is pressed.
    */
    @objc private func errorButtonPressed() {
        switch state {
        case .ErrorView(_, _, _, _, let errButAction):
            errButAction?()
        default:
            break
        }
    }
}
