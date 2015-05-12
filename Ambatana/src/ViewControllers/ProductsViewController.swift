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

class ProductsViewController: BaseViewController, CHTCollectionViewDelegateWaterfallLayout, IndicateLocationViewControllerDelegate, ProductsViewModelDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, ShowProductViewControllerDelegate {

    // Enums
    private enum UIState {
        case Loading, Loaded, NoProducts
    }
    
    // ViewModel
    var viewModel: ProductsViewModel!

    // Data
    var currentCategory: LetGoProductCategory?
    var currentSearchString: String?
    
    // UI
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var refreshControl: UIRefreshControl!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var noProductsFoundLabel: UILabel!
    @IBOutlet weak var reloadButton: UIButton!
    
    @IBOutlet weak var sellButton: UIButton!
    
    // MARK: - Lifecycle
    
    convenience init() {
        self.init(viewModel: ProductsViewModel(), nibName: "ProductsViewController")
    }

    required init(viewModel: ProductsViewModel, nibName nibNameOrNil: String?) {
        super.init(viewModel: viewModel, nibName: nibNameOrNil)
        self.viewModel = viewModel
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // ViewModel
        viewModel.delegate = self
        if let queryString = currentSearchString {
            viewModel.queryString = queryString
        }
        if let category = currentCategory {
            viewModel.categoryIds = [category.rawValue]
        }
        
        // UI
        // > No results
        if self.currentSearchString == nil {
            self.noProductsFoundLabel.text = translate("be_the_first_to_start_selling")
            self.reloadButton.hidden = true
        } else {
            self.noProductsFoundLabel.text = translate("no_products_found")
            self.reloadButton.hidden = false
        }
        self.reloadButton.setTitle(translate("reload_products"), forState: .Normal)
        
        // > Collection view
        var layout = CHTCollectionViewWaterfallLayout()
        layout.minimumColumnSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        self.collectionView.autoresizingMask = UIViewAutoresizing.FlexibleHeight // | UIViewAutoresizing.FlexibleWidth
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.collectionViewLayout = layout
        
        let cellNib = UINib(nibName: "ProductCell", bundle: nil)
        self.collectionView.registerNib(cellNib, forCellWithReuseIdentifier: "ProductCell")
        
        // > Pull to refresh
        self.refreshControl = UIRefreshControl()
//        self.refreshControl.attributedTitle = NSAttributedString(string: translate("pull_to_refresh"))
        self.refreshControl.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.collectionView.addSubview(refreshControl)

        // Initial UI state is Loading (by xib)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // UI
        // > Navigation bar
        let menuButton = UIBarButtonItem(image: UIImage(named: "actionbar_burger"), style: .Plain, target: self, action: Selector("toggleMenu:"))
        menuButton.tintColor = UIColor.blackColor()
        self.navigationItem.leftBarButtonItem = menuButton
        
        self.setLetGoNavigationBarStyle(title: currentCategory?.getName() ?? UIImage(named: "actionbar_logo"), includeBackArrow: currentCategory != nil || currentSearchString != nil)
        if let searchString = currentSearchString {
            setLetGoRightButtonsWithImageNames(["actionbar_chat"], andSelectors: ["conversationsButtonPressed:"], badgeButtonPosition: 0)
        }
        else {
            setLetGoRightButtonsWithImageNames(["actionbar_search", "actionbar_chat"], andSelectors: ["searchButtonPressed:", "conversationsButtonPressed:"], badgeButtonPosition: 1)
        }
        
        // > Menu should only be visible from the main screen. Disable sliding unless we are the only active vc.
        let vcNumber = self.navigationController?.viewControllers.count
        if vcNumber == 1 { // I am the first, main view controller
            self.findHamburguerViewController()?.gestureEnabled = true // enable sliding.
        } else { self.findHamburguerViewController()?.gestureEnabled = false } // otherwise, don't allow the pan gesture.

        // NSNotificationCenter
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "dynamicTypeChanged:", name: UIContentSizeCategoryDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "badgeChanged:", name: kLetGoUserBadgeChangedNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // UI
        // Disable menu
        self.findHamburguerViewController()?.gestureEnabled = false
        // Hide search bar (if showing)
        if letGoSearchBar != nil { self.dismissSearchBar(letGoSearchBar!, animated: true, searchBarCompletion: nil) }
        
        // NSNotificationCenter
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
   
    // MARK: - Private methods
    
    // MARK: > UI
    
    /**
        Sets up the UI state.
    
        :param: state The UI state to set the view to.
    */
    private func setUIState(state: UIState) {
        switch (state) {
        case .Loading:
            let isDisplayingProducts = viewModel.numberOfProducts > 0
            if isDisplayingProducts {
                activityIndicator.stopAnimating()
                collectionView.hidden = false
                refreshControl.endRefreshing()
            }
            else {
                activityIndicator.startAnimating()
                collectionView.hidden = true
            }
            noProductsFoundLabel.hidden = true
            reloadButton.hidden = true
        case .Loaded:
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
    }
    
    // MARK: > Actions
    
    /** Called when the hamburguer menu button is pressed. */
    func toggleMenu(sender: AnyObject) {
        // clear edition & dismiss keyboard
        self.view.endEditing(true)
        self.findHamburguerViewController()?.view.endEditing(true)
        
        // open menu
        self.findHamburguerViewController()?.showMenuViewController()
    }
    
    /** Called when the reload button is pressed. */
    @IBAction func reloadButtonPressed(sender: AnyObject) {
        refresh()
    }
    
    /** Called when the sell button is pressed. */
    @IBAction func sellButtonPressed(sender: AnyObject) {
        pushSellProductViewController()
    }
    
    /** Called when the conversations button is pressed. */
    func conversationsButtonPressed(sender: AnyObject) {
        pushConversationsViewController()
    }
    
    /** Called when the search button is pressed. */
    func searchButtonPressed(sender: AnyObject) {
        showSearchBarAnimated(true, delegate: self)
    }
    
    // MARK: > Action view model interaction
    
    func refresh() {
        if viewModel.canRetrieveProducts {
            viewModel.retrieveProductsFirstPage()
        }
        else {
            refreshControl.endRefreshing()
        }
    }
    
    // MARK: > Tracking
    
    private var trackingParams: [TrackingParameter: AnyObject] {
        get {
            var properties: [TrackingParameter: AnyObject] = [:]
            
            // current category data
            if currentCategory != nil {
                properties[.CategoryId] = currentCategory!.rawValue
                properties[.CategoryName] = currentCategory!.getName()
            }
            // current user data
            if let currentUser = PFUser.currentUser() {
                if let userCity = currentUser["city"] as? String {
                    properties[.UserCity] = userCity
                }
                if let userCountry = currentUser["country_code"] as? String {
                    properties[.UserCountry] = userCountry
                }
                if let userZipCode = currentUser["zipcode"] as? String {
                    properties[.UserZipCode] = userZipCode
                }
            }
            return properties
        }
    }
    
    // MARK: > Navigation
    
    func pushProductsViewControllerWithSearchQuery(searchQuery: String) {
        let vc = ProductsViewController()
        vc.currentSearchString = searchQuery
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func pushProductViewController(product: PFObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("showProductViewController") as! ShowProductViewController
        vc.productObject = product
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func pushIndicateLocationViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("indicateLocationViewController") as! IndicateLocationViewController
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func pushConversationsViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("conversationsViewController") as! ChatListViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func pushCategoriesViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("categoriesViewController") as! CategoriesViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func pushSellProductViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("myProfileViewController") as! SellProductViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func pushEditProfileViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("editProfileViewController") as! EditProfileViewController
        vc.userObject = PFUser.currentUser()
        self.navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - NSNotificationCenter
    
    func dynamicTypeChanged(notification: NSNotification) {
        self.collectionView.reloadSections(NSIndexSet(index: 0))
    }
    
    func badgeChanged (notification: NSNotification) {
        refreshBadgeButton()
    }
    
    // MARK: - IndicateLocationViewControllerDelegate
    
    func userDidManuallySetCoordinates(coordinates: CLLocationCoordinate2D) {
        viewModel.coordinates = LGLocationCoordinates2D(coordinates: coordinates)
    }
    
    // MARK: - ProductsViewModelDelegate
    
    func didFailRequestingLocationServices(status: LocationServiceStatus) {
        var alertMessage: String?
        var alertButtonTitle: String?
        
        switch status {
        case .Disabled:
            alertMessage = translate("location_disabled_message")
            alertButtonTitle = translate("location_disabled_settings")
        case .Enabled(let authStatus):
            if authStatus == .Restricted || authStatus == .Denied {
                alertMessage = translate("location_unauthorized_message")
                alertButtonTitle = translate("location_unauthorized_settings")
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
    
    func didTimeoutRetrievingLocation() {
        pushIndicateLocationViewController()
    }
    
    func didStartRetrievingLocation() {
        setUIState(.Loading)
    }
    
    func didFailRetrievingLocation() {
        pushIndicateLocationViewController()
    }
    
    func didStartRetrievingFirstPageProducts() {
        setUIState(.Loading)
    }
    
    func didSucceedRetrievingFirstPageProductsAtIndexPaths(indexPaths: [NSIndexPath]) {
        if indexPaths.isEmpty {
            setUIState(.NoProducts)
        }
        else {
            collectionView.reloadSections(NSIndexSet(index: 0))
            setUIState(.Loaded)
        }
        
        // Tracking
        TrackingHelper.trackEvent(.ProductList, parameters: trackingParams)
    }

    func didFailRetrievingFirstPageProducts(error: NSError) {
        
        let alert = UIAlertController(title: nil, message: translate("unable_get_products"), preferredStyle:.Alert)
        alert.addAction(UIAlertAction(title: translate("try_again"), style:.Default, handler: { [weak self] (action) -> Void in
            if let strongSelf = self {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
                    strongSelf.refresh()
                })
            }
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func didStartRetrievingNextPageProducts() {
        
    }
    
    func didSucceedRetrievingNextPageProductsAtIndexPaths(indexPaths: [NSIndexPath]) {
        self.collectionView.insertItemsAtIndexPaths(indexPaths)
        
        // Tracking
        TrackingHelper.trackEvent(.ProductList, parameters: trackingParams)
    }

    func didFailRetrievingNextPageProducts(error: NSError) {
        
        let alert = UIAlertController(title: nil, message: translate("unable_get_products"), preferredStyle:.Alert)
        alert.addAction(UIAlertAction(title: translate("try_again"), style:.Default, handler: { [weak self] (action) -> Void in
            if let strongSelf = self {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
                    strongSelf.viewModel.retrieveProductsNextPage()
                })
            }
            }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return viewModel.sizeForCellAtIndex(indexPath.row)
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, columnCountForSection section: Int) -> Int {
        return viewModel.numberOfColumns
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfProducts
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let product = viewModel.productAtIndex(indexPath.row)
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ProductCell", forIndexPath: indexPath) as! ProductCell
        cell.tag = indexPath.hash
        
        // TODO: VC should not handle data -> ask to VM about title etc etc...
        cell.setupCellWithPartialProduct(product, indexPath: indexPath)
        
        viewModel.setCurrentItemIndex(indexPath.row)
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.view.userInteractionEnabled = false
        self.showLoadingMessageAlert()
        
        // TODO: Refactor product id retrieval
        if let productObjectId = viewModel.productObjectIdForProductAtIndex(indexPath.row) {
            RESTManager.sharedInstance.retrieveParseObjectWithId(productObjectId, className: "Products") { (success, productObject) -> Void in
                self.view.userInteractionEnabled = true
                self.dismissLoadingMessageAlert(completion: { [weak self] (_) -> Void in
                    if let strongSelf = self {
                        if success {
                            strongSelf.pushProductViewController(productObject!)
                        }
                        else {
                            strongSelf.showAutoFadingOutMessageAlert(translate("unable_show_product"))
                        }
                    }
                })
            }
        }
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
                    strongSelf.pushProductsViewControllerWithSearchQuery(searchString)
                }
            }
        }
    }
    
    
    // MARK: - LEGACY (TO REFACTOR)
    
    // MARK: ShowProductViewControllerDelegate
    
    // update status of a product (i.e: if it gets marked as sold).
    func letgoProduct(productId: String, statusUpdatedTo newStatus: LetGoProductStatus) {
        // @ahl: skipped feature for now...
        
//        for product in self.entries {
//            if product.objectId == productId {
//                product.status = newStatus
//                self.collectionView.reloadSections(NSIndexSet(index: 0))
//                return
//            }
//        }
    }
}
