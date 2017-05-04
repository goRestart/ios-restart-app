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
    case lastSearch
    case trending
}

class MainProductsViewController: BaseViewController, ProductListViewScrollDelegate, MainProductsViewModelDelegate,
    FilterTagsViewControllerDelegate, UITextFieldDelegate, ScrollableToTop {
    
    // ViewModel
    var viewModel: MainProductsViewModel
    
    // UI
    @IBOutlet weak var productListView: ProductListView!
    
    @IBOutlet weak var tagsCollectionView: UICollectionView!
    var tagsCollectionTopSpace: NSLayoutConstraint?

    fileprivate let infoBubbleTopMargin: CGFloat = 8
    fileprivate let verticalMarginHeaderView: CGFloat = 16
    fileprivate let horizontalMarginHeaderView: CGFloat = 16
    fileprivate let sectionHeight: CGFloat = 54
    fileprivate let firstSectionMarginTop: CGFloat = -36
    fileprivate let numberOfSuggestionSections = 2
    fileprivate let heightFiltersTagView: CGFloat = 40
    @IBOutlet weak var infoBubbleLabel: UILabel!
    @IBOutlet weak var infoBubbleShadow: UIView!
    @IBOutlet weak var infoBubbleTopConstraint: NSLayoutConstraint!
    
    fileprivate let navbarSearch: LGNavBarSearchField
    @IBOutlet weak var suggestionsSearchesContainer: UIVisualEffectView!
    @IBOutlet weak var suggestionsSearchesTable: UITableView!
    
    private var tagsViewController : FilterTagsViewController?
    private var tagsShowing : Bool = false
    private var tagsAnimating : Bool = false

    private let topInset = Variable<CGFloat> (0)

    fileprivate let disposeBag = DisposeBag()
    
    fileprivate var categoriesHeader: CategoriesHeaderCollectionView?

    
    // MARK: - Lifecycle

    convenience init(viewModel: MainProductsViewModel) {
        self.init(viewModel: viewModel, nibName: "MainProductsViewController")
    }
    
    required init(viewModel: MainProductsViewModel, nibName nibNameOrNil: String?) {
        self.navbarSearch = LGNavBarSearchField.setupNavBarSearchFieldWithText(viewModel.searchString)
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nibNameOrNil)
        viewModel.delegate = self
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
        topInset.value = topBarHeight
        productListView.collectionViewContentInset.bottom = tabBarHeight
            + LGUIKitConstants.tabBarSellFloatingButtonHeight
            + LGUIKitConstants.tabBarSellFloatingButtonDistance
        if let image =  UIImage(named: "pattern_white") {
            productListView.setErrorViewStyle(bgColor: UIColor(patternImage: image), borderColor: UIColor.lineGray,
                                              containerColor: UIColor.white)
        }
        productListView.scrollDelegate = self
        productListView.headerDelegate = self
        productListView.cellsDelegate = viewModel
        productListView.switchViewModel(viewModel.listViewModel)
        let show3Columns = DeviceFamily.current.isWiderOrEqualThan(.iPhone6Plus)
        if show3Columns {
            productListView.updateLayoutWithSeparation(6)
        }
        addSubview(productListView)
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
        productListView.collectionViewContentInset.top = topBarHeight + (tagsShowing ? heightFiltersTagView : 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navbarSearch.endEdit()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard didCallViewDidLoaded else { return }
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        endEdit()
    }


    // MARK: - ScrollableToTop

    /**
    Scrolls the product list to the top
    */
    func scrollToTop() {
        guard didCallViewDidLoaded else { return }
        productListView.scrollToTop(true)
    }
    

    // MARK: - ProductListViewScrollDelegate
    
    func productListView(_ productListView: ProductListView, didScrollDown scrollDown: Bool) {
        guard viewModel.active else { return }

        if let tagsVC = self.tagsViewController, !tagsVC.tags.isEmpty {
            showTagsView(!scrollDown, updateInsets: false)
        }
        setBars(hidden: scrollDown)
    }

    func productListView(_ productListView: ProductListView, didScrollWithContentOffsetY contentOffsetY: CGFloat) {
        updateBubbleTopConstraint()
    }

    private func updateBubbleTopConstraint() {
        let delta = productListView.headerBottom - topInset.value
        if delta > 0 {
            infoBubbleTopConstraint.constant = infoBubbleTopMargin + delta
        } else {
            infoBubbleTopConstraint.constant = infoBubbleTopMargin
        }
    }
    
    
    // MARK: - MainProductsViewModelDelegate

    func vmDidSearch() {
        suggestionsSearchesContainer.isHidden = true
    }

    func vmShowTags(_ tags: [FilterTag]) {
        loadTagsViewWithTags(tags)
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
    
    // MARK: - FilterTagsViewControllerDelegate
    
    func filterTagsViewControllerDidRemoveTag(_ controller: FilterTagsViewController) {
        viewModel.updateFiltersFromTags(controller.tags)
        if controller.tags.isEmpty {
            loadTagsViewWithTags([])
        }
    }
    
    
    // MARK: - Private methods

    private func setBars(hidden: Bool, animated: Bool = true) {
        self.tabBarController?.setTabBarHidden(hidden, animated: animated)
        self.navigationController?.setNavigationBarHidden(hidden, animated: animated)
    }

    dynamic fileprivate func endEdit() {
        suggestionsSearchesContainer.isHidden = true
        setFiltersNavBarButton()
        setInviteNavBarButton()
        navbarSearch.endEdit()
    }

    private func beginEdit() {
        guard suggestionsSearchesContainer.isHidden else { return }

        viewModel.searchBegan()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel , target: self,
                                                            action: #selector(endEdit))
        suggestionsSearchesContainer.isHidden = false
        viewModel.retrieveLastUserSearch()
        navbarSearch.beginEdit()
    }
    
    /**
        Called when the search button is pressed.
    */
    dynamic private func filtersButtonPressed(_ sender: AnyObject) {
        navbarSearch.searchTextField.resignFirstResponder()
        viewModel.showFilters()
    }
    
    private func setupTagsView() {
        tagsCollectionTopSpace = NSLayoutConstraint(item: tagsCollectionView, attribute: .top, relatedBy: .equal,
            toItem: topLayoutGuide, attribute: .bottom, multiplier: 1.0, constant: -heightFiltersTagView)
        if let tagsCollectionTopSpace = tagsCollectionTopSpace {
            view.addConstraint(tagsCollectionTopSpace)
        }

        tagsViewController = FilterTagsViewController(collectionView: self.tagsCollectionView)
        tagsViewController?.delegate = self
        loadTagsViewWithTags(viewModel.tags)
    }
    
    private func loadTagsViewWithTags(_ tags: [FilterTag]) {
        
        tagsViewController?.updateTags(tags)
        let showTags = tags.count > 0
        showTagsView(showTags, updateInsets: true)
        
        //Update tags button
        setFiltersNavBarButton()
    }
    
    private func setFiltersNavBarButton() {
        let tagsIsEmpty = tagsViewController?.tags.isEmpty ?? false
        setLetGoRightButtonWith(imageName: tagsIsEmpty ? "ic_filters" : "ic_filters_active",
                                renderingMode: .alwaysOriginal, selector: "filtersButtonPressed:")
    }
    
    private func setInviteNavBarButton() {
        guard isRootViewController() else { return }
        guard viewModel.shouldShowInviteButton else { return }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: LGLocalizedString.mainProductsInviteNavigationBarButton,
                                                           style: .plain, 
                                                           target: self, 
                                                           action: #selector(openInvite))
    }
    
    dynamic private func openInvite() {
        viewModel.vmUserDidTapInvite()
    }
    
    private func showTagsView(_ show: Bool, updateInsets: Bool) {
        if tagsAnimating || tagsShowing == show {
            return
        }
        
        tagsShowing = show
        tagsAnimating = true
        
        if show {
            tagsCollectionView.isHidden = false
        }

        let tagsHeight = tagsCollectionView.frame.size.height
        tagsCollectionTopSpace?.constant = show ? 0.0 : -tagsHeight
        if updateInsets {
            topInset.value = show ? topBarHeight + tagsHeight : topBarHeight
        }

        UIView.animate(
            withDuration: 0.2,
            animations: { [weak self]  in
                self?.view.layoutIfNeeded()
            },
            completion: { [weak self] (value: Bool) in
                if !show {
                    self?.tagsCollectionView.isHidden = true
                }
                self?.tagsAnimating = false
            }
        )
    }
    
    private func setupInfoBubble() {
        infoBubbleShadow.applyInfoBubbleShadow()
    }

    private func setupSearchAndTrending() {
        // Add search text field
        navbarSearch.searchTextField.delegate = self
        setNavBarTitleStyle(.custom(navbarSearch))

        setupSuggestionsTable()
    }

    private func setupRxBindings() {
        viewModel.infoBubbleText.asObservable().bindTo(infoBubbleLabel.rx.text).addDisposableTo(disposeBag)
        viewModel.infoBubbleVisible.asObservable().map { !$0 }.bindTo(infoBubbleShadow.rx.isHidden).addDisposableTo(disposeBag)

        topInset.asObservable().skip(1).bindNext { [weak self] topInset in
                self?.productListView.collectionViewContentInset.top = topInset
        }.addDisposableTo(disposeBag)

        viewModel.mainProductsHeader.asObservable().bindNext { [weak self] header in
            self?.productListView.refreshDataView()
        }.addDisposableTo(disposeBag)

        viewModel.errorMessage.asObservable().bindNext { [weak self] errorMessage in
            if let toastTitle = errorMessage {
                self?.toastView?.title = toastTitle
                self?.setToastViewHidden(false)
            } else {
                self?.setToastViewHidden(true)
            }
        }.addDisposableTo(disposeBag)
    }
}


// MARK: - ProductListViewHeaderDelegate

extension MainProductsViewController: ProductListViewHeaderDelegate, PushPermissionsHeaderDelegate {

    func totalHeaderHeight() -> CGFloat {
        var totalHeight: CGFloat = 0
        if shouldShowPermissionsBanner {
            totalHeight = PushPermissionsHeader.viewHeight
        }
        if shouldShowCategoryCollectionBanner {
            totalHeight = totalHeight + CategoriesHeaderCollectionView.viewHeight
        }
        return totalHeight
    }

    func setupViewsInHeader(_ header: ListHeaderContainer) {
        header.clear()
        if shouldShowPermissionsBanner {
            let pushHeader = PushPermissionsHeader()
            pushHeader.tag = 0
            pushHeader.delegate = self
            header.addHeader(pushHeader, height: PushPermissionsHeader.viewHeight)
        }
        if shouldShowCategoryCollectionBanner {
            let headerSize = CGRect(x: 0, y: 0, width: 200, height: CategoriesHeaderCollectionView.viewHeight)
            categoriesHeader = CategoriesHeaderCollectionView(categories: ListingCategory.visibleValuesInFeed(), frame: headerSize)
            categoriesHeader?.categorySelected.asObservable().bindNext { [weak self] category in
                guard let category = category else { return }
                self?.viewModel.updateFiltersFromHeaderCategories(category)
            }.addDisposableTo(disposeBag)
            if let categoriesHeader = categoriesHeader {
                categoriesHeader.tag = 1
                header.addHeader(categoriesHeader, height: CategoriesHeaderCollectionView.viewHeight)
            }
            
        }
    }

    private var shouldShowPermissionsBanner: Bool {
        return viewModel.mainProductsHeader.value.contains(MainProductsHeader.PushPermissions)
    }
    
    private var shouldShowCategoryCollectionBanner: Bool {
        return viewModel.mainProductsHeader.value.contains(MainProductsHeader.CategoriesCollectionBanner)
    }

    func pushPermissionHeaderPressed() {
        viewModel.pushPermissionsHeaderPressed()
    }
}


// MARK: - Trending searches

extension MainProductsViewController: UITableViewDelegate, UITableViewDataSource {

    func setupSuggestionsTable() {
        suggestionsSearchesTable.register(UINib(nibName: SuggestionSearchCell.reusableID, bundle: nil),
                                          forCellReuseIdentifier: SuggestionSearchCell.reusableID)

        let topConstraint = NSLayoutConstraint(item: suggestionsSearchesContainer, attribute: .top, relatedBy: .equal,
                                               toItem: topLayoutGuide, attribute: .bottom, multiplier: 1.0, constant: 0)
        view.addConstraint(topConstraint)
        
        Observable.combineLatest(viewModel.trendingSearches.asObservable(), viewModel.lastSearches.asObservable()) { trendings, lastSearches in
            return trendings.count + lastSearches.count
            }.bindNext { [weak self] totalCount in
                self?.suggestionsSearchesTable.reloadData()
                self?.suggestionsSearchesTable.isHidden = totalCount == 0
            }.addDisposableTo(disposeBag)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                                         name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                                         name: NSNotification.Name.UIKeyboardWillHide, object: nil)

    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let sectionType = getSearchSuggestionType(section) else { return 0 }
        switch sectionType {
        case .lastSearch:
            return viewModel.lastSearchesCounter > 0 ? sectionHeight : 0
        case .trending:
            return viewModel.trendingCounter > 0 ? sectionHeight : 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        // Needed to avoid footer on grouped tableView.
        return 1.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: sectionHeight))
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
        clearButton.setTitle(LGLocalizedString.suggestionsLastSearchesClearButton.uppercase, for: .normal)
        clearButton.addTarget(self, action: #selector(cleanSearchesButtonPressed), for: .touchUpInside)
        container.addSubview(clearButton)
        
        var views = [String: Any]()
        views["label"] = suggestionTitleLabel
        views["clear"] = clearButton
        var metrics = [String: Any]()
        metrics["verticalMarginHeaderView"] = verticalMarginHeaderView
        metrics["horizontalMarginHeaderView"] = horizontalMarginHeaderView
        container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-verticalMarginHeaderView-[label]-verticalMarginHeaderView-|",
            options: [], metrics: metrics, views: views))
        container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-horizontalMarginHeaderView-[label]",
            options: [], metrics: metrics, views: views))
        container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-verticalMarginHeaderView-[clear]-verticalMarginHeaderView-|",
            options: [], metrics: metrics, views: views))
        container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[clear]-horizontalMarginHeaderView-|",
            options: [], metrics: metrics, views: views))
        
        guard let sectionType = getSearchSuggestionType(section) else { return UIView() }
        switch sectionType {
        case .lastSearch:
            suggestionTitleLabel.text = LGLocalizedString.suggestionsLastSearchesTitle.uppercase
        case .trending:
            clearButton.isHidden = true
            suggestionTitleLabel.text = LGLocalizedString.trendingSearchesTitle.uppercase
        }
        return container
    }
    
    dynamic private func cleanSearchesButtonPressed() {
        viewModel.cleanUpLastSearches()
    }
    
    @IBAction func trendingSearchesBckgPressed(_ sender: AnyObject) {
        endEdit()
    }

    func keyboardWillShow(_ notification: Notification) {
        suggestionsSearchesTable.contentInset.bottom = notification.keyboardChange.height
    }

    func keyboardWillHide(_ notification: Notification) {
        suggestionsSearchesTable.contentInset.bottom = 0
    }


    // MARK: > TableView

    func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSuggestionSections
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SuggestionSearchCell.cellHeight
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = getSearchSuggestionType(section) else { return 0 }
        switch sectionType {
        case .lastSearch:
            return viewModel.lastSearchesCounter
        case .trending:
            return viewModel.trendingCounter
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sectionType = getSearchSuggestionType(indexPath.section) else { return UITableViewCell() }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SuggestionSearchCell.reusableID,
                            for: indexPath) as? SuggestionSearchCell else { return UITableViewCell() }
        switch sectionType {
        case .lastSearch:
            guard let lastSearch = viewModel.lastSearchAtIndex(indexPath.row) else { return UITableViewCell() }
            cell.suggestionText.text = lastSearch
        case .trending:
            guard let trendingSearch = viewModel.trendingSearchAtIndex(indexPath.row) else { return UITableViewCell() }
            cell.suggestionText.text = trendingSearch
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let sectionType = getSearchSuggestionType(indexPath.section) else { return }
        switch sectionType {
        case .lastSearch:
            viewModel.selectedLastSearchAtIndex(indexPath.row)
        case .trending:
            viewModel.selectedTrendingSearchAtIndex(indexPath.row)
        }
    }
}

fileprivate extension MainProductsViewController {
    func getSearchSuggestionType(_ section: Int) -> SearchSuggestionType? {
        switch section {
        case 0:
            return .lastSearch
        case 1:
            return .trending
        default:
            return nil
        }
    }
}


extension MainProductsViewController {
    func setAccessibilityIds() {
        navigationItem.rightBarButtonItem?.accessibilityId = .mainProductsFilterButton
        productListView.accessibilityId = .mainProductsListView
        tagsCollectionView.accessibilityId = .mainProductsTagsCollection
        infoBubbleLabel.accessibilityId = .mainProductsInfoBubbleLabel
        navbarSearch.accessibilityId = .mainProductsNavBarSearch
        suggestionsSearchesTable.accessibilityId = .mainProductsSuggestionSearchesTable
        navigationItem.leftBarButtonItem?.accessibilityId = .mainProductsInviteButton
    }
}
