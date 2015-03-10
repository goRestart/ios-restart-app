//
//  ProductListViewController.swift
//  Ambatana
//
//  Created by Ignacio Nieto Carvajal on 04/02/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

private let kAmbatanaProductListCellFactor: CGFloat = 190.0 / 145.0
private let kAmbatanaMaxWaitingTimeForLocation: NSTimeInterval = 15 // seconds

class ProductListViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, ShowProductViewControllerDelegate, UISearchBarDelegate, UIAlertViewDelegate, UIActionSheetDelegate {
    // outlets & buttons
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noProductsFoundLabel: UILabel!
    @IBOutlet weak var noProductsFoundButton: UIButton!
    @IBOutlet weak var sellButton: UIButton!
    weak var searchButton: UIButton!
    var refreshControl: UIRefreshControl!
    
    // data
    var currentKmOffset = 1
    var currentProductOffset = 0
    var alreadyRetrievedProductIds: [String] = []
    var productToShow: PFObject?
    
    var lastRetrievedProductsCount = kAmbatanaProductListOffsetLoadingOffsetInc
    var queryingProducts = false
    var currentCategory: ProductListCategory?
    var currentSearchString: String?
    
    var entries: [PFObject] = []
    var cellSize = CGSizeMake(145.0, 190.0)
    var lastContentOffset: CGFloat = 0.0
    
    var unableToRetrieveLocationTimer: NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // cell size
        let cellWidth = kAmbatanaFullScreenWidth * 0.45 // width/2.0 (2 cells per row) - 0.5*width(span)*2 cells
        //let cellWidth = (kAmbatanaFullScreenWidth - (3*kAmbatanaProductCellSpan)) / 2.0 (margen más fino).
        let cellHeight = cellWidth * kAmbatanaProductListCellFactor
        cellSize = CGSizeMake(cellWidth, cellHeight)
        
        // add a pull to refresh control
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: translate("pull_to_refresh"))
        self.refreshControl.addTarget(self, action: "refreshProductList", forControlEvents: UIControlEvents.ValueChanged)
        self.collectionView.addSubview(refreshControl)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        hideNoProductsFoundInterface()
        
        // Navigation bar & items
        self.setAmbatanaNavigationBarStyle(title: currentCategory?.getName() ?? UIImage(named: "actionbar_logo"), includeBackArrow: currentCategory != nil || currentSearchString != nil)
        self.setAmbatanaRightButtonsWithImageNames(["actionbar_search", "actionbar_filter"], andSelectors: ["searchProduct", "showFilters"])

        // Ambatana issue #2. Menu should only be visible from the main screen. Disable sliding unless we are the only active vc.
        let vcNumber = self.navigationController?.viewControllers.count
        if vcNumber == 1 { // I am the first, main view controller
            self.findHamburguerViewController()?.gestureEnabled = true // enable sliding.
        } else { self.findHamburguerViewController()?.gestureEnabled = false } // otherwise, don't allow the pan gesture.
        println("Gesture enabled? \(self.findHamburguerViewController()?.gestureEnabled)")        

        // register for notifications.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "unableSetLocation:", name: kAmbatanaUnableToSetUserLocationNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "unableGetLocation:", name: kAmbatanaUnableToGetUserLocationNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userLocationReady:", name: kAmbatanaUserLocationSuccessfullySetNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userLocationUpdated:", name: kAmbatanaUserLocationSuccessfullyChangedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "dynamicTypeChanged", name: UIContentSizeCategoryDidChangeNotification, object: nil)
        
        // check current location status.
        if (CLLocationCoordinate2DIsValid(LocationManager.sharedInstance.lastRegisteredLocation)) { // we have a valid registered location.
            if entries.count > 0 { disableLoadingInterface() } // we have some entries, so show them.
            else { enableLoadingInterface(); queryProducts() } // query entries from Parse.
        } else { // we need a location.
            enableLoadingInterface()
            if (!LocationManager.sharedInstance.updatingLocation) { // if we are not already updating our location...
                if (LocationManager.sharedInstance.appIsAuthorizedToUseLocationServices()) { // ... and we have permission for updating it.
                    // enable a timer to fallback
                    unableToRetrieveLocationTimer = NSTimer.scheduledTimerWithTimeInterval(kAmbatanaMaxWaitingTimeForLocation, target: self, selector: "unableGetLocation:", userInfo: NSNotification(name: kAmbatanaUnableToGetUserLocationNotification, object: nil), repeats: false)
                    // update our location.
                    LocationManager.sharedInstance.startUpdatingLocation()
                } else { // segue to ask user about his/her location directly
                    self.performSegueWithIdentifier("IndicateLocation", sender: nil)
                }
            } else { // else we just wait for the notification to arrive.
                // enable a timer to fallback
                if unableToRetrieveLocationTimer == nil {
                    unableToRetrieveLocationTimer = NSTimer.scheduledTimerWithTimeInterval(kAmbatanaMaxWaitingTimeForLocation, target: self, selector: "unableGetLocation:", userInfo: NSNotification(name: kAmbatanaUnableToGetUserLocationNotification, object: nil), repeats: false)
                }
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        // disable menu
        self.findHamburguerViewController()?.gestureEnabled = false
        println("Gesture enabled? \(self.findHamburguerViewController()?.gestureEnabled)")
        // hide search bar (if showing)
        if ambatanaSearchBar != nil { self.dismissSearchBar(ambatanaSearchBar!, animated: true, searchBarCompletion: nil) }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Button actions.
    
    @IBAction func toggleMenu(sender: AnyObject) {
        // clear edition & dismiss keyboard
        self.view.endEditing(true)
        self.findHamburguerViewController()?.view.endEditing(true)
        
        // open menu
        self.findHamburguerViewController()?.showMenuViewController()
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
        let productName = productObject["name"] as? String ?? ""
        if let nameLabel = cell.viewWithTag(1) as? UILabel {
            nameLabel.text = productName
            nameLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        }
        // price
        if let priceLabel = cell.viewWithTag(2) as? UILabel {
            priceLabel.hidden = true
            if let price = productObject["price"] as? Double {
                let currencyString = productObject["currency"] as? String ?? CurrencyManager.sharedInstance.defaultCurrency.iso4217Code
                if let currency = CurrencyManager.sharedInstance.currencyForISO4217Symbol(currencyString) {
                    priceLabel.text = currency.formattedCurrency(price)
                    priceLabel.hidden = false
                } else { // fallback to just price.
                    priceLabel.text = "\(price)"
                    priceLabel.hidden = false
                }
                let boldBodyDescriptor = UIFontDescriptor.preferredFontDescriptorWithTextStyle(UIFontTextStyleBody).fontDescriptorWithSymbolicTraits(.TraitBold)
                priceLabel.font = UIFont(descriptor: boldBodyDescriptor, size: 0.0)
            }
        }
        
        // image
        // TODO: Implement a image cache for images...?
        if let imageView = cell.viewWithTag(3) as? UIImageView {
            // clean image first
            imageView.image = nil
            imageView.setNeedsDisplay()
            
            // get image from object
            if productObject[kAmbatanaProductFirstImageKey] != nil {
                let imageFile = productObject[kAmbatanaProductFirstImageKey] as PFFile
                // if processed == true, we try to retrieve the previously generated thumbnail images.
                var useThumbnails = false
                if let processed = productObject["processed"] as? Bool {
                    useThumbnails = processed
                }
                
                if useThumbnails { // can we try to download the image from the generated thumbnail?
                    let thumbnailURL = ImageManager.sharedInstance.calculateThumnbailImageURLForProductImage(productObject.objectId, imageURL: imageFile.url)
                    ImageManager.sharedInstance.retrieveImageFromURLString(thumbnailURL, completion: { (success, image) -> Void in
                        if success {
                            imageView.image = image
                            imageView.contentMode = .ScaleAspectFill
                            imageView.clipsToBounds = true
                        } else { // failure, fallback to parse PFFile for the image.
                            self.retrieveImageFile(imageFile, andAssignToImageView: imageView)
                        }
                    })
                } else { // stick to the Parse big fat old image...
                    self.retrieveImageFile(imageFile, andAssignToImageView: imageView)
                }
            }
        }
        
        // distance
        // TODO: Check if there's a better way of getting the distance in km. Maybe in the query?
        if let distanceLabel = cell.viewWithTag(4) as? UILabel {
            if let productGeoPoint = productObject["gpscoords"] as? PFGeoPoint {
                let distance = productGeoPoint.distanceInKilometersTo(PFUser.currentUser()["gpscoords"] as PFGeoPoint)
                if distance > 1.0 { distanceLabel.text = NSString(format: "%.1fK", distance) }
                else {
                    let metres: Int = Int(distance * 1000)
                    if metres > 1 { distanceLabel.text = NSString(format: "%dM", metres) }
                    else { distanceLabel.text = translate("here") }
                }
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
    
    func retrieveImageFile(imageFile: PFFile, andAssignToImageView imageView: UIImageView) {
        ImageManager.sharedInstance.retrieveImageFromParsePFFile(imageFile, completion: { (success, image) -> Void in
            if success {
                imageView.image = image
                imageView.contentMode = .ScaleAspectFill
                imageView.clipsToBounds = true
            }
        }, andAddToCache: true)
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
            var query = PFQuery(className: "Products")
            
            // current distance below currentKmOffset kms.
            query.whereKey("gpscoords", nearGeoPoint: userGeo, withinKilometers: Double(currentKmOffset))
            
            // do not include approval pending items or discarded items
            query.whereKey("status", notContainedIn: [ProductStatus.Discarded.rawValue, ProductStatus.Pending.rawValue])
            
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
            
            // search only in category (if set...)
            if currentCategory != nil { // if we have specified a category, retrieve only items in that category.
                query.whereKey("category_id", equalTo: currentCategory!.rawValue)
            }
            
            // search for name or description containing search string (if set...)
            if currentSearchString != nil {
                let nameQuery = PFQuery(className: "Products")
                nameQuery.whereKey("name", matchesRegex: currentSearchString, modifiers: "i")
                let descriptionQuery = PFQuery(className: "Products")
                descriptionQuery.whereKey("description", matchesRegex: currentSearchString, modifiers: "i")
                let innerQuery = PFQuery.orQueryWithSubqueries([nameQuery, descriptionQuery])
                query.whereKey("objectId", matchesKey: "objectId", inQuery: innerQuery)
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
                    if iOSVersionAtLeast("8.0") {
                        let alert = UIAlertController(title: translate("error"), message: translate("unable_get_products"), preferredStyle:.Alert)
                        alert.addAction(UIAlertAction(title: translate("try_again"), style:.Default, handler: { (action) -> Void in
                            self.queryingProducts = false
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
                                self.queryProducts()
                            })
                        }))
                        self.presentViewController(alert, animated: true, completion: nil)
                    } else {
                        let alert = UIAlertView(title: translate("error"), message: translate("unable_get_products"), delegate: self, cancelButtonTitle: translate("try_again"))
                        alert.show()
                    }
                    
                }
                // if refresh control was used, release it
                self.refreshControl.endRefreshing()
            })
        }
    }
    
    func refreshProductList() {
        self.queryProducts(force: true)
    }
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) { // Error: unable to get products message. Try again tries to reload the products until success.
        self.queryingProducts = false
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
            self.queryProducts()
        })
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
            spvc.delegate = self
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

    func dynamicTypeChanged() {
        self.collectionView.reloadSections(NSIndexSet(index: 0))
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
    
    // MARK: - UISearchBarDelegate methods
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        dismissSearchBar(searchBar, animated: true, searchBarCompletion: nil)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let searchString = searchBar.text
        dismissSearchBar(searchBar, animated: true) { () -> Void in
            // analyze search string
            if searchString != nil && countElements(searchString) > 0 {
                let newProductListVC = self.storyboard?.instantiateViewControllerWithIdentifier("productListViewController") as ProductListViewController
                newProductListVC.currentSearchString = searchString
                self.navigationController?.pushViewController(newProductListVC, animated: true)
            }
        }
        
    }
    
    // MARK: - UIBarButtonItems actions
    
    func searchProduct() {
        showSearchBarAnimated(true, delegate: self)
    }

    func conversations() {
        performSegueWithIdentifier("Conversations", sender: nil)
    }
    
    func showFilters() {
        if iOSVersionAtLeast("8.0") {
            let alert = UIAlertController(title: translate("order_by"), message: nil, preferredStyle: .ActionSheet)
            alert.addAction(UIAlertAction(title: translate("cancel"), style: .Cancel, handler: nil))
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
            
        } else { // iOS 7 fallback
            let actionSheet = UIActionSheet(title: translate("order_by"), delegate: self, cancelButtonTitle: translate("cancel"), destructiveButtonTitle: nil)
            actionSheet.addButtonWithTitle(translate("latest_published"))
            actionSheet.addButtonWithTitle(translate("highest_price"))
            actionSheet.addButtonWithTitle(translate("lowest_price"))
            actionSheet.addButtonWithTitle(translate("proximity"))
            actionSheet.showInView(self.view)
        }
    }
    
    // filter selection for iOS 7 action sheet.
    func actionSheet(actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {
        switch (buttonIndex) {
        case 0:
            break;
        case 1:
            self.changeFilterTo("createdAt", order: .OrderedDescending)
        case 2:
            self.changeFilterTo("price", order: .OrderedDescending)
        case 3:
            self.changeFilterTo("price", order: .OrderedAscending)
        case 4:
            self.changeFilterTo(nil, order: .OrderedDescending)
        default:
            break
        }
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

    // MARK: - ShowProductViewControllerDelegate methods
    
    // update status of a product (i.e: if it gets marked as sold).
    func ambatanaProduct(product: PFObject, statusUpdatedTo newStatus: ProductStatus) {
        if let found = find(entries, product) {
            entries[found]["status"] = newStatus.rawValue
            collectionView.reloadSections(NSIndexSet(index: 0))
        }
    }
    
}

