import CoreLocation
import LGCoreKit
import UIKit
import CHTCollectionViewWaterfallLayout
import RxSwift
import LGComponents

enum SearchSuggestionType {
    case suggestive
    case lastSearch
    case trending
    
    static func sectionType(index: Int) -> SearchSuggestionType? {
        switch index {
        case 0: return .suggestive
        case 1: return .lastSearch
        case 2: return .trending
        default: return nil
        }
    }
    
    static var numberOfSections: Int {
        return 3
    }
}

class MainListingsViewController: BaseViewController, ListingListViewScrollDelegate, MainListingsViewModelDelegate,
    FilterTagsViewDelegate, UITextFieldDelegate, ScrollableToTop, MainListingsAdsDelegate {
    
    // ViewModel
    var viewModel: MainListingsViewModel
    
    // MARK: - Subviews
    private let listingListView = ListingListView()
    private let filterDescriptionHeaderView = FilterDescriptionHeaderView()
    private let filterTitleHeaderView = FilterTitleHeaderView()
    private let infoBubbleView = InfoBubbleView(style: .light)
    private let recentItemsBubbleView = InfoBubbleView(style: .reddish)
    private let navbarSearch: LGNavBarSearchField
    private var trendingSearchView = TrendingSearchView()
    private var filterTagsView = FilterTagsView()
    
    private let tagsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .grayBackground
        view.isHidden = true
        return view
    }()
    
    private let statusTopView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private var mapTooltip: Tooltip?
    

    // MARK: - Constraints
    
    private var filterDescriptionTopConstraint: NSLayoutConstraint?
    private var tagsContainerHeightConstraint: NSLayoutConstraint?
    private var infoBubbleTopConstraint: NSLayoutConstraint?

    private var primaryTagsShowing: Bool = false
    private var secondaryTagsShowing: Bool = false

    private let topInset = Variable<CGFloat>(0)

    private let disposeBag = DisposeBag()
    
    private var categoriesHeader: CategoriesHeaderCollectionView?

    private var filterTagsViewHeight: CGFloat {
        if viewModel.secondaryTags.isEmpty || viewModel.filters.selectedTaxonomyChildren.count > 0 {
            return FilterTagsView.collectionViewHeight
        } else {
            return FilterTagsView.collectionViewHeight * 2
        }
    }
    private var filterHeadersHeight: CGFloat {
        return filterDescriptionHeaderView.height + filterTitleHeaderView.height
    }
    private var topHeadersHeight: CGFloat {
        return filterHeadersHeight + tagsContainerView.height
    }
    private var collectionViewHeadersHeight: CGFloat {
        return listingListView.headerDelegate?.totalHeaderHeight() ?? 0
    }
    
    // MARK: - Lifecycle

    required init(viewModel: MainListingsViewModel) {
        navbarSearch = LGNavBarSearchField(viewModel.searchString)
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
        viewModel.delegate = self
        viewModel.adsDelegate = self
        hidesBottomBarWhenPushed = false
        floatingSellButtonHidden = false
        hasTabBar = true
        automaticallyAdjustsScrollViewInsets = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            listingListView.collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        setupStatusTopView()
        addSubViews()

        setupFilterHeaders()
        setupListingView()
        setupInfoBubble()
        if viewModel.isEngagementBadgingEnabled {
            setupRecentItemsBubbleView()
        }
        setupTagsView()
        setupSearchAndTrending()
        setFiltersNavBarButton()
        setLeftNavBarButtons()
        setupRxBindings()
        setAccessibilityIds()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // we want to show the selected tags when the user closes the product detail too.  Also:
        // ⚠️ not showing the tags collection view causes a crash when trying to reload the collection data
        // ⚠️ while not visible (ABIOS-2696)
        showTagsView(showPrimaryTags: viewModel.primaryTags.count > 0, showSecondaryTags: viewModel.secondaryTags.count > 0, updateInsets: true)
        endEdit()
    }
    
    // MARK: - ScrollableToTop

    /**
    Scrolls the product list to the top
    */
    func scrollToTop() {
        guard didCallViewDidLoaded else { return }
        listingListView.scrollToTop(true)
    }
    

    // MARK: - ListingListViewScrollDelegate
    
    func listingListView(_ listingListView: ListingListView, didScrollDown scrollDown: Bool) {
        guard viewModel.active else { return }

        // Hide tab bar once all headers inside collection are gone
        let headersCollection = listingListView.headerDelegate?.totalHeaderHeight() ?? 0
        if listingListView.collectionView.contentOffset.y > headersCollection ||
           listingListView.collectionView.contentOffset.y <= -topHeadersHeight  {
            // Move tags view along iwth tab bar
            if !filterTagsView.tags.isEmpty {
                showTagsView(showPrimaryTags: !scrollDown, showSecondaryTags: !scrollDown && viewModel.filters.selectedTaxonomyChildren.count <= 0, updateInsets: false)
            }
            setBars(hidden: scrollDown)
        }
    }

    func listingListView(_ listingListView: ListingListView, didScrollWithContentOffsetY contentOffsetY: CGFloat) {
        updateBubbleTopConstraint()
        updateFilterHeaderTopConstraint(withContentOffsetY: contentOffsetY)
    }
    
    private func updateFilterHeaderTopConstraint(withContentOffsetY contentOffsetY: CGFloat) {
        // ignore positive values
        guard contentOffsetY <= 0 else { return }
        // ignore values higher than the topInset
        guard abs(contentOffsetY) <= topInset.value else {
            filterDescriptionTopConstraint?.constant = 0
            return
        }
        
        let filterHeadersOffset = topInset.value + contentOffsetY
        if filterHeadersOffset <= filterDescriptionHeaderView.height {
            // move upwards until description header is completely below
            filterDescriptionTopConstraint?.constant = -filterHeadersOffset
            filterDescriptionHeaderView.alpha = 1
        } else {
            // description header is completely below and also hidden
            filterDescriptionTopConstraint?.constant = -filterDescriptionHeaderView.height
            filterDescriptionHeaderView.alpha = 0.1
        }
    }

    private func updateBubbleTopConstraint() {
        let infoBubbleTopMargin: CGFloat = 8
        let offset: CGFloat = topInset.value
        let delta = listingListView.headerBottom - offset
        infoBubbleTopConstraint?.constant = infoBubbleTopMargin + max(0, delta)
    }
    
    // MARK: - MainListingsViewModelDelegate

    func vmDidSearch() {
        trendingSearchView.isHidden = true
    }

    func vmShowTags(primaryTags: [FilterTag], secondaryTags: [FilterTag]) {
        updateTagsView(primaryTags: primaryTags, secondaryTags: secondaryTags)
    }

    func vmFiltersChanged() {
        setFiltersNavBarButton()
    }
    
    func vmShowMapToolTip(with configuration: TooltipConfiguration) {
        guard let mapButton = navigationItem.rightBarButtonItems?.first?.customView else { return }
        
        let tryNowButton = LetgoButton(withStyle: .transparent(fontSize: .verySmall, sidePadding: Layout.ToolTipMap.buttonSidePadding))
        tryNowButton.setTitle(R.Strings.realEstateMapTooltipButtonTitle, for: .normal)
        tryNowButton.addTarget(self, action: #selector(openMap(_:)), for: UIControlEvents.touchUpInside)

        let tooltip = Tooltip(targetView: mapButton,
                              superView: view,
                              button: tryNowButton,
                              configuration: configuration)

        tooltip.alpha = 0.0
        tooltip.targetViewCenter = mapButton.convert(mapButton.frame.center, to: view)
        view.addSubviewForAutoLayout(tooltip)
        NSLayoutConstraint.activate([tryNowButton.heightAnchor.constraint(equalToConstant: Layout.ToolTipMap.buttonHeight),
                                     tooltip.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Layout.ToolTipMap.right),
                                     tooltip.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: Layout.ToolTipMap.left),
                                     tooltip.topAnchor.constraint(lessThanOrEqualTo: safeTopAnchor)])
        self.mapTooltip = tooltip
        UIView.animate(withDuration: 0.3) {
            self.mapTooltip?.alpha = 1.0
        }

    }
    
    func vmHideMapToolTip() {
        UIView.animate(withDuration: 0.3, animations: {
            self.mapTooltip?.alpha = 0.0
        }) { [weak self] _ in
            self?.mapTooltip?.removeFromSuperview()
            self?.mapTooltip = nil
            self?.viewModel.tooltipMapHidden()
        }
    }

    // MARK: - MainListingsAdsDelegate

    func rootViewControllerForAds() -> UIViewController {
        return self
    }


    // MARK: UITextFieldDelegate Methods

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if viewModel.clearTextOnSearch {
            textField.text = viewModel.searchString
            return false
        }
        return true
    }
    
    dynamic func textFieldDidBeginEditing(_ textField: UITextField) {
        if viewModel.clearTextOnSearch {
            textField.text = nil
        }
        beginEdit()
    }
    
    dynamic func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let query = textField.text else { return true }
        viewModel.search(query)
        return true
    }
    
    // MARK: - Add Subviews
    
    func addSubViews() {
        addSubview(listingListView)
        view.addSubviewsForAutoLayout([filterDescriptionHeaderView, filterTitleHeaderView,
                                       listingListView, infoBubbleView,
                                       tagsContainerView, trendingSearchView])
    }
    
    private func setupStatusTopView() {
        if !isSafeAreaAvailable {
            view.addSubviewForAutoLayout(statusTopView)
            NSLayoutConstraint.activate([
                statusTopView.leadingAnchor.constraint(equalTo: safeLeadingAnchor),
                statusTopView.topAnchor.constraint(equalTo: view.topAnchor),
                statusTopView.trailingAnchor.constraint(equalTo: safeTrailingAnchor),
                statusTopView.heightAnchor.constraint(equalToConstant: statusBarHeight)
                ])
        }
    }
    
    
    // MARK: - FilterHeaders
    
    private func setupFilterHeaders() {
        NSLayoutConstraint.activate([
            filterDescriptionHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            filterDescriptionHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filterTitleHeaderView.topAnchor.constraint(equalTo: filterDescriptionHeaderView.bottomAnchor),
            filterTitleHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            filterTitleHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
            ])
    }
    
    // MARK: - FilterTagsViewDelegate
    
    func filterTagsViewDidRemoveTag(_ tag: FilterTag, remainingTags: [FilterTag]) {
        viewModel.updateFiltersFromTags(remainingTags, removedTag: tag)
        updateTagsView(primaryTags: viewModel.primaryTags, secondaryTags: viewModel.secondaryTags)
    }
    
    func filterTagsViewDidSelectTag(_ tag: FilterTag) {
        if let taxonomyChild = tag.taxonomyChild {
            viewModel.updateSelectedTaxonomyChildren(taxonomyChildren: [taxonomyChild])
        }
        updateTagsView(primaryTags: viewModel.primaryTags, secondaryTags: viewModel.secondaryTags)
    }
    
    
    // MARK: - Private methods

    private func setBars(hidden: Bool, animated: Bool = true) {
        tabBarController?.setTabBarHidden(hidden, animated: animated)
        navigationController?.setNavigationBarHidden(hidden, animated: animated)
    }

    @objc private func endEdit() {
        trendingSearchView.isHidden = true
        setFiltersNavBarButton()
        setLeftNavBarButtons()
        navbarSearch.cancelEdit()
    }

    private func beginEdit() {
        guard trendingSearchView.isHidden else { return }

        viewModel.searchBegan()
        let spacing = makeSpacingButton(withFixedWidth: Metrics.navBarDefaultSpacing)
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel , target: self,
                                     action: #selector(endEdit))
        navigationItem.setRightBarButtonItems([cancel, spacing], animated: false)
        trendingSearchView.isHidden = false
        viewModel.retrieveLastUserSearch()
        navbarSearch.beginEdit()
    }
    
    @objc func openFilters(_ sender: AnyObject) {
        navbarSearch.searchTextField.resignFirstResponder()
        viewModel.showFilters()
    }
    
    @objc func openMap(_ sender: AnyObject) {
        navbarSearch.searchTextField.resignFirstResponder()
        vmHideMapToolTip()
        viewModel.showMap()
    }
    
    private func setupTagsView() {

        tagsContainerView.addSubviewForAutoLayout(filterTagsView)

        let heightConstraint = tagsContainerView.heightAnchor.constraint(equalToConstant: 0)
        let topConstraint = filterDescriptionHeaderView.topAnchor.constraint(equalTo: tagsContainerView.bottomAnchor)
        
        NSLayoutConstraint.activate([
            tagsContainerView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            tagsContainerView.leadingAnchor.constraint(equalTo: safeLeadingAnchor),
            tagsContainerView.trailingAnchor.constraint(equalTo: safeTrailingAnchor),
            topConstraint,
            heightConstraint
            ])
        tagsContainerHeightConstraint = heightConstraint
        filterDescriptionTopConstraint = topConstraint
        
        filterTagsView.delegate = self
        filterTagsView.layout(with: tagsContainerView).fill()
        
        updateTagsView(primaryTags: viewModel.primaryTags, secondaryTags: viewModel.secondaryTags)
    }
    
    private func updateTagsView(primaryTags: [FilterTag], secondaryTags: [FilterTag]) {
        filterTagsView.updateTags(primaryTags)
        filterTagsView.updateSecondaryTags(secondaryTags)
        let showPrimaryTags = primaryTags.count > 0
        let showSecondaryTags = secondaryTags.count > 0
        showTagsView(showPrimaryTags: showPrimaryTags, showSecondaryTags: showSecondaryTags, updateInsets: true)
        
        //Update tags button
        setFiltersNavBarButton()
    }
    
    private func setFiltersNavBarButton() {
        let buttons = viewModel.rightBarButtonsItems
        setLetGoRightButtonsWith(images: buttons.map { $0.image }, selectors: buttons.map { $0.selector })
    }
    
    private func setInviteNavBarButton() {
        guard isRootViewController() else { return }
        guard viewModel.shouldShowInviteButton  else { return }

        let invite = UIBarButtonItem(title: R.Strings.mainProductsInviteNavigationBarButton,
                                     style: .plain,
                                     target: self,
                                     action: #selector(openInvite))
        let spacing = makeSpacingButton(withFixedWidth: Metrics.navBarDefaultSpacing)

        navigationItem.setLeftBarButtonItems([invite, spacing], animated: false)
    }

    private func setLeftNavBarButtons() {
        guard isRootViewController() else { return }
        if viewModel.shouldShowCommunityButton {
            setCommunityButton()
        } else if viewModel.shouldShowUserProfileButton {
            setUserProfileButton()
        } else {
            setInviteNavBarButton()
        }
    }

    private func setCommunityButton() {
        let button = UIBarButtonItem(image: R.Asset.IconsButtons.tabbarCommunity.image,
                                     style: .plain,
                                     target: self,
                                     action: #selector(didTapCommunity))
        navigationItem.setLeftBarButton(button, animated: false)
    }

    private func setUserProfileButton() {
        let button = UIBarButtonItem(image: R.Asset.IconsButtons.tabbarProfile.image,
                                     style: .plain,
                                     target: self,
                                     action: #selector(didTapUserProfile))
        navigationItem.setLeftBarButton(button, animated: false)
    }

    @objc private func didTapCommunity() {
        viewModel.vmUserDidTapCommunity()
    }

    @objc private func didTapUserProfile() {
        viewModel.vmUserDidTapUserProfile()
    }
    
    @objc private func openInvite() {
        viewModel.vmUserDidTapInvite()
    }
    
    private func showTagsView(showPrimaryTags: Bool, showSecondaryTags: Bool, updateInsets: Bool) {
        if primaryTagsShowing == showPrimaryTags && secondaryTagsShowing == showSecondaryTags {
            return
        }
        primaryTagsShowing = showPrimaryTags
        secondaryTagsShowing = showSecondaryTags

        tagsContainerHeightConstraint?.constant = showPrimaryTags ? filterTagsViewHeight : 0
        if updateInsets {
            updateTopInset()
        }
        view.layoutIfNeeded()
        
        tagsContainerView.isHidden = !showPrimaryTags
    }
    
    private func setupListingView() {
        listingListView.collectionViewContentInset.bottom = tabBarHeight
            + LGUIKitConstants.tabBarSellFloatingButtonHeight
            + LGUIKitConstants.tabBarSellFloatingButtonDistance
        let errorStyle = ErrorViewCellStyle(backgroundColor: UIColor(patternImage: R.Asset.BackgroundsAndImages.patternWhite.image),
                                            borderColor: .lineGray,
                                            containerColor: .white)
        listingListView.setupErrorView(withStyle: errorStyle)

        listingListView.scrollDelegate = self
        listingListView.headerDelegate = self
        listingListView.adsDelegate = self
        listingListView.cellsDelegate = viewModel
        listingListView.switchViewModel(viewModel.listViewModel)
        let show3Columns = DeviceFamily.current.isWiderOrEqualThan(.iPhone6Plus)
        if show3Columns {
            listingListView.updateLayoutWithSeparation(6)
        }
        
        NSLayoutConstraint.activate([
            listingListView.leadingAnchor.constraint(equalTo: safeLeadingAnchor),
            listingListView.topAnchor.constraint(equalTo: isSafeAreaAvailable ? safeTopAnchor : view.topAnchor),
            listingListView.trailingAnchor.constraint(equalTo: safeTrailingAnchor),
            listingListView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        view.sendSubview(toBack: listingListView)
    }
    
    private func setupInfoBubble() {
        
        let infoBubbleTopConstraint = infoBubbleView.topAnchor.constraint(equalTo: filterTitleHeaderView.bottomAnchor)
        let infoBubbleLeadingConstraint = infoBubbleView.leadingAnchor.constraint(greaterThanOrEqualTo: safeLeadingAnchor, constant: Metrics.bigMargin)
        let infoBubbleTrailingConstraint = infoBubbleView.trailingAnchor.constraint(greaterThanOrEqualTo: safeTrailingAnchor, constant: Metrics.bigMargin)
        infoBubbleTopConstraint.priority = UILayoutPriority.defaultLow
        infoBubbleTrailingConstraint.priority = UILayoutPriority.defaultLow
        
        NSLayoutConstraint.activate([
            infoBubbleTopConstraint,
            infoBubbleView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            infoBubbleView.heightAnchor.constraint(equalToConstant: InfoBubbleView.bubbleHeight),
            infoBubbleLeadingConstraint,
            infoBubbleTrailingConstraint
            ])
        self.infoBubbleTopConstraint = infoBubbleTopConstraint
        
        let bubbleTap = UITapGestureRecognizer(target: self, action: #selector(onBubbleTapped))
        infoBubbleView.addGestureRecognizer(bubbleTap)
    }
    
    private func setupRecentItemsBubbleView() {
        view.addSubviewForAutoLayout(recentItemsBubbleView)
        // trendingSearchesView should be up front of every view, as it is added the latest in addSubviews method
        view.bringSubview(toFront: trendingSearchView)
        
        let recentItemsBubbleViewTopConstraint = recentItemsBubbleView.topAnchor.constraint(equalTo: infoBubbleView.bottomAnchor, constant: Metrics.shortMargin)
        let recentItemsBubbleViewTrailingConstraint = recentItemsBubbleView.trailingAnchor.constraint(greaterThanOrEqualTo: safeTrailingAnchor, constant: Metrics.bigMargin)
        recentItemsBubbleViewTopConstraint.priority = UILayoutPriority.defaultLow
        recentItemsBubbleViewTrailingConstraint.priority = UILayoutPriority.defaultLow
        
        NSLayoutConstraint.activate([
            recentItemsBubbleViewTopConstraint,
            recentItemsBubbleView.centerXAnchor.constraint(equalTo: view.centerXAnchor,
                                                           constant: 0),
            recentItemsBubbleView.heightAnchor.constraint(equalToConstant: InfoBubbleView.bubbleHeight),
            recentItemsBubbleView.leadingAnchor.constraint(greaterThanOrEqualTo: safeLeadingAnchor,
                                                           constant: Metrics.bigMargin),
            recentItemsBubbleViewTrailingConstraint
            ])

        let bubbleTap = UITapGestureRecognizer(target: self, action: #selector(onRecentItemsBubbleTapped))
        recentItemsBubbleView.addGestureRecognizer(bubbleTap)
    }

    @objc private func onBubbleTapped() {
        viewModel.bubbleTapped()
    }
    
    @objc private func onRecentItemsBubbleTapped() {
        viewModel.recentItemsBubbleTapped()
        scrollToTop()
    }

    private func setupSearchAndTrending() {
        navbarSearch.searchTextField.delegate = self
        setNavBarTitleStyle(.custom(navbarSearch))
        setupSuggestionsTable()
        addKeyboardObservers()
    }

    private func setupRxBindings() {
        
        viewModel.infoBubbleText.asObservable()
            .bind { [weak self] _ in
                self?.infoBubbleView.invalidateIntrinsicContentSize()
            }.disposed(by: disposeBag)
        
        viewModel.infoBubbleText.asObservable()
            .bind(to: infoBubbleView.title.rx.text)
            .disposed(by: disposeBag)
        viewModel.infoBubbleVisible.asObservable().map { !$0 }
            .bind(to: infoBubbleView.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.recentItemsBubbleText.asObservable()
            .bind(to: recentItemsBubbleView.title.rx.text)
            .disposed(by: disposeBag)
        viewModel.recentItemsBubbleVisible.asObservable().map { !$0 }
            .bind(to: recentItemsBubbleView.rx.isHidden)
            .disposed(by: disposeBag)

        topInset.asObservable()
            .bind { [weak self] topInset in
                self?.listingListView.collectionViewContentInset.top = topInset
            }.disposed(by: disposeBag)

        viewModel.mainListingsHeader.asObservable().bind { [weak self] header in
            self?.listingListView.refreshDataView()
        }.disposed(by: disposeBag)

        viewModel.errorMessage.asObservable().bind { [weak self] errorMessage in
            if let toastTitle = errorMessage {
                self?.toastView?.title = toastTitle
                self?.setToastViewHidden(false)
            } else {
                self?.setToastViewHidden(true)
            }
        }.disposed(by: disposeBag)

        viewModel.filterTitle.asObservable().distinctUntilChanged { (s1, s2) -> Bool in
            s1 == s2
        }.bind { [weak self] filterTitle in
            guard let strongSelf = self else { return }
            strongSelf.filterTitleHeaderView.text = filterTitle
            self?.updateTopInset()
        }.disposed(by: disposeBag)

        viewModel.filterDescription.asObservable().bind { [weak self] filterDescr in
            guard let strongSelf = self else { return }
            strongSelf.filterDescriptionHeaderView.text = filterDescr
            self?.updateTopInset()
        }.disposed(by: disposeBag)
        
        navbarSearch.searchTextField.rx.text.asObservable()
            .subscribeNext { [weak self] text in
                self?.navBarSearchTextFieldDidUpdate(text: text ?? "")
        }.disposed(by: disposeBag)
        
        navbarSearch.searchTextField.rx.text.asObservable().bind(to: viewModel.searchText).disposed(by: disposeBag)
    }

    private func updateTopInset() {
        let tagsHeight = primaryTagsShowing ? filterTagsViewHeight : 0
        if isSafeAreaAvailable {
            topInset.value = tagsHeight + filterHeadersHeight
        } else {
            topInset.value = topBarHeight + tagsHeight + filterHeadersHeight
        }
    }
    
    func navBarSearchTextFieldDidUpdate(text: String) {
        viewModel.searchTextFieldDidUpdate(text: text)
    }
    
    private struct Layout {
        struct ToolTipMap  {
            static let left: CGFloat = 50
            static let right: CGFloat = -60
            static let buttonHeight: CGFloat = 32
            static let buttonSidePadding: CGFloat = 20
        }
    }
}


// MARK: - ListingListViewHeaderDelegate

extension MainListingsViewController: ListingListViewHeaderDelegate, PushPermissionsHeaderDelegate, SearchAlertFeedHeaderDelegate {

    func totalHeaderHeight() -> CGFloat {
        var totalHeight: CGFloat = 0
        if shouldShowPermissionsBanner {
            totalHeight = PushPermissionsHeader.viewHeight
        }
        if shouldShowCategoryCollectionBanner {
            totalHeight += CategoriesHeaderCollectionView.viewHeight
        }
        if shouldShowSearchAlertBanner {
            totalHeight += SearchAlertFeedHeader.viewHeight
        }
        if viewModel.shouldShowCommunityBanner {
            totalHeight += CommunityHeaderView.viewHeight
        }

        return totalHeight
    }

    func setupViewsIn(header: ListHeaderContainer) {
        header.clear()
        if shouldShowPermissionsBanner {
            let pushHeader = PushPermissionsHeader()
            pushHeader.tag = 0
            pushHeader.delegate = self
            header.addHeader(pushHeader, height: PushPermissionsHeader.viewHeight)
        }
       
        if shouldShowCategoryCollectionBanner {
            categoriesHeader = CategoriesHeaderCollectionView()
            categoriesHeader?.configure(with: viewModel.categoryHeaderElements,
                                        categoryHighlighted: viewModel.categoryHeaderHighlighted)
            categoriesHeader?.delegateCategoryHeader = viewModel
            categoriesHeader?.categorySelected.asObservable().bind { [weak self] categoryHeaderInfo in
                guard let category = categoryHeaderInfo else { return }
                self?.categoryHeaderDidSelect(category: category)
                
            }.disposed(by: disposeBag)
            if let categoriesHeader = categoriesHeader {
                categoriesHeader.tag = 1
                header.addHeader(categoriesHeader, height: CategoriesHeaderCollectionView.viewHeight)
            }
        }
        
        if shouldShowSearchAlertBanner, let searchAlertCreationData = viewModel.currentSearchAlertCreationData.value {
            let searchAlertHeader = SearchAlertFeedHeader(searchAlertCreationData: searchAlertCreationData)
            searchAlertHeader.tag = 3
            searchAlertHeader.delegate = self
            header.addHeader(searchAlertHeader, height: SearchAlertFeedHeader.viewHeight)
        }

        if viewModel.shouldShowCommunityBanner {
            let community = CommunityHeaderView()
            community.delegate = self
            community.tag = 4
            header.addHeader(community, height: CommunityHeaderView.viewHeight)
        }
    }

    private var shouldShowPermissionsBanner: Bool {
        return viewModel.mainListingsHeader.value.contains(MainListingsHeader.PushPermissions)
    }
    
    private var shouldShowCategoryCollectionBanner: Bool {
        return viewModel.mainListingsHeader.value.contains(MainListingsHeader.CategoriesCollectionBanner)
    }

    private var shouldShowSearchAlertBanner: Bool {
        return viewModel.mainListingsHeader.value.contains(MainListingsHeader.SearchAlerts)
    }
    
    private func categoryHeaderDidSelect(category: CategoryHeaderInfo) {
        viewModel.updateFiltersFromHeaderCategories(category)
    }

    func pushPermissionHeaderPressed() {
        viewModel.pushPermissionsHeaderPressed()
    }

    func searchTextFieldReadyToSearch() {
        navbarSearch.searchTextField.becomeFirstResponder()
    }

    func searchAlertFeedHeaderDidEnableSearchAlert(fromEnabled: Bool) {
        viewModel.triggerCurrentSearchAlert(fromEnabled: fromEnabled)
    }
}


// MARK: - Trending searches

extension MainListingsViewController {
    
    func setupSuggestionsTable() {
        trendingSearchView.delegate = self
        trendingSearchView.isHidden = true
        
        trendingSearchView.layout(with: view).fillHorizontal().bottom()

        view.addConstraint(NSLayoutConstraint(item: trendingSearchView,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: topLayoutGuide,
                                              attribute: .bottom,
                                              multiplier: 1.0,
                                              constant: 0))
        
        Observable.combineLatest(viewModel.trendingSearches.asObservable(),
                                 viewModel.suggestiveSearchInfo.asObservable(),
                                 viewModel.lastSearches.asObservable()) { trendings, suggestiveSearches, lastSearches in
            return trendings.count + suggestiveSearches.count + lastSearches.count
            }.bind { [weak self] totalCount in
                self?.trendingSearchView.reloadTrendingSearchTableView()
                self?.trendingSearchView.updateTrendingSearchTableView(hidden: totalCount == 0)
        }.disposed(by: disposeBag)
        
    }
    
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                               name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                               name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        trendingSearchView.updateBottomTableView(contentInset: notification.keyboardChange.height)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        trendingSearchView.updateBottomTableView(contentInset: 0)
    }

}

extension MainListingsViewController: TrendingSearchViewDelegate {
    
    func trendingSearchBackgroundTapped(_ view: TrendingSearchView) {
        endEdit()
    }
    
    func trendingSearchCleanButtonPressed(_ view: TrendingSearchView) {
        viewModel.cleanUpLastSearches()
    }

    func trendingSearch(_ view: TrendingSearchView, numberOfRowsIn section: Int) -> Int {
        guard let sectionType = SearchSuggestionType.sectionType(index: section) else { return 0 }
        return viewModel.numberOfItems(type: sectionType)
    }
    
    func trendingSearch(_ view: TrendingSearchView, cellSelectedAt indexPath: IndexPath) {
        navbarSearch.searchTextField.endEditing(true)
        guard let sectionType = SearchSuggestionType.sectionType(index: indexPath.section) else { return }
        viewModel.selected(type: sectionType, row: indexPath.row)
    }
    
    func trendingSearch(_ view: TrendingSearchView, cellContentAt  indexPath: IndexPath) -> SuggestionSearchCellContent? {
        guard let sectionType = SearchSuggestionType.sectionType(index: indexPath.section) else { return nil }
        switch sectionType {
        case .suggestive:
            guard let (suggestiveSearch, sourceText) = viewModel.suggestiveSearchAtIndex(indexPath.row) else { return nil }
            return SuggestionSearchCellContent(title: suggestiveSearch.title,
                                               titleSkipHighlight: sourceText,
                                               subtitle: suggestiveSearch.subtitle,
                                               icon: suggestiveSearch.icon) { [weak self] in
                self?.updadeSearchTextfield(suggestiveSearch.title)
            }
        case .lastSearch:
            guard let lastSearch = viewModel.lastSearchAtIndex(indexPath.row) else { return nil }
            return SuggestionSearchCellContent(title: lastSearch.title, subtitle: lastSearch.subtitle, icon: lastSearch.icon)
        case .trending:
            guard let trendingSearch = viewModel.trendingSearchAtIndex(indexPath.row) else { return nil }
            return SuggestionSearchCellContent(title: trendingSearch)
        }
    }
    
    private func updadeSearchTextfield(_ text: String) {
        viewModel.searchText.value = text
        navbarSearch.searchTextField.text = text
        navBarSearchTextFieldDidUpdate(text: text)
    }
}

extension MainListingsViewController: CommunityHeaderViewDelegate {
    func didTapCommunityHeader() {
        viewModel.vmUserDidTapCommunity()
    }
}

extension MainListingsViewController {
    func setAccessibilityIds() {
        navigationItem.rightBarButtonItem?.set(accessibilityId: .mainListingsFilterButton)
        listingListView.set(accessibilityId: .mainListingsListView)
        tagsContainerView.set(accessibilityId: .mainListingsTagsCollection)
        navbarSearch.set(accessibilityId: .mainListingsNavBarSearch)
        navigationItem.leftBarButtonItem?.set(accessibilityId: .mainListingsInviteButton)
    }
}
