//
//  ProductsViewController.swift
//  letgo
//
//  Created by AHL on 3/5/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import CoreLocation
import LGCoreKit
import UIKit

class ProductsViewController: UIViewController, CHTCollectionViewDelegateWaterfallLayout, ProductsViewModelDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // Constants
    private static let cellAspectRatio: CGFloat = 210.0 / 160.0
    private static let cellWidth: CGFloat = UIScreen.mainScreen().bounds.size.width * 0.5
    
    private static let itemsPercentagePaging: Float = 0.9    // when we should start ask for a new page
    
    // Enums
    private enum UIState {
        case Loading, Loaded, Refreshing, Paging, NoProducts
    }
    
    // ViewModel
    var viewModel: ProductsViewModel!
    
    // UI
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var refreshControl: UIRefreshControl!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var noProductsFoundLabel: UILabel!
    @IBOutlet weak var reloadButton: UIButton!
    
    @IBOutlet weak var sellButton: UIButton!
    
    private var defaultCellSize: CGSize!
    
    // MARK: Lifecycle
    
    convenience init() {
        self.init(viewModel: ProductsViewModel())
    }
    
    init(viewModel: ProductsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "ProductsViewController", bundle: nil)
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // ViewModel
        self.viewModel.delegate = self
        
        // UI
        // cell size
        let cellHeight = ProductsViewController.cellWidth * ProductsViewController.cellAspectRatio
        defaultCellSize = CGSizeMake(ProductsViewController.cellWidth, cellHeight)
        
        // collection view.
        var layout = CHTCollectionViewWaterfallLayout()
        layout.minimumColumnSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        self.collectionView.autoresizingMask = UIViewAutoresizing.FlexibleHeight // | UIViewAutoresizing.FlexibleWidth
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.collectionViewLayout = layout
        
        // add a pull to refresh control
        self.refreshControl = UIRefreshControl()
        //self.refreshControl.attributedTitle = NSAttributedString(string: translate("pull_to_refresh"))
        self.refreshControl.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.collectionView.addSubview(refreshControl)
        
        // register ProductCell
        let cellNib = UINib(nibName: "ProductCell", bundle: nil)
        self.collectionView.registerNib(cellNib, forCellWithReuseIdentifier: "ProductCell")
        
        setUIState(.Loading)
        refresh()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        // appearance
//        if self.currentSearchString == nil {
//            self.noProductsFoundLabel.text = translate("be_the_first_to_start_selling")
//            self.noProductsFoundButton.setTitle(translate("sell_something"), forState: .Normal)
//        } else {
//            self.noProductsFoundLabel.text = translate("no_products_found")
//            self.noProductsFoundButton.setTitle(translate("reload_products"), forState: .Normal)
//        }
//        hideNoProductsFoundInterface()
        
        // Toggle menu
        let menuButton = UIBarButtonItem(image: UIImage(named: "actionbar_burger"), style: .Plain, target: self, action: Selector("toggleMenu:"))
        menuButton.tintColor = UIColor.blackColor()
        self.navigationItem.leftBarButtonItem = menuButton
        
        // Navigation bar & items
        self.setLetGoNavigationBarStyle(title: UIImage(named: "actionbar_logo"), includeBackArrow: false)
//        self.setLetGoNavigationBarStyle(title: currentCategory?.getName() ?? UIImage(named: "actionbar_logo"), includeBackArrow: currentCategory != nil || currentSearchString != nil)
//        if let searchString = currentSearchString {
//            setLetGoRightButtonsWithImageNames(["actionbar_chat"], andSelectors: ["conversations"], badgeButtonPosition: 0)
//        }
//        else {
            setLetGoRightButtonsWithImageNames(["actionbar_search", "actionbar_chat"], andSelectors: ["searchProduct", "conversations"], badgeButtonPosition: 1)
//        }
        
        // Menu should only be visible from the main screen. Disable sliding unless we are the only active vc.
        let vcNumber = self.navigationController?.viewControllers.count
        if vcNumber == 1 { // I am the first, main view controller
            self.findHamburguerViewController()?.gestureEnabled = true // enable sliding.
        } else { self.findHamburguerViewController()?.gestureEnabled = false } // otherwise, don't allow the pan gesture.
        
//        // register for notifications.
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "unableSetLocation:", name: kLetGoUnableToSetUserLocationNotification, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "unableGetLocation:", name: kLetGoUnableToGetUserLocationNotification, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userLocationReady:", name: kLetGoUserLocationSuccessfullySetNotification, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userLocationUpdated:", name: kLetGoUserLocationSuccessfullyChangedNotification, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "dynamicTypeChanged", name: UIContentSizeCategoryDidChangeNotification, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logoutImminent", name: kLetGoLogoutImminentNotification, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "badgeChanged:", name: kLetGoUserBadgeChangedNotification, object: nil)
        
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
//        // tracking
//        TrackingManager.sharedInstance.trackEvent(kLetGoTrackingEventNameProductList, eventParameters: self.getPropertiesForProductListTracking())
//        TrackingManager.sharedInstance.trackEvent(kLetGoTrackingEventNameScreenPrivate, eventParameters: [kLetGoTrackingParameterNameScreenName: "product-list"])
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        // disable menu
        self.findHamburguerViewController()?.gestureEnabled = false
//        // hide search bar (if showing)
//        if letGoSearchBar != nil { self.dismissSearchBar(letGoSearchBar!, animated: true, searchBarCompletion: nil) }
    }
    
    // MARK: - Private methods
    
    // MARK: > UI
    
    private func setUIState(state: UIState) {
        switch (state) {
        case .Loading:
            activityIndicator.startAnimating()
            collectionView.hidden = true
            refreshControl.endRefreshing()
            noProductsFoundLabel.hidden = true
            reloadButton.hidden = true
        case .Refreshing:
            activityIndicator.stopAnimating()
            collectionView.hidden = false
            noProductsFoundLabel.hidden = true
            reloadButton.hidden = true
        case .Loaded:
            activityIndicator.stopAnimating()
            collectionView.hidden = false
            refreshControl.endRefreshing()
            noProductsFoundLabel.hidden = true
            reloadButton.hidden = true
        case .Paging:
            activityIndicator.stopAnimating()
            collectionView.hidden = false
            refreshControl.endRefreshing()
            noProductsFoundLabel.hidden = true
            reloadButton.hidden = true
        case .NoProducts:
            activityIndicator.stopAnimating()
            collectionView.hidden = true
            refreshControl.endRefreshing()
            noProductsFoundLabel.hidden = false
            reloadButton.hidden = false
            
        }
//        InitialLoading, Loading, Paging, NoProducts
    }
    
    // MARK: > Actions
    
    func toggleMenu(sender: UIBarButtonItem) {
        // clear edition & dismiss keyboard
        self.view.endEditing(true)
        self.findHamburguerViewController()?.view.endEditing(true)
        
        // open menu
        self.findHamburguerViewController()?.showMenuViewController()
    }
    
    func refresh() {
        // reset query values
//        collectionView.userInteractionEnabled = false
//        self.resetQueryValues()

        let coordinates = LGLocationCoordinates2D(latitude: 41.404819, longitude: 2.154288)
        viewModel.retrieveProductsWithQueryString(nil, coordinates: coordinates, categoryIds: nil, sortCriteria: nil, maxPrice: nil, minPrice: nil, userObjectId: nil)
        // perform query
//        self.queryProducts(force: false)
    }

    // MARK: - ProductsViewModelDelegate
    
    func didSucceedRetrievingFirstPageProductsAtIndexPaths(indexPaths: [NSIndexPath]) {
        collectionView.reloadSections(NSIndexSet(index: 0))
        setUIState(.Loaded)
    }

    func didFailRetrievingFirstPageProducts(error: NSError) {
        
    }
    
    func didSucceedRetrievingNextPageProductsAtIndexPaths(indexPaths: [NSIndexPath]) {
        self.collectionView.insertItemsAtIndexPaths(indexPaths)
    }

    func didFailRetrievingNextPageProducts(error: NSError) {
        
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        // calculate size
//        let selectedProduct = self.entries[indexPath.row]
//        if let thumbnailSize = selectedProduct.thumbnailSize {
//            if thumbnailSize.height != 0 && thumbnailSize.width != 0 {
//                let thumbFactor = thumbnailSize.height / thumbnailSize.width
//                var baseSize = defaultCellSize
//                baseSize.height = max(kLetGoMinProductListCellHeight, round(baseSize.height * thumbFactor))
//                return baseSize
//            }
//        }
        return defaultCellSize
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, columnCountForSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfProducts
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ProductCell", forIndexPath: indexPath) as! ProductCell
        
//        if entries.count == 0 { return cell } // safety check for p2r
        let product = viewModel.productAtIndex(indexPath.row)
        
        cell.tag = indexPath.hash
        cell.setupCellWithPartialProduct(product, indexPath: indexPath)
//        cell.setupCellWithLetGoProduct(product, indexPath: indexPath)
        
//        // If we are close to the end (last cells) query the next products...
        let threshold = Int(Float(viewModel.numberOfProducts) * ProductsViewController.itemsPercentagePaging)
        if indexPath.row >= threshold {
            viewModel.retrieveProductsNextPage()
        }
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.view.userInteractionEnabled = false
        self.showLoadingMessageAlert()
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
    }

}
