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

public class MainProductsViewController: BaseViewController, IndicateLocationViewControllerDelegate, ProductListViewDataDelegate, ProductListViewLocationDelegate, MainProductsViewModelDelegate, UISearchBarDelegate, ShowProductViewControllerDelegate {

    // Constants
    private static let TooltipHidingPageCountThreshold: UInt = 4
    
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
    }

    public required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    public override func viewDidLoad() {
        super.viewDidLoad()

        // UI
        // > Main product list view
        mainProductListView.delegate = self
        mainProductListView.locationDelegate = self
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

    // MARK: - IndicateLocationViewControllerDelegate
    
    public func userDidManuallySetCoordinates(coordinates: CLLocationCoordinate2D) {
        mainProductListView.coordinates = LGLocationCoordinates2D(coordinates: coordinates)
        mainProductListView.refresh()
    }
    
    // MARK: - ProductListViewDataDelegate
    
    public func productListView(productListView: ProductListView, didStartRetrievingProductsPage page: UInt) {
    }
    
    public func productListView(productListView: ProductListView, didFailRetrievingProductsPage page: UInt, error: ProductsRetrieveServiceError) {
        
        // Notify the user setting up an alert with different message, button & button action depending if it's the first page or nexts
        let message: String
        let buttonTitle: String
        let buttonAction: () -> Void
        if page == 0 {
            message = NSLocalizedString("product_list_first_page_error_generic_label", comment: "")
            buttonTitle = NSLocalizedString("product_list_first_page_error_generic_button", comment: "")
            buttonAction = { () -> Void in
                productListView.refresh()
            }
        }
        else {
            message = NSLocalizedString("product_list_next_page_error_generic_label", comment: "")
            buttonTitle = NSLocalizedString("product_list_next_page_error_generic_button", comment: "")
            buttonAction = { () -> Void in
                productListView.retrieveProductsNextPage()
            }
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
    
    public func productListView(productListView: ProductListView, didSucceedRetrievingProductsPage page: UInt) {
        // If exceeding the page threshold, then hide the tip
        if page >= MainProductsViewController.TooltipHidingPageCountThreshold {
            if let tabBarCtl = tabBarController as? TabBarController {
                tabBarCtl.dismissTooltip(animated: true)
            }
        }
    }
    
    public func productListView(productListView: ProductListView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // TODO: Refactor when ShowProductViewController is refactored with MVVM
        let product = productListView.productAtIndex(indexPath.row)
        let vc = ShowProductViewController(product: product)
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - ProductListViewLocationDelegate
    
    public func mainProductListView(mainProductListView: MainProductListView, didFailRequestingLocationServices status: LocationServiceStatus) {
        var alertMessage: String?
        var alertButtonTitle: String?
        
        switch status {
        case .Disabled:
            alertMessage = NSLocalizedString("product_list_location_disabled_label", comment: "")
            alertButtonTitle = NSLocalizedString("product_list_location_disabled_button", comment: "")
        case .Enabled(let authStatus):
            if authStatus == .Restricted || authStatus == .Denied {
                alertMessage = NSLocalizedString("product_list_location_unauthorized_label", comment: "")
                alertButtonTitle = NSLocalizedString("product_list_location_unauthorized_button", comment: "")
            }
        }
        
        if let alertMsg = alertMessage, let alertButTitle = alertButtonTitle {
            let alert = UIAlertController(title: nil, message: alertMsg, preferredStyle:.Alert)
            alert.addAction(UIAlertAction(title: alertButTitle, style:.Default, handler: { (action) -> Void in
                UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    public func mainProductListView(mainProductListView: MainProductListView, didTimeOutRetrievingLocation timeout: NSTimeInterval) {
        // Push indicate location VC
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("indicateLocationViewController") as! IndicateLocationViewController
        vc.delegate = self
        let navCtl = UINavigationController(rootViewController: vc)
        self.navigationController?.presentViewController(navCtl, animated: true, completion: nil)
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
   
    // MARK: - ShowProductViewControllerDelegate

    func showProductViewController(viewController: ShowProductViewController, didUpdateStatusForProduct product: Product) {
        mainProductListView.refreshUI()
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
