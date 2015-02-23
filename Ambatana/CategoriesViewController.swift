//
//  CategoriesViewController.swift
//  Ambatana
//
//  Created by Nacho on 05/02/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

private let kAmbatanaCategoryCellRealImageTag = 1
private let kAmbatanaCategoryCellGradientImageTag = 2
private let kAmbatanaCategoryCellNameTag = 3
private let kAmbatanaCategoriesCellFactor: CGFloat = 115.0 / 145.0

class CategoriesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    // outlets & buttons
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var sellButton: UIButton!
    
    // data
    var categories: [PFObject]?
    var cellSize: CGSize?
    var lastContentOffset: CGFloat = 0.0
    var selectedCategory: ProductListCategory?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // UX/UI & Appearance
        setAmbatanaNavigationBarStyle(title: translate("categories"), includeBackArrow: true)
        setAmbatanaRightButtonsWithImageNames(["actionbar_search", "actionbar_chat"], andSelectors: ["searchProducts", "conversations"])
        
        // cell size
        let cellWidth = (kAmbatanaTableScreenWidth - (3*kAmbatanaProductCellSpan)) / 2.0
        let cellHeight = cellWidth * kAmbatanaCategoriesCellFactor
        cellSize = CGSizeMake(cellWidth, cellHeight)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let initialLanguage = NSLocale.preferredLanguages().first as? String ?? kAmbatanaDefaultCategoriesLanguage
        // load initial categories. First try to load from the user device's language. If none found, fallback to "en".
        let allCategoriesQuery = allCategoriesQueryForLanguage(initialLanguage)
        performCategoriesQuery(allCategoriesQuery, isDefaultLanguage: initialLanguage == kAmbatanaDefaultCategoriesLanguage)
    }

    // MARK: - Navigation bar item actions
    
    func searchProducts() {
        // TODO
    }
    
    func conversations() {
        performSegueWithIdentifier("Conversations", sender: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ProductListByCategory" {
            let plvc = segue.destinationViewController as ProductListViewController
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
                    self.categories = results as [PFObject]? ?? []
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
                let fallbackQuery = allCategoriesQueryForLanguage(kAmbatanaDefaultCategoriesLanguage)
                self.performCategoriesQuery(fallbackQuery, isDefaultLanguage: true)
            }
        }
    }
    
    // MARK: - UICollectionViewDelegate & DataSource methods
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            return cellSize!
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CategoriesCollectionCell", forIndexPath: indexPath) as UICollectionViewCell
        
        if let categoryObject = categories?[indexPath.row] {
            // configure cell
            
            // category name
            if let nameLabel = cell.viewWithTag(kAmbatanaCategoryCellNameTag) as? UILabel {
                nameLabel.text = categoryObject["name"] as? String ?? translate("unknown")
            }
            
            // category image
            if let categoryImage = cell.viewWithTag(kAmbatanaCategoryCellRealImageTag) as? UIImageView {
                ImageManager.sharedInstance.retrieveImageFromURLString(categoryObject["image"] as String, completion: { (success, image) -> Void in
                    if success { categoryImage.image = image }
                    // TODO: else? try again?
                })
            }
            
            // gradient image
            if let gradientImage = cell.viewWithTag(kAmbatanaCategoryCellGradientImageTag) as? UIImageView {
                gradientImage.image = UIImage(gradientColors: [UIColor.clearColor(), UIColor.blackColor().colorWithAlphaComponent(0.8)], size: cellSize!)
            }
            
        }
        
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let categoryObject = categories?[indexPath.row] {
            if let category = ProductListCategory(rawValue: categoryObject["category_id"] as Int) {
                selectedCategory = category
                println("Searching products with category \(selectedCategory?.getName()), number \(selectedCategory?.rawValue)")
                performSegueWithIdentifier("ProductListByCategory", sender: nil)
            }
        }
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
