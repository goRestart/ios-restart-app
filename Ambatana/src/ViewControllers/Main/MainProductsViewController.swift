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

public class MainProductsViewController: BaseViewController, ProductListViewDataDelegate, MainProductsViewModelDelegate, FilterTagsViewControllerDelegate, UITextFieldDelegate {
    
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
    // MARK: - Lifecycle
    
    public convenience init() {
        self.init(viewModel: MainProductsViewModel(), nibName: "MainProductsViewController")
    }
    
    public convenience init(viewModel: MainProductsViewModel) {
        self.init(viewModel: viewModel, nibName: "MainProductsViewController")
    }

    public required init(viewModel: MainProductsViewModel, nibName nibNameOrNil: String?) {
        print(viewModel.searchString)
        self.searchTextField = (viewModel.title == nil) ? LGNavBarSearchField.setupNavBarSearchFieldWithText(viewModel.searchString) : nil
        
        super.init(viewModel: viewModel, nibName: nibNameOrNil)
        self.viewModel = viewModel
        viewModel.delegate = self
        
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
        mainProductListView.delegate = self
        mainProductListView.queryString = viewModel.searchString
        
        if let category = viewModel.category {
            mainProductListView.categories = [category]
        }

        addSubview(mainProductListView)
        

        let rightItems = setLetGoRightButtonsWithImageNames(["ic_filters"], andSelectors: ["filtersButtonPressed:"])
        
        
        if let categoryTitle = viewModel.title as? String {
            self.setLetGoNavigationBarStyle(categoryTitle)
        } else {
            // Add search text field
            
            if let searchField = searchTextField {
                
                let navBarLeftItemsCount = (self.navigationController?.viewControllers[0] == self) ? CGFloat(0) : CGFloat(1)
                let navBarRightItemsCount = CGFloat(rightItems.count ?? 0) //CGFloat(self.navigationController?.navigationItem.rightBarButtonItems?.count ?? 0)
                let navBarWidth = self.navigationController?.navigationBar.frame.width ?? 0
                
                let navBarOcupiedSpace = (navBarLeftItemsCount + navBarRightItemsCount) * (45 + 12) // 45 = rightItems[0].frame.width
                let textFieldWidth = navBarWidth - navBarOcupiedSpace
                let xPosition = 12 + (self.navigationController?.navigationItem.leftBarButtonItem?.width ?? 0) // 12 + navBarLeftItemsCount * 60 ????????
                
                searchField.frame = CGRectMake(xPosition, 5, textFieldWidth, 30)
                searchField.searchTextField.delegate = self
                setLetGoNavigationBarStyle(searchField)
            }
        }
        
        distanceLabel.text = ""
        
        distanceShadow.layer.cornerRadius = 15
        distanceShadow.layer.shadowColor = UIColor.blackColor().CGColor
        distanceShadow.layer.shadowOffset = CGSize(width: 0.0, height: 8.0)
        distanceShadow.layer.shadowOpacity = 0.12
        distanceShadow.layer.shadowRadius = 8.0
        distanceShadow.hidden = true
        distanceShadow.alpha = 0

        //Filter tags
        tagsViewController = FilterTagsViewController(collectionView: self.tagsCollectionView)
        tagsViewController.delegate = self
        loadTagsViewWithTags(viewModel.tags)
    }

    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
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
        let distanceString = String(format: "%d %@", arguments: [min(Constants.productListMaxDistanceLabel, distance), type.string])
        if distance <= Constants.productListMaxDistanceLabel {
            distanceLabel.text = String(format: LGLocalizedString.productDistanceXFromYou, distanceString)
        } else {
            distanceLabel.text = String(format: LGLocalizedString.productDistanceMoreThanFromYou, distanceString)
        }
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

        // If we already have data then show an alert
        if hasProducts {
            let message = LGLocalizedString.commonErrorConnectionFailed
            if page == 0 {
                showAutoFadingOutMessageAlert(message)
            }
            else {
                let buttonTitle = LGLocalizedString.commonErrorRetryButton
                let buttonAction = { () -> Void in
                    productListView.retrieveProductsNextPage()
                }
                let alert = UIAlertController(title: nil, message: message, preferredStyle:.Alert)
                alert.addAction(UIAlertAction(title: buttonTitle, style:.Default, handler: { [weak self] (action) -> Void in
                    if let _ = self {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
                            buttonAction()
                        })
                    }
                    }))
                presentViewController(alert, animated: true, completion: nil)
            }
        }
        
        // Update distance label visibility
        distanceShadow.hidden = !hasProducts
        distanceShadow.alpha = hasProducts ? 1:0

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
        
        // Update distance label visibility
        distanceShadow.hidden = !hasProducts
        distanceShadow.alpha = hasProducts ? 1:0

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
    
    // TODO: delete method if finally product list view is not the one to decide if search field loses focus
    public func productListViewShouldResignSearch(productListView: ProductListView) {
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

    func endEdit() {
        cancelSearchOverlayButton?.removeFromSuperview()
        cancelSearchOverlayButton = nil

        distanceLabel.hidden = false

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
        
        distanceLabel.hidden = true
        
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
        
        // Notify the VM
        viewModel.searchButtonPressed()
        
        searchTextField?.searchTextField.resignFirstResponder()
        
        // Show filters
        viewModel.showFilters()
    }
    
    private func loadTagsViewWithTags(tags: [FilterTag]) {
        
        self.tagsViewController.updateTags(tags)
        
        let showTags = tags.count > 0
        
        if showTags {
            self.tagsCollectionView.hidden = false
        }
        
        UIView.animateWithDuration(0.2, animations: {
            self.tagsCollectionTopSpace.constant = showTags ? 64.0 : 14.0
            self.view.layoutIfNeeded()
            }, completion: {
                (value: Bool) in
                if !showTags {
                    self.tagsCollectionView.hidden = true
                }
        })
    }
    
    
}
