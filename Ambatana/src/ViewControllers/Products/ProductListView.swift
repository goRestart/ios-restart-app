//
//  ProductListView.swift
//  LetGo
//
//  Created by AHL on 9/7/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import CHTCollectionViewWaterfallLayout

protocol ProductListViewScrollDelegate: class {
    func productListView(productListView: ProductListView, didScrollDown scrollDown: Bool)
    func productListView(productListView: ProductListView, didScrollWithContentOffsetY contentOffsetY: CGFloat)
}

protocol ProductListViewCellsDelegate: class {
    func visibleTopCellWithIndex(index: Int, whileScrollingDown scrollingDown: Bool)
    func visibleBottomCell(index: Int)
    func pullingToRefresh(refreshing: Bool)
}

class ProductListView: BaseView, CHTCollectionViewDelegateWaterfallLayout, ProductListViewModelDelegate,
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
    @IBOutlet var topInsetDataViewConstraint: NSLayoutConstraint!
    @IBOutlet var leftInsetDataViewConstraint: NSLayoutConstraint!
    @IBOutlet var bottomInsetDataViewConstraint: NSLayoutConstraint!
    @IBOutlet var rightInsetDataViewConstraint: NSLayoutConstraint!

    @IBOutlet weak var topInsetFirstLoadConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftInsetFirstLoadConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomInsetFirstLoadConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightInsetFirstLoadConstraint: NSLayoutConstraint!

    @IBOutlet weak var topInsetErrorViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftInsetErrorViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomInsetErrorViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightInsetErrorViewConstraint: NSLayoutConstraint!


    var shouldScrollToTopOnFirstPageReload = true
    var dataPadding: UIEdgeInsets {
        didSet {
            topInsetDataViewConstraint.constant = dataPadding.top
            leftInsetDataViewConstraint.constant = dataPadding.left
            bottomInsetDataViewConstraint.constant = dataPadding.bottom
            rightInsetDataViewConstraint.constant = dataPadding.right
            dataView.updateConstraintsIfNeeded()
        }
    }
    var firstLoadPadding: UIEdgeInsets {
        didSet {
            topInsetFirstLoadConstraint.constant = firstLoadPadding.top
            leftInsetFirstLoadConstraint.constant = firstLoadPadding.left
            bottomInsetFirstLoadConstraint.constant = firstLoadPadding.bottom
            rightInsetFirstLoadConstraint.constant = firstLoadPadding.right
            firstLoadView.updateConstraintsIfNeeded()
        }
    }
    var errorPadding: UIEdgeInsets {
        didSet {
            topInsetErrorViewConstraint.constant = errorPadding.top
            leftInsetErrorViewConstraint.constant = errorPadding.left
            bottomInsetErrorViewConstraint.constant = errorPadding.bottom
            rightInsetErrorViewConstraint.constant = errorPadding.right
            errorView.updateConstraintsIfNeeded()
        }
    }

    var padding: UIEdgeInsets {
        didSet {
            dataPadding = padding
            firstLoadPadding = padding
            errorPadding = padding
        }
    }
    var collectionViewContentInset: UIEdgeInsets {
        get {
            return collectionView.contentInset
        }
        set {
            collectionView.contentInset = newValue
        }
    }

    var defaultCellSize: CGSize {
        return viewModel.defaultCellSize
    }
    
    // Data
    internal(set) var viewModel: ProductListViewModel

    // Delegate
    weak var scrollDelegate: ProductListViewScrollDelegate?
    weak var cellsDelegate: ProductListViewCellsDelegate?
    
    
    // MARK: - Lifecycle
    
    init(viewModel: ProductListViewModel, frame: CGRect) {
        self.viewModel = viewModel
        let padding = UIEdgeInsetsZero
        self.dataPadding = padding
        self.firstLoadPadding = padding
        self.errorPadding = padding
        self.padding = padding
        self.lastContentOffset = 0
        self.scrollingDown = true
        super.init(viewModel: viewModel, frame: frame)
        
        viewModel.delegate = self
        setupUI()
    }
    
    init?(viewModel: ProductListViewModel, coder aDecoder: NSCoder) {
        self.viewModel = viewModel
        let padding = UIEdgeInsetsZero
        self.dataPadding = padding
        self.firstLoadPadding = padding
        self.errorPadding = padding
        self.padding = padding
        self.lastContentOffset = 0
        self.scrollingDown = true
        super.init(viewModel: viewModel, coder: aDecoder)
        
        viewModel.delegate = self
        setupUI()
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init(viewModel: ProductListViewModel(requester: nil), coder: aDecoder)
    }

    internal override func didBecomeActive(firstTime: Bool) {
        super.didBecomeActive(firstTime)
        refreshDataView()
    }

    
    // MARK: Public methods

    // MARK: > UI

    /**
        Refreshes the user interface.
    */
    func refreshDataView() {
        reloadData()
    }

    /**
        Clears the collection view
    */
    func clearList() {
        viewModel.clearList()
    }

    /**
     Scrolls the collection to top
     */
    func scrollToTop(animated: Bool) {
        let position = CGPoint(x: -collectionViewContentInset.left, y: -collectionViewContentInset.top)
        collectionView.setContentOffset(position, animated: animated)
    }

    func setErrorViewStyle(bgColor bgColor: UIColor?, borderColor: UIColor?, containerColor: UIColor?) {
        errorView.backgroundColor = bgColor
        errorContentView.backgroundColor = containerColor
        errorContentView.layer.borderColor = borderColor?.CGColor
        errorContentView.layer.borderWidth = borderColor != nil ? 0.5 : 0
        errorContentView.layer.cornerRadius = 4
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
        super.switchViewModel(vm)

        refreshDataView()
        refreshUIWithState(vm.state)
    }
    
    
    // MARK: - CHTCollectionViewDelegateWaterfallLayout
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!,
        heightForFooterInSection section: Int) -> CGFloat {
            return Constants.productListFooterHeight
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: Constants.productListFixedInsets, left: Constants.productListFixedInsets,
                bottom: Constants.productListFixedInsets, right: Constants.productListFixedInsets)
    }


    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            return viewModel.sizeForCellAtIndex(indexPath.row)
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!,
        columnCountForSection section: Int) -> Int {
            return viewModel.numberOfColumns
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfProducts
    }

    func collectionView(collectionView: UICollectionView,
                               cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = viewModel.cellDrawer.cell(collectionView, atIndexPath: indexPath)
        cell.tag = indexPath.hash
        if let data = viewModel.productCellDataAtIndex(indexPath.item) {
            viewModel.cellDrawer.draw(cell, data: data, delegate: self)
        }
       
        viewModel.setCurrentItemIndex(indexPath.item)

        let indexes = collectionView.indexPathsForVisibleItems().map{ $0.item }
        let topProductIndex = indexes.minElement() ?? indexPath.item
        let bottomProductIndex = indexes.maxElement() ?? indexPath.item

        cellsDelegate?.visibleTopCellWithIndex(topProductIndex, whileScrollingDown: scrollingDown)
        cellsDelegate?.visibleBottomCell(bottomProductIndex)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String,
                               atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView  {
        switch kind {
        case CHTCollectionElementKindSectionFooter, UICollectionElementKindSectionFooter:
            guard let footer: CollectionViewFooter = collectionView.dequeueReusableSupplementaryViewOfKind(kind,
                    withReuseIdentifier: "CollectionViewFooter", forIndexPath: indexPath) as? CollectionViewFooter
                    else { return UICollectionReusableView() }
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
                    strongSelf.reloadData()
                }
            }
            return footer
        default:
            return UICollectionReusableView()
        }
    }
    
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(cv: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView(cv, cellForItemAtIndexPath: indexPath) as? ProductCell
        let thumbnailImage = cell?.thumbnailImageView.image
        viewModel.selectedItemAtIndex(indexPath.row, thumbnailImage: thumbnailImage)
    }
    
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
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


    // MARK: - ProductListViewModelDelegate

    func vmReloadData() {
        reloadData()
    }

    func vmDidUpdateState(state: ProductListViewState) {
        refreshUIWithState(state)

    }

    func vmDidStartRetrievingProductsPage(page: UInt) {
        // If it's the first page & there are no products, then set the loading state
        if page == 0 && viewModel.numberOfProducts == 0 {
            viewModel.state = .FirstLoad
        }
    }

    func vmDidFailRetrievingProducts(page page: UInt) {
        // Update the UI
        if page == 0 {
            refreshControl.endRefreshing()
        } else {
            reloadData()
        }
    }

    func vmDidSucceedRetrievingProductsPage(page: UInt, hasProducts: Bool, atIndexPaths indexPaths: [NSIndexPath]) {
        // First page
        if page == 0 {
            // Update the UI
            viewModel.state = .Data

            reloadData()

            if shouldScrollToTopOnFirstPageReload {
                scrollToTop(false)
            }
            refreshControl.endRefreshing()
        } else if viewModel.isLastPage {
            // Last page
            // Reload in order to be able to reload the footer
            reloadData()
        } else {
            // Middle pages
            // Reload animated
            collectionView.insertItemsAtIndexPaths(indexPaths)
        }
    }

    func vmDidUpdateProductDataAtIndex(index: Int) {
        let indexPath = NSIndexPath(forRow: index, inSection: 0)
        collectionView.reloadItemsAtIndexPaths([indexPath])
    }
    
    
    // MARK: - Private methods
    // MARK: > UI

    var minimumContentHeight: CGFloat {
        get {
            guard let waterfallLayout = collectionView.collectionViewLayout as? CHTCollectionViewWaterfallLayout else {
                return 0
            }
            return waterfallLayout.minimumContentHeight
        }
        set {
            guard let waterfallLayout = collectionView.collectionViewLayout as? CHTCollectionViewWaterfallLayout else {
                return
            }
            waterfallLayout.minimumContentHeight = newValue
        }
    }

    private func reloadData() {
        collectionView.reloadData()
    }

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
        refreshControl.addTarget(self, action: #selector(refreshControlTriggered), forControlEvents: UIControlEvents.ValueChanged)
        self.collectionView.addSubview(refreshControl)

        // > Error View
        errorButtonHeightConstraint.constant = ProductListView.defaultErrorButtonHeight
        errorButton.layer.cornerRadius = 4
        errorButton.setBackgroundImage(errorButton.backgroundColor?.imageWithSize(CGSize(width: 1, height: 1)),
                                       forState: .Normal)
        errorButton.addTarget(self, action: #selector(ProductListView.errorButtonPressed), forControlEvents: .TouchUpInside)
    }

    func refreshUIWithState(state: ProductListViewState) {
        switch (state) {
        case .FirstLoad:
            // Show/hide views
            firstLoadView.hidden = false
            dataView.hidden = true
            errorView.hidden = true
        case .Data:
            // Show/hide views
            firstLoadView.hidden = true
            dataView.hidden = false
            errorView.hidden = true
        case .Error(let errImage, let errTitle, let errBody, let errButTitle, let errButAction):
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

    dynamic private func refreshControlTriggered() {
        viewModel.refreshControlTriggered()
    }

    private func checkPullToRefresh(scrollView: UIScrollView) {
        
        if lastContentOffset >= -collectionViewContentInset.top &&
                                                        scrollView.contentOffset.y < -collectionViewContentInset.top {
            cellsDelegate?.pullingToRefresh(true)
        } else if lastContentOffset < -collectionViewContentInset.top &&
                                                        scrollView.contentOffset.y >= -collectionViewContentInset.top {
            cellsDelegate?.pullingToRefresh(false)
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
    dynamic private func errorButtonPressed() {
        switch viewModel.state {
        case .Error(_, _, _, _, let errButAction):
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