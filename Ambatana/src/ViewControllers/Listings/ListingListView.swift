import LGComponents
import CHTCollectionViewWaterfallLayout
import RxSwift
import LGCoreKit
import GoogleMobileAds
import MoPub


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

final class ListingListView: BaseView, CHTCollectionViewDelegateWaterfallLayout, ListingListViewModelDelegate,
UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private struct Layout { struct Height { static let errorButton: CGFloat = 50 } }

    let firstLoadView = ActivityView()

    private let refreshControl = UIRefreshControl()
    private let dataView = DataView()
    weak var collectionViewFooter: CollectionViewFooter?
    
    private var lastContentOffset: CGFloat
    private var scrollingDown: Bool

    var rxIsDragging: Observable<Bool> { return isDragging.asObservable() }
    private let isDragging = Variable<Bool>(false)

    let errorView = ErrorView()

    var shouldScrollToTopOnFirstPageReload = true
    var dataPadding: UIEdgeInsets {
        didSet {
            dataView.updateWithInsets(dataPadding)
            dataView.setNeedsLayout()
        }
    }
    var firstLoadPadding: UIEdgeInsets {
        didSet {
            firstLoadView.updateWithInsets(firstLoadPadding)
            firstLoadView.setNeedsLayout()
        }
    }
    var errorPadding: UIEdgeInsets {
        didSet {
            let headerHeight: CGFloat = headerDelegate?.totalHeaderHeight() ?? 0
            errorView.updateWithInsets(UIEdgeInsets(top: errorPadding.top + headerHeight,
                                                    left: errorPadding.left,
                                                    bottom: errorPadding.bottom,
                                                    right: errorPadding.right))
            errorView.setNeedsLayout()
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
        get { return collectionView.contentInset }
        set {  collectionView.contentInset = newValue }
    }

    var headerBottom: CGFloat {
        let headerSize = headerDelegate?.totalHeaderHeight() ?? 0
        let headerRect = CGRect(x: 0, y: 0, width: 0, height: headerSize)
        let convertedRect = convert(headerRect, from: collectionView)
        return convertedRect.bottom
    }

    var defaultCellSize: CGSize { return viewModel.defaultCellSize }
    
    internal(set) var viewModel: ListingListViewModel {
        didSet { drawerManager.cellStyle = viewModel.cellStyle }
    }

    private let drawerManager = GridDrawerManager(myUserRepository: Core.myUserRepository,
                                                  locationManager: Core.locationManager)
    
    weak var scrollDelegate: ListingListViewScrollDelegate?
    weak var cellsDelegate: ListingListViewCellsDelegate?
    weak var headerDelegate: ListingListViewHeaderDelegate? {
        didSet { dataView.collectionView.reloadData() }
    }
    weak var adsDelegate: MainListingsAdsDelegate?
    
    // MARK: - Lifecycle
    convenience init() {
        self.init(viewModel: ListingListViewModel(), featureFlags: FeatureFlags.sharedInstance)
        
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

    override func didBecomeActive(_ firstTime: Bool) {
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
    func removePullToRefresh() {
        refreshControl.removeFromSuperview()
    }
    func refreshDataView() {
        viewModel.reloadData()
    }

    func clearList() {
        viewModel.clearList()
    }

    func scrollToTop(_ animated: Bool) {
        let position = CGPoint(x: -collectionViewContentInset.left, y: -collectionViewContentInset.top)
        collectionView.setContentOffset(position, animated: animated)
    }

    func setErrorViewStyle(bgColor: UIColor?, borderColor: UIColor?, containerColor: UIColor?) {
        if errorView.superview == nil {
            collectionView.addSubviewForAutoLayout(errorView)
            NSLayoutConstraint.activate([
                errorView.topAnchor.constraint(equalTo: collectionView.topAnchor),
                errorView.leftAnchor.constraint(equalTo: leftAnchor),
                errorView.rightAnchor.constraint(equalTo: rightAnchor)
            ])
            sendSubview(toBack: errorView)
        }

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
        return SharedConstants.listingListFooterHeight
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
        drawerManager.cellStyle = viewModel.cellStyle
        drawerManager.draw(item,
                           inCell: cell,
                           delegate: viewModel.listingCellDelegate,
                           imageSize: viewModel.imageViewSizeForItem(at: indexPath.row))
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        guard let item = viewModel.itemAtIndex(indexPath.row) else { return }

        let imageSize = viewModel.imageViewSizeForItem(at: indexPath.row)
        let interestedState = viewModel.interestStateFor(listingAtIndex: indexPath.row)
        drawerManager.willDisplay(item,
                                  inCell: cell,
                                  delegate: viewModel.listingCellDelegate,
                                  imageSize: imageSize,
                                  interestedState: interestedState)

        viewModel.setCurrentItemIndex(indexPath.item)

        let indexes = collectionView.indexPathsForVisibleItems.map{ $0.item }
        let topProductIndex = indexes.min() ?? indexPath.item
        cellsDelegate?.visibleTopCellWithIndex(topProductIndex, whileScrollingDown: scrollingDown)
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
        let thumbnailImage = cell?.thumbnailImage
        
        var newFrame: CGRect? = nil
        if let cellFrame = cell?.frame {
            newFrame = superview?.convert(cellFrame, from: collectionView)
        }
        viewModel.selectedItemAtIndex(indexPath.row, thumbnailImage: thumbnailImage, originFrame: newFrame)
    }
    
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // while going down, increase distance in label, when going up, decrease
        scrollingDown = lastContentOffset < scrollView.contentOffset.y
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

    func vmReloadData(_ vm: ListingListViewModel, atIndex index: IndexPath) {
        guard viewModel === vm else { return }
        collectionView.reloadItems(at: [index])
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
        } else if viewModel.isLastPage {
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

    private func addSubviewToFill(_ view: UIView) {
        addSubviewForAutoLayout(view)
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                view.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
                view.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
                view.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor)
                ])
        } else {
            view.layout(with: self).fill()
        }
    }

    private func setupUI() {
        addSubviewToFill(firstLoadView)

        addSubviewForAutoLayout(dataView)
        dataView.layout(with: self).fill()
        dataView.collectionView.dataSource = self
        dataView.collectionView.delegate = self

        dataView.updateCollectionInsets(collectionViewContentInset)

        drawerManager.registerCell(inCollectionView: collectionView)
        collectionView.register(CollectionViewFooter.self,
                                forSupplementaryViewOfKind: CHTCollectionElementKindSectionFooter,
                                withReuseIdentifier: CollectionViewFooter.reusableID)
        collectionView.register(ListHeaderContainer.self,
                                forSupplementaryViewOfKind: CHTCollectionElementKindSectionHeader,
                                withReuseIdentifier: ListHeaderContainer.reusableID)

        refreshControl.addTarget(self, action: #selector(refreshControlTriggered), for: UIControlEvents.valueChanged)
        collectionView.addSubview(refreshControl)

        errorButtonHeightConstraint?.constant = Layout.Height.errorButton
        errorButton.addTarget(self, action: #selector(ListingListView.errorButtonPressed), for: .touchUpInside)
        
        if #available(iOS 10, *) {
            setupPrefetching()
        }

        bringSubview(toFront: firstLoadView)
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
        layout.itemRenderDirection = .leftToRight
        collectionView.collectionViewLayout = layout
    }

    func refreshUIWithState(_ state: ViewState) {
        switch (state) {
        case .loading:
            firstLoadView.isHidden = false
            dataView.isHidden = true
            errorView.isHidden = true
        case .data:
            firstLoadView.isHidden = true
            dataView.isHidden = false
            errorView.isHidden = true
        case .error(let emptyVM):
            firstLoadView.isHidden = true
            dataView.isHidden = true
            errorView.isHidden = false
            setErrorState(emptyVM)
        case .empty(let emptyVM):
            firstLoadView.isHidden = true
            dataView.isHidden = false
            errorView.isHidden = false
            setErrorState(emptyVM)
        }
        setNeedsLayout()
    }

    private func setErrorState(_ emptyViewModel: LGEmptyViewModel) {
        errorView.setImage(emptyViewModel.icon)
        errorImageViewHeightConstraint?.constant = emptyViewModel.iconHeight
        errorView.setTitle(emptyViewModel.title)
        errorView.setBody(emptyViewModel.body)
        errorButton.setTitle(emptyViewModel.buttonTitle, for: .normal)
        errorButtonHeightConstraint?.constant = emptyViewModel.hasAction ? Layout.Height.errorButton : 0
        errorView.setNeedsLayout()
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
        case .dfpAdvertisement(let data):
            guard !data.adRequested else { return }
            // DFP Ads
            let banner = DFPBannerView(adSize: kGADAdSizeFluid)
            banner.adUnitID = data.adUnitId
            banner.rootViewController = data.rootViewController
            banner.adSizeDelegate = self
            banner.delegate = self
            banner.validAdSizes = [NSValueFromGADAdSize(kGADAdSizeFluid)]
            banner.tag = data.adPosition
            banner.load(data.adRequest)
            viewModel.updateAdvertisementRequestedIn(position: inPosition, bannerView: banner)
            break
        case .mopubAdvertisement(let data):
            guard !data.adRequested else { return }
            MoPubAdsRequester.startMoPubRequestWith(data: data, completion: { (nativeAd, moPubView) in
                guard let nativeAd = nativeAd, let moPubView = moPubView else { return }
                nativeAd.delegate = self
                moPubView.tag = data.adPosition
                self.viewModel.updateAdvertisementRequestedIn(position: inPosition, moPubNativeAd: nativeAd, moPubView: moPubView)
            })
            break
        case .adxAdvertisement(let data):
            guard !data.adRequested else { return }
            let adLoader = data.adLoader
            adLoader.delegate = self
            adLoader.position = data.adPosition
            adLoader.load(GADRequest())
            break
        case .collectionCell, .emptyCell, .listingCell, .mostSearchedItems, .promo:
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
        viewModel.prefetchItems(atIndexes: indexPaths.compactMap { $0.row })
    }
}


// UI Testing + accessibility

extension ListingListView {
    func setAccessibilityIds() {
        collectionView.set(accessibilityId: .listingListViewCollection)
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

extension ListingListView: MPNativeAdDelegate {
    func viewControllerForPresentingModalView() -> UIViewController! {
        return adsDelegate?.rootViewControllerForAds()
    }
    
    func willLeaveApplication(from nativeAd: MPNativeAd?) {
        guard let nativeAd = nativeAd else { return }
        let feedPosition: EventParameterFeedPosition = .position(index: nativeAd.associatedView.tag)
        viewModel.bannerWasTapped(adType: .moPub,
                                  willLeaveApp: .trueParameter,
                                  categories: viewModel.categoriesForBannerIn(position: nativeAd.associatedView.tag),
                                  feedPosition: feedPosition)
    }
    
    func willPresentModal(for nativeAd: MPNativeAd?) {
        guard let nativeAd = nativeAd else { return }
        let feedPosition: EventParameterFeedPosition = .position(index: nativeAd.associatedView.tag)
        viewModel.bannerWasTapped(adType: .moPub,
                                  willLeaveApp: .falseParameter,
                                  categories: viewModel.categoriesForBannerIn(position: nativeAd.associatedView.tag),
                                  feedPosition: feedPosition)
    }
    
}

// MARK: - GADNativeContentAdLoaderDelegate
extension ListingListView: GADNativeContentAdLoaderDelegate, GADAdLoaderDelegate, GADNativeAdDelegate {
    public func adLoader(_ adLoader: GADAdLoader, didReceive nativeContentAd: GADNativeContentAd) {
        nativeContentAd.delegate = self
        guard let position = adLoader.position else { return }
        nativeContentAd.position = position
        let contentAdView = Bundle.main.loadNibNamed("GoogleAdxNativeView", owner: nil, options: nil)?.first as! GoogleAdxNativeView
        viewModel.updateAdvertisementRequestedIn(position: position, nativeContentAd: nativeContentAd, contentAdView: contentAdView)
    }
    
    public func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        logMessage(.info, type: .monetization, message: "Google Adx failed with error: \(error.localizedDescription)")
    }

    public func nativeAdWillLeaveApplication(_ nativeAd: GADNativeAd) {
        guard let position = nativeAd.position else { return }
        let feedPosition: EventParameterFeedPosition = .position(index: position)
        viewModel.bannerWasTapped(adType: .adx,
                                  willLeaveApp: .trueParameter,
                                  categories: viewModel.categoriesForBannerIn(position: position),
                                  feedPosition: feedPosition)
    }
    
}

extension GADAdLoader {
    var position: Int? {
        get  {
            guard let accessibilityValue = accessibilityValue else { return -1 }
            return Int(accessibilityValue)
        }
        
        set (newPosition) {
            guard let newPosition = newPosition else { return }
            accessibilityValue = newPosition.description
        }
    }
}

extension GADNativeAd {
    var position: Int? {
        get  {
            guard let accessibilityValue = accessibilityValue else { return -1 }
            return Int(accessibilityValue)
        }
        
        set (newPosition) {
            guard let newPosition = newPosition else { return }
            accessibilityValue = newPosition.description
        }
    }
}


extension ListingListView {
    var errorContentView: UIView { return errorView.containerView }
    var errorImageViewHeightConstraint: NSLayoutConstraint? { return errorView.imageHeight }

    var errorButton: LetgoButton! { return errorView.actionButton }
    var errorButtonHeightConstraint: NSLayoutConstraint? { return errorView.actionHeight }

    var collectionView: UICollectionView { return dataView.collectionView }
}

private final class DataView: UIView {
    struct Layout {
        static let defaultSeparation: CGFloat = 8
    }
    let collectionView: UICollectionView = {
        let waterFallLayout = CHTCollectionViewWaterfallLayout()
        waterFallLayout.minimumColumnSpacing = Layout.defaultSeparation
        waterFallLayout.minimumInteritemSpacing = Layout.defaultSeparation
        waterFallLayout.itemRenderDirection = .leftToRight
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: waterFallLayout)
        if #available(iOS 10.0, *) {
            collectionView.isPrefetchingEnabled = true
        }
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true

        return collectionView
    }()

    private var leadingInset: NSLayoutConstraint?
    private var topInset: NSLayoutConstraint?
    private var trailingInset: NSLayoutConstraint?
    private var bottomInset: NSLayoutConstraint?

    convenience init() {
        self.init(frame: .zero)
        setupUI()
    }
    
    func updateWithInsets(_ edgeInsets: UIEdgeInsets) {
        leadingInset?.constant = edgeInsets.left
        topInset?.constant = edgeInsets.top
        trailingInset?.constant = -edgeInsets.right
        bottomInset?.constant = -edgeInsets.bottom
    }

    func updateCollectionInsets(_ edgeInsets: UIEdgeInsets) {
        collectionView.contentInset = edgeInsets
    }

    private func setupUI() {
        backgroundColor = .clear
        setupConstraints()
    }

    private func setupConstraints() {
        addSubviewForAutoLayout(collectionView)
        let topInset = collectionView.topAnchor.constraint(equalTo: topAnchor)
        let leadingInset = collectionView.leadingAnchor.constraint(equalTo: leadingAnchor )
        let trailingInset = collectionView.trailingAnchor.constraint(equalTo: trailingAnchor )
        let bottomInset = collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        NSLayoutConstraint.activate([ topInset, leadingInset, trailingInset, bottomInset ])
        self.topInset = topInset
        self.leadingInset = leadingInset
        self.trailingInset = trailingInset
        self.bottomInset = bottomInset
    }
}

final class ErrorView: UIView {
    private struct Layout {
        static let sideMargin: CGFloat = 24
        static let actionHeight: CGFloat = 50
        static let imageViewHeight: CGFloat = 50
        static let imageViewBottom: CGFloat = 16
        static let titleBottom: CGFloat = Metrics.shortMargin
    }
    
    let containerView: UIView = {
        let container = UIView()
        container.backgroundColor = .clear
        container.isUserInteractionEnabled = true
        container.setContentCompressionResistancePriority(.required, for: .vertical)
        container.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return container
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.setContentHuggingPriority(.required, for: .vertical)
        imageView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemRegularFont(size: 17)
        label.textColor = .black
        label.textAlignment = .center
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.numberOfLines = 2
        return label
    }()

    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemRegularFont(size: 17)
        label.textColor = .grayDark
        label.textAlignment = .center
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()

    let actionButton = LetgoButton(withStyle: .primary(fontSize: .medium))

    var actionHeight: NSLayoutConstraint?
    var imageHeight: NSLayoutConstraint?

    private var leadingInset: NSLayoutConstraint?
    private var topInset: NSLayoutConstraint?
    private var trailingInset: NSLayoutConstraint?
    private var bottomInset: NSLayoutConstraint?

    convenience init() {
        self.init(frame: .zero)
        setupUI()
    }

    func updateWithInsets(_ edgeInsets: UIEdgeInsets) {
        leadingInset?.constant = edgeInsets.left
        topInset?.constant = edgeInsets.top
        trailingInset?.constant = -edgeInsets.right
        bottomInset?.constant = -edgeInsets.bottom
        setNeedsLayout()
    }

    fileprivate func setImage(_ image: UIImage?) {
        imageView.image = image
    }

    fileprivate func setBody(_ body: String?) {
        bodyLabel.text = body
    }

    fileprivate func setTitle(_ title: String?) {
        titleLabel.text = title
    }

    private func setupUI() {
        backgroundColor = .clear
        setContentHuggingPriority(.defaultLow, for: .horizontal)
        setupConstraints()
        setupAccessibilityIds()
    }

    private func setupAccessibilityIds() {
        set(accessibilityId: .listingListViewErrorView)
        imageView.set(accessibilityId:  .listingListErrorImageView)
        titleLabel.set(accessibilityId: .listingListErrorTitleLabel)
        bodyLabel.set(accessibilityId: .listingListErrorBodyLabel)
        actionButton.set(accessibilityId: .listingListErrorButton)
    }

    private func setupConstraints() {
        addSubviewsForAutoLayout([containerView])
        containerView.addSubviewsForAutoLayout([imageView, titleLabel, bodyLabel, actionButton])
        let imageViewHeight = imageView.heightAnchor.constraint(equalToConstant: 0)
        let actionHeight = actionButton.heightAnchor.constraint(equalToConstant: Layout.actionHeight)

        let topInset = containerView.topAnchor.constraint(equalTo: topAnchor, constant: Layout.sideMargin)
        let leadingInset = containerView.leftAnchor.constraint(equalTo: leftAnchor, constant: Layout.sideMargin)
        let trailingInset = containerView.rightAnchor.constraint(equalTo: rightAnchor, constant: -Layout.sideMargin)
        let bottomInset = containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Layout.sideMargin)
        NSLayoutConstraint.activate([
            trailingInset, topInset, leadingInset, bottomInset,
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Layout.imageViewHeight),
            imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: containerView.widthAnchor, constant: -2*Layout.sideMargin),
            imageViewHeight,

            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Layout.imageViewBottom),
            titleLabel.widthAnchor.constraint(equalTo: containerView.widthAnchor, constant: -2*Layout.sideMargin),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),

            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Layout.titleBottom),
            bodyLabel.widthAnchor.constraint(equalTo: containerView.widthAnchor, constant: -2*Layout.sideMargin),
            bodyLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),

            actionButton.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: Layout.sideMargin),
            actionButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, constant: -2*Layout.sideMargin),
            actionButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            actionButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Layout.sideMargin),
            actionHeight
        ])
        self.imageHeight = imageViewHeight
        self.actionHeight = actionHeight
        self.topInset = topInset
        self.leadingInset = leadingInset
        self.trailingInset = trailingInset
        self.bottomInset = bottomInset
    }
}

final class ActivityView: UIView {
    private var leadingInset: NSLayoutConstraint?
    private var topInset: NSLayoutConstraint?
    private var trailingInset: NSLayoutConstraint?
    private var bottomInset: NSLayoutConstraint?

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        indicator.color = UIColor(red: 153, green: 153, blue: 153)
        return indicator
    }()

    convenience init() {
        self.init(frame: .zero)
        setupUI()
        activityIndicator.startAnimating()
    }

    func updateWithInsets(_ edgeInsets: UIEdgeInsets) {
        leadingInset?.constant = edgeInsets.left
        topInset?.constant = edgeInsets.top
        trailingInset?.constant = -edgeInsets.right
        bottomInset?.constant = -edgeInsets.bottom
    }

    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0)
        setupConstraints()
    }

    private func setupAccessibilityIds() {
        set(accessibilityId: .listingListViewFirstLoadView)
        activityIndicator.set(accessibilityId: .listingListViewFirstLoadActivityIndicator)
    }

    private func setupConstraints() {
        addSubviewForAutoLayout(activityIndicator)
        let topInset = activityIndicator.topAnchor.constraint(equalTo: topAnchor)
        let leadingInset = activityIndicator.leadingAnchor.constraint(equalTo: leadingAnchor)
        let trailingInset = activityIndicator.trailingAnchor.constraint(equalTo: trailingAnchor)
        let bottomInset = activityIndicator.bottomAnchor.constraint(equalTo: bottomAnchor)
        NSLayoutConstraint.activate([ topInset, leadingInset, trailingInset, bottomInset ])
        self.topInset = topInset
        self.leadingInset = leadingInset
        self.trailingInset = trailingInset
        self.bottomInset = bottomInset
    }
}
