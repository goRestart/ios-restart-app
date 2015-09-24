//
//  CategoriesViewController.swift
//  LetGo
//
//  Created by Ignacio Nieto Carvajal on 05/02/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import LGCoreKit
import Parse
import Result
import UIKit

private let kLetGoCategoryCellRealImageTag = 1
private let kLetGoCategoryCellGradientImageTag = 2
private let kLetGoCategoryCellNameTag = 3
private let kLetGoCategoriesCellFactor: CGFloat = 150.0 / 160.0

class CategoriesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
    // outlets & buttons
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var searchBar: UISearchBar!
    
    // data
    var categoriesManager: CategoriesManager
    var categories: [ProductCategory]
    var cellSize: CGSize = CGSize(width: 160.0, height: 150.0)
    var lastContentOffset: CGFloat = 0.0
    
    init() {
        categoriesManager = CategoriesManager.sharedInstance
        categories = []
        super.init(nibName: "CategoriesViewController", bundle: nil)
        
        hidesBottomBarWhenPushed = false
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // UX/UI & Appearance
        setLetGoNavigationBarStyle(title: NSLocalizedString("categories_title", comment: ""))
        
        // CollectionView
        let cellNib = UINib(nibName: "CategoryCell", bundle: nil)
        self.collectionView.registerNib(cellNib, forCellWithReuseIdentifier: "CategoryCell")
        
        // cell size
        let cellWidth = UIScreen.mainScreen().bounds.size.width * 0.50
        let cellHeight = cellWidth * kLetGoCategoriesCellFactor
        cellSize = CGSizeMake(cellWidth, cellHeight)
        
        // Data
        var myResult: CategoriesRetrieveServiceResult = { (result: Result<[ProductCategory], CategoriesRetrieveServiceServiceError>) in
            if let categories = result.value {
                self.categories = categories
                self.collectionView.reloadData()
            }
        }
        categoriesManager.retrieveCategoriesWithResult(myResult)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

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
                // TODO: Refactor pending!
                let searchVM = MainProductsViewModel(searchString: searchString)
                let searchVC = MainProductsViewController(viewModel: searchVM)
                self.navigationController?.pushViewController(searchVC, animated: true)
            }
        }
        
    }
    
    // MARK: - Navigation bar item actions
    
    func searchProducts() {
        showSearchBarAnimated(true, delegate: self)
    }
    
    // MARK: - Button actions
    
    @IBAction func sellNewProduct(sender: AnyObject) {
        let vc = NewSellProductViewController()
        let navCtl = UINavigationController(rootViewController: vc)
        presentViewController(navCtl, animated: true, completion: nil)
    }

    // MARK: - UICollectionViewDelegate & DataSource methods
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return cellSize
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CategoryCell", forIndexPath: indexPath) as! UICollectionViewCell
        
        // configure cell
        let category = categories[indexPath.row]
        
        // name
        if let nameLabel = cell.viewWithTag(kLetGoCategoryCellNameTag) as? UILabel {
            nameLabel.text = category.name()
        }
        
        // image
        if let categoryImage = cell.viewWithTag(kLetGoCategoryCellRealImageTag) as? UIImageView {
            categoryImage.image = category.image()
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let category = categories[indexPath.row]
        
        // TODO: Refactor pending!
        let categoriesVM = MainProductsViewModel(category: category)
        let categoriesVC = MainProductsViewController(viewModel: categoriesVM)
        self.navigationController?.pushViewController(categoriesVC, animated: true)
    }
}
