//
//  EditProfileViewController.swift
//  Ambatana
//
//  Created by Nacho on 05/02/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

enum UserProductsListType: Int {
    case Sell = 0, Sold, Favorite
}

let kAmbatanaDisabledButtonBackgroundColor = UIColor(red: 0.902, green: 0.902, blue: 0.902, alpha: 1.0)
let kAmbatanaDisabledButtonForegroundColor = UIColor.lightGrayColor()
let kAmbatanaEnabledButtonBackgroundColor = UIColor.whiteColor()
let kAmbatanaEnabledButtonForegroundColor = UIColor(red: 0.949, green: 0.361, blue: 0.376, alpha: 1.0)


class EditProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    // outlets && buttons
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userLocationLabel: UILabel!
    @IBOutlet weak var sellButton: UIButton!
    @IBOutlet weak var soldButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var youDontHaveTitleLabel: UILabel!
    @IBOutlet weak var youDontHaveSubtitleLabel: UILabel!
    @IBOutlet weak var startSellingNowButton: UIButton!
    @IBOutlet weak var startSearchingNowButton: UIButton!
    
    
    // data
    var userObject: PFUser?
    var currentType: UserProductsListType = .Sell {
        didSet {
            if (oldValue != currentType) {
                collectionView.reloadData()
                selectButton(selectedButtonForProductsListType(currentType))
            }
        }
    }
    var sellEntries: [PFObject]?
    var soldEntries: [PFObject]?
    var favoriteEntries: [PFObject]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userImageView.layer.cornerRadius = self.userImageView.frame.size.width / 2.0
        self.userImageView.clipsToBounds = true
        
        // UX/UI and Appearance.
        setAmbatanaNavigationBarStyle(title: "", includeBackArrow: true)
        
        // internationalization
        sellButton.setTitle(translate("selling"), forState: .Normal)
        soldButton.setTitle(translate("sold"), forState: .Normal)
        favoriteButton.setTitle(translate("favorited"), forState: .Normal)
    }
    
    func goToSettings() {
        performSegueWithIdentifier("Settings", sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // load user data (image, name, location...)
        if userObject != nil {
            userObject!.fetchIfNeededInBackgroundWithBlock({ (retrievedObject, error) -> Void in
                if let userImageFile = retrievedObject?["avatar"] as? PFFile {
                    userImageFile.getDataInBackgroundWithBlock({ (data, error) -> Void in
                        if data != nil {
                            self.userImageView.image = UIImage(data: data)
                        }
                    })
                }
                if let userName = retrievedObject?["username_public"] as? String {
                    self.userNameLabel.text = userName
                    self.setAmbatanaNavigationBarStyle(title: userName, includeBackArrow: true)
                }
                if let userLocation = retrievedObject?["city"] as? String {
                    self.userLocationLabel.text = userLocation
                    self.userLocationLabel.hidden = false
                } else { self.userLocationLabel.hidden = true }
            })
            
            // Current user has the option of editing his/her settings
            if userObject!.objectId == PFUser.currentUser().objectId { setAmbatanaRightButtonsWithImageNames(["actionbar_edit"], andSelectors: ["goToSettings"]) }
        }
        
        // check products
        if sellEntries == nil || soldEntries == nil || favoriteEntries == nil {
            collectionView.hidden = true
            activityIndicator.hidden = false
            activityIndicator.startAnimating()
            loadInitialProductsForUser()
        } else if sellEntries!.count + soldEntries!.count + favoriteEntries!.count == 0 { // Unable to get any products.
            noProductsAvailableToShow()
        } else { // we do have some products to show.
            collectionView.hidden = false
            activityIndicator.hidden = true
            activityIndicator.stopAnimating()
            collectionView.reloadData()
        }
    }
    
    func loadInitialProductsForUser() {
        println("Loading initial products...")
        if userObject == nil {
            noProductsAvailableToShow()
        } else {
            // query for all user favorited products
            let innerQuery = PFQuery(className: "UserFavoriteProducts")
            innerQuery.whereKey("user", equalTo: userObject)
            let favoriteProductsQuery = PFQuery(className: "Products")
            favoriteProductsQuery.whereKey("user", matchesQuery: innerQuery)
            
            // query for all user products
            let userProductsQuery = PFQuery(className: "Products")
            userProductsQuery.whereKey("user", equalTo: userObject)
            
            // perform global query query.
            let query = PFQuery.orQueryWithSubqueries([favoriteProductsQuery, userProductsQuery])
            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                if error == nil && objects?.count > 0 {
                    self.handleRetrievedProducts(objects as [PFObject])
                } else {
                    self.noProductsAvailableToShow()
                }
            })
        }
    }
    
    func handleRetrievedProducts(products: [PFObject]) {
        // sanity check
        if userObject == nil { return }
        println("Found some items... analyzing")
        
        // initialize product arrays
        sellEntries = []
        soldEntries = []
        favoriteEntries = []
        
        for product in products {
            let ownerOfTheProduct = product["user"] as PFUser
            if ownerOfTheProduct.objectId == userObject!.objectId { // watched user is the owner of this product. Either sell it or sold it.
                if let status = ProductStatus(rawValue: product.objectForKey("status") as? Int ?? -1) {
                    if status == .Sold {
                        soldEntries!.append(product)
                    } else if status == .Approved {
                        sellEntries!.append(product)
                    }
                }
            } else { // user favorited the product
                favoriteEntries!.append(product)
            }
            println("Processed product: \(product)")
        }
        
        if sellEntries!.count + soldEntries!.count + favoriteEntries!.count == 0 { // Unable to get any products.
            noProductsAvailableToShow()
        } else { // We have some really cool products to show here, so go ahead!
            collectionView.hidden = false
            youDontHaveSubtitleLabel.hidden = true
            youDontHaveTitleLabel.hidden = true
            startSearchingNowButton.hidden = true
            startSearchingNowButton.hidden = true
            
            activityIndicator.hidden = true
            activityIndicator.stopAnimating()
            collectionView.reloadData()
        }
        
    }
    
    func noProductsAvailableToShow() {
        println("No products were found for user \(userObject)")
        collectionView.hidden = true
        youDontHaveTitleLabel.hidden = false
        activityIndicator.hidden = true
        activityIndicator.stopAnimating()
        sellButton.hidden = true
        soldButton.hidden = true
        favoriteButton.hidden = true
        sellEntries = []
        soldEntries = []
        favoriteEntries = []
        
        // set text depending on if we are the user being shown or not.
        if userObject?.objectId == PFUser.currentUser()?.objectId { // user is me!
            youDontHaveSubtitleLabel.hidden = false
            youDontHaveTitleLabel.text = translate("no_published_favorited_products")
            startSearchingNowButton.hidden = false
            startSellingNowButton.hidden = false
        } else {
            youDontHaveSubtitleLabel.hidden = true
            youDontHaveTitleLabel.text = translate("this_user_no_published_favorited_products")
            startSearchingNowButton.hidden = true
            startSellingNowButton.hidden = true
        }
    }
    
    // MARK: - Button actions
    
    @IBAction func showSellProducts(sender: AnyObject) {
        currentType = .Sell
        checkEntriesForSelectedProductList(sellEntries)
    }

    @IBAction func showSoldProducts(sender: AnyObject) {
        currentType = .Sold
        checkEntriesForSelectedProductList(soldEntries)
    }
    
    @IBAction func showFavoritedProducts(sender: AnyObject) {
        currentType = .Favorite
        checkEntriesForSelectedProductList(favoriteEntries)
    }
    
    func checkEntriesForSelectedProductList(entries: [AnyObject]?) {
        // check entries.
        if entries == nil {
            
        } else if entries!.count > 0 {
            youDontHaveTitleLabel.hidden = true
            collectionView.hidden = false
            collectionView.reloadData()
        } else {
            youDontHaveTitleLabel.hidden = false
            youDontHaveTitleLabel.text = translate("no_items_in_this_section")
            collectionView.hidden = true
        }
    }
    
    func selectedButtonForProductsListType(type: UserProductsListType) -> UIButton {
        switch (type) {
        case .Sell:
            return sellButton
        case .Sold:
            return soldButton
        case .Favorite:
            return favoriteButton
        }
    }
    
    func selectButton(button: UIButton) {
        button.backgroundColor = kAmbatanaEnabledButtonBackgroundColor
        button.setTitleColor(kAmbatanaEnabledButtonForegroundColor, forState: .Normal)
        if button != sellButton {
            sellButton.backgroundColor = kAmbatanaDisabledButtonBackgroundColor
            sellButton.setTitleColor(kAmbatanaDisabledButtonForegroundColor, forState: .Normal)
        }
        if button != soldButton {
            soldButton.backgroundColor = kAmbatanaDisabledButtonBackgroundColor
            soldButton.setTitleColor(kAmbatanaDisabledButtonForegroundColor, forState: .Normal)
        }
        if button != favoriteButton {
            favoriteButton.backgroundColor = kAmbatanaDisabledButtonBackgroundColor
            favoriteButton.setTitleColor(kAmbatanaDisabledButtonForegroundColor, forState: .Normal)
        }
    }

    // MARK: - You don't have any products action buttons.
    
    @IBAction func startSellingNow(sender: AnyObject) {
        // TODO
    }
    
    @IBAction func startSearchingNow(sender: AnyObject) {
        // TODO
    }
    
    // MARK: - UICollectionViewDataSource and Delegate methods
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch (currentType) {
        case .Sell:
            return sellEntries?.count ?? 0
        case .Sold:
            return soldEntries?.count ?? 0
        case .Favorite:
            return favoriteEntries?.count ?? 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ProductListCell", forIndexPath: indexPath) as UICollectionViewCell

        // get the type of product depending on the selected button.
        var productObject: PFObject!
        switch (currentType) {
        case .Sell:
            productObject = sellEntries![indexPath.row]
        case .Sold:
            productObject = soldEntries![indexPath.row]
        case .Favorite:
            productObject = favoriteEntries![indexPath.row]
        }
        
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
            if productObject["image_0"] != nil {
                let imageFile = productObject["image_0"] as PFFile
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
        
        return cell
    }
}
