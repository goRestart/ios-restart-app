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

class ProductsViewController: BaseViewController, IndicateLocationViewControllerDelegate, ProductListViewDataDelegate, ProductListViewLocationDelegate, ProductsViewModelDelegate, UISearchBarDelegate, ShowProductViewControllerDelegate {

//    // Enums
//    private enum UIState {
//        case Loading, Loaded, NoProducts
//    }
//    
//    // Constants
//    private static let TooltipHidingItemCountThreshold = 80
    
    // ViewModel
    var viewModel: ProductsViewModel!

    // Data
    var currentCategory: ProductCategory?
    var currentSearchString: String?
    
    // UI
    @IBOutlet weak var mainProductListView: MainProductListView!
    
    // MARK: - Lifecycle
    
    convenience init() {
        self.init(viewModel: ProductsViewModel(), nibName: "ProductsViewController")
    }

    required init(viewModel: ProductsViewModel, nibName nibNameOrNil: String?) {
        super.init(viewModel: viewModel, nibName: nibNameOrNil)
        self.viewModel = viewModel
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // ViewModel
        viewModel.delegate = self
        
        // UI
        addSubview(mainProductListView)
        mainProductListView.delegate = self
        mainProductListView.locationDelegate = self
        
        if let queryString = currentSearchString {
            mainProductListView.queryString = queryString
        }
        if let category = currentCategory {
            mainProductListView.categories = [category]
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // UI
        // > Navigation bar
        self.setLetGoNavigationBarStyle(title: currentCategory?.name() ?? UIImage(named: "navbar_logo"))

        if currentSearchString == nil {
            setLetGoRightButtonsWithImageNames(["actionbar_search"], andSelectors: ["searchButtonPressed:"])
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // UI
        // Hide search bar (if showing)
        if letGoSearchBar != nil { self.dismissSearchBar(letGoSearchBar!, animated: true, searchBarCompletion: nil) }
        
        // NSNotificationCenter
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
//    override func viewControllerDidBecomeActive(active: Bool) {
//        super.viewControllerDidBecomeActive(active)
//    }

    // MARK: - Private methods
    
    /** Called when the search button is pressed. */
    func searchButtonPressed(sender: AnyObject) {
//        // Tracking
//        TrackingHelper.trackEvent(.SearchStart, parameters: trackingParamsForEventType(.SearchStart))
        
        // Show search
        showSearchBarAnimated(true, delegate: self)
    }

//    // MARK: > Tracking
//    
//    func trackingParamsForEventType(eventType: TrackingEvent, value: AnyObject? = nil) -> [TrackingParameter: AnyObject] {
//        var properties: [TrackingParameter: AnyObject] = [:]
//        
//        // Common
//        // > current category data
//        if let category = currentCategory {
//            properties[.CategoryId] = category.rawValue
//            properties[.CategoryName] = category.name()
//        }
//        // > current user data
//        if let currentUser = MyUserManager.sharedInstance.myUser() {
//            if let userCity = currentUser.postalAddress.city {
//                properties[.UserCity] = userCity
//            }
//            if let userCountry = currentUser.postalAddress.countryCode {
//                properties[.UserCountry] = userCountry
//            }
//            if let userZipCode = currentUser.postalAddress.zipCode {
//                properties[.UserZipCode] = userZipCode
//            }
//        }
//        // > search query
//        if let actualSearchQuery = currentSearchString {
//            properties[.SearchString] = actualSearchQuery
//        }
//        
//        // ProductList
//        if eventType == .ProductList {
//            // > page number
//            properties[.PageNumber] = viewModel.pageNumber
//        }
//        
//        return properties
//    }
//    
//    
    // MARK: > Navigation
    
    func pushProductsViewControllerWithSearchQuery(searchQuery: String) {
        let vc = ProductsViewController()
        vc.currentSearchString = searchQuery
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func pushProductViewController(product: Product) {
        let vc = ShowProductViewController(product: product)
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func pushIndicateLocationViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("indicateLocationViewController") as! IndicateLocationViewController
        vc.delegate = self
        let navCtl = UINavigationController(rootViewController: vc)
        self.navigationController?.presentViewController(navCtl, animated: true, completion: nil)
    }
    
    // MARK: - IndicateLocationViewControllerDelegate
    
    func userDidManuallySetCoordinates(coordinates: CLLocationCoordinate2D) {
        mainProductListView.coordinates = LGLocationCoordinates2D(coordinates: coordinates)
        mainProductListView.refresh()
    }
    
    // MARK: - ProductListViewDataDelegate
    
    func productListView(productListView: ProductListView, didStartRetrievingProductsPage page: UInt) {
        
    }
    
    func productListView(productListView: ProductListView, didFailRetrievingProductsPage page: UInt, error: ProductsRetrieveServiceError) {
        
//            > No results
//            if self.currentSearchString == nil {
//                self.noProductsFoundLabel.text = NSLocalizedString("product_list_no_products_label", comment: "")
//                self.reloadButton.hidden = true
//            } else {
//                self.noProductsFoundLabel.text = NSLocalizedString("product_list_search_no_products_label", comment: "")
//                self.reloadButton.hidden = false
//            }
//            self.reloadButton.setTitle(NSLocalizedString("product_list_no_products_button", comment: ""), forState: .Normal)

        
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
    
    func productListView(productListView: ProductListView, didSucceedRetrievingProductsPage page: UInt) {
        if page == 0 {
            productListView.state = .DataView
        }
    }
    
    func productListView(productListView: ProductListView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        // TODO: Refactor, shouldn't be handled in here
        let product = productListView.productAtIndex(indexPath.row)
        pushProductViewController(product)
    }
    
    // MARK: - ProductListViewLocationDelegate
    
    func mainProductListView(mainProductListView: MainProductListView, didFailRequestingLocationServices status: LocationServiceStatus) {
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
    
    func mainProductListView(mainProductListView: MainProductListView, didTimeOutRetrievingLocation timeout: NSTimeInterval) {
        pushIndicateLocationViewController()
    }
    

   
    // MARK: - UISearchBarDelegate
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        dismissSearchBar(searchBar, animated: true, searchBarCompletion: nil)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        dismissSearchBar(searchBar, animated: true) { [weak self] () -> Void in
            if let strongSelf = self {
                let searchString = searchBar.text
                if searchString != nil && count(searchString) > 0 {
//                    // Tracking
//                    var parameters = strongSelf.trackingParamsForEventType(.SearchComplete)
//                    parameters[.SearchString] = searchString
//                    TrackingHelper.trackEvent(.SearchComplete, parameters: parameters)
                    
                    // Push a new products vc with the search
                    strongSelf.pushProductsViewControllerWithSearchQuery(searchString)
                }
            }
        }
    }
    
    // MARK: - LEGACY (TO REFACTOR)
    
    // MARK: ShowProductViewControllerDelegate
    
    // TODO: Refactor this...
    // update status of a product (i.e: if it gets marked as sold).
    
    func letgoProduct(productId: String, statusUpdatedTo newStatus: LetGoProductStatus) {
//        self.collectionView.reloadSections(NSIndexSet(index: 0))
    }
    
    
    
    
//    func didSucceedRetrievingFirstPageProductsAtIndexPaths(indexPaths: [NSIndexPath]) {
//        // Tracking
//        TrackingHelper.trackEvent(.ProductList, parameters: trackingParamsForEventType(.ProductList))
//    }
    
//    func didSucceedRetrievingNextPageProductsAtIndexPaths(indexPaths: [NSIndexPath]) {
//        // Tracking
//        TrackingHelper.trackEvent(.ProductList, parameters: trackingParamsForEventType(.ProductList))
//    }
}
