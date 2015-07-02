//
//  EditProfileViewController.swift
//  LetGo
//
//  Created by Ignacio Nieto Carvajal on 05/02/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import LGCoreKit
import Parse
import UIKit
import SDWebImage

private let kLetGoDisabledButtonBackgroundColor = UIColor(red: 0.902, green: 0.902, blue: 0.902, alpha: 1.0)
private let kLetGoDisabledButtonForegroundColor = UIColor.lightGrayColor()
private let kLetGoEnabledButtonBackgroundColor = UIColor.whiteColor()
private let kLetGoEnabledButtonForegroundColor = UIColor(red: 0.949, green: 0.361, blue: 0.376, alpha: 1.0)
private let kLetGoEditProfileCellFactor: CGFloat = 210.0 / 160.0


class EditProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout {
    
    enum ProfileTab {
        case ProductImSelling
        case ProductISold
        case ProductFavourite
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
    @IBOutlet weak var activityIndicatorCenterYConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var youDontHaveTitleLabel: UILabel!
    @IBOutlet weak var youDontHaveSubtitleLabel: UILabel!
    @IBOutlet weak var startSellingNowButton: UIButton!
    @IBOutlet weak var startSearchingNowButton: UIButton!
    
    // data
    var user: User {
        didSet {
            shouldReload = true
        }
    }
    var selectedTab: ProfileTab = .ProductImSelling
    
    private var sellProducts: [Product] = []
    private var soldProducts: [Product] = []
    private var favProducts: [Product] = []
    
    private var loadingSellProducts: Bool = false
    private var loadingSoldProducts: Bool = false
    private var loadingFavProducts: Bool = false
    
    private var shouldReload: Bool
    
    var cellSize = CGSizeMake(160.0, 210.0)
    
    init(user: User) {
        self.user = user
        shouldReload = true
        super.init(nibName: "EditProfileViewController", bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userImageView.layer.cornerRadius = self.userImageView.frame.size.width / 2.0
        self.userImageView.clipsToBounds = true
        
        // internationalization
        sellButton.setTitle(NSLocalizedString("profile_selling_products_tab", comment: ""), forState: .Normal)
        soldButton.setTitle(NSLocalizedString("profile_sold_products_tab", comment: ""), forState: .Normal)
        favoriteButton.setTitle(NSLocalizedString("profile_favourites_products_tab", comment: ""), forState: .Normal)
        
        // center activity indicator (if there's a tabbar)
        let bottomMargin: CGFloat
        if let tabBarCtl = self.tabBarController {
            bottomMargin = tabBarCtl.tabBar.hidden ? 0 : -tabBarCtl.tabBar.frame.size.height/2
        }
        else {
            bottomMargin = 0
        }
        activityIndicatorCenterYConstraint.constant = bottomMargin
        
        // collection view.
        var layout = CHTCollectionViewWaterfallLayout()
        layout.minimumColumnSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        self.collectionView.autoresizingMask = UIViewAutoresizing.FlexibleHeight // | UIViewAutoresizing.FlexibleWidth
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.collectionViewLayout = layout
        
        // Add bottom inset (tabbar) if tabbar visible
        let bottomInset: CGFloat
        if let tabBarCtl = self.tabBarController {
            bottomInset = tabBarCtl.tabBar.hidden ? 0 : tabBarCtl.tabBar.frame.height
        }
        else {
            bottomInset = 0
        }
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
        
        // register ProductCell
        let cellNib = UINib(nibName: "ProductCell", bundle: nil)
        collectionView.registerNib(cellNib, forCellWithReuseIdentifier: "ProductCell")
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if shouldReload {
            // UX/UI and Appearance.
            setLetGoNavigationBarStyle(title: "")
            
            collectionView.hidden = true
            activityIndicator.hidden = false
            activityIndicator.startAnimating()
            
            // load
            sellProducts = []
            soldProducts = []
            favProducts = []
            collectionView.reloadSections(NSIndexSet(index: 0))
            retrieveProductsForTab(ProfileTab.ProductImSelling)
            retrieveProductsForTab(ProfileTab.ProductISold)
            retrieveProductsForTab(ProfileTab.ProductFavourite)
            
            // UI
            if let avatarURL = user.avatar?.fileURL {
                userImageView.sd_setImageWithURL(avatarURL, placeholderImage: UIImage(named: "no_photo"))
            }
            else {
                userImageView.image = UIImage(named: "no_photo")
            }
            userNameLabel.text = user.publicUsername ?? ""
            userLocationLabel.text = user.postalAddress.city ?? ""
            
            // If it's me, then allow go to settings
            if let myUser = MyUserManager.sharedInstance.myUser(), let myUserId = myUser.objectId, let userId = user.objectId {
                if userId == myUserId {
                    setLetGoRightButtonsWithImageNames(["navbar_settings"], andSelectors: ["goToSettings"])
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // cell size
        let cellWidth = kLetGoFullScreenWidth * 0.50
        let cellHeight = cellWidth * kLetGoEditProfileCellFactor
        cellSize = CGSizeMake(cellWidth, cellHeight)
    }
    
    // MARK: - Actions
    
    func goToSettings() {
        let vc = SettingsViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func showSellProducts(sender: AnyObject) {
        selectedTab = .ProductImSelling
        updateUIForCurrentTab()
    }

    @IBAction func showSoldProducts(sender: AnyObject) {
        selectedTab = .ProductISold
        updateUIForCurrentTab()
    }
    
    @IBAction func showFavoritedProducts(sender: AnyObject) {
        selectedTab = .ProductFavourite
        updateUIForCurrentTab()
    }
    
    // MARK: - You don't have any products action buttons.
    
    @IBAction func startSellingNow(sender: AnyObject) {
        let vc = SellProductViewController()
        let navCtl = UINavigationController(rootViewController: vc)
        presentViewController(navCtl, animated: true, completion: nil)
    }
    
    @IBAction func startSearchingNow(sender: AnyObject) {
        if let tabBarCtl = tabBarController as? TabBarController {
            tabBarCtl.switchToTab(.Home)
        }
    }
    
    // MARK: - UICollectionViewDataSource and Delegate methods
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        // TODO: Calculate size in the future when using thumbnail sizes from REST API.
        return cellSize
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, columnCountForSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch selectedTab {
        case .ProductImSelling:
            return sellProducts.count
        case .ProductISold:
            return soldProducts.count
        case .ProductFavourite:
            return favProducts.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ProductCell", forIndexPath: indexPath) as! ProductCell
        cell.tag = indexPath.hash
        
        if let product = self.productAtIndexPath(indexPath) {
            cell.setupCellWithProduct(product, indexPath: indexPath)
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let product = self.productAtIndexPath(indexPath) {
            let vc = ShowProductViewController(product: product)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        // Hide tip when dragging
        if let tabBarCtl = tabBarController as? TabBarController {
            tabBarCtl.dismissTooltip(animated: true)
        }
    }
    
    // MARK: - UI
    
    func selectButton(button: UIButton) {
        button.backgroundColor = kLetGoEnabledButtonBackgroundColor
        button.setTitleColor(kLetGoEnabledButtonForegroundColor, forState: .Normal)
        if button != sellButton {
            sellButton.backgroundColor = kLetGoDisabledButtonBackgroundColor
            sellButton.setTitleColor(kLetGoDisabledButtonForegroundColor, forState: .Normal)
        }
        if button != soldButton {
            soldButton.backgroundColor = kLetGoDisabledButtonBackgroundColor
            soldButton.setTitleColor(kLetGoDisabledButtonForegroundColor, forState: .Normal)
        }
        if button != favoriteButton {
            favoriteButton.backgroundColor = kLetGoDisabledButtonBackgroundColor
            favoriteButton.setTitleColor(kLetGoDisabledButtonForegroundColor, forState: .Normal)
        }
    }
    
    func updateUIForCurrentTab() {
        var products: [AnyObject] = []
        switch selectedTab {
        case .ProductImSelling:
            products = sellProducts
        case .ProductISold:
            products = soldProducts
        case .ProductFavourite:
            products = favProducts
        }
        
        if products.isEmpty {
            youDontHaveTitleLabel.hidden = false
            youDontHaveTitleLabel.text = NSLocalizedString("profile_no_products", comment: "")
            collectionView.hidden = true
        }
        else {
            youDontHaveTitleLabel.hidden = true
            collectionView.hidden = false
            collectionView.reloadSections(NSIndexSet(index: 0))
        }
        
        switch selectedTab {
        case .ProductImSelling:
            selectButton(sellButton)
        case .ProductISold:
            selectButton(soldButton)
        case .ProductFavourite:
            selectButton(favoriteButton)
        }
    }
    
    // MARK: - Requests
    
    func retrieveProductsForTab(tab: ProfileTab) {
        
        if let userId = user.objectId {
            switch tab {
            case .ProductImSelling:
                
                // If it's me then show my approved & pending products
                let statuses: [LetGoProductStatus]
                if userId == MyUserManager.sharedInstance.myUser()?.objectId {
                    statuses = [.Approved, .Pending]
                }
                    // Otherwise, only show the approved products
                else {
                    statuses = [.Approved]
                }
                
                // Retrieve the products
                loadingSellProducts = true
                retrieveProductsForUserId(userId, statuses: statuses, completion: { [weak self] (products, error) -> (Void) in
                    if let strongSelf = self {
                        if let actualProducts = products {
                            strongSelf.sellProducts = actualProducts
                        }
                        strongSelf.loadingSellProducts = false
                        strongSelf.retrievalFinishedForProductsAtTab(tab)
                    }
                })
                
            case .ProductISold:
                
                // Retrieve the products (sold)
                loadingSoldProducts = true
                self.retrieveProductsForUserId(userId, statuses: [.Sold], completion: { [weak self] (products, error) -> Void in
                    if let strongSelf = self {
                        if let actualProducts = products {
                            strongSelf.soldProducts = actualProducts
                        }
                        strongSelf.loadingSoldProducts = false
                        strongSelf.retrievalFinishedForProductsAtTab(tab)
                    }
                })
                
            case .ProductFavourite:

                // Retrieve the products
                loadingFavProducts = true
                self.retrieveFavouriteProductsForUserId(userId, completion: { [weak self] (products, error) -> Void in
                    if let strongSelf = self {
                        if let actualProducts = products {
                            strongSelf.favProducts = actualProducts
                        }
                        strongSelf.loadingFavProducts = false
                        strongSelf.retrievalFinishedForProductsAtTab(tab)
                    }
                })
            }
            
        }
        else {
            retrievalFinishedForProductsAtTab(tab)
        }
    }
    
    func retrieveProductsForUserId(userId: String, statuses: [LetGoProductStatus], completion: (products: [PAProduct]!, error: NSError!) -> (Void)) {
        let user = PFObject(withoutDataWithClassName: PFUser.parseClassName(), objectId: userId)
        let query = PFQuery(className: PAProduct.parseClassName())
        query.whereKey("user", equalTo: user)
        // statuses
        var statusesIncluded: [Int] = []
        for status in statuses { statusesIncluded.append(status.rawValue) }
        
        //query.whereKey("status", equalTo: status.rawValue)
        query.whereKey("status", containedIn: statusesIncluded)
        query.includeKey("user")
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock( { (objects, error) -> Void in
            let products = objects as? [PAProduct]
            completion(products: products, error: error)
        })
    }
    
    func retrieveFavouriteProductsForUserId(userId: String?, completion: (favProducts: [PAProduct]!, error: NSError!) -> (Void)) {
        let user = PFObject(withoutDataWithClassName: PFUser.parseClassName(), objectId: userId)
        let query = PFQuery(className: "UserFavoriteProducts")
        query.whereKey("user", equalTo: user)
        query.includeKey("product")
        query.includeKey("product.user")
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock( { (objects, error) -> Void in
            
            var productList: [PAProduct] = []
            if let favorites = objects as? [PFObject] {
                for favorite in favorites {
                    if let product = favorite["product"] as? PAProduct {
                        productList.append(product)
                    }
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
            if user.objectId == MyUserManager.sharedInstance.myUser()?.objectId { // user is me!
                youDontHaveTitleLabel.text = NSLocalizedString("profile_favourites_my_user_no_products_label", comment: "")
                youDontHaveSubtitleLabel.text = NSLocalizedString("profile_favourites_my_user_no_products_subtitle_label", comment: "")
                youDontHaveSubtitleLabel.hidden = false
                
                startSearchingNowButton.hidden = false
                startSellingNowButton.hidden = false
            }
            else {
                youDontHaveTitleLabel.text = NSLocalizedString("profile_favourites_other_user_no_products_label", comment: "")
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
            
            sellButton.hidden = false
            soldButton.hidden = false
            favoriteButton.hidden = false
            
            startSearchingNowButton.hidden = true
            startSellingNowButton.hidden = true
            
            updateUIForCurrentTab()
        }
    }
    
    // MARK: Helper
    
    func productAtIndexPath(indexPath: NSIndexPath) -> Product? {
        let row = indexPath.row
        var product: Product?
        switch selectedTab {
        case .ProductImSelling:
            product = sellProducts[row]
        case .ProductISold:
            product = soldProducts[row]
        case .ProductFavourite:
            product = favProducts[row]
        }
        
        return product
    }
}
