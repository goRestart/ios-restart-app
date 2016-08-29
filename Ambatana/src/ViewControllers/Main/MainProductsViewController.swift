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


class MainProductsViewController: BaseViewController, ProductListViewScrollDelegate, MainProductsViewModelDelegate,
    FilterTagsViewControllerDelegate, InfoBubbleDelegate, PermissionsDelegate, UITextFieldDelegate, ScrollableToTop {
    
    // ViewModel
    var viewModel: MainProductsViewModel
    
    // UI
    @IBOutlet weak var productListView: ProductListView!
    
    @IBOutlet weak var tagsCollectionView: UICollectionView!
    var tagsCollectionTopSpace: NSLayoutConstraint?
    
    @IBOutlet weak var infoBubbleLabel: UILabel!
    @IBOutlet weak var infoBubbleShadow: UIView!
    
    private let navbarSearch: LGNavBarSearchField
    @IBOutlet weak var trendingSearchesContainer: UIVisualEffectView!
    @IBOutlet weak var trendingSearchesTable: UITableView!
    
    private var tagsViewController : FilterTagsViewController?
    private var tagsShowing : Bool = false
    private var tagsAnimating : Bool = false

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
        viewModel.bubbleDelegate = self
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
        let show3Columns = DeviceFamily.isWideScreen
        if show3Columns {
            productListView.updateLayoutWithSeparation(6)
        }
        addSubview(productListView)

        setupInfoBubble()
        setupTagsView()
        setupSearchAndTrending()
        setFiltersNavbarButton()

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


    // MARK: - InfoBubbleDelegate
    
    func mainProductsViewModel(mainProductsViewModel: MainProductsViewModel, updatedBubbleInfoString: String) {
        infoBubbleLabel.text = updatedBubbleInfoString
    }

    func mainProductsViewModel(mainProductsViewModel: MainProductsViewModel, shouldHideBubble hidden: Bool) {
        UIView.animateWithDuration(0.35, animations: { () -> Void in
            self.infoBubbleShadow.alpha = hidden ? 0:1
        })
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
    }
    
    
    // MARK: - MainProductsViewModelDelegate

    func vmDidSearch(searchViewModel: MainProductsViewModel) {
        trendingSearchesContainer.hidden = true
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


    func vmDidFailRetrievingProducts(hasProducts hasProducts: Bool, error: String?) {
        if let toastTitle = error {
            toastView?.title = toastTitle
            setToastViewHidden(false)
        }

        // Update distance label visibility
        showInfoBubble(hasProducts, alpha: hasProducts ? 1:0)

        // Floating sell button should be shown if has products
        if let tabBarCtl = tabBarController as? TabBarController {

            // Only if there's a change
            let previouslyHidden = floatingSellButtonHidden
            floatingSellButtonHidden = !hasProducts
            if floatingSellButtonHidden != previouslyHidden  {
                tabBarCtl.setSellFloatingButtonHidden(floatingSellButtonHidden, animated: true)
            }
        }
    }

    func vmDidSuceedRetrievingProducts(hasProducts hasProducts: Bool, isFirstPage: Bool) {
        // Hide toast, if visible
        setToastViewHidden(true)

        // Update distance label visibility
        showInfoBubble(hasProducts, alpha: hasProducts ? 1:0)

        // If the first page load succeeds
        guard isFirstPage else { return }

        // Floating sell button should be shown
        guard let tabBarCtl = tabBarController as? TabBarController else { return }
        // Only if there's a change
        let previouslyHidden = floatingSellButtonHidden
        floatingSellButtonHidden = false
        guard floatingSellButtonHidden != previouslyHidden else { return }
        tabBarCtl.setSellFloatingButtonHidden(floatingSellButtonHidden, animated: true)
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
        trendingSearchesContainer.hidden = true
        setFiltersNavbarButton()
        navbarSearch.endEdit()
    }

    private func beginEdit() {
        guard trendingSearchesContainer.hidden else { return }

        viewModel.searchBegan()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel , target: self,
                                                            action: #selector(endEdit))
        trendingSearchesContainer.hidden = false
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
        if let tagsTopSpace = tagsCollectionTopSpace {
            tagsTopSpace.constant = show ? 0.0 : -tagsHeight
        }
        productListView.collectionViewContentInset.top = show ? topBarHeight + tagsHeight : topBarHeight

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
        infoBubbleLabel.text = viewModel.infoBubbleDefaultText
        infoBubbleShadow.applyInfoBubbleShadow()

        showInfoBubble(false, alpha: 0.0)
    }
    
    private func showInfoBubble(show: Bool, alpha: CGFloat? = nil) {
        infoBubbleShadow.hidden = !viewModel.infoBubblePresent || !show
        if let alpha = alpha {
            infoBubbleShadow.alpha = alpha
        }
    }

    private func setupSearchAndTrending() {
        // Add search text field
        navbarSearch.searchTextField.delegate = self
        setNavBarTitleStyle(.Custom(navbarSearch))

        setupTrendingTable()
    }

    private func setupRxBindings() {
        RatingManager.sharedInstance.ratingProductListBannerVisible.asObservable()
            .distinctUntilChanged().subscribeNext { [weak self] _ in
                self?.productListView.refreshDataView()
        }.addDisposableTo(disposeBag)
    }
}


// MARK: - ProductListViewHeaderDelegate

extension MainProductsViewController: ProductListViewHeaderDelegate, AppRatingBannerDelegate {
    private var shouldShowBanner: Bool {
        return RatingManager.sharedInstance.shouldShowRatingProductListBanner
    }

    func registerHeader(collectionView: UICollectionView) {
        let headerNib = UINib(nibName: "AppRatingBannerCell", bundle: nil)
        collectionView.registerNib(headerNib, forSupplementaryViewOfKind: CHTCollectionElementKindSectionHeader,
                                        withReuseIdentifier: "AppRatingBannerCell")
    }

    func heightForHeader() -> CGFloat {
        return shouldShowBanner ? AppRatingBannerCell.height : 0
    }

    func viewForHeader(collectionView: UICollectionView, kind: String, indexPath: NSIndexPath) -> UICollectionReusableView {
        guard shouldShowBanner else { return UICollectionReusableView() }
        guard let footer: AppRatingBannerCell = collectionView.dequeueReusableSupplementaryViewOfKind(kind,
                        withReuseIdentifier: "AppRatingBannerCell", forIndexPath: indexPath) as? AppRatingBannerCell
            else { return UICollectionReusableView() }
        footer.setupUI()
        footer.delegate = self
        return footer
    }

    func appRatingBannerClose() {
        viewModel.appRatingBannerClose()
    }

    func appRatingBannerShowRating() {
        guard let tabBarController = tabBarController as? TabBarController else { return }
        tabBarController.showAppRatingView(.Banner)
    }
}


// MARK: - Trending searches

extension MainProductsViewController: UITableViewDelegate, UITableViewDataSource {

    func setupTrendingTable() {
        trendingSearchesTable.registerNib(UINib(nibName: TrendingSearchCell.reusableID, bundle: nil),
                                          forCellReuseIdentifier: TrendingSearchCell.reusableID)

        let topConstraint = NSLayoutConstraint(item: trendingSearchesContainer, attribute: .Top, relatedBy: .Equal,
                                               toItem: topLayoutGuide, attribute: .Bottom, multiplier: 1.0, constant: 0)
        view.addConstraint(topConstraint)

        viewModel.trendingSearches.asObservable().bindNext { [weak self] trendings in
            self?.trendingSearchesTable.reloadData()
            self?.trendingSearchesTable.hidden = (trendings?.count ?? 0) == 0
        }.addDisposableTo(disposeBag)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                                         name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                                         name: UIKeyboardWillHideNotification, object: nil)

        addTrendingsTitle()
    }

    private func addTrendingsTitle() {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 54))
        let trendingTitleLabel = UILabel()
        trendingTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        trendingTitleLabel.textAlignment = .Center
        trendingTitleLabel.font = UIFont.mediumHeadlineFont
        trendingTitleLabel.textColor = UIColor.darkGrayText
        trendingTitleLabel.text = LGLocalizedString.trendingSearchesTitle
        container.addSubview(trendingTitleLabel)
        var views = [String: AnyObject]()
        views["label"] = trendingTitleLabel
        container.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-16-[label]-0-|",
            options: [], metrics: nil, views: views))
        container.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-8-[label]-8-|",
            options: [], metrics: nil, views: views))

        trendingSearchesTable.tableHeaderView = container
    }

    @IBAction func trendingSearchesBckgPressed(sender: AnyObject) {
        endEdit()
    }

    func keyboardWillShow(notification: NSNotification) {
        let kbAnimation = KeyboardAnimation(keyboardNotification: notification)
        trendingSearchesTable.contentInset.bottom = kbAnimation.size.height
    }

    func keyboardWillHide(notification: NSNotification) {
        trendingSearchesTable.contentInset.bottom = 0
    }


    // MARK: > TableView

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return TrendingSearchCell.cellHeight
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.trendingSearches.value?.count ?? 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let trendingSearch = viewModel.trendingSearchAtIndex(indexPath.row) else { return UITableViewCell() }
        guard let cell = tableView.dequeueReusableCellWithIdentifier(TrendingSearchCell.reusableID,
                            forIndexPath: indexPath) as? TrendingSearchCell else { return UITableViewCell() }
        cell.trendingText.text = trendingSearch
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        viewModel.selectedTrendingSearchAtIndex(indexPath.row)
    }
}


extension MainProductsViewController {
    func setAccessibilityIds() {
        navigationItem.rightBarButtonItem?.accessibilityId = .MainProductsFilterButton
        productListView.accessibilityId = .MainProductsListView
        tagsCollectionView.accessibilityId = .MainProductsTagsCollection
        infoBubbleLabel.accessibilityId = .MainProductsInfoBubbleLabel
        navbarSearch.accessibilityId = .MainProductsNavBarSearch
        trendingSearchesTable.accessibilityId = .MainProductsTrendingSearchesTable
    }
}
