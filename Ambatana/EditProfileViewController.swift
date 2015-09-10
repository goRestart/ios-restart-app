//
//  EditProfileViewController.swift
//  LetGo
//
//  Created by Ignacio Nieto Carvajal on 05/02/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import CHTCollectionViewWaterfallLayout
import LGCoreKit
import Parse
import Result
import UIKit
import SDWebImage

private let kLetGoDisabledButtonBackgroundColor = UIColor(red: 0.902, green: 0.902, blue: 0.902, alpha: 1.0)
private let kLetGoDisabledButtonForegroundColor = UIColor.lightGrayColor()
private let kLetGoEnabledButtonBackgroundColor = UIColor.whiteColor()
private let kLetGoEnabledButtonForegroundColor = UIColor(red: 0.949, green: 0.361, blue: 0.376, alpha: 1.0)
private let kLetGoEditProfileCellFactor: CGFloat = 210.0 / 160.0


class EditProfileViewController: UIViewController, ProductListViewDataDelegate, UICollectionViewDelegate, UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout {
    
    enum ProfileTab {
        case ProductImSelling
        case ProductISold
        case ProductFavourite
    }
    
    // Header
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userLocationLabel: UILabel!
    
    // "tab" buttons
    @IBOutlet weak var sellButton: UIButton!
    @IBOutlet weak var soldButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    // Selling
    @IBOutlet weak var sellingProductListView: ProfileProductListView!
    
    // Sold
    @IBOutlet weak var soldProductListView: ProfileProductListView!

    // Favourites
    @IBOutlet weak var favouriteCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityIndicatorCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var noFavouritesLabel: UILabel!
    
    // No products
    @IBOutlet weak var youDontHaveTitleLabel: UILabel!
    @IBOutlet weak var youDontHaveSubtitleLabel: UILabel!
    @IBOutlet weak var startSellingNowButton: UIButton!
    @IBOutlet weak var startSearchingNowButton: UIButton!
    
    // data
    
    private let productsFavouriteRetrieveService: ProductsFavouriteRetrieveService
    
    var user: User {
        didSet {
            shouldReload = true
        }
    }
    var selectedTab: ProfileTab = .ProductImSelling
    
    private var isSellProductsEmpty: Bool = true
    private var isSoldProductsEmpty: Bool = true
    private var favProducts: [Product] = []
    
    private var loadingSellProducts: Bool = false
    private var loadingSoldProducts: Bool = false
    private var loadingFavProducts: Bool = false
    
    private var shouldReload: Bool
    
    var cellSize = CGSizeMake(160.0, 210.0)
    
    init(user: User) {
        self.user = user
        shouldReload = true
        self.productsFavouriteRetrieveService = LGProductsFavouriteRetrieveService()
        super.init(nibName: "EditProfileViewController", bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI
        // > Main product list view
        sellingProductListView.delegate = self
        sellingProductListView.user = user
        sellingProductListView.type = .Selling
        soldProductListView.delegate = self
        soldProductListView.user = user
        soldProductListView.type = .Sold
        
        // User image
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2.0
        userImageView.clipsToBounds = true
        userImageView.layer.borderColor = UIColor(rgb: 0xD8D8D8).CGColor
        userImageView.layer.borderWidth = 1
        
        // internationalization
        sellButton.setTitle(NSLocalizedString("profile_selling_products_tab", comment: ""), forState: .Normal)
        soldButton.setTitle(NSLocalizedString("profile_sold_products_tab", comment: ""), forState: .Normal)
        favoriteButton.setTitle(NSLocalizedString("profile_favourites_products_tab", comment: ""), forState: .Normal)
        
        noFavouritesLabel.text = NSLocalizedString("profile_no_products", comment: "")
        
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
        self.favouriteCollectionView.autoresizingMask = UIViewAutoresizing.FlexibleHeight // | UIViewAutoresizing.FlexibleWidth
        self.favouriteCollectionView.alwaysBounceVertical = true
        self.favouriteCollectionView.collectionViewLayout = layout
        
        // Add bottom inset (tabbar) if tabbar visible
        let bottomInset: CGFloat
        if let tabBarCtl = self.tabBarController {
            bottomInset = tabBarCtl.tabBar.hidden ? 0 : tabBarCtl.tabBar.frame.height
        }
        else {
            bottomInset = 0
        }
        favouriteCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
        sellingProductListView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
        soldProductListView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
        
        // register ProductCell
        let cellNib = UINib(nibName: "ProductCell", bundle: nil)
        favouriteCollectionView.registerNib(cellNib, forCellWithReuseIdentifier: "ProductCell")
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if shouldReload {
            // UX/UI and Appearance.
            setLetGoNavigationBarStyle(title: "")
            
            sellingProductListView.hidden = true
            soldProductListView.hidden = true
            favouriteCollectionView.hidden = true
            activityIndicator.startAnimating()
            
            // load
            isSellProductsEmpty = true
            isSoldProductsEmpty = true
            favProducts = []
            
            // reset UI
            sellingProductListView.delegate = self
            sellingProductListView.user = user
            sellingProductListView.type = .Selling
            soldProductListView.delegate = self
            soldProductListView.user = user
            soldProductListView.type = .Sold
            
            favouriteCollectionView.reloadSections(NSIndexSet(index: 0))
            
            
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
            if user.objectId == MyUserManager.sharedInstance.myUser()?.objectId {
                userLocationLabel.text = MyUserManager.sharedInstance.profileLocationInfo ?? ""
            }
            else {
                userLocationLabel.text = user.postalAddress.city ?? ""
            }
            
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
        let vc = NewSellProductViewController()
        let navCtl = UINavigationController(rootViewController: vc)
        presentViewController(navCtl, animated: true, completion: nil)
    }
    
    @IBAction func startSearchingNow(sender: AnyObject) {
        if let tabBarCtl = tabBarController as? TabBarController {
            tabBarCtl.switchToTab(.Home)
        }
    }
    
    // MARK: - ProductListViewDataDelegate
    
    func productListView(productListView: ProductListView, didStartRetrievingProductsPage page: UInt) {
    }
    
    
    
    func productListView(productListView: ProductListView, didFailRetrievingProductsPage page: UInt, error: ProductsRetrieveServiceError) {
    }
    
    func productListView(productListView: ProductListView, didFailRetrievingUserProductsPage page: UInt, error: ProductsRetrieveServiceError) {
        
        if productListView == sellingProductListView {
            isSellProductsEmpty = productListView.isEmpty
            loadingSellProducts = false
            
            retrievalFinishedForProductsAtTab(.ProductImSelling)
        }
        else if productListView == soldProductListView {
            isSoldProductsEmpty = productListView.isEmpty
            loadingSoldProducts = false
            
            retrievalFinishedForProductsAtTab(.ProductISold)
        }
    }
    
    func productListView(productListView: ProductListView, didSucceedRetrievingProductsPage page: UInt) {
        
        if productListView == sellingProductListView {
            isSellProductsEmpty = productListView.isEmpty
            loadingSellProducts = false
            
            retrievalFinishedForProductsAtTab(.ProductImSelling)
        }
        else if productListView == soldProductListView {
            isSoldProductsEmpty = productListView.isEmpty
            loadingSoldProducts = false
            
            retrievalFinishedForProductsAtTab(.ProductISold)
        }
        else if productListView == soldProductListView {
            isSoldProductsEmpty = productListView.isEmpty
            loadingSoldProducts = false
            
            retrievalFinishedForProductsAtTab(.ProductISold)
        }
        
    }
    
    func productListView(productListView: ProductListView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let productVM = productListView.productViewModelForProductAtIndex(indexPath.row)
        let vc = ProductViewController(viewModel: productVM)
        // TODO: @ahl: Delegate stuff!
//        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
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
        return favProducts.count
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
        // TODO: VM should be provided by this VC's VM
        if let product = self.productAtIndexPath(indexPath) {
            let productVM = ProductViewModel(product: product, tracker: TrackerProxy.sharedInstance)
            let vc = ProductViewController(viewModel: productVM)
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
        youDontHaveTitleLabel.hidden = true
        
        switch selectedTab {
        case .ProductImSelling:
            sellingProductListView.hidden = false
            soldProductListView.hidden = true
            noFavouritesLabel.hidden = true
            favouriteCollectionView.hidden = true
            break
        case .ProductISold:
            sellingProductListView.hidden = true
            soldProductListView.hidden = false
            noFavouritesLabel.hidden = true
            favouriteCollectionView.hidden = true
            break
        case .ProductFavourite:
            sellingProductListView.hidden = true
            soldProductListView.hidden = true
            
            if favProducts.isEmpty {
                noFavouritesLabel.hidden = false
                favouriteCollectionView.hidden = true
            }
            else {
                noFavouritesLabel.hidden = true
                favouriteCollectionView.hidden = false
            }
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
                loadingSellProducts = true
                sellingProductListView.refresh()
                
            case .ProductISold:
                loadingSoldProducts = true
                soldProductListView.refresh()
            case .ProductFavourite:

                // Retrieve the products
                loadingFavProducts = true
                
                productsFavouriteRetrieveService.retrieveFavouriteProducts(user) { [weak self] (myResult: Result<ProductsFavouriteResponse, ProductsFavouriteRetrieveServiceError>)  in
                    
                    if let strongSelf = self {
                        if let actualResult = myResult.value {
                            // Success
                            strongSelf.favProducts = actualResult.products as! [LGProduct]
                        }
                        else {
                            // Failure
                            if let actualError = myResult.error {
                                println(actualError)
                                //                                result?(Result<ProductsFavouriteResponse, ProductsFavouriteRetrieveServiceError>.failure(actualError))
                            }
                        }
                        
                        strongSelf.loadingFavProducts = false
                        strongSelf.favouriteCollectionView.reloadSections(NSIndexSet(index: 0))
                        strongSelf.retrievalFinishedForProductsAtTab(tab)
                        
                    }
                }
            }
        }
        else {
            retrievalFinishedForProductsAtTab(tab)
        }
    }
    
    func retrieveFavouriteProducts(user: User, result: ProductsFavouriteRetrieveServiceResult?) {
        
        productsFavouriteRetrieveService.retrieveFavouriteProducts(user, result: result)
    }
    
    
    func retrievalFinishedForProductsAtTab(tab: ProfileTab) {
        // If any tab is loading, then quit this function
        if loadingSellProducts || loadingSoldProducts || loadingFavProducts {
            return
        }
        
        activityIndicator.stopAnimating()
        
        // If the 3 tabs are empty then display update UI with "no products available"
        if isSellProductsEmpty && isSoldProductsEmpty && favProducts.isEmpty {
            
            youDontHaveTitleLabel.hidden = false
            
            sellButton.hidden = true
            soldButton.hidden = true
            favoriteButton.hidden = true
            
            favouriteCollectionView.hidden = true
            noFavouritesLabel.hidden = true
            
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
        // Else, update the UI
        else {
            favouriteCollectionView.hidden = false
            
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
        return favProducts[row]
    }
}
