//
//  ProductListView.swift
//  LetGo
//
//  Created by AHL on 9/7/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import CHTCollectionViewWaterfallLayout
import RxSwift

protocol ProductListViewScrollDelegate: class {
    func productListView(productListView: ProductListView, didScrollDown scrollDown: Bool)
    func productListView(productListView: ProductListView, didScrollWithContentOffsetY contentOffsetY: CGFloat)
}

protocol ProductListViewCellsDelegate: class {
    func visibleTopCellWithIndex(index: Int, whileScrollingDown scrollingDown: Bool)
    func visibleBottomCell(index: Int)
    func pullingToRefresh(refreshing: Bool)
}

protocol ProductListViewHeaderDelegate: class {
    func registerHeader(collectionView: UICollectionView)
    func heightForHeader() -> CGFloat
    func viewForHeader(collectionView: UICollectionView, kind: String, indexPath: NSIndexPath) -> UICollectionReusableView
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
    let isDragging = Variable<Bool>(false)
    
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
    internal(set) var viewModel: ProductListViewModel {
        didSet {
            drawerManager.cellStyle = viewModel.cellStyle
        }
    }
    private let drawerManager = GridDrawerManager()
    
    // Delegate
    weak var scrollDelegate: ProductListViewScrollDelegate?
    weak var cellsDelegate: ProductListViewCellsDelegate?
    weak var headerDelegate: ProductListViewHeaderDelegate? {
        didSet {
            guard let collectionView = collectionView else { return }
            headerDelegate?.registerHeader(collectionView)
        }
    }
    
    
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
        setupAccessibilityIds()
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
        setupAccessibilityIds()
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
        viewModel.reloadData()
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

    func switchViewModel(vm: ProductListViewModel) {
        viewModel.delegate = nil
        viewModel = vm
        viewModel.delegate = self
        refreshDataView()
        refreshUIWithState(vm.state)
        
        super.switchViewModel(vm)
    }
    
    
    // MARK: - CHTCollectionViewDelegateWaterfallLayout

    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!,
                        heightForHeaderInSection section: Int) -> CGFloat {
        return headerDelegate?.heightForHeader() ?? 0
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!,
        heightForFooterInSection section: Int) -> CGFloat {
            return Constants.productListFooterHeight
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        let inset = viewModel.productListFixedInset
        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
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
        guard let item = viewModel.itemAtIndex(indexPath.row) else { return UICollectionViewCell() }
        let cell = drawerManager.cell(item, collectionView: collectionView, atIndexPath: indexPath)
        drawerManager.draw(item, inCell: cell)
        cell.tag = indexPath.hash
        return cell
    }

    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell,
                        forItemAtIndexPath indexPath: NSIndexPath) {
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            self?.viewModel.setCurrentItemIndex(indexPath.item)

            let indexes = collectionView.indexPathsForVisibleItems().map{ $0.item }
            let topProductIndex = indexes.minElement() ?? indexPath.item
            let bottomProductIndex = indexes.maxElement() ?? indexPath.item
            let scrollingDown = self?.scrollingDown ?? false

            self?.cellsDelegate?.visibleTopCellWithIndex(topProductIndex, whileScrollingDown: scrollingDown)
            self?.cellsDelegate?.visibleBottomCell(bottomProductIndex)
        }
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
        case CHTCollectionElementKindSectionHeader, UICollectionElementKindSectionHeader:
            return headerDelegate?.viewForHeader(collectionView, kind: kind, indexPath: indexPath) ?? UICollectionReusableView()
        default:
            return UICollectionReusableView()
        }
    }
    
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(cv: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView(cv, cellForItemAtIndexPath: indexPath) as? ProductCell
        let thumbnailImage = cell?.thumbnailImageView.image
        
        var newFrame: CGRect? = nil
        if let cellFrame = cell?.frame {
            newFrame = superview?.convertRect(cellFrame, fromView: collectionView)
        }
        viewModel.selectedItemAtIndex(indexPath.row, thumbnailImage: thumbnailImage, originFrame: newFrame)
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

    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        isDragging.value = true
    }

    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        isDragging.value = false
    }


    // MARK: - ProductListViewModelDelegate

    func vmReloadData(vm: ProductListViewModel) {
        guard viewModel === vm else { return }
        reloadData()
    }

    func vmDidUpdateState(vm: ProductListViewModel, state: ViewState) {
        guard viewModel === vm else { return }
        refreshUIWithState(state)
    }

    func vmDidFailRetrievingProducts(vm: ProductListViewModel, page: UInt) {
        guard viewModel === vm else { return }
        // Update the UI
        if page == 0 {
            refreshControl.endRefreshing()
        } else {
            reloadData()
        }
    }

    func vmDidSucceedRetrievingProductsPage(vm: ProductListViewModel, page: UInt, indexes: [Int]) {
        guard viewModel === vm else { return }
        // First page
        if page == 0 {
            reloadData()
            if refreshControl.refreshing {
                refreshControl.endRefreshing()
            } else if shouldScrollToTopOnFirstPageReload {
                scrollToTop(false)
            }
        } else if viewModel.isLastPage {
            // Last page
            // Reload in order to be able to reload the footer
            reloadData()
        } else {
            // Middle pages
            // Insert animated
            let indexPaths = indexes.map{ NSIndexPath(forItem: $0, inSection: 0) }
            collectionView.insertItemsAtIndexPaths(indexPaths)
        }
    }

    func vmDidUpdateProductDataAtIndex(vm: ProductListViewModel, index: Int) {
        guard viewModel === vm else { return }
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
        updateLayoutWithSeparation(10)

        self.collectionView.autoresizingMask = UIViewAutoresizing.FlexibleHeight // | UIViewAutoresizing.FlexibleWidth
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = collectionViewContentInset

        drawerManager.registerCell(inCollectionView: collectionView)
        let footerNib = UINib(nibName: "CollectionViewFooter", bundle: nil)
        self.collectionView.registerNib(footerNib, forSupplementaryViewOfKind: CHTCollectionElementKindSectionFooter,
                                        withReuseIdentifier: "CollectionViewFooter")

        // >> Pull to refresh
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlTriggered), forControlEvents: UIControlEvents.ValueChanged)
        self.collectionView.addSubview(refreshControl)

        // > Error View
        errorButtonHeightConstraint.constant = ProductListView.defaultErrorButtonHeight
        errorButton.setStyle(.Primary(fontSize: .Medium))
        errorButton.addTarget(self, action: #selector(ProductListView.errorButtonPressed), forControlEvents: .TouchUpInside)
    }
    
    func updateLayoutWithSeparation(separationBetweenCells: CGFloat) {
        let layout = CHTCollectionViewWaterfallLayout()
        layout.minimumColumnSpacing = separationBetweenCells
        layout.minimumInteritemSpacing = separationBetweenCells
        collectionView.collectionViewLayout = layout
    }

    func refreshUIWithState(state: ViewState) {
        switch (state) {
        case .Loading:
            // Show/hide views
            firstLoadView.hidden = false
            dataView.hidden = true
            errorView.hidden = true
        case .Data:
            // Show/hide views
            firstLoadView.hidden = true
            dataView.hidden = false
            errorView.hidden = true
        case .Error(let emptyVM):
            setErrorState(emptyVM)
        case .Empty(let emptyVM):
            setErrorState(emptyVM)
        }
    }

    private func setErrorState(emptyViewModel: LGEmptyViewModel) {
        errorImageView.image = emptyViewModel.icon
        errorImageViewHeightConstraint.constant = emptyViewModel.iconHeight
        errorTitleLabel.text = emptyViewModel.title
        errorBodyLabel.text = emptyViewModel.body
        errorButton.setTitle(emptyViewModel.buttonTitle, forState: .Normal)
        // > If there's no button title or action then hide it
        if emptyViewModel.hasAction {
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
        case .Empty(let emptyVM):
            emptyVM.action?()
        case .Error(let emptyVM):
            emptyVM.action?()
        default:
            break
        }
    }
}


// UI Testing + accessibility

extension ProductListView {
    func setupAccessibilityIds() {
        firstLoadView.accessibilityId = .ProductListViewFirstLoadView
        firstLoadActivityIndicator.accessibilityId = .ProductListViewFirstLoadActivityIndicator
        collectionView.accessibilityId = .ProductListViewCollection
        errorView.accessibilityId = .ProductListViewErrorView
        errorImageView.accessibilityId =  .ProductListErrorImageView
        errorTitleLabel.accessibilityId = .ProductListErrorTitleLabel
        errorBodyLabel.accessibilityId = .ProductListErrorBodyLabel
        errorButton.accessibilityId = .ProductListErrorButton
    }
}
