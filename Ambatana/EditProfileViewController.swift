//
//  EditProfileViewController.swift
//  Ambatana
//
//  Created by Ignacio Nieto Carvajal on 05/02/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

private let kAmbatanaDisabledButtonBackgroundColor = UIColor(red: 0.902, green: 0.902, blue: 0.902, alpha: 1.0)
private let kAmbatanaDisabledButtonForegroundColor = UIColor.lightGrayColor()
private let kAmbatanaEnabledButtonBackgroundColor = UIColor.whiteColor()
private let kAmbatanaEnabledButtonForegroundColor = UIColor(red: 0.949, green: 0.361, blue: 0.376, alpha: 1.0)
private let kAmbatanaEditProfileCellFactor: CGFloat = 190.0 / 145.0


class EditProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    enum ProfileTab {
        case MyProduct(ProductStatus) // sell / sold
        case ProductFavourite       // fav
    }
    
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
    var selectedTab: ProfileTab = .MyProduct(ProductStatus.Approved) /* sell */
    
    private var sellProducts: [PFObject] = []
    private var soldProducts: [PFObject] = []
    private var favProducts: [PFObject] = []
    
    private var loadingSellProducts: Bool = false
    private var loadingSoldProducts: Bool = false
    private var loadingFavProducts: Bool = false
    
    var cellSize = CGSizeMake(145.0, 190.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userImageView.layer.cornerRadius = self.userImageView.frame.size.width / 2.0
        self.userImageView.clipsToBounds = true
        
        // UX/UI and Appearance.
        userLocationLabel.text = ""
        userNameLabel.text = ""
        setAmbatanaNavigationBarStyle(title: "", includeBackArrow: true)
        
        // cell size
        let cellWidth = (kAmbatanaFullScreenWidth - (3*kAmbatanaProductCellSpan)) / 2.0
        let cellHeight = cellWidth * kAmbatanaEditProfileCellFactor
        cellSize = CGSizeMake(cellWidth, cellHeight)

        // internationalization
        sellButton.setTitle(translate("selling_button"), forState: .Normal)
        soldButton.setTitle(translate("sold"), forState: .Normal)
        favoriteButton.setTitle(translate("favorited"), forState: .Normal)
        
        // ui
        collectionView.hidden = true
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        
        // load
        retrieveProductsForTab(ProfileTab.MyProduct(ProductStatus.Approved))
        retrieveProductsForTab(ProfileTab.MyProduct(ProductStatus.Sold))
        retrieveProductsForTab(ProfileTab.ProductFavourite)
        
        // register ProductCell
        let cellNib = UINib(nibName: "ProductCell", bundle: nil)
        collectionView.registerNib(cellNib, forCellWithReuseIdentifier: "ProductCell")
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // load user data (image, name, location...)
        if userObject != nil {
            userObject!.fetchIfNeededInBackgroundWithBlock({ (retrievedObject, error) -> Void in
                if let userImageFile = retrievedObject?["avatar"] as? PFFile {
                    ImageManager.sharedInstance.retrieveImageFromParsePFFile(userImageFile, completion: { (success, image) -> Void in
                        if success { self.userImageView.image = image }
                    }, andAddToCache: true)
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
    }
    
    // MARK: - Actions
    
    func goToSettings() {
        performSegueWithIdentifier("Settings", sender: nil)
    }
    
    @IBAction func showSellProducts(sender: AnyObject) {
        selectedTab = .MyProduct(ProductStatus.Approved)
        updateUIForCurrentTab()
    }

    @IBAction func showSoldProducts(sender: AnyObject) {
        selectedTab = .MyProduct(ProductStatus.Sold)
        updateUIForCurrentTab()
    }
    
    @IBAction func showFavoritedProducts(sender: AnyObject) {
        selectedTab = .ProductFavourite
        updateUIForCurrentTab()
    }
    
    // MARK: - You don't have any products action buttons.
    
    @IBAction func startSellingNow(sender: AnyObject) {
        performSegueWithIdentifier("SellProducts", sender: sender)
    }
    
    @IBAction func startSearchingNow(sender: AnyObject) {
        performSegueWithIdentifier("SearchProducts", sender: sender)
    }
    
    // MARK: - UICollectionViewDataSource and Delegate methods
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            return cellSize
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch selectedTab {
        case .MyProduct(let status):
            switch status {
            case .Approved: // Selling
                return sellProducts.count
            case .Sold:
                return soldProducts.count
            default:
                println("not handled!")
            }
        case .ProductFavourite:
            return favProducts.count
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ProductCell", forIndexPath: indexPath) as ProductCell
        cell.tag = indexPath.hash
        
        if let product = self.productAtIndexPath(indexPath) {
            cell.setupCellWithProduct(product, indexPath: indexPath)
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let spvc = self.storyboard?.instantiateViewControllerWithIdentifier("showProductViewController") as? ShowProductViewController {
            spvc.productObject = self.productAtIndexPath(indexPath)
            self.navigationController?.pushViewController(spvc, animated: true)
        }
    }
    
    // MARK: - UI
    
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
    
    func updateUIForCurrentTab() {
        var products: [AnyObject] = []
        switch selectedTab {
        case .MyProduct(let status):
            switch status {
            case .Approved: // Selling
                products = sellProducts
            case .Sold:
                products = soldProducts
            default:
                println("not handled!")
            }
        case .ProductFavourite:
            products = favProducts
        }
        
        if products.isEmpty {
            youDontHaveTitleLabel.hidden = false
            youDontHaveTitleLabel.text = translate("no_items_in_this_section")
            collectionView.hidden = true
        }
        else {
            youDontHaveTitleLabel.hidden = true
            collectionView.hidden = false
            collectionView.reloadSections(NSIndexSet(index: 0))
        }
        
        switch selectedTab {
        case .MyProduct(let status):
            switch status {
            case .Approved: // Selling
                selectButton(sellButton)
            case .Sold:
                selectButton(soldButton)
            default:
                println("not handled!")
            }
        case .ProductFavourite:
            selectButton(favoriteButton)
        }
    }
    
    // MARK: - Requests
    
    func retrieveProductsForTab(tab: ProfileTab) {
        switch tab {
        case .MyProduct(let status):
            switch status {
            case .Approved: // Selling
                loadingSellProducts = true
                self.retrieveProductsForUserId(userObject?.objectId, status: status, completion: { (products, error) -> (Void) in
                    if error == nil && products.count > 0 {
                        self.sellProducts = products
                    }
                    self.loadingSellProducts = false
                    self.retrievalFinishedForProductsAtTab(tab)
                })
            case .Sold:
                loadingSoldProducts = true
                
                self.retrieveProductsForUserId(userObject?.objectId, status: status, completion: {
                    (products, error) -> Void in
                    if error == nil && products.count > 0 {
                        self.soldProducts = products
                    }
                    self.loadingSoldProducts = false
                    self.retrievalFinishedForProductsAtTab(tab)
                })
            default:
                println("not handled!")
            }
        case .ProductFavourite:
            loadingFavProducts = true
            
            self.retrieveFavouriteProductsForUserId(userObject?.objectId, completion: {
                (products, error) -> Void in
                if error == nil && products.count > 0 {
                    self.favProducts = products
                }
                self.loadingFavProducts = false
                self.retrievalFinishedForProductsAtTab(tab)
            })
        }
    }
    
    func retrieveProductsForUserId(userId: String?, status: ProductStatus, completion: (products: [PFObject]!, error: NSError!) -> (Void)) {
        let user = PFObject(withoutDataWithClassName: "_User", objectId: userId)
        let query = PFQuery(className: "Products")
        query.whereKey("user", equalTo: user)
        query.whereKey("status", equalTo: status.rawValue)
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock( { (objects, error) -> Void in
            let products = objects as [PFObject]!
            completion(products: products, error: error)
        })
    }
    
    func retrieveFavouriteProductsForUserId(userId: String?, completion: (favProducts: [PFObject]!, error: NSError!) -> (Void)) {
        let user = PFObject(withoutDataWithClassName: "_User", objectId: userId)
        let query = PFQuery(className: "UserFavoriteProducts")
        query.whereKey("user", equalTo: user)
        query.orderByDescending("createdAt")
        query.includeKey("product")
        query.findObjectsInBackgroundWithBlock( { (objects, error) -> Void in
            let favorites = objects as [PFObject]!
            var productList: [PFObject] = []
            for favorite in favorites {
                if let product = favorite["product"] as? PFObject {
                    productList.append(product)
                }
            }
            completion(favProducts: productList, error: error)
        })
    }
    
    
    func retrievalFinishedForProductsAtTab(tab: ProfileTab) {
        // If any tab is loading, then quit this function
        if loadingSellProducts || loadingSoldProducts || loadingFavProducts {
            return
        }
        
        activityIndicator.hidden = true
        activityIndicator.stopAnimating()
        
        // If the 3 tabs are empty then display update UI with "no products available"
        if sellProducts.isEmpty && soldProducts.isEmpty && favProducts.isEmpty {
            
            collectionView.hidden = true
            youDontHaveTitleLabel.hidden = false
            sellButton.hidden = true
            soldButton.hidden = true
            favoriteButton.hidden = true
            
            // set text depending on if we are the user being shown or not
            if userObject?.objectId == PFUser.currentUser()?.objectId { // user is me!
                youDontHaveTitleLabel.text = translate("no_published_favorited_products")
                youDontHaveSubtitleLabel.hidden = false
                
                startSearchingNowButton.hidden = false
                startSellingNowButton.hidden = false
            }
            else {
                youDontHaveTitleLabel.text = translate("this_user_no_published_favorited_products")
                youDontHaveSubtitleLabel.hidden = true
                
                startSearchingNowButton.hidden = true
                startSellingNowButton.hidden = true
            }
        }
        // Else, update the UI and refresh the collection view
        else {
            collectionView.hidden = false
            
            youDontHaveTitleLabel.hidden = true
            youDontHaveSubtitleLabel.hidden = true
            
            startSearchingNowButton.hidden = true
            startSellingNowButton.hidden = true
            
            updateUIForCurrentTab()
        }
    }
    
    // MARK: Helper
    
    func productAtIndexPath(indexPath: NSIndexPath) -> PFObject? {
        let row = indexPath.row
        var product: PFObject?
        switch selectedTab {
        case .MyProduct(let status):
            switch status {
            case .Approved: // Selling
                product = sellProducts[row]
            case .Sold:
                product = soldProducts[row]
            default:
                println("not handled!")
            }
        case .ProductFavourite:
            product = favProducts[row]
        }
        return product
    }
}
