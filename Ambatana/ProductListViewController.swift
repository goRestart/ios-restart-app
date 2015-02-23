//
//  ProductListViewController.swift
//  Ambatana
//
//  Created by Nacho on 04/02/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

private let kAmbatanaProductListCellFactor: CGFloat = 190.0 / 145.0
private let kAmbatanaMaxWaitingTimeForLocation: NSTimeInterval = 30 // seconds

class ProductListViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    // outlets & buttons
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noProductsFoundLabel: UILabel!
    @IBOutlet weak var noProductsFoundButton: UIButton!
    @IBOutlet weak var sellButton: UIButton!
    
    // data
    var currentKmOffset = 1
    var currentProductOffset = 0
    var alreadyRetrievedProductIds: [String] = []
    var productToShow: PFObject?
    
    var lastRetrievedProductsCount = kAmbatanaProductListOffsetLoadingOffsetInc
    var queryingProducts = false
    var currentCategory: ProductListCategory?
    
    var entries: [PFObject] = []
    var cellSize = CGSizeMake(145.0, 190.0)
    var lastContentOffset: CGFloat = 0.0
    
    var unableToRetrieveLocationTimer: NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // cell size
        let cellWidth = (kAmbatanaTableScreenWidth - (3*kAmbatanaProductCellSpan)) / 2.0
        let cellHeight = cellWidth * kAmbatanaProductListCellFactor
        cellSize = CGSizeMake(cellWidth, cellHeight)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        hideNoProductsFoundInterface()
    
        // Navigation bar & items
        self.setAmbatanaNavigationBarStyle(title: currentCategory?.getName() ?? UIImage(named: "actionbar_logo"), includeBackArrow: currentCategory != nil)
        self.setAmbatanaRightButtonsWithImageNames(["actionbar_search", "actionbar_chat", "actionbar_filter"], andSelectors: ["searchProduct", "conversations", "showFilters"])

        // register for notifications.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "unableSetLocation:", name: kAmbatanaUnableToSetUserLocationNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "unableGetLocation:", name: kAmbatanaUnableToGetUserLocationNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userLocationReady:", name: kAmbatanaUserLocationSuccessfullySetNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userLocationUpdated:", name: kAmbatanaUserLocationSuccessfullyChangedNotification, object: nil)
        
        // check current location status.
        if (CLLocationCoordinate2DIsValid(LocationManager.sharedInstance.lastRegisteredLocation)) { // we have a valid registered location.
            if entries.count > 0 { disableLoadingInterface() } // we have some entries, so show them.
            else { enableLoadingInterface(); queryProducts() } // query entries from Parse.
        } else { // we need a location.
            enableLoadingInterface()
            if (!LocationManager.sharedInstance.updatingLocation) { // if we are not already updating our location...
                if (LocationManager.sharedInstance.appIsAuthorizedToUseLocationServices()) { // ... and we have permission for updating it.
                    // enable a timer to fallback
                    unableToRetrieveLocationTimer = NSTimer.scheduledTimerWithTimeInterval(kAmbatanaMaxWaitingTimeForLocation, target: self, selector: "unableGetLocation:", userInfo: NSNotification(), repeats: false)
                    // update our location.
                    LocationManager.sharedInstance.startUpdatingLocation()
                } else { // segue to ask user about his/her location directly
                    self.performSegueWithIdentifier("IndicateLocation", sender: nil)
                }
            }
            // else we just wait for the notification to arrive.
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Button actions.
    
    @IBAction func toggleMenu(sender: AnyObject) {
        // clear edition & dismiss keyboard
        self.view.endEditing(true)
        self.frostedViewController?.view.endEditing(true)
        
        // open menu
        self.frostedViewController?.presentMenuViewController()
    }
    
    @IBAction func reloadProducts(sender: UIButton) {
        resetProductList()
    }
    
    @IBAction func sellNewProduct(sender: AnyObject) {
        performSegueWithIdentifier("SellProduct", sender: sender)
    }
    
    // MARK: - UICollectionViewDataSource methods
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return cellSize
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return entries.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ProductListCell", forIndexPath: indexPath) as UICollectionViewCell
        
        // configure cell
        let productObject = entries[indexPath.row]
        
        // name
        if let nameLabel = cell.viewWithTag(1) as? UILabel {
            nameLabel.text = productObject["name"] as? String ?? ""
        }
        // price
        if let priceLabel = cell.viewWithTag(2) as? UILabel {
            priceLabel.hidden = true
            if let price = productObject["price"] as? Double {
                let currencyString = productObject["currency"] as? String ?? "EUR"
                if let currency = Currency(rawValue: currencyString) {
                    priceLabel.text = currency.formattedCurrency(price)
                    priceLabel.hidden = false
                }
            }
        }
        
        // image
        // TODO: Implement a image cache for images...?
        if let imageView = cell.viewWithTag(3) as? UIImageView {
            if productObject[kAmbatanaProductFirstImageKey] != nil {
                let imageFile = productObject[kAmbatanaProductFirstImageKey] as PFFile
                imageFile.getDataInBackgroundWithBlock({ (data, error) -> Void in
                    if error == nil {
                        imageView.image = UIImage(data: data)
                        imageView.contentMode = .ScaleAspectFill
                        imageView.clipsToBounds = true
                    } else {
                        println("Unable to get image data for image \(productObject.objectId): \(error.localizedDescription)")
                    }
                })
            }
        }
        
        // distance
        // TODO: Check if there's a better way of getting the distance in km. Maybe in the query?
        if let distanceLabel = cell.viewWithTag(4) as? UILabel {
            if let productGeoPoint = productObject["gpscoords"] as? PFGeoPoint {
                let distance = productGeoPoint.distanceInKilometersTo(PFUser.currentUser()["gpscoords"] as PFGeoPoint)
                distanceLabel.text = NSString(format: "%.1fK", distance)
                distanceLabel.hidden = false
            } else { distanceLabel.hidden = true }
        }

        // status
        if let tagView = cell.viewWithTag(5) as? UIImageView { // product status
            if let statusValue = productObject["status"] as? Int {
                if let status = ProductStatus(rawValue: productObject["status"].integerValue) {
                    if (status == .Sold) {
                        tagView.image = UIImage(named: "label_sold")
                        tagView.hidden = false
                    } else if productObject.createdAt != nil && NSDate().timeIntervalSinceDate(productObject.createdAt!) < 60*60*24 {
                        tagView.image = UIImage(named: "label_new")
                        tagView.hidden = false
                    } else {
                        tagView.hidden = true
                    }
                } else { tagView.hidden = true }
            } else { tagView.hidden = true }
        }
        
        // If we are close to the end (last cells) query the next products...
        if (indexPath.row > entries.count - 3) {
            askForNextBunchOfProducts()
        }
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate methods
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.productToShow = self.entries[indexPath.row]
        if (self.productToShow != nil) { performSegueWithIdentifier("ShowProduct", sender: nil) }
        else { showAutoFadingOutMessageAlert(translate("unable_show_product")) }
    }
    
    // MARK: - Product queries.
    
    func queryProducts(force: Bool = false) {
        if queryingProducts && !force { return } // exit if already querying products
        queryingProducts = true
        
        if let userGeo = PFUser.currentUser()["gpscoords"] as? PFGeoPoint {
            // query in the products table
            let query = PFQuery(className: "Products")
            // current distance below currentKmOffset kms.
            query.whereKey("gpscoords", nearGeoPoint: userGeo, withinKilometers: Double(currentKmOffset))
            // do not include approval pending items...            
            query.whereKey("status", notEqualTo: 0)
            // ... or discarded items.
            query.whereKey("status", notEqualTo: 2)
            // paginate in groups of kAmbatanaProductListOffsetLoadingOffsetInc
            query.limit = kAmbatanaProductListOffsetLoadingOffsetInc
            // order by current filter (default, creation date).
            if ConfigurationManager.sharedInstance.currentFilterForSearch != nil {
                if (ConfigurationManager.sharedInstance.currentFilterOrderForSearch == .OrderedDescending) {
                    query.orderByDescending(ConfigurationManager.sharedInstance.currentFilterForSearch)
                } else { query.orderByAscending(ConfigurationManager.sharedInstance.currentFilterForSearch) }
            }
            // do not include currently downloaded items
            query.whereKey("objectId", notContainedIn: alreadyRetrievedProductIds)
            // filter by name (if needed).
            if (ConfigurationManager.sharedInstance.currentNameForSearch != nil) {
                query.whereKey("name", containsString: ConfigurationManager.sharedInstance.currentNameForSearch!)
            }
            // search only in category (if set...)
            if currentCategory != nil { // if we have specified a category, retrieve only items in that category.
                query.whereKey("category_id", equalTo: currentCategory!.rawValue)
            }
            
            // perform query.
            //println("Performing query with currentKmOffset=\(currentKmOffset), current offset: \(lastRetrievedProductsCount)")
            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                if error == nil { // success
                    self.queryingProducts = false
                    self.lastRetrievedProductsCount = objects.count
                    if (objects != nil && objects.count > 0) {
                        
                        // append results and register already retrieved IDs
                        var ids = ""
                        for retrievedObject in objects {
                            if let retrievedProduct = retrievedObject as? PFObject {
                                self.entries.append(retrievedProduct)
                                self.alreadyRetrievedProductIds.append(retrievedProduct.objectId)
                                ids += "\(retrievedProduct.objectId), "
                            }
                        }
                        //println("Retrieved: \(ids)")
                        //println("Retrieved: \(objects.count) objects. Currently we have loaded \(self.entries.count) products")
                        
                        // Update UI
                        self.collectionView.reloadSections(NSIndexSet(index: 0))
                        self.disableLoadingInterface()
                    } else if (objects.count == 0) { // no more items found. Time to next bunch of products.
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
                            self.askForNextBunchOfProducts()
                        })
                    }
                } else { // error
                    // TODO: Better management of this error.
                    let alert = UIAlertController(title: translate("error"), message: translate("unable_get_products"), preferredStyle:.Alert)
                    alert.addAction(UIAlertAction(title: translate("try_again"), style:.Default, handler: { (action) -> Void in
                        self.queryingProducts = false
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
                            self.queryProducts()
                        })
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })
        }
    }

    func askForNextBunchOfProducts() {
        if (self.currentKmOffset < kAmbatanaProductListMaxKmDistance) {
            if (self.lastRetrievedProductsCount == 0) {
                self.currentKmOffset = nextKmOffset(self.currentKmOffset)
            }
            queryProducts(force: false)
        } else { // at end.
            self.queryingProducts = false
            if (entries.count == 0) {
                disableLoadingInterface()
                showNoProductsFoundInterface()
            }
        }
    }
    
    func resetProductList() {
        // update UI
        enableLoadingInterface()
        hideNoProductsFoundInterface()
        
        // reset query values
        self.queryingProducts = false
        self.currentKmOffset = 1
        self.lastRetrievedProductsCount = kAmbatanaProductListOffsetLoadingOffsetInc
        self.alreadyRetrievedProductIds = []
        self.entries = []
        
        // perform query
        self.queryProducts(force: false)
    }
    
    // MARK: - Navigation & segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let spvc = segue.destinationViewController as? ShowProductViewController {
            spvc.productObject = self.productToShow
        } else if let epvc = segue.destinationViewController as? EditProfileViewController {
            epvc.userObject = PFUser.currentUser()
        }
    }
    
    // MARK: - Reacting to location notifications.
    
    func unableSetLocation(notification: NSNotification) {
        unableToRetrieveLocationTimer?.invalidate()
        unableToRetrieveLocationTimer = nil
        // ask the user to indicate the location directly
        performSegueWithIdentifier("IndicateLocation", sender: nil)
    }

    func unableGetLocation(notification: NSNotification) {
        unableToRetrieveLocationTimer?.invalidate()
        unableToRetrieveLocationTimer = nil
        // ask the user to indicate the location directly
        performSegueWithIdentifier("IndicateLocation", sender: nil)
    }

    /** (Re)load products based in last registered user location */
    func userLocationReady(notification: NSNotification) {
        unableToRetrieveLocationTimer?.invalidate()
        unableToRetrieveLocationTimer = nil
        self.queryProducts()
    }

    /** Reset product list and start query again */
    func userLocationUpdated(notification: NSNotification) {
        unableToRetrieveLocationTimer?.invalidate()
        unableToRetrieveLocationTimer = nil
        self.resetProductList()
    }
    
    func nextKmOffset(kmOffset: Int) -> Int {
        if (kmOffset <= 1) { return 5 }
        else if (kmOffset <= 5) { return 10 }
        else if (kmOffset <= 10) { return 50 }
        else if (kmOffset <= 50) { return 100 }
        else if (kmOffset <= 100) { return 500 }
        else if (kmOffset <= 500) { return 1000 }
        else if (kmOffset <= 1000) { return 5000 }
        else { return 10000 }
    }
    
    // MARK: - UI Enable/Disable
    
    func enableLoadingInterface() {
        activityIndicator.startAnimating()
        activityIndicator.hidden = false
        collectionView.hidden = true
    }
    
    func disableLoadingInterface() {
        activityIndicator.hidden = true
        activityIndicator.stopAnimating()
        collectionView.hidden = false
    }
    
    func showNoProductsFoundInterface() {
        collectionView.hidden = true
        activityIndicator.hidden = true
        activityIndicator.stopAnimating()
        noProductsFoundButton.hidden = false
        noProductsFoundLabel.hidden = false
    }
    
    func hideNoProductsFoundInterface() {
        noProductsFoundButton.hidden = true
        noProductsFoundLabel.hidden = true
    }
    
    // MARK: - UIBarButtonItems actions
    
    func searchProduct() {
        // TODO
        println("Search products!")
    }

    func conversations() {
        performSegueWithIdentifier("Conversations", sender: nil)
    }
    
    func showFilters() {
        let alert = UIAlertController(title: translate("order_by"), message: nil, preferredStyle: .ActionSheet)
        alert.addAction(UIAlertAction(title: translate("latest_published"), style: .Default, handler: { (action) -> Void in
            self.changeFilterTo("createdAt", order: .OrderedDescending)
        }))
        alert.addAction(UIAlertAction(title: translate("highest_price"), style: .Default, handler: { (action) -> Void in
            self.changeFilterTo("price", order: .OrderedDescending)
        }))
        alert.addAction(UIAlertAction(title: translate("lowest_price"), style: .Default, handler: { (action) -> Void in
            self.changeFilterTo("price", order: .OrderedAscending)
        }))
        alert.addAction(UIAlertAction(title: translate("proximity"), style: .Default, handler: { (action) -> Void in
            self.changeFilterTo(nil, order: .OrderedDescending)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func changeFilterTo(filter: String?, order: NSComparisonResult) {
        ConfigurationManager.sharedInstance.currentFilterForSearch = filter
        ConfigurationManager.sharedInstance.currentFilterOrderForSearch = order
        self.resetProductList()
    }

    // MARK: - ScrollView delegate methods
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let overflow = scrollView.contentOffset.y + scrollView.frame.size.height - scrollView.contentSize.height

        // Determine if we need to hide the sell button.
        let diff = scrollView.contentOffset.y - self.lastContentOffset
        if diff > kAmbatanaContentScrollingDownThreshold {
            UIView.animateWithDuration(0.50, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.7, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.sellButton.transform = CGAffineTransformMakeTranslation(0, 3*self.sellButton.frame.size.height)
            }, completion: nil)
        } else if diff < kAmbatanaContentScrollingUpThreshold {
            UIView.animateWithDuration(0.50, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.6, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                self.sellButton.transform = CGAffineTransformIdentity
            }, completion: nil)
        }
        self.lastContentOffset = scrollView.contentOffset.y
    }
    
    func scrollViewDidScrollToTop(scrollView: UIScrollView) {
        UIView.animateWithDuration(0.30, animations: { () -> Void in
            self.sellButton.transform = CGAffineTransformIdentity
        })
    }

}

