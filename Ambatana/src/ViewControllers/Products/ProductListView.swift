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
    func productListView(_ productListView: ProductListView, didScrollDown scrollDown: Bool)
    func productListView(_ productListView: ProductListView, didScrollWithContentOffsetY contentOffsetY: CGFloat)
}

protocol ProductListViewCellsDelegate: class {
    func visibleTopCellWithIndex(_ index: Int, whileScrollingDown scrollingDown: Bool)
}

protocol ProductListViewHeaderDelegate: class {
    func totalHeaderHeight() -> CGFloat
    func setupViewsInHeader(_ header: ListHeaderContainer)
}

class ProductListView: BaseView, CHTCollectionViewDelegateWaterfallLayout, ProductListViewModelDelegate,
UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // Constants
    private static let defaultErrorButtonHeight: CGFloat = 50
    
    // UI
    @IBOutlet weak private var contentView: UIView!
    
    // > First load
    @IBOutlet weak var firstLoadView: UIView!
    @IBOutlet weak var firstLoadActivityIndicator: UIActivityIndicatorView!
    
    // > Data
    @IBOutlet weak var dataView: UIView!
    var refreshControl = UIRefreshControl()
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
            var headerHeight: CGFloat = 0
            if let totalHeaderHeight = headerDelegate?.totalHeaderHeight() {
                headerHeight = totalHeaderHeight
            }
            topInsetErrorViewConstraint.constant = errorPadding.top + headerHeight
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

    var headerBottom: CGFloat {
        let headerSize = headerDelegate?.totalHeaderHeight() ?? 0
        let headerRect = CGRect(x: 0, y: 0, width: 0, height: headerSize)
        let convertedRect = convert(headerRect, from: collectionView)
        return convertedRect.bottom
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
            collectionView.reloadData()
        }
    }
    
    
    // MARK: - Lifecycle
    
    init(viewModel: ProductListViewModel,featureFlags: FeatureFlaggeable, frame: CGRect) {
        self.viewModel = viewModel
        let padding = UIEdgeInsets.zero
        self.dataPadding = padding
        self.firstLoadPadding = padding
        self.errorPadding = padding
        self.padding = padding
        self.lastContentOffset = 0
        self.scrollingDown = true
        super.init(viewModel: viewModel, frame: frame)
        drawerManager.freePostingAllowed = featureFlags.freePostingModeAllowed
        viewModel.delegate = self
        setupUI()
        setAccessibilityIds()
    }
    
    init?(viewModel: ProductListViewModel, featureFlags: FeatureFlaggeable, coder aDecoder: NSCoder) {
        self.viewModel = viewModel
        let padding = UIEdgeInsets.zero
        self.dataPadding = padding
        self.firstLoadPadding = padding
        self.errorPadding = padding
        self.padding = padding
        self.lastContentOffset = 0
        self.scrollingDown = true
        super.init(viewModel: viewModel, coder: aDecoder)
        drawerManager.freePostingAllowed = featureFlags.freePostingModeAllowed
        viewModel.delegate = self
        setupUI()
        setAccessibilityIds()
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init(viewModel: ProductListViewModel(requester: nil), featureFlags: FeatureFlags.sharedInstance, coder: aDecoder)
    }

    internal override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        refreshDataView()
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        switch viewModel.state {
        case .empty:
            guard let headerHeight = headerDelegate?.totalHeaderHeight(), headerHeight > 0 else { return errorView }
            let collectionConvertedPoint = collectionView.convert(point, from: self)
            let collectionHeaderSize = CGSize(width: collectionView.frame.width, height: CGFloat(headerHeight))
            let headerFrame = CGRect(origin: CGPoint.zero, size: collectionHeaderSize)
            let insideHeader = headerFrame.contains(collectionConvertedPoint)
            return insideHeader ? hitView : errorView
        case .data, .loading, .error:
            return hitView
        }
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
    func scrollToTop(_ animated: Bool) {
        let position = CGPoint(x: -collectionViewContentInset.left, y: -collectionViewContentInset.top)
        collectionView.setContentOffset(position, animated: animated)
    }

    func setErrorViewStyle(bgColor: UIColor?, borderColor: UIColor?, containerColor: UIColor?) {
        errorView.backgroundColor = bgColor
        errorContentView.backgroundColor = containerColor
        errorContentView.layer.borderColor = borderColor?.cgColor
        errorContentView.layer.borderWidth = borderColor != nil ? 0.5 : 0
        errorContentView.layer.cornerRadius = 4
    }

    
    // MARK: > ViewModel

    func switchViewModel(_ vm: ProductListViewModel) {
        viewModel.delegate = nil
        viewModel = vm
        viewModel.delegate = self
        refreshDataView()
        refreshUIWithState(vm.state)
        
        super.switchViewModel(vm)
    }


    // MARK: - CHTCollectionViewDelegateWaterfallLayout

    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!,
                        heightForHeaderInSection section: Int) -> CGFloat {
        return headerDelegate?.totalHeaderHeight() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!,
        heightForFooterInSection section: Int) -> CGFloat {
        return Constants.productListFooterHeight
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int) -> UIEdgeInsets {
        let inset = viewModel.productListFixedInset
        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }


    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
            return viewModel.sizeForCellAtIndex(indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!,
        columnCountForSection section: Int) -> Int {
            return viewModel.numberOfColumns
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfProducts
    }

    func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = viewModel.itemAtIndex(indexPath.row) else { return UICollectionViewCell() }
        let cell = drawerManager.cell(item, collectionView: collectionView, atIndexPath: indexPath)
        drawerManager.draw(item, inCell: cell)
        cell.tag = (indexPath as NSIndexPath).hash
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        DispatchQueue.main.async { [weak self] in
            self?.viewModel.setCurrentItemIndex(indexPath.item)

            let indexes = collectionView.indexPathsForVisibleItems.map{ $0.item }
            let topProductIndex = indexes.min() ?? indexPath.item
            let scrollingDown = self?.scrollingDown ?? false

            self?.cellsDelegate?.visibleTopCellWithIndex(topProductIndex, whileScrollingDown: scrollingDown)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        didEndDisplaying cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {

        let topProductIndex = (collectionView.indexPathsForVisibleItems.map{ $0.item }).min() ?? indexPath.item
        cellsDelegate?.visibleTopCellWithIndex(topProductIndex, whileScrollingDown: scrollingDown)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String,
                               at indexPath: IndexPath) -> UICollectionReusableView  {
        switch kind {
        case CHTCollectionElementKindSectionFooter, UICollectionElementKindSectionFooter:
            guard let footer: CollectionViewFooter = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                    withReuseIdentifier: CollectionViewFooter.reusableID, for: indexPath) as? CollectionViewFooter
                    else { return UICollectionReusableView() }
            if viewModel.isOnErrorState {
                footer.status = .error
            } else if viewModel.isLastPage {
                footer.status = .lastPage
            } else {
                footer.status = .loading
            }
            footer.retryButtonBlock = { [weak self] in
                if let strongSelf = self {
                    strongSelf.viewModel.retrieveProductsNextPage()
                    strongSelf.reloadData()
                }
            }
            return footer
        case CHTCollectionElementKindSectionHeader, UICollectionElementKindSectionHeader:
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                    withReuseIdentifier: ListHeaderContainer.reusableID, for: indexPath) as? ListHeaderContainer
                    else { return UICollectionReusableView() }
            headerDelegate?.setupViewsInHeader(header)
            return header
        default:
            return UICollectionReusableView()
        }
    }
    
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ cv: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView(cv, cellForItemAt: indexPath) as? ProductCell
        let thumbnailImage = cell?.thumbnailImageView.image
        
        var newFrame: CGRect? = nil
        if let cellFrame = cell?.frame {
            newFrame = superview?.convert(cellFrame, from: collectionView)
        }
        viewModel.selectedItemAtIndex(indexPath.row, thumbnailImage: thumbnailImage, originFrame: newFrame)
    }
    
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // while going down, increase distance in label, when going up, decrease
        if lastContentOffset >= scrollView.contentOffset.y {
            scrollingDown = false
        } else {
            scrollingDown = true
        }
        lastContentOffset = scrollView.contentOffset.y
        
        informScrollDelegate(scrollView)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isDragging.value = true
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        isDragging.value = false
    }


    // MARK: - ProductListViewModelDelegate

    func vmReloadData(_ vm: ProductListViewModel) {
        guard viewModel === vm else { return }
        reloadData()
    }

    func vmDidUpdateState(_ vm: ProductListViewModel, state: ViewState) {
        guard viewModel === vm else { return }
        refreshUIWithState(state)
    }

    func vmDidFinishLoading(_ vm: ProductListViewModel, page: UInt, indexes: [Int]) {
        guard viewModel === vm else { return }
        if page == 0 {
            reloadData()
            if refreshControl.isRefreshing {
                refreshControl.endRefreshing()
            } else if shouldScrollToTopOnFirstPageReload {
                scrollToTop(false)
            }
        } else if self.viewModel.isLastPage {
            // Last page
            // Reload in order to be able to reload the footer
            reloadData()
        } else if !indexes.isEmpty {
            // Middle pages
            // Insert animated
            let indexPaths = indexes.map{ IndexPath(item: $0, section: 0) }
            collectionView.insertItems(at: indexPaths)
        } else {
            // delay added because reload is ignored if too fast after insertItems
            delay(0.4) { _ in
                self.collectionView.reloadSections(IndexSet(integer: 0))
            }
        }
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
        informScrollDelegate(collectionView)
    }

    /**
     Sets up the UI.
     */
    private func setupUI() {
        // Load the view, and add it as Subview
        Bundle.main.loadNibNamed("ProductListView", owner: self, options: nil)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(contentView)

        // Setup UI
        // > Data
        updateLayoutWithSeparation(8)

        collectionView.autoresizingMask = UIViewAutoresizing.flexibleHeight
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = collectionViewContentInset

        drawerManager.registerCell(inCollectionView: collectionView)
        let footerNib = UINib(nibName: CollectionViewFooter.reusableID, bundle: nil)
        collectionView.register(footerNib, forSupplementaryViewOfKind: CHTCollectionElementKindSectionFooter,
                                        withReuseIdentifier: CollectionViewFooter.reusableID)
        let headerNib = UINib(nibName: ListHeaderContainer.reusableID, bundle: nil)
        collectionView.register(headerNib, forSupplementaryViewOfKind: CHTCollectionElementKindSectionHeader,
                                   withReuseIdentifier: ListHeaderContainer.reusableID)


        // >> Pull to refresh
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlTriggered), for: UIControlEvents.valueChanged)
        collectionView.addSubview(refreshControl)

        // > Error View
        errorButtonHeightConstraint.constant = ProductListView.defaultErrorButtonHeight
        errorButton.setStyle(.primary(fontSize: .medium))
        errorButton.addTarget(self, action: #selector(ProductListView.errorButtonPressed), for: .touchUpInside)
        
        if #available(iOS 10, *) {
            setupPrefetching()
        }
    }
    
    func updateLayoutWithSeparation(_ separationBetweenCells: CGFloat) {
        let layout = CHTCollectionViewWaterfallLayout()
        layout.minimumColumnSpacing = separationBetweenCells
        layout.minimumInteritemSpacing = separationBetweenCells
        collectionView.collectionViewLayout = layout
    }

    func refreshUIWithState(_ state: ViewState) {
        switch (state) {
        case .loading:
            // Show/hide views
            firstLoadView.isHidden = false
            dataView.isHidden = true
            errorView.isHidden = true
        case .data:
            // Show/hide views
            firstLoadView.isHidden = true
            dataView.isHidden = false
            errorView.isHidden = true
        case .error(let emptyVM):
            firstLoadView.isHidden = true
            dataView.isHidden = true
            errorView.isHidden = false
            setErrorState(emptyVM)
        case .empty(let emptyVM):
            // Show/hide views
            firstLoadView.isHidden = true
            dataView.isHidden = false
            errorView.isHidden = false
            setErrorState(emptyVM)
        }
    }

    private func setErrorState(_ emptyViewModel: LGEmptyViewModel) {
        errorImageView.image = emptyViewModel.icon
        errorImageViewHeightConstraint.constant = emptyViewModel.iconHeight
        errorTitleLabel.text = emptyViewModel.title
        errorBodyLabel.text = emptyViewModel.body
        errorButton.setTitle(emptyViewModel.buttonTitle, for: .normal)
        // > If there's no button title or action then hide it
        if emptyViewModel.hasAction {
            errorButtonHeightConstraint.constant = ProductListView.defaultErrorButtonHeight
        }
        else {
            errorButtonHeightConstraint.constant = 0
        }
        errorView.updateConstraintsIfNeeded()
    }

    dynamic private func refreshControlTriggered() {
        viewModel.refreshControlTriggered()
    }

    /**
        Will call scroll delegate on scroll events different than bouncing in the edges indicating scrollingDown state
    */
    private func informScrollDelegate(_ scrollView: UIScrollView) {
        notifyScrollDownIfNeeded(scrollView: scrollView)
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

    private func notifyScrollDownIfNeeded(scrollView: UIScrollView) {
        if isDragging.value {
            let limit = (scrollView.contentSize.height - scrollView.frame.size.height + collectionViewContentInset.bottom)
            let offsetLowerThanBouncingLimit = lastContentOffset < limit
            if lastContentOffset > 0.0 && offsetLowerThanBouncingLimit || lastContentOffset < 0.0 && !scrollingDown {
                scrollDelegate?.productListView(self, didScrollDown: scrollingDown)
            }
        } else if lastContentOffset == -collectionViewContentInset.top {
            // If automatically scrolled to top, we should inform !scrollDown
            scrollDelegate?.productListView(self, didScrollDown: false)
        }
    }
    
    /**
        Called when the error button is pressed.
    */
    dynamic private func errorButtonPressed() {
        switch viewModel.state {
        case .empty(let emptyVM):
            emptyVM.action?()
        case .error(let emptyVM):
            emptyVM.action?()
        default:
            break
        }
    }
}

@available(iOS 10, *)
extension ProductListView: UICollectionViewDataSourcePrefetching {
    
    fileprivate func setupPrefetching() {
        collectionView.prefetchDataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        viewModel.prefetchItems(atIndexes: indexPaths.flatMap { $0.row })
    }
}


// UI Testing + accessibility

extension ProductListView {
    func setAccessibilityIds() {
        firstLoadView.accessibilityId = .productListViewFirstLoadView
        firstLoadActivityIndicator.accessibilityId = .productListViewFirstLoadActivityIndicator
        collectionView.accessibilityId = .productListViewCollection
        errorView.accessibilityId = .productListViewErrorView
        errorImageView.accessibilityId =  .productListErrorImageView
        errorTitleLabel.accessibilityId = .productListErrorTitleLabel
        errorBodyLabel.accessibilityId = .productListErrorBodyLabel
        errorButton.accessibilityId = .productListErrorButton
    }
}
