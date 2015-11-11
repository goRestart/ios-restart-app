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

public class MainProductsViewController: BaseViewController, ProductListViewDataDelegate, MainProductsViewModelDelegate, UISearchBarDelegate {
    
    // ViewModel
    var viewModel: MainProductsViewModel!

    // UI
    @IBOutlet weak var mainProductListView: MainProductListView!
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var distanceShadow: UIView!
    
    // MARK: - Lifecycle
    
    public convenience init() {
        self.init(viewModel: MainProductsViewModel(), nibName: "MainProductsViewController")
    }
    
    public convenience init(viewModel: MainProductsViewModel) {
        self.init(viewModel: viewModel, nibName: "MainProductsViewController")
    }

    public required init(viewModel: MainProductsViewModel, nibName nibNameOrNil: String?) {
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
        
        // > Navigation bar
        self.setLetGoNavigationBarStyle(viewModel.title)
        if viewModel.hasSearchButton {
            setLetGoRightButtonsWithImageNames(["actionbar_search"], andSelectors: ["searchButtonPressed:"])
        }
        
        distanceLabel.layer.cornerRadius = 15
        distanceLabel.layer.masksToBounds = true
        distanceLabel.text = ""
        
        distanceShadow.layer.shadowColor = UIColor.blackColor().CGColor
        distanceShadow.layer.shadowOffset = CGSize(width: 0.0, height: 8.0)
        distanceShadow.layer.shadowOpacity = 0.12
        distanceShadow.layer.shadowRadius = 8.0
        distanceShadow.hidden = true
        distanceShadow.alpha = 0

    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.layoutIfNeeded()
        distanceLabel.sizeToFit()
        
        distanceLabel.preferredMaxLayoutWidth = distanceLabel.frame.size.width + 30
        
        let size = CGSize(width: distanceLabel.preferredMaxLayoutWidth, height: 30)
        
        distanceLabel.frame = CGRect(origin: CGPoint(x: -15.0, y: 0.0), size: size)
        view.layoutIfNeeded()
    }
    
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // UI
        // > Hide search bar (if showing)
        if letGoSearchBar != nil { self.dismissSearchBar(letGoSearchBar!, animated: true, searchBarCompletion: nil) }
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
    
    // MARK: - MainProductsViewModelDelegate
    
    public func mainProductsViewModel(viewModel: MainProductsViewModel, didSearchWithViewModel searchViewModel: MainProductsViewModel) {
        if let searchBar = letGoSearchBar {
            
            // Dismiss the search bar & push a new VC to look for search results
            dismissSearchBar(searchBar, animated: true) { [weak self] () -> Void in
                let vc = MainProductsViewController(viewModel: searchViewModel)
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    // MARK: - UISearchBarDelegate
    
    public func searchBar(searchBar: UISearchBar, textDidChange searchText: String)  {
        viewModel.searchString = searchText
    }
    
    public func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        dismissSearchBar(searchBar, animated: true, searchBarCompletion: nil)
    }
    
    public func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        viewModel.search()
    }
    
    // MARK: - Private methods
    
    /** 
        Called when the search button is pressed.
    */
    @objc private func searchButtonPressed(sender: AnyObject) {
        
//        // Notify the VM
//        viewModel.searchButtonPressed()
//        
//        // Show search
//        showSearchBarAnimated(true, delegate: self)
        
        //TODO: JUST FOR TESTING! REMOVE!
        FiltersViewController.presentAsSemimodalOnViewController(self)
    }
}
