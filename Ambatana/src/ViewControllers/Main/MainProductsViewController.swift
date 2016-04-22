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

class MainProductsViewController: BaseViewController, ProductListViewScrollDelegate, MainProductsViewModelDelegate,
    FilterTagsViewControllerDelegate, InfoBubbleDelegate, PermissionsDelegate, UITextFieldDelegate, ScrollableToTop {
    
    // ViewModel
    var viewModel: MainProductsViewModel!
    
    // UI
    @IBOutlet weak var productListView: ProductListView!
    
    @IBOutlet weak var tagsCollectionView: UICollectionView!
    var tagsCollectionTopSpace: NSLayoutConstraint?
    
    @IBOutlet weak var infoBubbleLabel: UILabel!
    @IBOutlet weak var infoBubbleShadow: UIView!
    
    private var searchTextField : LGNavBarSearchField?
    private var cancelSearchOverlayButton : UIButton?   // button with a light blur effect by now,
                                                        // will be a table when history is implemented
    private var tagsViewController : FilterTagsViewController!
    private var tagsShowing : Bool = false
    private var tagsAnimating : Bool = false

    
    // MARK: - Lifecycle
    
    convenience init() {
        self.init(viewModel: MainProductsViewModel(), nibName: "MainProductsViewController")
    }
    
    convenience init(viewModel: MainProductsViewModel) {
        self.init(viewModel: viewModel, nibName: "MainProductsViewController")
    }
    
    required init(viewModel: MainProductsViewModel, nibName nibNameOrNil: String?) {
        self.searchTextField = LGNavBarSearchField.setupNavBarSearchFieldWithText(viewModel.searchString)
        
        super.init(viewModel: viewModel, nibName: nibNameOrNil)
        self.viewModel = viewModel
        viewModel.delegate = self
        viewModel.bubbleDelegate = self
        viewModel.permissionsDelegate = self

        hidesBottomBarWhenPushed = false
        floatingSellButtonHidden = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI
        // > Main product list view
        productListView.collectionViewContentInset.top = topBarHeight
        productListView.collectionViewContentInset.bottom = tabBarHeight + Constants.tabBarSellFloatingButtonHeight
        productListView.setErrorViewStyle(bgColor: UIColor(patternImage: UIImage(named: "pattern_white")!),
                            borderColor: StyleHelper.lineColor, containerColor: StyleHelper.emptyViewContentBgColor)
        productListView.scrollDelegate = self
        productListView.cellsDelegate = viewModel
        productListView.switchViewModel(viewModel.listViewModel)

        addSubview(productListView)
        
        //Info bubble
        setupInfoBubble()
        
        //Filter tags
        setupTagsView()
        
        // Add search text field
        if let searchField = searchTextField {
            searchField.searchTextField.delegate = self
            setLetGoNavigationBarStyle(searchField)
        }
        
        // Add filters button
        setFiltersNavbarButton()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        searchTextField?.endEdit()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        setBarsHidden(false, animated: false)
        
        if let actualSearchField = searchTextField {
            endEdit()
            viewModel.searchString = actualSearchField.searchTextField.text
        }
    }


    // MARK: - ScrollableToTop

    /**
    Scrolls the product list to the top
    */
    func scrollToTop() {
        guard let productListView = productListView else { return }
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
        if !self.tagsViewController.tags.isEmpty {
            showTagsView(!scrollDown)
        }
        
        setBarsHidden(scrollDown)
    }

    func productListView(productListView: ProductListView, didScrollWithContentOffsetY contentOffsetY: CGFloat) {
    }
    
    
    // MARK: - MainProductsViewModelDelegate

    func vmDidSearch(searchViewModel: MainProductsViewModel) {
        cancelSearchOverlayButton?.removeFromSuperview()
        cancelSearchOverlayButton = nil
        let vc = MainProductsViewController(viewModel: searchViewModel)
        navigationController?.pushViewController(vc, animated: true)
    }

    func vmShowFilters(filtersVM: FiltersViewModel) {
        FiltersViewController.presentAsSemimodalOnViewController(self, withViewModel: filtersVM)
    }

    func vmShowTags(tags: [FilterTag]) {
        loadTagsViewWithTags(tags)
    }

    func endEdit() {
        cancelSearchOverlayButton?.removeFromSuperview()
        cancelSearchOverlayButton = nil
        
        setFiltersNavbarButton()
        
        if let searchField = searchTextField {
            searchField.endEdit()
        }
    }
    
    func beginEdit() {
        
        if cancelSearchOverlayButton != nil {
            return
        }
        
        viewModel.searchBegan()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel , target: self,
            action: #selector(MainProductsViewController.endEdit))
        
        let blur = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let searchOverlayView = UIVisualEffectView(effect: blur)
        
        cancelSearchOverlayButton = UIButton(frame: productListView.bounds)
        cancelSearchOverlayButton?.addTarget(self, action: #selector(MainProductsViewController.endEdit),
            forControlEvents: UIControlEvents.TouchUpInside)
        
        searchOverlayView.frame = cancelSearchOverlayButton!.bounds
        searchOverlayView.userInteractionEnabled = false
        cancelSearchOverlayButton?.insertSubview(searchOverlayView, atIndex: 0)
        
        view.addSubview(cancelSearchOverlayButton!)
        
        guard let searchField = searchTextField else {
            return
        }
        
        searchField.beginEdit()
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

    func vmShowProduct(productVC: UIViewController) {
        navigationController?.pushViewController(productVC, animated: true)
    }

    
    // MARK: UITextFieldDelegate Methods
    
    dynamic func textFieldDidBeginEditing(textField: UITextField) {
        beginEdit()
    }
    
    dynamic func textFieldShouldReturn(textField: UITextField) -> Bool {
        viewModel.search()
        return true
    }
    
    // will be used for history & predictive search
    dynamic func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange,
        replacementString string: String) -> Bool {

            if let textFieldText = textField.text {
                let text = (textFieldText as NSString).stringByReplacingCharactersInRange(range, withString: string)
                viewModel.searchString = text
            }
            return true
    }
    
    dynamic func textFieldShouldClear(textField: UITextField) -> Bool {
        viewModel.searchString = ""
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
    
    /**
        Called when the search button is pressed.
    */
    @objc private func filtersButtonPressed(sender: AnyObject) {

        searchTextField?.searchTextField.resignFirstResponder()
        
        // Show filters
        viewModel.showFilters()
    }
    
    private func setupTagsView() {
        tagsCollectionTopSpace = NSLayoutConstraint(item: tagsCollectionView, attribute: .Top, relatedBy: .Equal,
            toItem: topLayoutGuide, attribute: .Bottom, multiplier: 1.0, constant: -40.0)
        view.addConstraint(tagsCollectionTopSpace!)

        tagsViewController = FilterTagsViewController(collectionView: self.tagsCollectionView)
        tagsViewController.delegate = self
        loadTagsViewWithTags(viewModel.tags)
    }
    
    private func loadTagsViewWithTags(tags: [FilterTag]) {
        
        self.tagsViewController.updateTags(tags)
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
        StyleHelper.applyInfoBubbleShadow(infoBubbleShadow.layer)

        showInfoBubble(false, alpha: 0.0)
    }
    
    private func showInfoBubble(show: Bool, alpha: CGFloat? = nil) {
        infoBubbleShadow.hidden = !viewModel.infoBubblePresent || !show
        if let alpha = alpha {
            infoBubbleShadow.alpha = alpha
        }
    }
}
