//
//  ProductsViewController.swift
//  letgo
//
//  Created by AHL on 3/5/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import CoreLocation
import LGCoreKit
import UIKit
import CHTCollectionViewWaterfallLayout
import RxSwift

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
    
    let listingListView = ListingListView()
    
    @IBOutlet weak var tagsContainerView: UIView!
    @IBOutlet weak var tagsContainerViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var filterDescriptionHeaderViewContainer: UIView!
    @IBOutlet weak var filterTitleHeaderViewContainer: UIView!
    fileprivate let filterDescriptionHeaderView = FilterDescriptionHeaderView()
    fileprivate let filterTitleHeaderView = FilterTitleHeaderView()
    @IBOutlet weak var filterDescriptionTopConstraint: NSLayoutConstraint!

    fileprivate let infoBubbleTopMargin: CGFloat = 8
    fileprivate let sectionHeight: CGFloat = 40
    fileprivate let firstSectionMarginTop: CGFloat = -36

    @IBOutlet weak var infoBubbleLabel: UILabel!
    @IBOutlet weak var infoBubbleShadow: UIView!
    @IBOutlet weak var infoBubbleArrow: UIImageView!
    @IBOutlet weak var infoBubbleArrowLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var infoBubbleArrowWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var infoBubbleTopConstraint: NSLayoutConstraint!
    
    fileprivate let navbarSearch: LGNavBarSearchField
    @IBOutlet weak var suggestionsSearchesContainer: UIVisualEffectView!
    @IBOutlet weak var suggestionsSearchesTable: UITableView!
    
    private var filterTagsView: FilterTagsView?
    private var primaryTagsShowing: Bool = false
    private var secondaryTagsShowing: Bool = false

    private let topInset = Variable<CGFloat>(0)

    fileprivate let disposeBag = DisposeBag()
    
    fileprivate var categoriesHeader: CategoriesHeaderCollectionView?

    fileprivate var filterTagsViewHeight: CGFloat {
        if viewModel.secondaryTags.isEmpty || viewModel.filters.selectedTaxonomyChildren.count > 0 {
            return FilterTagsView.collectionViewHeight
        } else {
            return FilterTagsView.collectionViewHeight * 2
        }
    }
    fileprivate var filterHeadersHeight: CGFloat {
        return filterDescriptionHeaderView.height + filterTitleHeaderView.height
    }
    fileprivate var topHeadersHeight: CGFloat {
        return filterHeadersHeight + tagsContainerView.height
    }
    fileprivate var collectionViewHeadersHeight: CGFloat {
        return listingListView.headerDelegate?.totalHeaderHeight() ?? 0
    }
    
    // MARK: - Lifecycle

    convenience init(viewModel: MainListingsViewModel) {
        self.init(viewModel: viewModel, nibName: "MainListingsViewController")
    }
    
    required init(viewModel: MainListingsViewModel, nibName nibNameOrNil: String?) {
        navbarSearch = LGNavBarSearchField(viewModel.searchString)
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nibNameOrNil)
        viewModel.delegate = self
        viewModel.adsDelegate = self
        hidesBottomBarWhenPushed = false
        floatingSellButtonHidden = false
        hasTabBar = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFilterHeaders()
        
        listingListView.collectionViewContentInset.bottom = tabBarHeight
            + LGUIKitConstants.tabBarSellFloatingButtonHeight
            + LGUIKitConstants.tabBarSellFloatingButtonDistance
        if let image =  UIImage(named: "pattern_white") {
            listingListView.setErrorViewStyle(bgColor: UIColor(patternImage: image), borderColor: UIColor.lineGray,
                                              containerColor: UIColor.white)
        }
        listingListView.scrollDelegate = self
        listingListView.headerDelegate = self
        listingListView.cellsDelegate = viewModel
        listingListView.switchViewModel(viewModel.listViewModel)
        let show3Columns = DeviceFamily.current.isWiderOrEqualThan(.iPhone6Plus)
        if show3Columns {
            listingListView.updateLayoutWithSeparation(6)
        }

        addSubview(listingListView)
        view.addSubviewForAutoLayout(listingListView)
        NSLayoutConstraint.activate([
            listingListView.leadingAnchor.constraint(equalTo: safeLeadingAnchor),
            listingListView.topAnchor.constraint(equalTo: safeTopAnchor),
            listingListView.trailingAnchor.constraint(equalTo: safeTrailingAnchor),
            listingListView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        view.sendSubview(toBack: listingListView)

        automaticallyAdjustsScrollViewInsets = false
        //Add negative top inset to avoid extra padding adding by "grouped" table style.
        suggestionsSearchesTable.contentInset = UIEdgeInsetsMake(firstSectionMarginTop, 0, 0, 0)
        setupInfoBubble()
        setupTagsView()
        setupSearchAndTrending()
        setFiltersNavBarButton()
        setInviteNavBarButton()
        setupRxBindings()
        setAccessibilityIds()
        
        if #available(iOS 11.0, *) {
            listingListView.collectionView.contentInsetAdjustmentBehavior = .never
        }
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
            if let tagsVC = self.filterTagsView, !tagsVC.tags.isEmpty {
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
            filterDescriptionTopConstraint.constant = 0
            return
        }
        
        let filterHeadersOffset = topInset.value + contentOffsetY
        if filterHeadersOffset <= filterDescriptionHeaderView.height {
            // move upwards until description header is completely below
            filterDescriptionTopConstraint.constant = -filterHeadersOffset
            filterDescriptionHeaderView.alpha = 1
        } else {
            // description header is completely below and also hidden
            filterDescriptionTopConstraint.constant = -filterDescriptionHeaderView.height
            filterDescriptionHeaderView.alpha = 0.1
        }
    }

    private func updateBubbleTopConstraint() {
        let offset: CGFloat = topInset.value
        let delta = listingListView.headerBottom - offset
        if delta > 0 {
            infoBubbleTopConstraint.constant = infoBubbleTopMargin + delta
        } else {
            infoBubbleTopConstraint.constant = infoBubbleTopMargin
        }
    }
    
    
    // MARK: - MainListingsViewModelDelegate

    func vmDidSearch() {
        suggestionsSearchesContainer.isHidden = true
    }

    func vmShowTags(primaryTags: [FilterTag], secondaryTags: [FilterTag]) {
        loadTagsViewWithTags(primaryTags: primaryTags, secondaryTags: secondaryTags)
    }

    func vmFiltersChanged() {
        setFiltersNavBarButton()
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
    
    
    // MARK: - FilterHeaders
    
    private func setupFilterHeaders() {
        filterDescriptionHeaderView.translatesAutoresizingMaskIntoConstraints = false
        filterDescriptionHeaderViewContainer.addSubview(filterDescriptionHeaderView)
        filterDescriptionHeaderView.layout(with: filterDescriptionHeaderViewContainer).fill()
        
        filterTitleHeaderView.translatesAutoresizingMaskIntoConstraints = false
        filterTitleHeaderViewContainer.addSubview(filterTitleHeaderView)
        filterTitleHeaderView.layout(with: filterTitleHeaderViewContainer).fill()
    }
    
    func setFilterHeaderTitle(withText text: String) {
        filterTitleHeaderView.text = text
    }
    
    func setFilterHeaderDescription(withText text: String) {
        filterDescriptionHeaderView.text = text
    }
    
    
    // MARK: - FilterTagsViewDelegate
    
    func filterTagsViewDidRemoveTag(_ tag: FilterTag, remainingTags: [FilterTag]) {
        viewModel.updateFiltersFromTags(remainingTags, removedTag: tag)
        loadTagsViewWithTags(primaryTags: viewModel.primaryTags, secondaryTags: viewModel.secondaryTags)
    }
    
    func filterTagsViewDidSelectTag(_ tag: FilterTag) {
        if let taxonomyChild = tag.taxonomyChild {
            viewModel.updateSelectedTaxonomyChildren(taxonomyChildren: [taxonomyChild])
        }
        loadTagsViewWithTags(primaryTags: viewModel.primaryTags, secondaryTags: viewModel.secondaryTags)
    }
    
    
    // MARK: - Private methods

    private func setBars(hidden: Bool, animated: Bool = true) {
        self.tabBarController?.setTabBarHidden(hidden, animated: animated)
        self.navigationController?.setNavigationBarHidden(hidden, animated: animated)
    }

    @objc fileprivate func endEdit() {
        // ☢️☢️ Changing tabs when constructing the app from a push notifications calls didDissappear before didLoad
        if let searchContainer = suggestionsSearchesContainer {
            searchContainer.isHidden = true
        }
        setFiltersNavBarButton()
        setInviteNavBarButton()
        navbarSearch.endEdit()
    }

    private func beginEdit() {
        guard suggestionsSearchesContainer.isHidden else { return }

        viewModel.searchBegan()
        let spacing = makeSpacingButton(withFixedWidth: Metrics.navBarDefaultSpacing)
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel , target: self,
                                     action: #selector(endEdit))
        navigationItem.setRightBarButtonItems([cancel, spacing], animated: false)
        suggestionsSearchesContainer.isHidden = false
        viewModel.retrieveLastUserSearch()
        navbarSearch.beginEdit()
    }
    
    /**
        Called when the search button is pressed.
    */
    @objc private func filtersButtonPressed(_ sender: AnyObject) {
        navbarSearch.searchTextField.resignFirstResponder()
        viewModel.showFilters()
    }
    
    private func setupTagsView() {
        view.addConstraint(NSLayoutConstraint(item: tagsContainerView, attribute: .top, relatedBy: .equal, toItem: topLayoutGuide, attribute: .bottom, multiplier: 1.0, constant: 0))

        filterTagsView = FilterTagsView()
        filterTagsView?.delegate = self
        tagsContainerView.backgroundColor = .grayBackground
        tagsContainerView.addSubview(filterTagsView!)
        tagsContainerView.isHidden = true
        tagsContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        filterTagsView?.layout(with: tagsContainerView).fill()
        
        loadTagsViewWithTags(primaryTags: viewModel.primaryTags, secondaryTags: viewModel.secondaryTags)
    }
    
    private func loadTagsViewWithTags(primaryTags: [FilterTag], secondaryTags: [FilterTag]) {
        filterTagsView?.updateTags(primaryTags)
        filterTagsView?.updateSecondaryTags(secondaryTags)
        let showPrimaryTags = primaryTags.count > 0
        let showSecondaryTags = secondaryTags.count > 0
        showTagsView(showPrimaryTags: showPrimaryTags, showSecondaryTags: showSecondaryTags, updateInsets: true)
        
        //Update tags button
        setFiltersNavBarButton()
    }
    
    private func setFiltersNavBarButton() {
        setLetGoRightButtonWith(imageName: viewModel.hasFilters ? "ic_filters_active" : "ic_filters",
                                renderingMode: .alwaysOriginal, selector: "filtersButtonPressed:")
    }
    
    private func setInviteNavBarButton() {
        guard isRootViewController() else { return }
        guard viewModel.shouldShowInviteButton  else { return }

        let invite = UIBarButtonItem(title: LGLocalizedString.mainProductsInviteNavigationBarButton,
                                     style: .plain,
                                     target: self,
                                     action: #selector(openInvite))
        let spacing = makeSpacingButton(withFixedWidth: Metrics.navBarDefaultSpacing)

        navigationItem.setLeftBarButtonItems([invite, spacing], animated: false)
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

        tagsContainerViewHeightConstraint.constant = showPrimaryTags ? filterTagsViewHeight : 0
        if updateInsets {
            updateTopInset()
        }
        view.layoutIfNeeded()
        
        tagsContainerView.isHidden = !showPrimaryTags
    }
    
    private func setupInfoBubble() {
        infoBubbleShadow.applyInfoBubbleShadow()

        infoBubbleArrowLeadingConstraint.constant = Metrics.shortMargin
        infoBubbleArrowWidthConstraint.constant = Metrics.shortMargin

        let bubbleTap = UITapGestureRecognizer(target: self, action: #selector(onBubbleTapped))
        infoBubbleShadow.addGestureRecognizer(bubbleTap)

    }

    @objc private func onBubbleTapped() {
        viewModel.bubbleTapped()
    }

    private func setupSearchAndTrending() {
        navbarSearch.searchTextField.delegate = self
        setNavBarTitleStyle(.custom(navbarSearch))
        setupSuggestionsTable()
    }

    private func setupRxBindings() {
        viewModel.infoBubbleText.asObservable().bind(to: infoBubbleLabel.rx.text).disposed(by: disposeBag)
        viewModel.infoBubbleVisible.asObservable().map { !$0 }.bind(to: infoBubbleShadow.rx.isHidden).disposed(by: disposeBag)

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

    fileprivate func updateTopInset() {
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
}


// MARK: - ListingListViewHeaderDelegate

extension MainListingsViewController: ListingListViewHeaderDelegate, PushPermissionsHeaderDelegate, RealEstateBannerDelegate {

    func totalHeaderHeight() -> CGFloat {
        var totalHeight: CGFloat = 0
        if shouldShowPermissionsBanner {
            totalHeight = PushPermissionsHeader.viewHeight
        }
        if shouldShowCategoryCollectionBanner {
            totalHeight += CategoriesHeaderCollectionView.viewHeight
        }
        if shouldShowRealEstateBanner {
            totalHeight += RealEstateBanner().intrinsicContentSize.height
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
            let screenWidth: CGFloat = UIScreen.main.bounds.size.width
            categoriesHeader = CategoriesHeaderCollectionView(categories: viewModel.categoryHeaderElements,
                                                              frame: CGRect(x: 0, y: 0, width: screenWidth, height: CategoriesHeaderCollectionView.viewHeight),
                                                              categoryHighlighted: viewModel.categoryHeaderHighlighted,
                                                              isMostSearchedItemsEnabled: viewModel.isMostSearchedItemsEnabled)
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
        
        if shouldShowRealEstateBanner {
            let realEstateBanner = RealEstateBanner()
            realEstateBanner.tag = 2
            let height = realEstateBanner.intrinsicContentSize.height
            realEstateBanner.delegate = self
            header.addHeader(realEstateBanner, height: height)
        }
    }

    private var shouldShowPermissionsBanner: Bool {
        return viewModel.mainListingsHeader.value.contains(MainListingsHeader.PushPermissions)
    }
    
    private var shouldShowCategoryCollectionBanner: Bool {
        return viewModel.mainListingsHeader.value.contains(MainListingsHeader.CategoriesCollectionBanner)
    }
    private var shouldShowRealEstateBanner: Bool {
        return viewModel.mainListingsHeader.value.contains(MainListingsHeader.RealEstateBanner)
    }
    
    private func categoryHeaderDidSelect(category: CategoryHeaderInfo) {
        viewModel.updateFiltersFromHeaderCategories(category)
        if category.categoryHeaderElement.isRealEstate {
            viewModel.showRealEstateTutorial()
        }
    }

    func pushPermissionHeaderPressed() {
        viewModel.pushPermissionsHeaderPressed()
    }
    
    func realEstateBannerPressed() {
        viewModel.navigator?.openSell(source: .realEstatePromo, postCategory: .realEstate)
    }
}


// MARK: - Trending searches

extension MainListingsViewController: UITableViewDelegate, UITableViewDataSource {

    func setupSuggestionsTable() {
        suggestionsSearchesTable.register(SuggestionSearchCell.self,
                                          forCellReuseIdentifier: SuggestionSearchCell.reusableID)
        suggestionsSearchesTable.rowHeight = UITableViewAutomaticDimension
        suggestionsSearchesTable.estimatedRowHeight = SuggestionSearchCell.estimatedHeight
        suggestionsSearchesTable.backgroundColor = UIColor.white

        let topConstraint = NSLayoutConstraint(item: suggestionsSearchesContainer, attribute: .top, relatedBy: .equal,
                                               toItem: topLayoutGuide, attribute: .bottom, multiplier: 1.0, constant: 0)
        view.addConstraint(topConstraint)
        
        Observable.combineLatest(viewModel.trendingSearches.asObservable(),
                                 viewModel.suggestiveSearchInfo.asObservable(),
                                 viewModel.lastSearches.asObservable()) { trendings, suggestiveSearches, lastSearches in
            return trendings.count + suggestiveSearches.count + lastSearches.count
            }.bind { [weak self] totalCount in
                self?.suggestionsSearchesTable.reloadData()
                self?.suggestionsSearchesTable.isHidden = totalCount == 0
        }.disposed(by: disposeBag)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                                         name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                                         name: NSNotification.Name.UIKeyboardWillHide, object: nil)

    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let sectionType = SearchSuggestionType.sectionType(index: section) else { return 0 }
        switch sectionType {
        case .suggestive:
            return viewModel.suggestiveCounter > 0 ? sectionHeight : 0
        case .lastSearch:
            return viewModel.lastSearchesCounter > 0 ? sectionHeight : 0
        case .trending:
            return viewModel.trendingCounter > 0 ? sectionHeight : 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: sectionHeight))
        container.clipsToBounds = true
        container.backgroundColor = UIColor.white
        let suggestionTitleLabel = UILabel()
        suggestionTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        suggestionTitleLabel.textAlignment = .left
        suggestionTitleLabel.font = UIFont.sectionTitleFont
        suggestionTitleLabel.textColor = UIColor.darkGrayText
        container.addSubview(suggestionTitleLabel)

        let clearButton = UIButton()
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.titleLabel?.textAlignment = .right
        clearButton.titleLabel?.font = UIFont.sectionTitleFont
        clearButton.setTitleColor(UIColor.darkGrayText, for: .normal)
        clearButton.setTitle(LGLocalizedString.suggestionsLastSearchesClearButton.localizedUppercase, for: .normal)
        clearButton.addTarget(self, action: #selector(cleanSearchesButtonPressed), for: .touchUpInside)
        container.addSubview(clearButton)
        
        var views = [String: Any]()
        views["label"] = suggestionTitleLabel
        views["clear"] = clearButton
        var metrics = [String: Any]()
        metrics["horizontalMarginHeaderView"] = Metrics.margin
        container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[label]-5-|",
            options: [], metrics: metrics, views: views))
        container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-horizontalMarginHeaderView-[label]",
            options: [], metrics: metrics, views: views))
        container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[clear]-5-|",
            options: [], metrics: metrics, views: views))
        container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[clear]-horizontalMarginHeaderView-|",
            options: [], metrics: metrics, views: views))
        
        guard let sectionType = SearchSuggestionType.sectionType(index: section) else { return UIView() }
        switch sectionType {
        case .suggestive:
            clearButton.isHidden = true
            suggestionTitleLabel.text = LGLocalizedString.suggestedSearchesTitle.localizedUppercase
        case .lastSearch:
            clearButton.isHidden = false
            suggestionTitleLabel.text = LGLocalizedString.suggestionsLastSearchesTitle.localizedUppercase
        case .trending:
            clearButton.isHidden = true
            suggestionTitleLabel.text = LGLocalizedString.trendingSearchesTitle.localizedUppercase
        }
        return container
    }
    
    @objc private func cleanSearchesButtonPressed() {
        viewModel.cleanUpLastSearches()
    }
    
    @IBAction func trendingSearchesBckgPressed(_ sender: AnyObject) {
        endEdit()
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        suggestionsSearchesTable.contentInset.bottom = notification.keyboardChange.height
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        suggestionsSearchesTable.contentInset.bottom = 0
    }


    // MARK: > TableView

    func numberOfSections(in tableView: UITableView) -> Int {
        return SearchSuggestionType.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = SearchSuggestionType.sectionType(index: section) else { return 0 }
        switch sectionType {
        case .suggestive:
            return viewModel.suggestiveCounter
        case .lastSearch:
            return viewModel.lastSearchesCounter
        case .trending:
            return viewModel.trendingCounter
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sectionType = SearchSuggestionType.sectionType(index: indexPath.section),
              let cell = tableView.dequeueReusableCell(withIdentifier: SuggestionSearchCell.reusableID,
                                                 for: indexPath) as? SuggestionSearchCell else {
                                                    return UITableViewCell()
        }
        let title: String
        let titleSkipHighlight: String?
        let subtitle: String?
        let icon: UIImage?
        let fillSearchButtonBlock: (() -> ())?
        switch sectionType {
        case .suggestive:
            guard let (suggestiveSearch, sourceText) = viewModel.suggestiveSearchAtIndex(indexPath.row) else {
                return UITableViewCell()
            }
            title = suggestiveSearch.title
            titleSkipHighlight = sourceText
            subtitle = suggestiveSearch.subtitle
            icon = suggestiveSearch.icon
            fillSearchButtonBlock = { [weak self] in
                self?.navbarSearch.searchTextField.text = title
                self?.viewModel.searchText.value = title
                self?.navBarSearchTextFieldDidUpdate(text: title)
            }
        case .lastSearch:
            guard let lastSearch = viewModel.lastSearchAtIndex(indexPath.row) else { return UITableViewCell() }
            title = lastSearch.title
            titleSkipHighlight = nil
            subtitle = lastSearch.subtitle
            icon = lastSearch.icon
            fillSearchButtonBlock = nil
        case .trending:
            guard let trendingSearch = viewModel.trendingSearchAtIndex(indexPath.row) else { return UITableViewCell() }
            title = trendingSearch
            titleSkipHighlight = nil
            subtitle = nil
            icon = nil
            fillSearchButtonBlock = nil
        }
        cell.set(title: title,
                 titleSkipHighlight: titleSkipHighlight,
                 subtitle: subtitle,
                 icon: icon)
        cell.fillSearchButtonBlock = fillSearchButtonBlock
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navbarSearch.searchTextField.endEditing(true)
        guard let sectionType = SearchSuggestionType.sectionType(index: indexPath.section) else { return }
        switch sectionType {
        case .suggestive:
            viewModel.selectedSuggestiveSearchAtIndex(indexPath.row)
        case .lastSearch:
            viewModel.selectedLastSearchAtIndex(indexPath.row)
        case .trending:
            viewModel.selectedTrendingSearchAtIndex(indexPath.row)
        }
    }
}


extension MainListingsViewController {
    func setAccessibilityIds() {
        navigationItem.rightBarButtonItem?.set(accessibilityId: .mainListingsFilterButton)
        listingListView.set(accessibilityId: .mainListingsListView)
        tagsContainerView.set(accessibilityId: .mainListingsTagsCollection)
        infoBubbleLabel.set(accessibilityId: .mainListingsInfoBubbleLabel)
        navbarSearch.set(accessibilityId: .mainListingsNavBarSearch)
        suggestionsSearchesTable.set(accessibilityId: .mainListingsSuggestionSearchesTable)
        navigationItem.leftBarButtonItem?.set(accessibilityId: .mainListingsInviteButton)
    }
}
