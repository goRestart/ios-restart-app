//
//  CategoriesViewController.swift
//  LetGo
//
//  Created by Ignacio Nieto Carvajal on 05/02/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import Parse
import UIKit

private let kLetGoCategoryCellRealImageTag = 1
private let kLetGoCategoryCellGradientImageTag = 2
private let kLetGoCategoryCellNameTag = 3
private let kLetGoCategoriesCellFactor: CGFloat = 150.0 / 160.0

class CategoriesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
    // outlets & buttons
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var sellButton: UIButton!
    var searchBar: UISearchBar!
    
    // data
    var categories: [PFObject]?
    var cellSize: CGSize = CGSize(width: 160.0, height: 150.0)
    var lastContentOffset: CGFloat = 0.0
    var selectedCategory: LetGoProductCategory?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // UX/UI & Appearance
        setLetGoNavigationBarStyle(title: translate("categories"), includeBackArrow: true)
        
        // cell size
        let cellWidth = kLetGoFullScreenWidth * 0.50
        let cellHeight = cellWidth * kLetGoCategoriesCellFactor
        cellSize = CGSizeMake(cellWidth, cellHeight)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // UX/UI & Appearance
        setLetGoRightButtonsWithImageNames(["actionbar_search", "actionbar_chat"], andSelectors: ["searchProducts", "conversations"], badgeButtonPosition: 1)
        
        // NSNotificationCenter register
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "badgeChanged:", name: kLetGoUserBadgeChangedNotification, object: nil)
        
        let initialLanguage = NSLocale.preferredLanguages().first as? String ?? kLetGoDefaultCategoriesLanguage
        // load initial categories. First try to load from the user device's language. If none found, fallback to "en".
        let allCategoriesQuery = allCategoriesQueryForLanguage(initialLanguage)
        performCategoriesQuery(allCategoriesQuery, isDefaultLanguage: initialLanguage == kLetGoDefaultCategoriesLanguage)
        
        // Tracking
        TrackingManager.sharedInstance.trackEvent(kLetGoTrackingEventNameScreenPrivate, eventParameters: [kLetGoTrackingParameterNameScreenName: "categories-list"])
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        // NSNotificationCenter deregister
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        // hide search bar (if showing)
        if letGoSearchBar != nil { self.dismissSearchBar(letGoSearchBar!, animated: true, searchBarCompletion: nil) }
    }
    
    // MARK: - UISearchBarDelegate methods
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        dismissSearchBar(searchBar, animated: true, searchBarCompletion: nil)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let searchString = searchBar.text
        dismissSearchBar(searchBar, animated: true) { () -> Void in
            // analyze search string
            if searchString != nil && count(searchString) > 0 {
                let newProductListVC = self.storyboard?.instantiateViewControllerWithIdentifier("productListViewController") as! ProductListViewController
                newProductListVC.currentSearchString = searchString
                self.navigationController?.pushViewController(newProductListVC, animated: true)
            }
        }
        
    }
    
    // MARK: - Navigation bar item actions
    
    func searchProducts() {
        showSearchBarAnimated(true, delegate: self)
    }
    
    func conversations() {
        performSegueWithIdentifier("Conversations", sender: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ProductListByCategory" {
            let plvc = segue.destinationViewController as! ProductListViewController
            plvc.currentCategory = selectedCategory
        }
    }
    
    // MARK: - Button actions
    @IBAction func sellNewProduct(sender: AnyObject) {
        performSegueWithIdentifier("SellProduct", sender: sender)
    }

    // MARK: - Queries and categories methods
    
    /**
    * Performs a query of the (favorite) categories for the current user. On failure, tries to fallback to the default language (if not on it already).
    */
    func performCategoriesQuery(query: PFQuery, isDefaultLanguage defaultLanguage: Bool) {
        query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
            if error == nil { // check if there are results for that language or we need to fallback to "en".
                if results?.count > 0 { // alright, we do have some categories for that language.
                    self.categories = results as! [PFObject]? ?? []
                    self.collectionView.reloadSections(NSIndexSet(index: 0))
                } else { // fallback
                    self.fallbackForCategoriesQuery(defaultLanguage: defaultLanguage)
                }
            } else { // error. fallback
                self.fallbackForCategoriesQuery(defaultLanguage: defaultLanguage)
            }
        }
        
    }
    
    func fallbackForCategoriesQuery(#defaultLanguage: Bool) {
        if defaultLanguage {
            self.categories = []
        } else { // we have another chance. Fallback to default language.
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.01 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                let fallbackQuery = allCategoriesQueryForLanguage(kLetGoDefaultCategoriesLanguage)
                self.performCategoriesQuery(fallbackQuery, isDefaultLanguage: true)
            }
        }
    }
    
    // MARK: - UICollectionViewDelegate & DataSource methods
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            return cellSize
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CategoriesCollectionCell", forIndexPath: indexPath) as! UICollectionViewCell
        
        if let categoryObject = categories?[indexPath.row] {
            // configure cell
            
            // category name
            if let nameLabel = cell.viewWithTag(kLetGoCategoryCellNameTag) as? UILabel {
                nameLabel.text = categoryObject["name"] as? String ?? translate("unknown")
            }
            
            // category image
            if let categoryImage = cell.viewWithTag(kLetGoCategoryCellRealImageTag) as? UIImageView {
                categoryImage.clipsToBounds = true
                // first we try to retrieve it locally.
                var imageRetrievedLocally = false
                if let categoryId = categoryObject["category_id"] as? Int {
                    if let category = LetGoProductCategory(rawValue: categoryId) {
                        if let localImage = category.imageForCategory() {
                            categoryImage.image = localImage
                            imageRetrievedLocally = true
                        }
                    }
                }
                
                // if we don't have an image for that category locally, we must retrieve it from the network using the "image" URL String from the backend.
                if !imageRetrievedLocally {
                    if let imageURLString = categoryObject["image"] as? String {
                        ImageManager.sharedInstance.retrieveImageFromURLString(imageURLString, completion: { (success, image, fromURL) -> Void in
                            if success && fromURL == imageURLString { categoryImage.image = image }
                            // TODO: else? try again?
                        })
                    }
                }
            }
        }
        
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let categoryObject = categories?[indexPath.row] {
            if let category = LetGoProductCategory(rawValue: categoryObject["category_id"] as! Int) {
                selectedCategory = category
                performSegueWithIdentifier("ProductListByCategory", sender: nil)
            }
        }
    }
    
    /*
    // MARK: - ScrollView delegate methods
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let overflow = scrollView.contentOffset.y + scrollView.frame.size.height - scrollView.contentSize.height
        
        // Determine if we need to hide the sell button.
        let diff = scrollView.contentOffset.y - self.lastContentOffset
        if diff > kLetGoContentScrollingDownThreshold {
            UIView.animateWithDuration(0.50, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.7, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.sellButton.transform = CGAffineTransformMakeTranslation(0, 3*self.sellButton.frame.size.height)
                }, completion: nil)
        } else if diff < kLetGoContentScrollingUpThreshold {
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
    */
    
    // MARK: - NSNotificationCenter
    
    func badgeChanged (notification: NSNotification) {
        refreshBadgeButton()
    }
}
