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
    case LastSearch
    case Trending
}

class MainProductsViewController: BaseViewController, ProductListViewScrollDelegate, MainProductsViewModelDelegate,
    FilterTagsViewControllerDelegate, PermissionsDelegate, UITextFieldDelegate, ScrollableToTop {
    
    // ViewModel
    var viewModel: MainProductsViewModel
    
    // UI
    @IBOutlet weak var productListView: ProductListView!
    
    @IBOutlet weak var tagsCollectionView: UICollectionView!
    var tagsCollectionTopSpace: NSLayoutConstraint?

    private let infoBubbleTopMargin: CGFloat = 8
    private let verticalMarginHeaderView: CGFloat = 16
    private let horizontalMarginHeaderView: CGFloat = 16
    private let sectionHeight: CGFloat = 54
    private let firstSectionMarginTop: CGFloat = -36
    private let numberOfSuggestionSections = 2
    @IBOutlet weak var infoBubbleLabel: UILabel!
    @IBOutlet weak var infoBubbleShadow: UIView!
    @IBOutlet weak var infoBubbleTopConstraint: NSLayoutConstraint!
    
    private let navbarSearch: LGNavBarSearchField
    @IBOutlet weak var suggestionsSearchesContainer: UIVisualEffectView!
    @IBOutlet weak var suggestionsSearchesTable: UITableView!
    
    private var tagsViewController : FilterTagsViewController?
    private var tagsShowing : Bool = false
    private var tagsAnimating : Bool = false

    private let topInset = Variable<CGFloat> (0)

    private let disposeBag = DisposeBag()

    
    // MARK: - Lifecycle

    convenience init(viewModel: MainProductsViewModel) {
        self.init(viewModel: viewModel, nibName: "MainProductsViewController")
    }
    
    required init(viewModel: MainProductsViewModel, nibName nibNameOrNil: String?) {
        self.navbarSearch = LGNavBarSearchField.setupNavBarSearchFieldWithText(viewModel.searchString)
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nibNameOrNil)
        viewModel.delegate = self
        viewModel.permissionsDelegate = self
        hidesBottomBarWhenPushed = false
        floatingSellButtonHidden = false
        hasTabBar = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        topInset.value = topBarHeight
        productListView.collectionViewContentInset.top = topBarHeight
        productListView.collectionViewContentInset.bottom = tabBarHeight + Constants.tabBarSellFloatingButtonHeight
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
        setFiltersNavbarButton()
        setInviteNavBarButton()
        setupRxBindings()
        setAccessibilityIds()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        navbarSearch.endEdit()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        guard viewLoaded else { return }
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        endEdit()
    }


    // MARK: - ScrollableToTop

    /**
    Scrolls the product list to the top
    */
    func scrollToTop() {
        guard viewLoaded else { return }
        productListView.scrollToTop(true)
    }


    // MARK: - PermissionsDelegate

    func mainProductsViewModelShowPushPermissionsAlert(mainProductsViewModel: MainProductsViewModel) {
        guard let tabBarCtl = tabBarController else { return }
        PushPermissionsManager.sharedInstance.showPrePermissionsViewFrom(tabBarCtl, type: .ProductList, completion: nil)
    }
    

    // MARK: - ProductListViewScrollDelegate
    
    func productListView(productListView: ProductListView, didScrollDown scrollDown: Bool) {
        guard viewModel.active else { return }

        if let tagsVC = self.tagsViewController where !tagsVC.tags.isEmpty {
            showTagsView(!scrollDown)
        }
        setBarsHidden(scrollDown)
    }

    func productListView(productListView: ProductListView, didScrollWithContentOffsetY contentOffsetY: CGFloat) {
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

    func vmDidSearch(searchViewModel: MainProductsViewModel) {
        suggestionsSearchesContainer.hidden = true
        let vc = MainProductsViewController(viewModel: searchViewModel)
        navigationController?.pushViewController(vc, animated: true)
    }

    func vmShowFilters(filtersVM: FiltersViewModel) {
        let vc = FiltersViewController(viewModel: filtersVM)
        let navVC = UINavigationController(rootViewController: vc)
        presentViewController(navVC, animated: true, completion: nil)
    }

    func vmShowTags(tags: [FilterTag]) {
        loadTagsViewWithTags(tags)
    }

    
    // MARK: UITextFieldDelegate Methods

    func textFieldShouldClear(textField: UITextField) -> Bool {
        if viewModel.clearTextOnSearch {
            textField.text = viewModel.searchString
            return false
        }
        return true
    }
    
    dynamic func textFieldDidBeginEditing(textField: UITextField) {
        if viewModel.clearTextOnSearch {
            textField.text = nil
        }
        beginEdit()
    }
    
    dynamic func textFieldShouldReturn(textField: UITextField) -> Bool {
        guard let query = textField.text else { return true }
        viewModel.search(query)
        return true
    }
    
    // MARK: - FilterTagsViewControllerDelegate
    
    func filterTagsViewControllerDidRemoveTag(controller: FilterTagsViewController) {
        viewModel.updateFiltersFromTags(controller.tags)
        if controller.tags.isEmpty {
            loadTagsViewWithTags([])
        }
    }
    
    
    // MARK: - Private methods

    private func setBarsHidden(hidden: Bool, animated: Bool = true) {
        self.tabBarController?.setTabBarHidden(hidden, animated: animated)
        self.navigationController?.setNavigationBarHidden(hidden, animated: animated)
    }

    dynamic private func endEdit() {
        suggestionsSearchesContainer.hidden = true
        setFiltersNavbarButton()
        setInviteNavBarButton()
        navbarSearch.endEdit()
    }

    private func beginEdit() {
        guard suggestionsSearchesContainer.hidden else { return }

        viewModel.searchBegan()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel , target: self,
                                                            action: #selector(endEdit))
        suggestionsSearchesContainer.hidden = false
        viewModel.retrieveLastUserSearch()
        navbarSearch.beginEdit()
    }
    
    /**
        Called when the search button is pressed.
    */
    dynamic private func filtersButtonPressed(sender: AnyObject) {
        navbarSearch.searchTextField.resignFirstResponder()
        viewModel.showFilters()
    }
    
    private func setupTagsView() {
        tagsCollectionTopSpace = NSLayoutConstraint(item: tagsCollectionView, attribute: .Top, relatedBy: .Equal,
            toItem: topLayoutGuide, attribute: .Bottom, multiplier: 1.0, constant: -40.0)
        if let tagsCollectionTopSpace = tagsCollectionTopSpace {
            view.addConstraint(tagsCollectionTopSpace)
        }

        tagsViewController = FilterTagsViewController(collectionView: self.tagsCollectionView)
        tagsViewController?.delegate = self
        loadTagsViewWithTags(viewModel.tags)
    }
    
    private func loadTagsViewWithTags(tags: [FilterTag]) {
        
        tagsViewController?.updateTags(tags)
        let showTags = tags.count > 0
        showTagsView(showTags)
        
        //Update tags button
        setFiltersNavbarButton()
    }
    
    private func setFiltersNavbarButton() {
        var filtersIcon = "ic_filters"
        if let tagsViewController = self.tagsViewController {
            filtersIcon = tagsViewController.tags.isEmpty ? "ic_filters": "ic_filters_active"
        }
        setLetGoRightButtonWith(imageName: filtersIcon, renderingMode: .AlwaysOriginal, selector: "filtersButtonPressed:")
    }
    
    private func setInviteNavBarButton() {
        guard isRootViewController() else { return }
        guard viewModel.shouldShowInviteButton else { return }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: LGLocalizedString.appShareInviteText, style: .Plain,
                                                           target: self, action: #selector(openInvite))
    }
    
    dynamic private func openInvite() {
        viewModel.vmUserDidTapInvite()
    }
    
    private func showTagsView(show: Bool) {
        if tagsAnimating || tagsShowing == show {
            return
        }
        
        tagsShowing = show
        tagsAnimating = true
        
        if show {
            tagsCollectionView.hidden = false
        }

        let tagsHeight = tagsCollectionView.frame.size.height
        tagsCollectionTopSpace?.constant = show ? 0.0 : -tagsHeight
        topInset.value = show ? topBarHeight + tagsHeight : topBarHeight

        UIView.animateWithDuration(
            0.2,
            animations: { [weak self]  in
                self?.view.layoutIfNeeded()
            },
            completion: { [weak self] (value: Bool) in
                if !show {
                    self?.tagsCollectionView.hidden = true
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
        setNavBarTitleStyle(.Custom(navbarSearch))

        setupSuggestionsTable()
    }

    private func setupRxBindings() {
        viewModel.infoBubbleText.asObservable().bindTo(infoBubbleLabel.rx_text).addDisposableTo(disposeBag)
        viewModel.infoBubbleVisible.asObservable().map { !$0 }.bindTo(infoBubbleShadow.rx_hidden).addDisposableTo(disposeBag)

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
        return shouldShowPermissionsBanner ? PushPermissionsHeader.viewHeight : 0
    }

    func setupViewsInHeader(header: ListHeaderContainer) {
        if shouldShowPermissionsBanner {
            let pushHeader = PushPermissionsHeader()
            pushHeader.delegate = self
            header.addHeader(pushHeader, height: PushPermissionsHeader.viewHeight)
        } else {
            header.clear()
        }
    }

    private var shouldShowPermissionsBanner: Bool {
        return viewModel.mainProductsHeader.value.contains(MainProductsHeader.PushPermissions)
    }

    func pushPermissionHeaderPressed() {
        viewModel.pushPermissionsHeaderPressed()
    }
}


// MARK: - Trending searches

extension MainProductsViewController: UITableViewDelegate, UITableViewDataSource {

    func setupSuggestionsTable() {
        suggestionsSearchesTable.registerNib(UINib(nibName: SuggestionSearchCell.reusableID, bundle: nil),
                                          forCellReuseIdentifier: SuggestionSearchCell.reusableID)

        let topConstraint = NSLayoutConstraint(item: suggestionsSearchesContainer, attribute: .Top, relatedBy: .Equal,
                                               toItem: topLayoutGuide, attribute: .Bottom, multiplier: 1.0, constant: 0)
        view.addConstraint(topConstraint)
        
        Observable.combineLatest(viewModel.trendingSearches.asObservable(), viewModel.lastSearches.asObservable()) { trendings, lastSearches in
            return trendings.count + lastSearches.count
            }.bindNext { [weak self] totalCount in
                self?.suggestionsSearchesTable.reloadData()
                self?.suggestionsSearchesTable.hidden = totalCount == 0
            }.addDisposableTo(disposeBag)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                                         name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                                         name: UIKeyboardWillHideNotification, object: nil)

    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let sectionType = getSearchSuggestionType(section) else { return 0 }
        switch sectionType {
        case .LastSearch:
            return viewModel.lastSearchesCounter > 0 ? sectionHeight : 0
        case .Trending:
            return viewModel.trendingCounter > 0 ? sectionHeight : 0
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: sectionHeight))
        let suggestionTitleLabel = UILabel()
        suggestionTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        suggestionTitleLabel.textAlignment = .Left
        suggestionTitleLabel.font = UIFont.sectionTitleFont
        suggestionTitleLabel.textColor = UIColor.darkGrayText
        container.addSubview(suggestionTitleLabel)

        let clearButton = UIButton()
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.titleLabel?.textAlignment = .Right
        clearButton.titleLabel?.font = UIFont.sectionTitleFont
        clearButton.setTitleColor(UIColor.darkGrayText, forState: .Normal)
        clearButton.setTitle(LGLocalizedString.suggestionsLastSearchesClearButton.uppercase, forState: .Normal)
        clearButton.addTarget(self, action: #selector(cleanSearchesButtonPressed), forControlEvents: .TouchUpInside)
        container.addSubview(clearButton)
        
        var views = [String: AnyObject]()
        views["label"] = suggestionTitleLabel
        views["clear"] = clearButton
        var metrics = [String: AnyObject]()
        metrics["verticalMarginHeaderView"] = verticalMarginHeaderView
        metrics["horizontalMarginHeaderView"] = horizontalMarginHeaderView
        container.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-verticalMarginHeaderView-[label]-verticalMarginHeaderView-|",
            options: [], metrics: metrics, views: views))
        container.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-horizontalMarginHeaderView-[label]",
            options: [], metrics: metrics, views: views))
        container.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-verticalMarginHeaderView-[clear]-verticalMarginHeaderView-|",
            options: [], metrics: metrics, views: views))
        container.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[clear]-horizontalMarginHeaderView-|",
            options: [], metrics: metrics, views: views))
        
        guard let sectionType = getSearchSuggestionType(section) else { return UIView() }
        switch sectionType {
        case .LastSearch:
            suggestionTitleLabel.text = LGLocalizedString.suggestionsLastSearchesTitle.uppercase
        case .Trending:
            clearButton.hidden = true
            suggestionTitleLabel.text = LGLocalizedString.trendingSearchesTitle.uppercase
        }
        return container
    }
    
    dynamic private func cleanSearchesButtonPressed() {
        viewModel.cleanUpLastSearches()
    }
    
    @IBAction func trendingSearchesBckgPressed(sender: AnyObject) {
        endEdit()
    }

    func keyboardWillShow(notification: NSNotification) {
        let kbAnimation = KeyboardAnimation(keyboardNotification: notification)
        suggestionsSearchesTable.contentInset.bottom = kbAnimation.size.height
    }

    func keyboardWillHide(notification: NSNotification) {
        suggestionsSearchesTable.contentInset.bottom = 0
    }


    // MARK: > TableView

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return numberOfSuggestionSections
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return SuggestionSearchCell.cellHeight
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = getSearchSuggestionType(section) else { return 0 }
        switch sectionType {
        case .LastSearch:
            return viewModel.lastSearchesCounter
        case .Trending:
            return viewModel.trendingCounter
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let sectionType = getSearchSuggestionType(indexPath.section) else { return UITableViewCell() }
        guard let cell = tableView.dequeueReusableCellWithIdentifier(SuggestionSearchCell.reusableID,
                            forIndexPath: indexPath) as? SuggestionSearchCell else { return UITableViewCell() }
        switch sectionType {
        case .LastSearch:
            guard let lastSearch = viewModel.lastSearchAtIndex(indexPath.row) else { return UITableViewCell() }
            cell.suggestionText.text = lastSearch
        case .Trending:
            guard let trendingSearch = viewModel.trendingSearchAtIndex(indexPath.row) else { return UITableViewCell() }
            cell.suggestionText.text = trendingSearch
        }
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let sectionType = getSearchSuggestionType(indexPath.section) else { return }
        switch sectionType {
        case .LastSearch:
            viewModel.selectedLastSearchAtIndex(indexPath.row)
        case .Trending:
            viewModel.selectedTrendingSearchAtIndex(indexPath.row)
        }
    }
}

private extension MainProductsViewController {
    func getSearchSuggestionType(section: Int) -> SearchSuggestionType? {
        switch section {
        case 0:
            return .LastSearch
        case 1:
            return .Trending
        default:
            return nil
        }
    }
}


extension MainProductsViewController {
    func setAccessibilityIds() {
        navigationItem.rightBarButtonItem?.accessibilityId = .MainProductsFilterButton
        productListView.accessibilityId = .MainProductsListView
        tagsCollectionView.accessibilityId = .MainProductsTagsCollection
        infoBubbleLabel.accessibilityId = .MainProductsInfoBubbleLabel
        navbarSearch.accessibilityId = .MainProductsNavBarSearch
        suggestionsSearchesTable.accessibilityId = .MainProductsSuggestionSearchesTable
        navigationItem.leftBarButtonItem?.accessibilityId = .MainProductsInviteButton
    }
}
