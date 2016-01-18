//
//  ProductsViewController.swift
//  letgo
//
//  Created by AHL on 3/5/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import CoreLocation
import LGCoreKit
import Parse
import UIKit

public class MainProductsViewController: BaseViewController, ProductListViewDataDelegate, ProductListViewScrollDelegate,
MainProductsViewModelDelegate, FilterTagsViewControllerDelegate, InfoBubbleDelegate, PermissionsDelegate,
UITextFieldDelegate {
    
    // ViewModel
    var viewModel: MainProductsViewModel!
    
    // UI
    @IBOutlet weak var mainProductListView: MainProductListView!
    
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
    
    public convenience init() {
        self.init(viewModel: MainProductsViewModel(), nibName: "MainProductsViewController")
    }
    
    public convenience init(viewModel: MainProductsViewModel) {
        self.init(viewModel: viewModel, nibName: "MainProductsViewController")
    }
    
    public required init(viewModel: MainProductsViewModel, nibName nibNameOrNil: String?) {
        self.searchTextField = LGNavBarSearchField.setupNavBarSearchFieldWithText(viewModel.searchString)
        
        super.init(viewModel: viewModel, nibName: nibNameOrNil)
        self.viewModel = viewModel
        viewModel.delegate = self
        viewModel.bubbleDelegate = self
        viewModel.permissionsDelegate = self

        hidesBottomBarWhenPushed = false
        floatingSellButtonHidden = false
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI
        // > Main product list view
        mainProductListView.collectionViewContentInset.top = topBarHeight
        mainProductListView.collectionViewContentInset.bottom = tabBarHeight + Constants.tabBarSellFloatingButtonHeight
        mainProductListView.delegate = self
        mainProductListView.actionsDelegate = self
        mainProductListView.scrollDelegate = self
        mainProductListView.topProductInfoDelegate = self.viewModel
        mainProductListView.queryString = viewModel.searchString
        
        //Applying previous filters
        setProductListFilters()
        
        addSubview(mainProductListView)
        
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
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        searchTextField?.endEdit()
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        setBarsHidden(false, animated: false)
        
        if let actualSearchField = searchTextField {
            endEdit()
            viewModel.searchString = actualSearchField.searchTextField.text
        }
    }
    

    // MARK: - InfoBubbleDelegate
    
    public func mainProductsViewModel(mainProductsViewModel: MainProductsViewModel, updatedBubbleInfoString: String) {
        infoBubbleLabel.text = updatedBubbleInfoString
    }

    public func mainProductsViewModel(mainProductsViewModel: MainProductsViewModel, shouldHideBubble hidden: Bool) {
        UIView.animateWithDuration(0.35, animations: { () -> Void in
            self.infoBubbleShadow.alpha = hidden ? 0:1
        })
    }


    // MARK: - PermissionsDelegate

    public func mainProductsViewModelShowPushPermissionsAlert(mainProductsViewModel: MainProductsViewModel) {
        PushPermissionsManager.sharedInstance.showPushPermissionsAlertFromViewController(self,
            prePermissionType: .ProductList)
    }
    
    
    // MARK: - ProductListViewDataDelegate
    
    public func productListView(productListView: ProductListView, didFailRetrievingProductsPage page: UInt,
        hasProducts: Bool, error: ProductsRetrieveServiceError) {
            
            // If we already have data & it's the first page then show a toast
            if hasProducts && page > 0 {
                let toastTitle: String?
                switch error {
                case .Network:
                    toastTitle = LGLocalizedString.toastNoNetwork
                case .Internal:
                    toastTitle = LGLocalizedString.toastErrorInternal
                case .Forbidden:
                    toastTitle = nil
                }
                if let toastTitle = toastTitle {
                    toastView?.title = toastTitle
                    setToastViewHidden(false)
                }
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
    
    public func productListView(productListView: ProductListView, didSucceedRetrievingProductsPage page: UInt,
        hasProducts: Bool) {
            
            // Hide toast, if visible
            setToastViewHidden(true)
            
            // Update distance label visibility
            showInfoBubble(hasProducts, alpha: hasProducts ? 1:0)
            
            // If the first page load succeeds
            guard page == 0 else { return }

            // Floating sell button should be shown
            guard let tabBarCtl = tabBarController as? TabBarController else { return }
            // Only if there's a change
            let previouslyHidden = floatingSellButtonHidden
            floatingSellButtonHidden = false
            guard floatingSellButtonHidden != previouslyHidden else { return }
            tabBarCtl.setSellFloatingButtonHidden(floatingSellButtonHidden, animated: true)
    }
    
    public func productListView(productListView: ProductListView, didSelectItemAtIndexPath indexPath: NSIndexPath,
        thumbnailImage: UIImage?) {
        let productVM = productListView.productViewModelForProductAtIndex(indexPath.row, thumbnailImage: thumbnailImage)
        let vc = ProductViewController(viewModel: productVM)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    // MARK: - ProductListViewScrollDelegate
    
    public func productListView(productListView: ProductListView, didScrollDown scrollDown: Bool) {
        if !self.tagsViewController.tags.isEmpty {
            showTagsView(!scrollDown)
        }
        
        setBarsHidden(scrollDown)
    }
    
    
    // MARK: - MainProductsViewModelDelegate
    
    public func mainProductsViewModel(viewModel: MainProductsViewModel,
        didSearchWithViewModel searchViewModel: MainProductsViewModel) {
            
            cancelSearchOverlayButton?.removeFromSuperview()
            cancelSearchOverlayButton = nil
            let vc = MainProductsViewController(viewModel: searchViewModel)
            self.navigationController?.pushViewController(vc, animated: true)
            
    }
    
    func mainProductsViewModel(viewModel: MainProductsViewModel, showFilterWithViewModel filtersVM: FiltersViewModel) {
        FiltersViewController.presentAsSemimodalOnViewController(self, withViewModel: filtersVM)
    }
    
    func mainProductsViewModel(viewModel: MainProductsViewModel, showTags: [FilterTag]) {
        loadTagsViewWithTags(showTags)
    }
    
    func mainProductsViewModelRefresh(viewModel: MainProductsViewModel){
        setProductListFilters()
        mainProductListView.refresh()
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
            action: "endEdit")
        
        let blur = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let searchOverlayView = UIVisualEffectView(effect: blur)
        
        cancelSearchOverlayButton = UIButton(frame: mainProductListView.bounds)
        cancelSearchOverlayButton?.addTarget(self, action: Selector("endEdit"),
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
    
    
    // MARK: UITextFieldDelegate Methods
    
    dynamic public func textFieldDidBeginEditing(textField: UITextField) {
        beginEdit()
    }
    
    dynamic public func textFieldShouldReturn(textField: UITextField) -> Bool {
        viewModel.search()
        return true
    }
    
    // will be used for history & predictive search
    dynamic public func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange,
        replacementString string: String) -> Bool {

            if let textFieldText = textField.text {
                let text = (textFieldText as NSString).stringByReplacingCharactersInRange(range, withString: string)
                viewModel.searchString = text
            }
            return true
    }
    
    dynamic public func textFieldShouldClear(textField: UITextField) -> Bool {
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
        //Top constraint
        tagsCollectionTopSpace = NSLayoutConstraint(item: tagsCollectionView, attribute: .Top, relatedBy: .Equal,
            toItem: topLayoutGuide, attribute: .Bottom, multiplier: 1.0, constant: -40.0)
        self.view.addConstraint(tagsCollectionTopSpace!)
        
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
            self.tagsCollectionView.hidden = false
        }
        
        UIView.animateWithDuration(
            0.2,
            animations: { [weak self]  in
                guard let strongSelf = self else { return }
                
                let tagsHeight = strongSelf.tagsCollectionView.frame.size.height
                if let tagsTopSpace = strongSelf.tagsCollectionTopSpace {
                    tagsTopSpace.constant = show ? 0.0 : -tagsHeight
                }
                strongSelf.mainProductListView.collectionViewContentInset.top = show ? strongSelf.topBarHeight +
                    tagsHeight : strongSelf.topBarHeight
                strongSelf.view.layoutIfNeeded()
            },
            completion: { [weak self] (value: Bool) in
                guard let strongSelf = self else { return }
                
                if !show {
                    strongSelf.tagsCollectionView.hidden = true
                }
                strongSelf.tagsAnimating = false
            }
        )
    }
    
    private func setupInfoBubble() {
        
        //Initial text
        infoBubbleLabel.text = ""
        
        //Shape & shadow
        infoBubbleShadow.layer.cornerRadius = 15
        infoBubbleShadow.layer.shadowColor = UIColor.blackColor().CGColor
        infoBubbleShadow.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        infoBubbleShadow.layer.shadowOpacity = 0.12
        infoBubbleShadow.layer.shadowRadius = 8.0
        
        showInfoBubble(false, alpha: 0.0)
    }
    
    private func showInfoBubble(show: Bool, alpha: CGFloat? = nil) {
        infoBubbleShadow.hidden = !viewModel.infoBubblePresent || !show
        if let alpha = alpha {
            infoBubbleShadow.alpha = alpha
        }
    }
    
    private func setProductListFilters() {
        mainProductListView.categories = viewModel.filters.selectedCategories
        mainProductListView.timeCriteria = viewModel.filters.selectedWithin
        mainProductListView.sortCriteria = viewModel.filters.selectedOrdering
        mainProductListView.distanceRadius = viewModel.filters.distanceRadius
        mainProductListView.distanceType = viewModel.filters.distanceType
    }
}


// MARK: - ProductListActionsDelegate

extension MainProductsViewController: ProductListActionsDelegate {

    public func productListViewModel(productListViewModel: ProductListViewModel,
        didTapChatOnProduct product: Product) {

            let showChatAction = { [weak self] in
                guard let chatVM = self?.viewModel.chatViewModelForProduct(product) else { return }
                let chatVC = ChatViewController(viewModel: chatVM)
                self?.navigationController?.pushViewController(chatVC, animated: true)
            }

            ifLoggedInThen(.AskQuestion, loggedInAction: showChatAction,
                elsePresentSignUpWithSuccessAction: showChatAction)
    }

    public func productListViewModel(productListViewModel: ProductListViewModel,
        didTapShareOnProduct product: Product) {
            if let shareDelegate = viewModel.shareDelegateForProduct(product) {
                presentNativeShareWith(shareText: shareDelegate.shareText, delegate: shareDelegate)
            }
    }
}
