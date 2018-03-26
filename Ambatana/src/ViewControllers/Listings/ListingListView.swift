//
//  ListingListView.swift
//  LetGo
//
//  Created by AHL on 9/7/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import CHTCollectionViewWaterfallLayout
import RxSwift
import LGCoreKit
import GoogleMobileAds

protocol ListingListViewScrollDelegate: class {
    func listingListView(_ listingListView: ListingListView, didScrollDown scrollDown: Bool)
    func listingListView(_ listingListView: ListingListView, didScrollWithContentOffsetY contentOffsetY: CGFloat)
    func listingListViewAllowScrollingOnEmptyState(_ listingListView: ListingListView) -> Bool
}

extension ListingListViewScrollDelegate {
    func listingListViewAllowScrollingOnEmptyState(_ listingListView: ListingListView) -> Bool {
        return false
    }
}

protocol ListingListViewCellsDelegate: class {
    func visibleTopCellWithIndex(_ index: Int, whileScrollingDown scrollingDown: Bool)
}

protocol ListingListViewHeaderDelegate: class {
    func totalHeaderHeight() -> CGFloat
    func setupViewsIn(header: ListHeaderContainer)
}

class ListingListView: BaseView, CHTCollectionViewDelegateWaterfallLayout, ListingListViewModelDelegate,
UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // Constants
    private static let defaultErrorButtonHeight: CGFloat = 50
    
    fileprivate let firstLoad = ActivityView()
    var firstLoadView: UIView { return firstLoad }
    var firstLoadActivityIndicator: UIActivityIndicatorView { return firstLoad.activityIndicator }
    
    // > Data
    fileprivate let codedDataView = DataView()
    var dataView: UIView { return codedDataView }
    var refreshControl = UIRefreshControl()
    var collectionView: UICollectionView { return codedDataView.collectionView }
    weak var collectionViewFooter: CollectionViewFooter?
    
    private var lastContentOffset: CGFloat
    private var scrollingDown: Bool
    let isDragging = Variable<Bool>(false)

    fileprivate let codedErrorView = ErrorView()

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
    internal(set) var viewModel: ListingListViewModel {
        didSet {
            drawerManager.cellStyle = viewModel.cellStyle
        }
    }

    private let drawerManager = GridDrawerManager(myUserRepository: Core.myUserRepository,
                                                  locationManager: Core.locationManager)
    
    // Delegate
    weak var scrollDelegate: ListingListViewScrollDelegate?
    weak var cellsDelegate: ListingListViewCellsDelegate?
    weak var headerDelegate: ListingListViewHeaderDelegate? {
        didSet {
            codedDataView.collectionView.reloadData()
        }
    }
    
    
    // MARK: - Lifecycle
    convenience init() {
        self.init(viewModel: ListingListViewModel(requester: nil), featureFlags: FeatureFlags.sharedInstance)
    }
    init(viewModel: ListingListViewModel, featureFlags: FeatureFlaggeable) {
        self.viewModel = viewModel
        let padding = UIEdgeInsets.zero
        self.dataPadding = padding
        self.firstLoadPadding = padding
        self.errorPadding = padding
        self.padding = padding
        self.lastContentOffset = 0
        self.scrollingDown = true
        super.init(viewModel: viewModel, frame: .zero)
        drawerManager.freePostingAllowed = featureFlags.freePostingModeAllowed
        viewModel.delegate = self
        setupUI()
        setAccessibilityIds()
    }
    
    required convenience init?(coder aDecoder: NSCoder) { fatalError("Long life to coded views") }

    internal override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        refreshDataView()
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        switch viewModel.state {
        case .empty:
            if let delegate = scrollDelegate, delegate.listingListViewAllowScrollingOnEmptyState(self) { return hitView }
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

    override func awakeFromNib() {
        super.awakeFromNib()
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
    }

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
        addSubviewForAutoLayout(codedErrorView)
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                codedErrorView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                codedErrorView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
                codedErrorView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
                codedErrorView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor)
            ])
        } else {
            codedErrorView.layout(with: self).fill()
        }
        codedErrorView.layoutIfNeeded()

        errorView.backgroundColor = bgColor
        errorContentView.backgroundColor = containerColor
        errorContentView.layer.borderColor = borderColor?.cgColor
        errorContentView.layer.borderWidth = borderColor != nil ? 0.5 : 0
        errorContentView.cornerRadius = 4
    }

    
    // MARK: > ViewModel

    func switchViewModel(_ vm: ListingListViewModel) {
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
        return Constants.listingListFooterHeight
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int) -> UIEdgeInsets {
        let inset = viewModel.listingListFixedInset
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
        return viewModel.numberOfListings
    }
    

    func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = viewModel.itemAtIndex(indexPath.row) else { return UICollectionViewCell() }
        requestAdFor(cellModel: item, inPosition: indexPath.row)
        let cell = drawerManager.cell(item, collectionView: collectionView, atIndexPath: indexPath)
        cell.tag = (indexPath as NSIndexPath).hash
        drawerManager.draw(item,
                           inCell: cell,
                           delegate: viewModel.listingCellDelegate,
                           imageSize: viewModel.imageViewSizeForItem(at: indexPath.row))
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        DispatchQueue.main.async { [weak self] in
            if let item = self?.viewModel.itemAtIndex(indexPath.row),
                let cell = self?.collectionView.cellForItem(at: indexPath),
                let imageSize = self?.viewModel.imageViewSizeForItem(at: indexPath.row) {
                self?.drawerManager.willDisplay(item, inCell: cell, delegate: self?.viewModel.listingCellDelegate, imageSize: imageSize)
            }

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
            collectionViewFooter = footer
            refreshFooter()
            return footer
        case CHTCollectionElementKindSectionHeader, UICollectionElementKindSectionHeader:
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                    withReuseIdentifier: ListHeaderContainer.reusableID, for: indexPath) as? ListHeaderContainer
                    else { return UICollectionReusableView() }
            headerDelegate?.setupViewsIn(header: header)
            return header
        default:
            return UICollectionReusableView()
        }
    }
    
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ cv: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView(cv, cellForItemAt: indexPath) as? ListingCell
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


    // MARK: - ListingListViewModelDelegate

    func vmReloadData(_ vm: ListingListViewModel) {
        guard viewModel === vm else { return }
        reloadData()
    }

    func vmDidUpdateState(_ vm: ListingListViewModel, state: ViewState) {
        guard viewModel === vm else { return }
        refreshUIWithState(state)
    }

    func vmDidFinishLoading(_ vm: ListingListViewModel, page: UInt, indexes: [Int]) {
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
            refreshFooter()
        } else if !indexes.isEmpty {
            // Middle pages
            // Insert animated
            let indexPaths = indexes.map{ IndexPath(item: $0, section: 0) }
            collectionView.insertItems(at: indexPaths)
            refreshFooter()
        } else {
            reloadData()
        }
    }

    func vmReloadItemAtIndexPath(indexPath: IndexPath) {
        collectionView.reloadItems(at: [indexPath])
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
        addSubviewForAutoLayout(firstLoadView)
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                firstLoadView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                firstLoadView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
                firstLoadView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
                firstLoadView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor)
            ])
        } else {
            firstLoadView.layout(with: self).fill()
        }
        firstLoadView.layoutIfNeeded()

        codedDataView.collectionView.dataSource = self
        codedDataView.collectionView.delegate = self
        addSubviewForAutoLayout(codedDataView)
        codedDataView.layout(with: self).fill()
        codedDataView.backgroundColor = .white


        // Setup UI
        // > Data
        updateLayoutWithSeparation(8)

        collectionView.autoresizingMask = UIViewAutoresizing.flexibleHeight
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = collectionViewContentInset

        drawerManager.registerCell(inCollectionView: collectionView)
        collectionView.register(CollectionViewFooter.self,
                                forSupplementaryViewOfKind: CHTCollectionElementKindSectionFooter,
                                withReuseIdentifier: CollectionViewFooter.reusableID)
        collectionView.register(ListHeaderContainer.self,
                                forSupplementaryViewOfKind: CHTCollectionElementKindSectionHeader,
                                withReuseIdentifier: ListHeaderContainer.reusableID)

        // >> Pull to refresh
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlTriggered), for: UIControlEvents.valueChanged)
        collectionView.addSubview(refreshControl)

        errorButtonHeightConstraint?.constant = ListingListView.defaultErrorButtonHeight
        errorButton.setStyle(.primary(fontSize: .medium))
        errorButton.addTarget(self, action: #selector(ListingListView.errorButtonPressed), for: .touchUpInside)
        
        if #available(iOS 10, *) {
            setupPrefetching()
        }

        bringSubview(toFront: firstLoad)
    }
    
    private func refreshFooter() {
        guard let footer = collectionViewFooter else { return }
        if viewModel.isOnErrorState {
            footer.status = .error
        } else if viewModel.isLastPage {
            footer.status = .lastPage
        } else {
            footer.status = .loading
        }
        footer.retryButtonBlock = { [weak self] in
            if let strongSelf = self {
                strongSelf.viewModel.retrieveListingsNextPage()
                strongSelf.reloadData()
            }
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
        errorImageViewHeightConstraint?.constant = emptyViewModel.iconHeight
        errorTitleLabel.text = emptyViewModel.title
        errorBodyLabel.text = emptyViewModel.body
        errorButton.setTitle(emptyViewModel.buttonTitle, for: .normal)
        // > If there's no button title or action then hide it
        if emptyViewModel.hasAction {
            errorButtonHeightConstraint?.constant = ListingListView.defaultErrorButtonHeight
        }
        else {
            errorButtonHeightConstraint?.constant = 0
        }
        errorView.updateConstraintsIfNeeded()
    }

    @objc private func refreshControlTriggered() {
        viewModel.refreshControlTriggered()
    }

    /**
        Will call scroll delegate on scroll events different than bouncing in the edges indicating scrollingDown state
    */
    private func informScrollDelegate(_ scrollView: UIScrollView) {
        notifyScrollDownIfNeeded(scrollView: scrollView)
        scrollDelegate?.listingListView(self, didScrollWithContentOffsetY: scrollView.contentOffset.y)
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
                scrollDelegate?.listingListView(self, didScrollDown: scrollingDown)
            }
        } else if lastContentOffset == -collectionViewContentInset.top {
            // If automatically scrolled to top, we should inform !scrollDown
            scrollDelegate?.listingListView(self, didScrollDown: false)
        }
    }
    
    /**
        Called when the error button is pressed.
    */
    @objc private func errorButtonPressed() {
        switch viewModel.state {
        case .empty(let emptyVM):
            emptyVM.action?()
        case .error(let emptyVM):
            emptyVM.action?()
        default:
            break
        }
    }

    fileprivate func requestAdFor(cellModel: ListingCellModel, inPosition: Int) {
        switch cellModel {
        case .advertisement(let data):
            guard !data.adRequested else { return }
            let banner = DFPBannerView(adSize: kGADAdSizeFluid)

            banner.adUnitID = data.adUnitId
            banner.rootViewController = data.rootViewController
            banner.adSizeDelegate = self
            banner.delegate = self
            banner.validAdSizes = [NSValueFromGADAdSize(kGADAdSizeFluid)]
            banner.tag = data.adPosition

            banner.load(data.adRequest)

            viewModel.updateAdvertisementRequestedIn(position: inPosition, withBanner: banner)
        case .collectionCell, .emptyCell, .listingCell, .mostSearchedItems:        
            break
        }
    }
}

@available(iOS 10, *)
extension ListingListView: UICollectionViewDataSourcePrefetching {
    
    fileprivate func setupPrefetching() {
        collectionView.prefetchDataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        viewModel.prefetchItems(atIndexes: indexPaths.flatMap { $0.row })
    }
}


// UI Testing + accessibility

extension ListingListView {
    func setAccessibilityIds() {
        firstLoadView.set(accessibilityId: .listingListViewFirstLoadView)
        firstLoadActivityIndicator.set(accessibilityId: .listingListViewFirstLoadActivityIndicator)
        collectionView.set(accessibilityId: .listingListViewCollection)
        errorView.set(accessibilityId: .listingListViewErrorView)
        errorImageView.set(accessibilityId:  .listingListErrorImageView)
        errorTitleLabel.set(accessibilityId: .listingListErrorTitleLabel)
        errorBodyLabel.set(accessibilityId: .listingListErrorBodyLabel)
        errorButton.set(accessibilityId: .listingListErrorButton)
    }
}


// MARK: - GADBannerViewDelegate, GADAdSizeDelegate

extension ListingListView: GADBannerViewDelegate, GADAdSizeDelegate {

    func adView(_ bannerView: GADBannerView, willChangeAdSizeTo size: GADAdSize) {
        let sizeFromAdSize = CGSizeFromGADAdSize(size)
        viewModel.updateAdCellHeight(newHeight: sizeFromAdSize.height, forPosition: bannerView.tag, withBannerView: bannerView)
    }

    func adViewDidReceiveAd(_ bannerView: GADBannerView) { }

    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        logMessage(.info, type: .monetization, message: "Feed banner in position \(bannerView.tag) failed with error: \(error.localizedDescription)")
        viewModel.updateAdCellHeight(newHeight: 0, forPosition: bannerView.tag, withBannerView: bannerView)
    }

    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        let feedPosition: EventParameterFeedPosition = .position(index: bannerView.tag)
        viewModel.bannerWasTapped(adType: .dfp,
                                  willLeaveApp: .falseParameter,
                                  categories: viewModel.categoriesForBannerIn(position: bannerView.tag),
                                  feedPosition: feedPosition)
    }

    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        let feedPosition: EventParameterFeedPosition = .position(index: bannerView.tag)
        viewModel.bannerWasTapped(adType: .dfp,
                                  willLeaveApp: .trueParameter,
                                  categories: viewModel.categoriesForBannerIn(position: bannerView.tag),
                                  feedPosition: feedPosition)
    }
}

extension ListingListView {
    var errorView: UIView { return codedErrorView }
    var errorContentView: UIView { return codedErrorView.containerView }
    var errorImageView: UIImageView { return codedErrorView.imageView }
    var errorImageViewHeightConstraint: NSLayoutConstraint? { return codedErrorView.imageHeight }

    var errorTitleLabel: UILabel { return codedErrorView.title }
    var errorBodyLabel: UILabel { return codedErrorView.body }
    var errorButton: LetgoButton! { return codedErrorView.actionButton }
    var errorButtonHeightConstraint: NSLayoutConstraint? { return codedErrorView.actionHeight }
}

private final class DataView: UIView {
    let collectionView: UICollectionView = {
        let waterFallLayout = CHTCollectionViewWaterfallLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: waterFallLayout)
        if #available(iOS 10.0, *) {
            collectionView.isPrefetchingEnabled = true
        }
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        collectionView.backgroundColor = .white
        return collectionView
    }()

    convenience init() {
        self.init(frame: .zero)
        setupUI()
    }

    private func setupUI() {
        setupConstraints()
    }

    private func setupConstraints() {
        addSubviewForAutoLayout(collectionView)
        collectionView.layout(with: self).fill()
    }
}

private final class ErrorView: UIView {
    private struct Layout {
        static let sideMargin: CGFloat = 24
        static let actionHeight: CGFloat = 50
        static let imageViewHeight: CGFloat = 50
        static let imageViewBottom: CGFloat = 16
        static let titleBottom: CGFloat = Metrics.shortMargin
    }
    let containerView: UIView = {
        let container = UIView()
        container.backgroundColor = .white
        return container
    }()

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()

    let title: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemRegularFont(size: 17)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()

    let body: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemRegularFont(size: 17)
        label.textColor = .grayDark
        label.textAlignment = .center
        return label
    }()

    let actionButton: LetgoButton = {
        let button = LetgoButton(withStyle: .primary(fontSize: .medium))
        return button
    }()

    var actionHeight: NSLayoutConstraint?
    var imageHeight: NSLayoutConstraint?

    convenience init() {
        self.init(frame: .zero)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = .clear
        setupConstraints()
    }

    private func setupConstraints() {
        addSubviewsForAutoLayout([containerView])
        containerView.addSubviewsForAutoLayout([imageView, title, body, actionButton])
        let imageViewHeight = imageView.heightAnchor.constraint(equalToConstant: 0)
        let actionHeight = actionButton.heightAnchor.constraint(equalToConstant: Layout.actionHeight)
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.sideMargin),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Layout.sideMargin),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Layout.imageViewHeight),
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Layout.sideMargin),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Layout.sideMargin),
            imageViewHeight,
            title.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Layout.imageViewBottom),
            title.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Layout.sideMargin),
            title.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Layout.sideMargin),
            body.topAnchor.constraint(equalTo: title.bottomAnchor, constant: Layout.titleBottom),
            body.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Layout.sideMargin),
            body.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Layout.sideMargin),
            actionButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Layout.sideMargin),
            actionButton.topAnchor.constraint(equalTo: body.bottomAnchor, constant: Layout.sideMargin),
            actionButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Layout.sideMargin),
            actionButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Layout.sideMargin),
            actionHeight
        ])
        self.imageHeight = imageViewHeight
        self.actionHeight = actionHeight
    }
}

private final class ActivityView: UIView {

    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        indicator.color = UIColor(red: 153, green: 153, blue: 153)
        indicator.hidesWhenStopped = false
        return indicator
    }()

    convenience init() {
        self.init(frame: .zero)
        setupUI()

        activityIndicator.startAnimating()
    }

    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0)
        setupConstraints()
    }

    private func setupConstraints() {
        addSubviewForAutoLayout(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
