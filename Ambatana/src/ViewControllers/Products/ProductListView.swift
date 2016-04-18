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
    func productListView(productListView: ProductListView, didScrollWithContentOffsetY contentOffsetY: CGFloat)
}

public class ProductListView: BaseView, CHTCollectionViewDelegateWaterfallLayout, ProductListViewModelDelegate,
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

    @IBOutlet var topInsetDataViewConstraint: NSLayoutConstraint!
    @IBOutlet var leftInsetDataViewConstraint: NSLayoutConstraint!
    @IBOutlet var bottomInsetDataViewConstraint: NSLayoutConstraint!
    @IBOutlet var rightInsetDataViewConstraint: NSLayoutConstraint!

    public var shouldScrollToTopOnFirstPageReload = true
    public var ignoreDataViewWhenSettingContentInset = false
    public var contentInset: UIEdgeInsets {
        didSet {
            for constraint in topInsetConstraints {
                if constraint == topInsetDataViewConstraint && ignoreDataViewWhenSettingContentInset { continue }
                constraint.constant = contentInset.top
            }
            for constraint in leftInsetConstraints {
                if constraint == leftInsetDataViewConstraint && ignoreDataViewWhenSettingContentInset { continue }
                constraint.constant = contentInset.left
            }
            for constraint in bottomInsetConstraints {
                if constraint == bottomInsetDataViewConstraint && ignoreDataViewWhenSettingContentInset { continue }
                constraint.constant = contentInset.bottom
            }
            for constraint in rightInsetConstraints {
                if constraint == rightInsetDataViewConstraint && ignoreDataViewWhenSettingContentInset { continue }
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
        return viewModel.defaultCellSize
    }
    
    // Data
    internal(set) var viewModel: ProductListViewModel

    // > Computed iVars
    public var state: ProductListViewState {
        get {
            return viewModel.state
        }
        set {
            viewModel.state = newValue
        }
    }
    public var queryString: String? {
        get {
            return viewModel.queryString
        }
        set {
            viewModel.queryString = newValue
        }
    }
    public var place: Place? {
        get {
            return viewModel.place
        }
        set {
            viewModel.place = newValue
        }
    }
    public var categories: [ProductCategory]? {
        get {
            return viewModel.categories
        }
        set {
            viewModel.categories = newValue
        }
    }
    public var timeCriteria: ProductTimeCriteria? {
        get {
            return viewModel.timeCriteria
        }
        set {
            viewModel.timeCriteria = newValue
        }
    }
    public var sortCriteria: ProductSortCriteria? {
        get {
            return viewModel.sortCriteria
        }
        set {
            viewModel.sortCriteria = newValue
        }
    }
    public var maxPrice: Int? {
        get {
            return viewModel.maxPrice
        }
        set {
            viewModel.maxPrice = newValue
        }
    }
    public var minPrice: Int? {
        get {
            return viewModel.minPrice
        }
        set {
            viewModel.minPrice = newValue
        }
    }
    public var userObjectId: String? {
        get {
            return viewModel.userObjectId
        }
        set {
            viewModel.userObjectId = newValue
        }
    }
    
    public var distanceType: DistanceType? {
        get {
            return viewModel.distanceType
        }
        set {
            viewModel.distanceType = newValue
        }
    }
    public var distanceRadius: Int? {
        get {
            return viewModel.distanceRadius
        }
        set {
            viewModel.distanceRadius = newValue
        }
    }
    public var topProductInfoDelegate: TopProductInfoDelegate? {
        get {
            return viewModel.topProductInfoDelegate
        }
        set {
            viewModel.topProductInfoDelegate = newValue
        }
    }
    public var actionsDelegate: ProductListActionsDelegate? {
        get {
            return viewModel.actionsDelegate
        }
        set {
            viewModel.actionsDelegate = newValue
        }
    }

    // Delegate
    weak public var delegate: ProductListViewDataDelegate?
    weak public var scrollDelegate : ProductListViewScrollDelegate?
    
    
    // MARK: - Lifecycle
    
    public init(viewModel: ProductListViewModel, frame: CGRect) {
        self.viewModel = viewModel
        self.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.collectionViewContentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.lastContentOffset = 0
        self.scrollingDown = true
        super.init(viewModel: viewModel, frame: frame)
        
        viewModel.delegate = self
        setupUI()
    }
    
    public init?(viewModel: ProductListViewModel, coder aDecoder: NSCoder) {
        self.viewModel = viewModel
        self.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.collectionViewContentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.lastContentOffset = 0
        self.scrollingDown = true
        super.init(viewModel: viewModel, coder: aDecoder)
        
        viewModel.delegate = self
        setupUI()
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        self.init(viewModel: ProductListViewModel(), coder: aDecoder)
    }

    internal override func didBecomeActive(firstTime: Bool) {
        super.didBecomeActive(firstTime)
        refreshDataView()
    }

    
    // MARK: Public methods
    
    // MARK: > Actions
    
    /**
        Retrieves the products first page.
    */
    public func refresh() {
        viewModel.refreshing = true
        if viewModel.canRetrieveProducts {
            viewModel.retrieveProducts()
        } else {
            refreshControl.endRefreshing()
        }
    }

    
    // MARK: > UI

    /**
    Sets up the UI.
    */
    func setupUI() {
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
        refreshControl.addTarget(self, action: #selector(ProductListView.refresh), forControlEvents: UIControlEvents.ValueChanged)
        self.collectionView.addSubview(refreshControl)

        // > Error View
        errorButtonHeightConstraint.constant = ProductListView.defaultErrorButtonHeight
        errorButton.layer.cornerRadius = 4
        errorButton.setBackgroundImage(errorButton.backgroundColor?.imageWithSize(CGSize(width: 1, height: 1)),
            forState: .Normal)
        errorButton.addTarget(self, action: #selector(ProductListView.errorButtonPressed), forControlEvents: .TouchUpInside)
    }

    /**
        Refreshes the user interface.
    */
    public func refreshDataView() {
        viewModel.reloadProducts()
        collectionView.reloadData()
    }

    /**
        Clears the collection view
    */
    public func clearList() {
        viewModel.clearList()
        collectionView.reloadData()
    }

    /**
     Scrolls the collection to top
     */
    public func scrollToTop(animated: Bool) {
        let position = CGPoint(x: -collectionViewContentInset.left, y: -collectionViewContentInset.top)
        collectionView.setContentOffset(position, animated: animated)
    }
    
    // MARK: > ViewModel
    
    
    /**
        Returns the product view model for the given index.
    
        - parameter index: The index of the product.
        - parameter thumbnailImage: The thumbnail image.
        - returns: The product view model.
    */
    func productViewModelForProductAtIndex(index: Int, thumbnailImage: UIImage?) -> ProductViewModel? {
        return viewModel.productViewModelForProductAtIndex(index, thumbnailImage: thumbnailImage)
    }

    func switchViewModel(vm: ProductListViewModel) {
        viewModel.delegate = nil

        viewModel = vm
        viewModel.delegate = self

        refreshDataView()
        refreshUIWithState(vm.state)
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
            return viewModel.sizeForCellAtIndex(indexPath.row)
    }
    
    public func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!,
        columnCountForSection section: Int) -> Int {
            return viewModel.numberOfColumns
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfProducts
    }

    public func collectionView(collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

            let drawer = viewModel.cellDrawer
            let cell = drawer.cell(collectionView, atIndexPath: indexPath)
            cell.tag = indexPath.hash
            if let data = viewModel.productCellDataAtIndex(indexPath.item) {
                drawer.draw(cell, data: data, delegate: self)
            }
           
            viewModel.setCurrentItemIndex(indexPath.item)
            
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
            
            viewModel.visibleTopCellWithIndex(topProductIndex, whileScrollingDown: scrollingDown)
            
            return cell
    }
    
    public func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String,
        atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView  {
            let view: UICollectionReusableView
            
            switch kind {
            case CHTCollectionElementKindSectionFooter, UICollectionElementKindSectionFooter:

                if let footer: CollectionViewFooter = collectionView.dequeueReusableSupplementaryViewOfKind(kind,
                    withReuseIdentifier: "CollectionViewFooter", forIndexPath: indexPath) as? CollectionViewFooter {

                        if viewModel.isOnErrorState {
                            footer.status = .Error
                        } else if viewModel.isLastPage {
                            footer.status = .LastPage
                        } else {
                            footer.status = .Loading
                        }
                        footer.retryButtonBlock = { [weak self] in
                            if let strongSelf = self {
                                strongSelf.viewModel.retrieveProductsNextPage()
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

    public func vmDidUpdateState(state: ProductListViewState) {
        refreshUIWithState(state)

    }

    public func vmDidStartRetrievingProductsPage(page: UInt) {
        // If it's the first page & there are no products, then set the loading state
        if page == 0 && viewModel.numberOfProducts == 0 {
            state = .FirstLoadView
        }
    }

    public func vmDidFailRetrievingProductsPage(page: UInt, hasProducts: Bool, error: RepositoryError) {
        // Update the UI
        if page == 0 {
            refreshControl.endRefreshing()
        } else {
            collectionView.reloadData()
        }

        // Notify the delegate
        delegate?.productListView(self, didFailRetrievingProductsPage: page, hasProducts: hasProducts, error: error)
    }

    public func vmDidSucceedRetrievingProductsPage(page: UInt, hasProducts: Bool, atIndexPaths indexPaths: [NSIndexPath]) {
        // First page
        if page == 0 {
            // Update the UI
            state = .DataView

            collectionView.reloadData()

            if shouldScrollToTopOnFirstPageReload {
                scrollToTop(false)
            }
            refreshControl.endRefreshing()

            // Finished refreshing
            viewModel.refreshing = false
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

    public func vmDidUpdateProductDataAtIndex(index: Int) {
        let indexPath = NSIndexPath(forRow: index, inSection: 0)
        collectionView.reloadItemsAtIndexPaths([indexPath])
    }
    
    
    // MARK: - Private methods
    
    // MARK: > UI

    func refreshUIWithState(state: ProductListViewState) {
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
        case .ErrorView(let errBgColor, let errBorderColor, let errContainerColor,
            let errImage, let errTitle, let errBody, let errButTitle, let errButAction):
            // UI
            errorView.backgroundColor = errBgColor
            errorContentView.backgroundColor = errContainerColor
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

    private func checkPullToRefresh(scrollView: UIScrollView) {
        
        if lastContentOffset >= -collectionViewContentInset.top &&
            scrollView.contentOffset.y < -collectionViewContentInset.top {
                viewModel.pullingToRefresh(true)
        } else if lastContentOffset < -collectionViewContentInset.top &&
            scrollView.contentOffset.y >= -collectionViewContentInset.top {
                viewModel.pullingToRefresh(false)
        }
    }
    
    /**
        Will call scroll delegate on scroll events different than bouncing in the edges indicating scrollingDown state
    */
    private func informScrollDelegate(scrollView: UIScrollView) {
        if shouldNotifyScrollDelegate(scrollView) {
            scrollDelegate?.productListView(self, didScrollDown: scrollingDown)
        }
        scrollDelegate?.productListView(self, didScrollWithContentOffsetY: scrollView.contentOffset.y)
    }
    
    /**
     Helper func to decide if the scroll delegate should be called.
     Extracted to its own func for easier understanding.
     
     Should notify the delegate if:
        - Last content offset is positive (the default offset is -64 and increases if we scroll down)
        AND the lastContentOffset is less than the bouncing limit. The limit is equal to the offset after scrolling up
        to the maximum and then let the table bounce to a stable position. The bouncing counts as a DidScroll event
        with scrollingDown = false. checking for this limit we avoid that the delegate is called when we are not 
        scrolling, but the table is bouncing. -> YES IF (0 < LastContentOffset < BouncingLimit)
     
        OR
     
        - LastContentOffet is negative and we are scrolling up. This case only happens when we scroll up from the top:
        when doing a Pull To Refresh or when pulling after reaching the bouncing limit described in the previous case.
        With this condition, we defend against and edge case where the Delegate should be triggered in the previous
        case but wasn't: In cases where the contentSize is lower than the ScreenSize, if you scroll down and up very fast
        you could pass from a value higher than the bouncingLimit to a negative value. 
        -> YES IF (LastContentOffset < 0 && ScrollingUP)
     */
    private func shouldNotifyScrollDelegate(scrollView: UIScrollView) -> Bool {
        let limit = (scrollView.contentSize.height - scrollView.frame.size.height + collectionViewContentInset.bottom)
        let offsetLowerThanBouncingLimit = lastContentOffset < limit
        return lastContentOffset > 0.0 && offsetLowerThanBouncingLimit || lastContentOffset < 0.0 && !scrollingDown
    }
    
    /**
        Called when the error button is pressed.
    */
    @objc private func errorButtonPressed() {
        switch state {
        case .ErrorView(_, _, _, _, _, _, _, let errButAction):
            errButAction?()
        default:
            break
        }
    }
}


// MARK: - ProductCellDelegate

extension ProductListView: ProductCellDelegate {
    func productCellDidChat(cell: ProductCell, indexPath: NSIndexPath) {
        viewModel.cellDidTapChat(indexPath.row)
    }

    func productCellDidShare(cell: ProductCell, indexPath: NSIndexPath) {
        viewModel.cellDidTapShare(indexPath.row)
    }

    func productCellDidLike(cell: ProductCell, indexPath: NSIndexPath) {
        viewModel.cellDidTapFavorite(indexPath.row)
    }
}