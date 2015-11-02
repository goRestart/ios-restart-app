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
    func productListView(productListView: ProductListView, didStartRetrievingProductsPage page: UInt)
    func productListView(productListView: ProductListView, didFailRetrievingProductsPage page: UInt, hasProducts: Bool, error: ProductsRetrieveServiceError)
    func productListView(productListView: ProductListView, didSucceedRetrievingProductsPage page: UInt, hasProducts: Bool)
    func productListView(productListView: ProductListView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    func productListView(productListView: ProductListView, shouldUpdateDistanceLabel distance: Int, withDistanceType type: DistanceType)
    func productListView(productListView: ProductListView, shouldHideDistanceLabel hidden: Bool)
    func productListView(productListView: ProductListView, shouldHideFloatingSellButton hidden: Bool)
}



public enum ProductListViewState {
    case FirstLoadView
    case DataView
    case ErrorView(errBgColor: UIColor?, errBorderColor: UIColor?, errImage: UIImage?, errTitle: String?, errBody: String?, errButTitle: String?, errButAction: (() -> Void)?)
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
    var collectionViewFooterHeight: CGFloat
    
    private var lastContentOffset: CGFloat
    private var maxDistance: Float
    private var scrollingDown: Bool
    private var refreshing: Bool
    
    // > Error
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorContentView: UIView!
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
            case .ErrorView(let errBgColor, let errBorderColor, let errImage, let errTitle, let errBody, let errButTitle, let errButAction):
                // UI
                errorView.backgroundColor = errBgColor
                errorContentView.layer.borderColor = errBorderColor?.CGColor
                errorContentView.layer.borderWidth = errBorderColor != nil ? 0.5 : 0
                errorContentView.layer.cornerRadius = 4
                
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
    
    // Delegate
    weak public var delegate: ProductListViewDataDelegate?
    
    // MARK: - Lifecycle
    
    public init(viewModel: ProductListViewModel, frame: CGRect) {
        self.state = .FirstLoadView
        self.productListViewModel = viewModel
        self.collectionViewFooterHeight = 0
        self.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.maxDistance = 1
        self.lastContentOffset = 0
        self.scrollingDown = true
        self.refreshing = false
        super.init(viewModel: viewModel, frame: frame)
        
        viewModel.dataDelegate = self
        setupUI()
    }
    
    public init?(viewModel: ProductListViewModel, coder aDecoder: NSCoder) {
        self.state = .FirstLoadView
        self.productListViewModel = viewModel
        self.collectionViewFooterHeight = 0
        self.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.maxDistance = 1
        self.lastContentOffset = 0
        self.scrollingDown = true
        self.refreshing = false
        super.init(viewModel: viewModel, coder: aDecoder)

        viewModel.dataDelegate = self
        setupUI()
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        self.init(viewModel: ProductListViewModel(), coder: aDecoder)
    }
    
    internal override func didSetActive(active: Bool) {
        super.didSetActive(active)
        if active {
            refreshUI()
        }
    }
    
    
    // MARK: Public methods
    
    // MARK: > Actions
    
    /**
        Retrieves the products first page.
    */
    public func refresh() {
        refreshing = true
        if productListViewModel.canRetrieveProducts {
            maxDistance = 1
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
        maxDistance = 1
        collectionView.reloadData()
    }
    
    // MARK: > ViewModel
    
    /**
        Returns the product view model for the given index.
    
        - parameter index: The index of the product.
        - returns: The product view model.
    */
    public func productViewModelForProductAtIndex(index: Int) -> ProductViewModel {
        let product = productAtIndex(index)
        return ProductViewModel(product: product, tracker: TrackerProxy.sharedInstance)
    }
    
    // MARK: - UICollectionViewDataSource
    
    public func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, heightForFooterInSection section: Int) -> CGFloat {
        return collectionViewFooterHeight
    }
    
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
        
        let product = productListViewModel.productAtIndex(indexPath.item)
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ProductCell", forIndexPath: indexPath) as! ProductCell
        cell.tag = indexPath.hash
        
        // TODO: VC should not handle data -> ask to VM about title etc etc...
        cell.setupCellWithProduct(product, indexPath: indexPath)
        
        productListViewModel.setCurrentItemIndex(indexPath.item)

        // Decides the product of which we will show distance to shoew in the label
        let topProduct: Product
        
        if !collectionView.indexPathsForVisibleItems().isEmpty {
            
            // show distance of the FIRST VISIBLE cell, must loop bc "indexPathsForVisibleItems" gives an unordered array
            var lowerIndex = indexPath.item
            for index in collectionView.indexPathsForVisibleItems() {
                if index.item < lowerIndex {
                    lowerIndex = index.item
                }
            }
            
            topProduct = productListViewModel.productAtIndex(lowerIndex)
            
        } else {
            // the 1st appeareance of the 1st cell doesn't know about visible cells yet
            topProduct = product
        }
        
 
        let distance = Float(productListViewModel.distanceFromProductCoordinates(topProduct.location))
        
        // instance var max distance or MIN distance to avoid updating the label everytime
        if scrollingDown && distance > maxDistance {
            maxDistance = distance
        } else if !scrollingDown && distance < maxDistance {
            maxDistance = distance
        } else if refreshing {
            maxDistance = distance
        }
        
        delegate?.productListView(self, shouldUpdateDistanceLabel: max(1,Int(round(maxDistance))), withDistanceType: productListViewModel.queryDistanceType())
        
        return cell
    }
    
    
    // MARK: - UICollectionViewDelegate
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        delegate?.productListView(self, didSelectItemAtIndexPath: indexPath)
    }
    
    // MARK: - UIScrollViewDelegate
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        
        // when refreshing the distance label should be hidden
        if lastContentOffset >= 0 && scrollView.contentOffset.y < 0 {
            delegate?.productListView(self, shouldHideDistanceLabel: true)
        } else if lastContentOffset < 0 && scrollView.contentOffset.y >= 0 {
            delegate?.productListView(self, shouldHideDistanceLabel: false)
        }
        
        // while going down, increase distance in label, when going up, decrease
        if lastContentOffset >= scrollView.contentOffset.y {
            scrollingDown = false
        } else {
            scrollingDown = true
        }
        lastContentOffset = scrollView.contentOffset.y
    }
    
    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        delegate?.productListView(self, shouldHideFloatingSellButton: true)
    }

    public func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let moving = abs(velocity.y) > 0
        delegate?.productListView(self, shouldHideFloatingSellButton: moving)
    }
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        delegate?.productListView(self, shouldHideFloatingSellButton: false)
    }
    
    // MARK: - ProductListViewModelDataDelegate
    
    public func viewModel(viewModel: ProductListViewModel, didStartRetrievingProductsPage page: UInt) {
        // If it's the first page & there are no products, then set the loading state
        if page == 0 && viewModel.numberOfProducts == 0 {
            state = .FirstLoadView
        }
        
        // Notify the delegate
        delegate?.productListView(self, didStartRetrievingProductsPage: page)
    }
    
    public func viewModel(viewModel: ProductListViewModel, didFailRetrievingProductsPage page: UInt, hasProducts: Bool, error: ProductsRetrieveServiceError) {
        
        // Update the UI
        if page == 0 {
            refreshControl.endRefreshing()
        }
        
        // Notify the delegate
        delegate?.productListView(self, didFailRetrievingProductsPage: page, hasProducts: hasProducts, error: error)
    }
    
    public func viewModel(viewModel: ProductListViewModel, didSucceedRetrievingProductsPage page: UInt, hasProducts: Bool, atIndexPaths indexPaths: [NSIndexPath]) {
        // Update the UI
        if page == 0 {
            state = .DataView
            maxDistance = 1

//            collectionView.reloadSections(NSIndexSet(index: 0))
            collectionView.reloadData()
            
            refreshControl.endRefreshing()
            refreshing = false
        }
        else {
            collectionView.insertItemsAtIndexPaths(indexPaths)
        }
        
        // Notify the delegate
        delegate?.productListView(self, didSucceedRetrievingProductsPage: page, hasProducts: hasProducts)
    }
    
    // MARK: - Private methods
    
    // MARK: > UI
    
    /**
        Sets up the UI.
    */
    
    // MARK: > UI
    
    
    private func setupUI() {
        // Load the view, and add it as Subview
        NSBundle.mainBundle().loadNibNamed("ProductListView", owner: self, options: nil)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        self.addSubview(contentView)
        
        // Setup UI
        // > Data
        let layout = CHTCollectionViewWaterfallLayout()
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
        errorButton.layer.cornerRadius = 4
        errorButton.setBackgroundImage(errorButton.backgroundColor?.imageWithSize(CGSize(width: 1, height: 1)), forState: .Normal)
        errorButton.addTarget(self, action: Selector("errorButtonPressed"), forControlEvents: .TouchUpInside)
        
        // Initial UI state is Loading (by xib)
    }
    
    /**
        Called when the error button is pressed.
    */
    @objc private func errorButtonPressed() {
        switch state {
        case .ErrorView(_, _, _, _, _, _, let errButAction):
            errButAction?()
        default:
            break
        }
    }
    
    /**
        Returns the product at the given index.
    
        - parameter index: The index of the product.
        - returns: The product.
    */
    private func productAtIndex(index: Int) -> Product {
        return productListViewModel.productAtIndex(index)
    }
}
