//
//  SetFavoriteCategoriesViewController.swift
//  Ambatana
//
//  Created by Ignacio Nieto Carvajal on 19/2/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

private let kAmbatanaFavoriteCategoriesCellNameTag = 1
private let kAmbatanaFavoriteCategoriesCellImageTag = 2
private let kAmbatanaFavoriteCategoriesCellActivityIndicatorTag = 3

class SetFavoriteCategoriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // outlets & buttons
    @IBOutlet weak var tableView: UITableView!
    
    // data
    var categories: [PFObject]?
    var favoriteCategories: [String]? {
        didSet {
            //if categories?.count > 0 { setAmbatanaRightButtonsWithImageNames(["actionbar_save"], andSelectors: ["changeFavoriteCategories"]) }
            //else { self.navigationItem.rightBarButtonItem = nil }
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // UX/UI & Appearance.
        setAmbatanaNavigationBarStyle(title: translate("favorite_categories"), includeBackArrow: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let initialLanguage = NSLocale.preferredLanguages().first as? String ?? kAmbatanaDefaultCategoriesLanguage
        // load initial categories. First try to load from the user device's language. If none found, fallback to "en".
        let allCategoriesQuery = allCategoriesQueryForLanguage(initialLanguage)
        performCategoriesQuery(allCategoriesQuery, isDefaultLanguage: initialLanguage == kAmbatanaDefaultCategoriesLanguage)
    }
    
    // MARK: - Favorite categories functions and parse communication.
    
    func changeFavoriteCategories() {
        
    }
    
    /**
     * Performs a query of the (favorite) categories for the current user. On failure, tries to fallback to the default language (if not on it already).
     */
    func performCategoriesQuery(query: PFQuery, isDefaultLanguage defaultLanguage: Bool) {
        query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
            if error == nil { // check if there are results for that language or we need to fallback to "en".
                if results?.count > 0 { // alright, we do have some categories for that language.
                    self.categories = results as [PFObject]? ?? []
                    // now look for current favorite categories.
                    let favQuery = favoriteCategoriesQuery()
                    favQuery.findObjectsInBackgroundWithBlock({ (favoriteObjects, error) -> Void in
                        if error == nil {
                            var favoriteIds: [String] = []
                            for favoriteObject in favoriteObjects {
                                if let favorite = favoriteObject as? PFObject { favoriteIds.append(favorite.objectId) }
                            }
                            self.favoriteCategories = favoriteIds
                        } else { // assume user has no favorites.
                            self.favoriteCategories = []
                        }
                    })
                    
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
            self.favoriteCategories = []
        } else { // we have another chance. Fallback to default language.
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.01 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                let fallbackQuery = allCategoriesQueryForLanguage(kAmbatanaDefaultCategoriesLanguage)
                self.performCategoriesQuery(fallbackQuery, isDefaultLanguage: true)
            }
        }
    }
    
    // MARK: - UITableViewDataSource & Delegate methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if categories?.count > 0 { return categories!.count } // we do have some categories.
        else { return 1 } // loading & no categories
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if categories?.count > 0 { // we do have some categories.
            let cell = tableView.dequeueReusableCellWithIdentifier("FavoriteCategoriesCell", forIndexPath: indexPath) as UITableViewCell
            
            let categoryObject = categories![indexPath.row]
            // name
            if let nameLabel = cell.viewWithTag(kAmbatanaFavoriteCategoriesCellNameTag) as? UILabel {
                nameLabel.text = categoryObject["name"] as? String ?? translate("unknown")
            }
            // check to indicate a favorite category?
            if let imageView = cell.viewWithTag(kAmbatanaFavoriteCategoriesCellImageTag) as? UIImageView {
                if favoriteCategories != nil && contains(favoriteCategories!, categoryObject.objectId) { imageView.alpha = 1.0 } // favorite category
                else { imageView.alpha = 0.0 } // non-favorite category.
            }
            // clear activity indicator
            if let activityView = cell.viewWithTag(kAmbatanaFavoriteCategoriesCellActivityIndicatorTag) as? UIActivityIndicatorView {
                activityView.hidden = true
                activityView.stopAnimating()
            }
            
            cell.selectionStyle = .Default
            
            return cell
        } else { // still loading categories or not categories found.
            let cell = tableView.dequeueReusableCellWithIdentifier("LoadingFavoriteCategoriesCell", forIndexPath: indexPath) as UITableViewCell
    
            if categories == nil { cell.textLabel!.text = translate("loading") }
            else { cell.textLabel!.text = translate("no_categories_found") }
            cell.selectionStyle = .None
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if categories?.count > 0 {
            let categoryObject = categories![indexPath.row]
            
            // prevent further interaction until category is set or not
            tableView.userInteractionEnabled = false
            activateLoadingIndicationForCellInTableView(tableView, atIndexPath: indexPath)
            
            // (un)favorite category
            if let favoriteIndex = find(favoriteCategories!, categoryObject.objectId) { // *** remove *** previously favorited category
                // remove at the backend. Peform a query for the favorite category object and then delete it if found.
                let favoriteToRemoveQuery = PFQuery(className: "UserFavoriteCategories")
                favoriteToRemoveQuery.whereKey("user", equalTo: PFUser.currentUser())
                favoriteToRemoveQuery.whereKey("category_id", equalTo: categoryObject["category_id"])
                favoriteToRemoveQuery.getFirstObjectInBackgroundWithBlock({ (favoriteToRemove, error) -> Void in
                    if error == nil { // success!
                        favoriteToRemove.deleteInBackgroundWithBlock({ (success, deleteError) -> Void in
                            if success {
                                // remove locally & update UI
                                self.favoriteCategories?.removeAtIndex(favoriteIndex)
                                self.deactivateLoadingIndicationForCellInTableView(tableView, atIndexPath: indexPath)
                                self.setCategoryMarkForCellInTableView(tableView, atIndexPath: indexPath, enabled: false)
                                tableView.userInteractionEnabled = true
                            } else { // show error
                                self.deactivateLoadingIndicationForCellInTableView(tableView, atIndexPath: indexPath)
                                tableView.userInteractionEnabled = true
                                self.showAutoFadingOutMessageAlert(translate("error_setting_favorite_categories"))
                                println("Got the object \(favoriteToRemove) but couldn't delete it")
                            }
                        })
                    } else { // error
                        self.deactivateLoadingIndicationForCellInTableView(tableView, atIndexPath: indexPath)
                        tableView.userInteractionEnabled = true
                        self.showAutoFadingOutMessageAlert(translate("error_setting_favorite_categories"))
                    }
                })
            } else { // add new favorite category
                let newFavoriteCategoryObject = PFObject(className: "UserFavoriteCategories")
                newFavoriteCategoryObject["category_id"] = categoryObject["category_id"]
                newFavoriteCategoryObject["user"] = PFUser.currentUser()
                newFavoriteCategoryObject.ACL = globalReadAccessACL()
                
                // save in background
                newFavoriteCategoryObject.saveInBackgroundWithBlock({ (success, error) -> Void in
                    if success {
                        self.favoriteCategories?.append(categoryObject.objectId)
                        self.deactivateLoadingIndicationForCellInTableView(tableView, atIndexPath: indexPath)
                        self.setCategoryMarkForCellInTableView(tableView, atIndexPath: indexPath, enabled: true)
                        tableView.userInteractionEnabled = true
                    } else {
                        self.deactivateLoadingIndicationForCellInTableView(tableView, atIndexPath: indexPath)
                        tableView.userInteractionEnabled = true
                        self.showAutoFadingOutMessageAlert(translate("error_setting_favorite_categories"))
                    }
                })
            }
            
        }
    }
    
    func activateLoadingIndicationForCellInTableView(tableView: UITableView, atIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if let activityView = cell.viewWithTag(kAmbatanaFavoriteCategoriesCellActivityIndicatorTag) as? UIActivityIndicatorView {
                activityView.startAnimating()
                activityView.hidden = false
            }
        }
    }
    
    func deactivateLoadingIndicationForCellInTableView(tableView: UITableView, atIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if let activityView = cell.viewWithTag(kAmbatanaFavoriteCategoriesCellActivityIndicatorTag) as? UIActivityIndicatorView {
                activityView.hidden = true
                activityView.stopAnimating()
            }
        }
    }
    
    func setCategoryMarkForCellInTableView(tableView: UITableView, atIndexPath indexPath: NSIndexPath, enabled: Bool) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if let imageView = cell.viewWithTag(kAmbatanaFavoriteCategoriesCellImageTag) as? UIImageView {
                let newAlpha: CGFloat = enabled ? 1.0 : 0.0
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    imageView.alpha = newAlpha
                })
            }
        }
    }
}












