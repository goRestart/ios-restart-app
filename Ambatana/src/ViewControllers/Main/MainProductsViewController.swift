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

public class MainProductsViewController: BaseViewController, ProductListViewDataDelegate, ProductListViewScrollDelegate, MainProductsViewModelDelegate, FilterTagsViewControllerDelegate, UITextFieldDelegate {
    
    // ViewModel
    var viewModel: MainProductsViewModel!

    // UI
    @IBOutlet weak var mainProductListView: MainProductListView!

    @IBOutlet weak var tagsCollectionView: UICollectionView!
    @IBOutlet weak var tagsCollectionTopSpace: NSLayoutConstraint!
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var distanceShadow: UIView!
    
    private var searchTextField : LGNavBarSearchField?
    private var cancelSearchOverlayButton : UIButton? // button with a light blur effect by now, will be a table when history is implemented
    
    
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
        self.searchTextField = (viewModel.title == nil) ? LGNavBarSearchField.setupNavBarSearchFieldWithText(viewModel.searchString) : nil
        
        super.init(viewModel: viewModel, nibName: nibNameOrNil)
        self.viewModel = viewModel
        viewModel.delegate = self
        
        hidesBottomBarWhenPushed = false
        
        showReachabilityMessageEnabled = true
        floatingSellButtonHidden = false
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI
        // > Main product list view
        mainProductListView.delegate = self
        mainProductListView.scrollDelegate = self
        mainProductListView.queryString = viewModel.searchString
        
        if let category = viewModel.category {
            mainProductListView.categories = [category]
        }

        addSubview(mainProductListView)
        
        setLetGoRightButtonWithImageName("ic_filters", andSelector: "filtersButtonPressed:")
        
        if let categoryTitle = viewModel.title as? String {
            self.setLetGoNavigationBarStyle(categoryTitle)
        } else {
            // Add search text field
            
            if let searchField = searchTextField {                
                searchField.searchTextField.delegate = self
                setLetGoNavigationBarStyle(searchField)
            }
        }
        
        
        //Info bubble
        distanceLabel.text = ""
        distanceShadow.layer.cornerRadius = 15
        distanceShadow.layer.shadowColor = UIColor.blackColor().CGColor
        distanceShadow.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        distanceShadow.layer.shadowOpacity = 0.12
        distanceShadow.layer.shadowRadius = 8.0
        showInfoBubble(false, alpha: 0.0)

        //Filter tags
        tagsViewController = FilterTagsViewController(collectionView: self.tagsCollectionView)
        tagsViewController.delegate = self
        loadTagsViewWithTags(viewModel.tags)
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
        
        if let actualSearchField = searchTextField {
            endEdit()
            viewModel.searchString = actualSearchField.searchTextField.text

        }
    }
    
    // MARK: - ProductListViewDataDelegate

    public func productListView(productListView: ProductListView, shouldUpdateDistanceLabel distance: Int, withDistanceType type: DistanceType) {

        // Update distance label
        distanceLabel.text = viewModel.distanceInfoTextForDistance(distance, type: type)
        
    }
    
    public func productListView(productListView: ProductListView, shouldHideDistanceLabel hidden: Bool) {

        UIView.animateWithDuration(0.35, animations: { () -> Void in
            self.distanceShadow.alpha = hidden ? 0:1
        })
    }
    
    public func productListView(productListView: ProductListView, shouldHideFloatingSellButton hidden: Bool) {
        if let tabBarCtl = tabBarController as? TabBarController {
            floatingSellButtonHidden = hidden
            tabBarCtl.setSellFloatingButtonHidden(floatingSellButtonHidden, animated: true)
        }
    }

    public func productListView(productListView: ProductListView, didStartRetrievingProductsPage page: UInt) {
        // If it's the first page load
        if page == 0 {
            if let tabBarCtl = tabBarController as? TabBarController {
                
                // then floating sell button should be hidden
                floatingSellButtonHidden = false
                tabBarCtl.setSellFloatingButtonHidden(floatingSellButtonHidden, animated: true)
            }
        }
    }

    public func productListView(productListView: ProductListView, didFailRetrievingProductsPage page: UInt, hasProducts: Bool, error: ProductsRetrieveServiceError) {

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
    
    public func productListView(productListView: ProductListView, didSucceedRetrievingProductsPage page: UInt, hasProducts: Bool) {
        
        // Hide toast, if visible
        setToastViewHidden(true)
        
        // Update distance label visibility
        showInfoBubble(hasProducts, alpha: hasProducts ? 1:0)

        // If the first page load succeeds
        if page == 0 {
            // Floating sell button should be shown
            if let tabBarCtl = tabBarController as? TabBarController {
                // Only if there's a change
                let previouslyHidden = floatingSellButtonHidden
                floatingSellButtonHidden = false
                if floatingSellButtonHidden != previouslyHidden  {
                    tabBarCtl.setSellFloatingButtonHidden(floatingSellButtonHidden, animated: true)
                }
            }
        }
    }
    
    public func productListView(productListView: ProductListView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let productVM = productListView.productViewModelForProductAtIndex(indexPath.row)
        let vc = ProductViewController(viewModel: productVM)
        navigationController?.pushViewController(vc, animated: true)
    }    
    
    // MARK: - ProductListViewScrollDelegate
    public func productListView(productListView: ProductListView, didScrollDown scrollDown: Bool) {
        if self.tagsViewController.tags.isEmpty {
            //Nothing to do, tags are not showing
            return
        }
        
        showTagsView(!scrollDown)
    }
    
    // MARK: - MainProductsViewModelDelegate
    
    public func mainProductsViewModel(viewModel: MainProductsViewModel, didSearchWithViewModel searchViewModel: MainProductsViewModel) {

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
    
    func mainProductsViewModelRefresh(viewModel: MainProductsViewModel, withCategories categories: [ProductCategory]?, sortCriteria: ProductSortCriteria?, distanceRadius: Int?, distanceType: DistanceType?){
        mainProductListView.categories = categories
        mainProductListView.sortCriteria = sortCriteria
        mainProductListView.distanceRadius = distanceRadius
        mainProductListView.distanceType = distanceType
        mainProductListView.refresh()
    }

    func endEdit() {
        cancelSearchOverlayButton?.removeFromSuperview()
        cancelSearchOverlayButton = nil

        showInfoBubble(true)

        setLetGoRightButtonsWithImageNames(["ic_filters"], andSelectors: ["filtersButtonPressed:"])

        guard let searchField = searchTextField else {
            return
        }

        searchField.endEdit()
    }
    
    func beginEdit() {
        
        if cancelSearchOverlayButton != nil {
            return
        }
        
        viewModel.searchBegan()
        
        showInfoBubble(false)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel , target: self, action: "endEdit")
        
        let blur = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let searchOverlayView = UIVisualEffectView(effect: blur)
        
        cancelSearchOverlayButton = UIButton(frame: mainProductListView.bounds)
        cancelSearchOverlayButton?.addTarget(self, action: Selector("endEdit"), forControlEvents: UIControlEvents.TouchUpInside)
        searchOverlayView.frame = cancelSearchOverlayButton!.bounds
        searchOverlayView.userInteractionEnabled = false
        cancelSearchOverlayButton?.insertSubview(searchOverlayView, atIndex: 0)
        
        mainProductListView.addSubview(cancelSearchOverlayButton!)
        
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
    dynamic public func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {

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
    
    /** 
        Called when the search button is pressed.
    */
    @objc private func filtersButtonPressed(sender: AnyObject) {
        
        searchTextField?.searchTextField.resignFirstResponder()
        
        // Show filters
        viewModel.showFilters()
    }
    
    private func loadTagsViewWithTags(tags: [FilterTag]) {
        
        self.tagsViewController.updateTags(tags)
        
        let showTags = tags.count > 0
        
        showTagsView(showTags)
        
        //Update tags button
        setLetGoRightButtonWithImageName(showTags ? "ic_filters_active": "ic_filters", andSelector: "filtersButtonPressed:")
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
        
        UIView.animateWithDuration(0.2, animations: {
            self.tagsCollectionTopSpace.constant = show ? 64.0 : 24.0
            self.view.layoutIfNeeded()
            }, completion: {
                (value: Bool) in
                if !show {
                    self.tagsCollectionView.hidden = true
                }
                self.tagsAnimating = false
        })
    }
    
    private func showInfoBubble(show: Bool, alpha: CGFloat? = nil) {
        distanceShadow.hidden = !viewModel.infoBubblePresent || !show
        if let alpha = alpha {
            distanceShadow.alpha = alpha
        }
    }
    
}
