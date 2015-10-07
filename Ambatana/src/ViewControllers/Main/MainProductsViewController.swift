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

    public required init(coder: NSCoder) {
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
        self.setLetGoNavigationBarStyle(title: viewModel.title)
        if viewModel.hasSearchButton {
            setLetGoRightButtonsWithImageNames(["actionbar_search"], andSelectors: ["searchButtonPressed:"])
        }
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // UI
        // > Hide search bar (if showing)
        if letGoSearchBar != nil { self.dismissSearchBar(letGoSearchBar!, animated: true, searchBarCompletion: nil) }
    }

    // MARK: - ProductListViewDataDelegate
    
    public func productListView(productListView: ProductListView, didStartRetrievingProductsPage page: UInt) {
        // !!!
        if let tabBarCtl = tabBarController as? TabBarController {

            // Floating sell button should be hidden
            floatingSellButtonHidden = false
            tabBarCtl.setSellFloatingButtonHidden(floatingSellButtonHidden, animated: false)
        }
    }
    
    public func productListView(productListView: ProductListView, didFailRetrievingProductsPage page: UInt, hasProducts: Bool, error: ProductsRetrieveServiceError) {

        // If we already have data then show an alert
        if hasProducts {
            let message = NSLocalizedString("common_error_connection_failed", comment: "")
            if page == 0 {
                showAutoFadingOutMessageAlert(message)
            }
            else {
                let buttonTitle = NSLocalizedString("common_error_retry_button", comment: "")
                let buttonAction = { () -> Void in
                    productListView.retrieveProductsNextPage()
                }
                let alert = UIAlertController(title: nil, message: message, preferredStyle:.Alert)
                alert.addAction(UIAlertAction(title: buttonTitle, style:.Default, handler: { [weak self] (action) -> Void in
                    if let strongSelf = self {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
                            buttonAction()
                        })
                    }
                    }))
                presentViewController(alert, animated: true, completion: nil)
            }
        }
        
        // Floating sell button should be shown if has products
        if let tabBarCtl = tabBarController as? TabBarController {
            floatingSellButtonHidden = !hasProducts
            tabBarCtl.setSellFloatingButtonHidden(floatingSellButtonHidden, animated: false)
        }
    }
    
    public func productListView(productListView: ProductListView, didSucceedRetrievingProductsPage page: UInt) {

        // Floating sell button should be shown
        if let tabBarCtl = tabBarController as? TabBarController {
            floatingSellButtonHidden = false
            tabBarCtl.setSellFloatingButtonHidden(floatingSellButtonHidden, animated: false)
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
        
        // Notify the VM
        viewModel.searchButtonPressed()
        
        // Show search
        showSearchBarAnimated(true, delegate: self)
    }
}
