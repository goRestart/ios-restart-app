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
    func productListView(productListView: ProductListView, didFailRetrievingProductsPage page: UInt, hasProducts: Bool,
        error: RepositoryError)
    func productListView(productListView: ProductListView, didSucceedRetrievingProductsPage page: UInt,
        hasProducts: Bool)
    func productListView(productListView: ProductListView, didSelectItemAtIndexPath indexPath: NSIndexPath,
        thumbnailImage: UIImage?)
}

public protocol ProductListViewScrollDelegate: class {
    func productListView(productListView: ProductListView, didScrollDown scrollDown: Bool)
}

public enum ProductListViewState {
    case FirstLoadView
    case DataView
    case ErrorView(errBgColor: UIColor?, errBorderColor: UIColor?, errImage: UIImage?, errTitle: String?,
        errBody: String?, errButTitle: String?, errButAction: (() -> Void)?)
}

public class ProductListView: BaseView, CHTCollectionViewDelegateWaterfallLayout, ProductListViewModelDataDelegate,
UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

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
    
    private var lastContentOffset: CGFloat
    private var scrollingDown: Bool
    
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
    public var collectionViewContentInset: UIEdgeInsets {
        didSet {
            collectionView.contentInset = collectionViewContentInset
        }
    }
    public var defaultCellSize: CGSize {
        return productListViewModel.defaultCellSize
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
            case .ErrorView(let errBgColor, let errBorderColor, let errImage, let errTitle, let errBody,
                let errButTitle, let errButAction):
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
    public var timeCriteria: ProductTimeCriteria? {
        get {
            return productListViewModel.timeCriteria
        }
        set {
            productListViewModel.timeCriteria = newValue
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
    
    public var distanceType: DistanceType? {
        get {
            return productListViewModel.distanceType
        }
        set {
            productListViewModel.distanceType = newValue
        }
    }
    public var distanceRadius: Int? {
        get {
            return productListViewModel.distanceRadius
        }
        set {
            productListViewModel.distanceRadius = newValue
        }
    }
    public var topProductInfoDelegate: TopProductInfoDelegate? {
        get {
            return productListViewModel.topProductInfoDelegate
        }
        set {
            productListViewModel.topProductInfoDelegate = newValue
        }
    }
    public var actionsDelegate: ProductListActionsDelegate? {
        get {
            return productListViewModel.actionsDelegate
        }
        set {
            productListViewModel.actionsDelegate = newValue
        }
    }

    // Delegate
    weak public var delegate: ProductListViewDataDelegate?
    weak public var scrollDelegate : ProductListViewScrollDelegate?
    
    
    // MARK: - Lifecycle
    
    public init(viewModel: ProductListViewModel, frame: CGRect) {
        self.state = .FirstLoadView
        self.productListViewModel = viewModel
        self.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.collectionViewContentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.lastContentOffset = 0
        self.scrollingDown = true
        super.init(viewModel: viewModel, frame: frame)
        
        viewModel.dataDelegate = self
        setupUI()
    }
    
    public init?(viewModel: ProductListViewModel, coder aDecoder: NSCoder) {
        self.state = .FirstLoadView
        self.productListViewModel = viewModel
        self.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.collectionViewContentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.lastContentOffset = 0
        self.scrollingDown = true
        super.init(viewModel: viewModel, coder: aDecoder)
        
        viewModel.dataDelegate = self
        setupUI()
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        self.init(viewModel: ProductListViewModel(), coder: aDecoder)
    }

    internal override func didBecomeActive(firstTime: Bool) {
        super.didBecomeActive(firstTime)
        refreshUI()
    }

    
    // MARK: Public methods
    
    // MARK: > Actions
    
    /**
        Retrieves the products first page.
    */
    public func refresh() {
        productListViewModel.refreshing = true
        if productListViewModel.canRetrieveProducts {
            productListViewModel.retrieveProducts()
        } else {
            refreshControl.endRefreshing()
        }
    }

    
    // MARK: > UI
    
    /**
        Refreshes the user interface.
    */
    public func refreshUI() {
        productListViewModel.reloadProducts()
        collectionView.reloadData()
    }

    /**
        Clears the collection view
    */
    public func clearList() {
        productListViewModel.clearList()
        collectionView.reloadData()
    }

    /**
    Forces teh list to scroll to the top
    */
    public func scrollToTop() {
        let point = CGPoint(x: -collectionViewContentInset.left, y: -collectionViewContentInset.top)
        collectionView.setContentOffset(point, animated: true)
    }

    
    // MARK: > ViewModel
    
    /**
        Returns the product view model for the given index.
    
        - parameter index: The index of the product.
        - parameter thumbnailImage: The thumbnail image.
        - returns: The product view model.
    */
    public func productViewModelForProductAtIndex(index: Int, thumbnailImage: UIImage?) -> ProductViewModel {
        return productListViewModel.productViewModelForProductAtIndex(index, thumbnailImage: thumbnailImage)
    }
    
    
    // MARK: - CHTCollectionViewDelegateWaterfallLayout
    
    public func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!,
        heightForFooterInSection section: Int) -> CGFloat {
            return Constants.productListFooterHeight
    }

    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: Constants.productListFixedInsets, left: Constants.productListFixedInsets,
                bottom: Constants.productListFixedInsets, right: Constants.productListFixedInsets)
    }


    // MARK: - UICollectionViewDataSource
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            return productListViewModel.sizeForCellAtIndex(indexPath.row)
    }
    
    public func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!,
        columnCountForSection section: Int) -> Int {
            return productListViewModel.numberOfColumns
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productListViewModel.numberOfProducts
    }

    public func collectionView(collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

            let drawer = productListViewModel.cellDrawer
            let cell = drawer.cell(collectionView, atIndexPath: indexPath)
            cell.tag = indexPath.hash
            drawer.draw(cell, data: productListViewModel.productCellDataAtIndex(indexPath.item), delegate: self)
            
            productListViewModel.setCurrentItemIndex(indexPath.item)
            
            // Decides the product of which we will show distance to shoew in the label
            let topProductIndex: Int
            if !collectionView.indexPathsForVisibleItems().isEmpty {
                
                // show distance of the FIRST VISIBLE cell, must loop bc "indexPathsForVisibleItems" is an unordered array
                var lowerIndex = indexPath.item
                for index in collectionView.indexPathsForVisibleItems() {
                    if index.item < lowerIndex {
                        lowerIndex = index.item
                    }
                }
                
                topProductIndex = lowerIndex
            } else {
                // the 1st appeareance of the 1st cell doesn't know about visible cells yet
                topProductIndex = indexPath.item
            }
            
            productListViewModel.visibleTopCellWithIndex(topProductIndex, whileScrollingDown: scrollingDown)
            
            return cell
    }
    
    public func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String,
        atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView  {
            let view: UICollectionReusableView
            
            switch kind {
            case CHTCollectionElementKindSectionFooter, UICollectionElementKindSectionFooter:

                if let footer: CollectionViewFooter = collectionView.dequeueReusableSupplementaryViewOfKind(kind,
                    withReuseIdentifier: "CollectionViewFooter", forIndexPath: indexPath) as? CollectionViewFooter {

                        if productListViewModel.isOnErrorState {
                            footer.status = .Error
                        } else if productListViewModel.isLastPage {
                            footer.status = .LastPage
                        } else {
                            footer.status = .Loading
                        }
                        footer.retryButtonBlock = { [weak self] in
                            if let strongSelf = self {
                                strongSelf.productListViewModel.retrieveProductsNextPage()
                                strongSelf.collectionView.reloadData()
                            }
                        }
                        view = footer
                }
                else {
                    view = UICollectionReusableView()
                }
            default:
                view = UICollectionReusableView()
            }
            return view
    }
    
    
    // MARK: - UICollectionViewDelegate
    
    public func collectionView(cv: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView(cv, cellForItemAtIndexPath: indexPath) as? ProductCell
        let thumbnailImage = cell?.thumbnailImageView.image
        delegate?.productListView(self, didSelectItemAtIndexPath: indexPath, thumbnailImage: thumbnailImage)
    }
    
    
    // MARK: - UIScrollViewDelegate
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        
        checkPullToRefresh(scrollView)
        
        // while going down, increase distance in label, when going up, decrease
        if lastContentOffset >= scrollView.contentOffset.y {
            scrollingDown = false
        } else {
            scrollingDown = true
        }
        lastContentOffset = scrollView.contentOffset.y
        
        informScrollDelegate(scrollView)
    }


    // MARK: - ProductListViewModelDataDelegate
    
    public func viewModel(viewModel: ProductListViewModel, didStartRetrievingProductsPage page: UInt) {
        // If it's the first page & there are no products, then set the loading state
        if page == 0 && viewModel.numberOfProducts == 0 {
            state = .FirstLoadView
        }
    }
    
    public func viewModel(viewModel: ProductListViewModel, didFailRetrievingProductsPage page: UInt, hasProducts: Bool,
        error: RepositoryError) {
            // Update the UI
            if page == 0 {
                refreshControl.endRefreshing()
            } else {
                collectionView.reloadData()
            }
            
            // Notify the delegate
            delegate?.productListView(self, didFailRetrievingProductsPage: page, hasProducts: hasProducts, error: error)
    }
    
    public func viewModel(viewModel: ProductListViewModel, didSucceedRetrievingProductsPage page: UInt,
        hasProducts: Bool, atIndexPaths indexPaths: [NSIndexPath]) {
            // First page
            if page == 0 {
                // Update the UI
                state = .DataView
                
                collectionView.reloadData()
                scrollToTop(false)
                
                refreshControl.endRefreshing()
                
                // Finished refreshing
                productListViewModel.refreshing = false
            } else if viewModel.isLastPage {
                // Last page
                // Reload in order to be able to reload the footer
                collectionView.reloadData()
            } else {
                // Middle pages
                // Reload animated
                collectionView.insertItemsAtIndexPaths(indexPaths)
            }
            
            // Notify the delegate
            delegate?.productListView(self, didSucceedRetrievingProductsPage: page, hasProducts: hasProducts)
    }

    public func viewModel(viewModel: ProductListViewModel, didUpdateProductDataAtIndex index: Int) {
        let indexPath = NSIndexPath(forRow: index, inSection: 0)
        collectionView.reloadItemsAtIndexPaths([indexPath])
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
        contentView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        self.addSubview(contentView)
        
        // Setup UI
        // > Data
        let layout = CHTCollectionViewWaterfallLayout()
        layout.minimumColumnSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        collectionView.collectionViewLayout = layout
        
        self.collectionView.autoresizingMask = UIViewAutoresizing.FlexibleHeight // | UIViewAutoresizing.FlexibleWidth
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = collectionViewContentInset

        ProductCellDrawerFactory.registerCells(collectionView)
        let footerNib = UINib(nibName: "CollectionViewFooter", bundle: nil)
        self.collectionView.registerNib(footerNib, forSupplementaryViewOfKind: CHTCollectionElementKindSectionFooter,
            withReuseIdentifier: "CollectionViewFooter")
        
        // >> Pull to refresh
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.collectionView.addSubview(refreshControl)
        
        // > Error View
        errorButtonHeightConstraint.constant = ProductListView.defaultErrorButtonHeight
        errorButton.layer.cornerRadius = 4
        errorButton.setBackgroundImage(errorButton.backgroundColor?.imageWithSize(CGSize(width: 1, height: 1)),
            forState: .Normal)
        errorButton.addTarget(self, action: Selector("errorButtonPressed"), forControlEvents: .TouchUpInside)
    }
    
    /**
        Scrolls the collection to top
    */
    private func scrollToTop(animated: Bool) {
        let position = CGPoint(x: 0, y: -collectionViewContentInset.top)
        collectionView.setContentOffset(position, animated: animated)
    }
    
    private func checkPullToRefresh(scrollView: UIScrollView) {
        
        if lastContentOffset >= -collectionViewContentInset.top &&
            scrollView.contentOffset.y < -collectionViewContentInset.top {
                productListViewModel.pullingToRefresh(true)
        } else if lastContentOffset < -collectionViewContentInset.top &&
            scrollView.contentOffset.y >= -collectionViewContentInset.top {
                productListViewModel.pullingToRefresh(false)
        }
    }
    
    /**
        Will call scroll delegate on scroll events different than bouncing in the edges indicating scrollingDown state
    */
    private func informScrollDelegate(scrollView: UIScrollView) {
        if(lastContentOffset > 0.0 && lastContentOffset < (scrollView.contentSize.height -
            scrollView.frame.size.height + collectionViewContentInset.bottom)){
                scrollDelegate?.productListView(self, didScrollDown: scrollingDown)
        }
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
}


// MARK: - ProductCellDelegate

extension ProductListView: ProductCellDelegate {
    func productCellDidChat(cell: ProductCell, indexPath: NSIndexPath) {
        productListViewModel.cellDidTapChat(indexPath.row)
    }

    func productCellDidShare(cell: ProductCell, indexPath: NSIndexPath) {
        productListViewModel.cellDidTapShare(indexPath.row)
    }

    func productCellDidLike(cell: ProductCell, indexPath: NSIndexPath) {
        productListViewModel.cellDidTapFavorite(indexPath.row)
    }
}