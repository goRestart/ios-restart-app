//
//  ProductListViewController.swift
//  LetGo
//
//  Created by Ignacio Nieto Carvajal on 04/02/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import Bolts
import LGCoreKit
import Parse
import UIKit

//private let kLetGoProductListCellFactor: CGFloat = 210.0 / 160.0
//private let kLetGoMaxWaitingTimeForLocation: NSTimeInterval = 15 // seconds
//private let kLetGoMinProductListCellHeight: CGFloat = 160

class ProductListViewController: UIViewController/*, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, ShowProductViewControllerDelegate, UISearchBarDelegate, UIAlertViewDelegate, UIActionSheetDelegate, CHTCollectionViewDelegateWaterfallLayout*/ {
    // outlets & buttons
//    @IBOutlet weak var collectionView: UICollectionView!
//    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
//    @IBOutlet weak var noProductsFoundLabel: UILabel!
//    @IBOutlet weak var noProductsFoundButton: UIButton!
//    @IBOutlet weak var sellButton: UIButton!
//    weak var searchButton: UIButton!
//    var refreshControl: UIRefreshControl!
//    
//    // data
//    var productToShow: PFObject?
//    var offset = 0
//    var lastRetrievedProductsCount = kLetGoProductListOffsetLoadingOffsetInc
//    var queryingProducts = false
//    var currentCategory: LetGoProductCategory?
//    var currentSearchString: String?
//    var currentFilterName = translate("proximity")
//    
//    var entries: [LetGoProduct] = []
//    var defaultCellSize = CGSizeMake(160.0, 210.0)
//    var lastContentOffset: CGFloat = 0.0
//    
//    var unableToRetrieveLocationTimer: NSTimer?
//    
//    // MARK: Lifecycle
//    
//    required init(coder aDecoder: NSCoder) {
//        let sessionManager = SessionManager.sharedInstance
//        let productsService = LGProductsService()
//        super.init(coder: aDecoder)
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // cell size
//        let cellWidth = kLetGoFullScreenWidth * 0.50
//        let cellHeight = cellWidth * kLetGoProductListCellFactor
//        defaultCellSize = CGSizeMake(cellWidth, cellHeight)
//        
//        // collection view.
//        var layout = CHTCollectionViewWaterfallLayout()
//        layout.minimumColumnSpacing = 0.0
//        layout.minimumInteritemSpacing = 0.0
//        self.collectionView.autoresizingMask = UIViewAutoresizing.FlexibleHeight // | UIViewAutoresizing.FlexibleWidth
//        self.collectionView.alwaysBounceVertical = true
//        self.collectionView.collectionViewLayout = layout
//        
//        // add a pull to refresh control
//        self.refreshControl = UIRefreshControl()
//        //self.refreshControl.attributedTitle = NSAttributedString(string: translate("pull_to_refresh"))
//        self.refreshControl.addTarget(self, action: "refreshProductList", forControlEvents: UIControlEvents.ValueChanged)
//        self.collectionView.addSubview(refreshControl)
//        
//        // register ProductCell
//        let cellNib = UINib(nibName: "ProductCell", bundle: nil)
//        self.collectionView.registerNib(cellNib, forCellWithReuseIdentifier: "ProductCell")
//    }
//    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        // appearance
//        if self.currentSearchString == nil {
//            self.noProductsFoundLabel.text = translate("be_the_first_to_start_selling")
//            self.noProductsFoundButton.setTitle(translate("sell_something"), forState: .Normal)
//        } else {
//            self.noProductsFoundLabel.text = translate("no_products_found")
//            self.noProductsFoundButton.setTitle(translate("reload_products"), forState: .Normal)
//        }
//        hideNoProductsFoundInterface()
//        
//        // Navigation bar & items
//        self.setLetGoNavigationBarStyle(title: currentCategory?.getName() ?? UIImage(named: "actionbar_logo"), includeBackArrow: currentCategory != nil || currentSearchString != nil)
//        if let searchString = currentSearchString {
//            setLetGoRightButtonsWithImageNames(["actionbar_chat"], andSelectors: ["conversations"], badgeButtonPosition: 0)
//        }
//        else {
//            setLetGoRightButtonsWithImageNames(["actionbar_search", "actionbar_chat"], andSelectors: ["searchProduct", "conversations"], badgeButtonPosition: 1)
//        }
//
//        // Menu should only be visible from the main screen. Disable sliding unless we are the only active vc.
//        let vcNumber = self.navigationController?.viewControllers.count
//        if vcNumber == 1 { // I am the first, main view controller
//            self.findHamburguerViewController()?.gestureEnabled = true // enable sliding.
//        } else { self.findHamburguerViewController()?.gestureEnabled = false } // otherwise, don't allow the pan gesture.
//
//        // register for notifications.
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "unableSetLocation:", name: kLetGoUnableToSetUserLocationNotification, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "unableGetLocation:", name: kLetGoUnableToGetUserLocationNotification, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userLocationReady:", name: kLetGoUserLocationSuccessfullySetNotification, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userLocationUpdated:", name: kLetGoUserLocationSuccessfullyChangedNotification, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "dynamicTypeChanged", name: UIContentSizeCategoryDidChangeNotification, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logoutImminent", name: kLetGoLogoutImminentNotification, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "badgeChanged:", name: kLetGoUserBadgeChangedNotification, object: nil)
//        
//        // check current location status.
//        if (CLLocationCoordinate2DIsValid(LocationManager.sharedInstance.lastRegisteredLocation)) { // we have a valid registered location.
//            if entries.count > 0 { disableLoadingInterface() } // we have some entries, so show them.
//            else { enableLoadingInterface(); queryProducts() } // query entries from Parse.
//        } else { // we need a location.
//            enableLoadingInterface()
//            if (!LocationManager.sharedInstance.updatingLocation) { // if we are not already updating our location...
//                if (LocationManager.sharedInstance.appIsAuthorizedToUseLocationServices()) { // ... and we have permission for updating it.
//                    // enable a timer to fallback
//                    unableToRetrieveLocationTimer = NSTimer.scheduledTimerWithTimeInterval(kLetGoMaxWaitingTimeForLocation, target: self, selector: "unableGetLocation:", userInfo: NSNotification(name: kLetGoUnableToGetUserLocationNotification, object: nil), repeats: false)
//                    // update our location.
//                    LocationManager.sharedInstance.startUpdatingLocation()
//                } else { // segue to ask user about his/her location directly
//                    self.performSegueWithIdentifier("IndicateLocation", sender: nil)
//                }
//            } else { // else we just wait for the notification to arrive.
//                // enable a timer to fallback
//                if unableToRetrieveLocationTimer == nil {
//                    unableToRetrieveLocationTimer = NSTimer.scheduledTimerWithTimeInterval(kLetGoMaxWaitingTimeForLocation, target: self, selector: "unableGetLocation:", userInfo: NSNotification(name: kLetGoUnableToGetUserLocationNotification, object: nil), repeats: false)
//                }
//            }
//        }
//        // Tracking
//        TrackingHelper.trackEvent(.ProductList, parameters: getPropertiesForProductListTracking())
//    }
//    
//    /** Generates the properties for the product-list tracking event. NOTE: This would probably change once Parse is not used anymore */
//    func getPropertiesForProductListTracking() -> [TrackingParameter: AnyObject] {
//        var properties: [TrackingParameter: AnyObject] = [:]
//        
//        // current category data
//        if currentCategory != nil {
//            properties[.CategoryId] = currentCategory!.rawValue ?? 0
//            properties[.CategoryName] = currentCategory!.getName() ?? "none"
//        }
//        else {
//            properties[.CategoryId] = 0
//            properties[.CategoryName] = "none"
//        }
//        // current user data
//        if let currentUser = PFUser.currentUser() {
//            if let userCity = currentUser["city"] as? String {
//                properties[.UserCity] = userCity
//            }
//            if let userCountry = currentUser["country_code"] as? String {
//                properties[.UserCountry] = userCountry
//            }
//            if let userZipCode = currentUser["zipcode"] as? String {
//                properties[.UserZipCode] = userZipCode
//            }
//        }
//        return properties
//    }
//    
//    override func viewWillDisappear(animated: Bool) {
//        super.viewWillDisappear(animated)
//        NSNotificationCenter.defaultCenter().removeObserver(self)
//        
//        // disable menu
//        self.findHamburguerViewController()?.gestureEnabled = false
//        // hide search bar (if showing)
//        if letGoSearchBar != nil { self.dismissSearchBar(letGoSearchBar!, animated: true, searchBarCompletion: nil) }
//    }
//    
//    // MARK: - Button actions.
//    
//    @IBAction func toggleMenu(sender: AnyObject) {
//        // clear edition & dismiss keyboard
//        self.view.endEditing(true)
//        self.findHamburguerViewController()?.view.endEditing(true)
//        
//        // open menu
//        self.findHamburguerViewController()?.showMenuViewController()
//    }
//    
//    @IBAction func reloadProducts(sender: UIButton) {
//        // if we are not looking for an object, then we invite the user to sell something
//        if self.currentSearchString == nil {
//            performSegueWithIdentifier("SellProduct", sender: sender)
//        } else { // else, we reload the products.
//            resetProductList()
//        }
//    }
//    
//    @IBAction func sellNewProduct(sender: AnyObject) {
//        performSegueWithIdentifier("SellProduct", sender: sender)
//    }
//    
//    // MARK: - UICollectionViewDataSource methods
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//        // calculate size
//        let selectedProduct = self.entries[indexPath.row]
//        if let thumbnailSize = selectedProduct.thumbnailSize {
//            if thumbnailSize.height != 0 && thumbnailSize.width != 0 {
//                let thumbFactor = thumbnailSize.height / thumbnailSize.width
//                var baseSize = defaultCellSize
//                baseSize.height = max(kLetGoMinProductListCellHeight, round(baseSize.height * thumbFactor))
//                return baseSize
//            }
//        }
//        return defaultCellSize
//    }
//
//    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, columnCountForSection section: Int) -> Int {
//        return 2
//    }
//
//    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return entries.count
//    }
//    
//    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
//        
//        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ProductCell", forIndexPath: indexPath) as! ProductCell
//        
//        if entries.count == 0 { return cell } // safety check for p2r
//        let product = entries[indexPath.row]
//        
//        cell.tag = indexPath.hash
//        cell.setupCellWithLetGoProduct(product, indexPath: indexPath)
//        
//        // If we are close to the end (last cells) query the next products...
//        if (indexPath.row > entries.count - 2) {
//            askForNextBunchOfProducts()
//        }
//        
//        return cell
//    }
//    
//    // MARK: - UICollectionViewDelegate methods
//    
//    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        self.view.userInteractionEnabled = false
//        self.showLoadingMessageAlert()
//        // prepare basic object
//        let selectedProduct = self.entries[indexPath.row]
//        RESTManager.sharedInstance.retrieveParseObjectWithId(selectedProduct.objectId, className: "Products") { (success, parseObject) -> Void in
//            self.view.userInteractionEnabled = true
//            self.dismissLoadingMessageAlert(completion: { (_) -> Void in
//                if success {
//                    self.productToShow = parseObject
//                    self.performSegueWithIdentifier("ShowProduct", sender: nil)
//                } else {
//                    self.showAutoFadingOutMessageAlert(translate("unable_show_product"))
//                }
//            })
//        }
//    }
//    
//    // MARK: - Product queries.
//    
//    func queryProducts(force: Bool = false) {
//        if queryingProducts && !force { return } // exit if already querying products
//        queryingProducts = true
//
//        var currentLocation = kCLLocationCoordinate2DInvalid
//        if CLLocationCoordinate2DIsValid(LocationManager.sharedInstance.lastKnownLocation) { currentLocation = LocationManager.sharedInstance.lastKnownLocation }
//        else if CLLocationCoordinate2DIsValid(LocationManager.sharedInstance.lastRegisteredLocation) { currentLocation = LocationManager.sharedInstance.lastRegisteredLocation }
//        else if let userGeo = PFUser.currentUser()?["gpscoords"] as? PFGeoPoint { currentLocation = CLLocationCoordinate2DMake(userGeo.latitude, userGeo.longitude) }
//
//        if CLLocationCoordinate2DIsValid(currentLocation) {
//            // Call to LetGo backend API.
//            let coordinates = LGLocationCoordinates2D(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
//            let accessToken: String
//            if let sessionToken = SessionManager.sharedInstance.sessionToken {
//                accessToken = sessionToken.accessToken
//            }
//            else {
//                accessToken = ""
//            }
//            var params = RetrieveProductsParams(coordinates: coordinates, accessToken: accessToken)
//            if let queryString = currentSearchString {
//                params.queryString = queryString
//            }
//            if let categoryId = currentCategory {
//                params.categoryIds = [categoryId.rawValue]
//            }
//            params.sortCriteria = .Distance
//            
//            
//            RESTManager.sharedInstance.getListOfProducts(currentSearchString, location: currentLocation, categoryId: currentCategory, sortBy: ConfigurationManager.sharedInstance.userFilterForProducts, offset: self.offset, status: nil, maxPrice: nil, distanceRadius: nil, minPrice: nil, fromUser: nil, completion: { (success, products, retrievedItems, successfullyParsedItems) -> Void in
//                if success {
//                    //println("Retrieved products: \(products)")
//                    // update counters and management variables.
//                    self.queryingProducts = false
//                    self.lastRetrievedProductsCount = retrievedItems
//                    self.offset += retrievedItems
//                    
//                    // update entries
//                    if (products != nil && successfullyParsedItems > 0) {
//                        self.entries += products!
//                        // Update UI
//                        self.collectionView.reloadSections(NSIndexSet(index: 0))
//                        self.disableLoadingInterface()
//                    } else if (products?.count == 0) { // no more items found. Time to next bunch of products.
//                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
//                            self.askForNextBunchOfProducts()
//                        })
//                    }
//                } else { // error retrieving products.
//                    if iOSVersionAtLeast("8.0") {
//                        let alert = UIAlertController(title: nil, message: translate("unable_get_products"), preferredStyle:.Alert)
//                        alert.addAction(UIAlertAction(title: translate("try_again"), style:.Default, handler: { (action) -> Void in
//                            self.queryingProducts = false
//                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
//                                self.queryProducts()
//                            })
//                        }))
//                        self.presentViewController(alert, animated: true, completion: nil)
//                    } else {
//                        let alert = UIAlertView(title: nil, message: translate("unable_get_products"), delegate: self, cancelButtonTitle: translate("try_again"))
//                        alert.show()
//                    }
//                }
//                // if refresh control was used, release it
//                self.refreshControl.endRefreshing()
//                self.collectionView.userInteractionEnabled = true
//            })
//        }
//    }
//    
//    func refreshProductList() {
//        // reset query values
//        self.collectionView.userInteractionEnabled = false
//        self.resetQueryValues()
//
//        // perform query
//        self.queryProducts(force: false)
//    }
//    
//    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) { // Error: unable to get products message. Try again tries to reload the products until success.
//        self.queryingProducts = false
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
//            self.queryProducts()
//        })
//    }
//
//    func askForNextBunchOfProducts() {
//        if self.lastRetrievedProductsCount == 0 {
//            // no entries at all?
//            if (entries.count == 0) {
//                disableLoadingInterface()
//                showNoProductsFoundInterface()
//            }
//            return
//        }
//        else {
//            queryProducts(force: false)
//        }
//    }
//    
//    func resetProductList() {
//        // update UI
//        enableLoadingInterface()
//        hideNoProductsFoundInterface()
//        
//        // perform query
//        self.resetQueryValues()
//        self.queryProducts(force: false)
//    }
//    
//    func resetQueryValues() {
//        // reset query values
//        self.queryingProducts = false
//        self.offset = 0
//        self.lastRetrievedProductsCount = kLetGoProductListOffsetLoadingOffsetInc
//        self.entries = []
//        
//    }
//    
//    
//    func logoutImminent() {
//        self.resetQueryValues()
//    }
//    
//    // MARK: - Navigation & segues
//    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if let spvc = segue.destinationViewController as? ShowProductViewController {
//            spvc.productObject = self.productToShow
//            spvc.delegate = self
//        } else if let epvc = segue.destinationViewController as? EditProfileViewController {
//            epvc.userObject = PFUser.currentUser()
//        }
//    }
//    
//    // MARK: - Reacting to location notifications.
//    
//    func unableSetLocation(notification: NSNotification) {
//        unableToRetrieveLocationTimer?.invalidate()
//        unableToRetrieveLocationTimer = nil
//        // ask the user to indicate the location directly
//        performSegueWithIdentifier("IndicateLocation", sender: nil)
//    }
//
//    func unableGetLocation(notification: NSNotification) {
//        unableToRetrieveLocationTimer?.invalidate()
//        unableToRetrieveLocationTimer = nil
//        // ask the user to indicate the location directly
//        performSegueWithIdentifier("IndicateLocation", sender: nil)
//    }
//
//    /** (Re)load products based in last registered user location */
//    func userLocationReady(notification: NSNotification) {
//        unableToRetrieveLocationTimer?.invalidate()
//        unableToRetrieveLocationTimer = nil
//        self.queryProducts()
//    }
//
//    func dynamicTypeChanged() {
//        self.collectionView.reloadSections(NSIndexSet(index: 0))
//    }
//    
//    /** Reset product list and start query again */
//    func userLocationUpdated(notification: NSNotification) {
//        unableToRetrieveLocationTimer?.invalidate()
//        unableToRetrieveLocationTimer = nil
//        self.resetProductList()
//    }
//    
//    // MARK: - UI Enable/Disable
//    
//    func enableLoadingInterface() {
//        activityIndicator.startAnimating()
//        activityIndicator.hidden = false
//        collectionView.hidden = true
//    }
//    
//    func disableLoadingInterface() {
//        activityIndicator.hidden = true
//        activityIndicator.stopAnimating()
//        collectionView.hidden = false
//    }
//    
//    func showNoProductsFoundInterface() {
//        collectionView.hidden = true
//        activityIndicator.hidden = true
//        activityIndicator.stopAnimating()
//        noProductsFoundButton.hidden = false
//        noProductsFoundLabel.hidden = false
//    }
//    
//    func hideNoProductsFoundInterface() {
//        noProductsFoundButton.hidden = true
//        noProductsFoundLabel.hidden = true
//    }
//    
//    // MARK: - UISearchBarDelegate methods
//    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
//        dismissSearchBar(searchBar, animated: true, searchBarCompletion: nil)
//    }
//    
//    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
//        let searchString = searchBar.text
//        dismissSearchBar(searchBar, animated: true) { () -> Void in
//            // analyze search string
//            if searchString != nil && count(searchString) > 0 {
//                let newProductListVC = self.storyboard?.instantiateViewControllerWithIdentifier("productListViewController") as! ProductListViewController
//                newProductListVC.currentSearchString = searchString
//                self.navigationController?.pushViewController(newProductListVC, animated: true)
//            }
//        }
//        
//    }
//    
//    // MARK: - UIBarButtonItems actions
//    
//    func searchProduct() {
//        showSearchBarAnimated(true, delegate: self)
//    }
//
//    func conversations() {
//        performSegueWithIdentifier("Conversations", sender: nil)
//    }
//    
//    func showFilters() {
//        if iOSVersionAtLeast("8.0") {
//            let alert = UIAlertController(title: translate("order_by") + ": " + self.currentFilterName, message: nil, preferredStyle: .ActionSheet)
//            alert.addAction(UIAlertAction(title: translate("cancel"), style: .Cancel, handler: nil))
//            alert.addAction(UIAlertAction(title: translate("latest_published"), style: .Default, handler: { (action) -> Void in
//                self.currentFilterName = translate("latest_published")
//                self.changeFilterTo(.CreationDate)
//            }))
//            alert.addAction(UIAlertAction(title: translate("highest_price"), style: .Default, handler: { (action) -> Void in
//                self.currentFilterName = translate("highest_price")
//                self.changeFilterTo(.MaxPrice)
//            }))
//            alert.addAction(UIAlertAction(title: translate("lowest_price"), style: .Default, handler: { (action) -> Void in
//                self.currentFilterName = translate("lowest_price")
//                self.changeFilterTo(.MinPrice)
//            }))
//            alert.addAction(UIAlertAction(title: translate("proximity"), style: .Default, handler: { (action) -> Void in
//                self.currentFilterName = translate("proximity")
//                self.changeFilterTo(.Proximity)
//            }))
//            self.presentViewController(alert, animated: true, completion: nil)
//            
//        } else { // iOS 7 fallback
//            let actionSheet = UIActionSheet(title: translate("order_by") + ": " + self.currentFilterName, delegate: self, cancelButtonTitle: translate("cancel"), destructiveButtonTitle: nil)
//            actionSheet.addButtonWithTitle(translate("latest_published"))
//            actionSheet.addButtonWithTitle(translate("highest_price"))
//            actionSheet.addButtonWithTitle(translate("lowest_price"))
//            actionSheet.addButtonWithTitle(translate("proximity"))
//            actionSheet.showInView(self.view)
//        }
//    }
//    
//    // filter selection for iOS 7 action sheet.
//    func actionSheet(actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {
//        switch (buttonIndex) {
//        case 0:
//            break;
//        case 1:
//            self.currentFilterName = translate("latest_published")
//            self.changeFilterTo(.CreationDate)
//        case 2:
//            self.currentFilterName = translate("highest_price")
//            self.changeFilterTo(.MaxPrice)
//        case 3:
//            self.currentFilterName = translate("lowest_price")
//            self.changeFilterTo(.MinPrice)
//        case 4:
//            self.currentFilterName = translate("proximity")
//            self.changeFilterTo(.Proximity)
//        default:
//            break
//        }
//    }
//    
//    /** Sets the filter based on user's selection */
//    func changeFilterTo(newFilter: LetGoUserFilterForProducts) {
//        ConfigurationManager.sharedInstance.userFilterForProducts = newFilter
//        self.resetProductList()
//    }
//
//    // MARK: - ShowProductViewControllerDelegate methods
//    
//    // update status of a product (i.e: if it gets marked as sold).
//    func letgoProduct(productId: String, statusUpdatedTo newStatus: LetGoProductStatus) {
//        for product in self.entries {
//            if product.objectId == productId {
//                product.status = newStatus
//                self.collectionView.reloadSections(NSIndexSet(index: 0))
//                return
//            }
//        }
//    }
//    
//    // MARK: - NSNotificationCenter
//    
//    func badgeChanged (notification: NSNotification) {
//        refreshBadgeButton()
//    }
}

