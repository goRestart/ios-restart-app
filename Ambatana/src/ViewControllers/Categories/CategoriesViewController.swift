//
//  CategoriesViewController.swift
//  LetGo
//
//  Created by Dídac on 22/10/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import Result
import UIKit

public class CategoriesViewController: BaseViewController, CategoriesViewModelDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    // outlets & buttons
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var searchBar: UISearchBar!
    
    // data
    var cellSize: CGSize = CGSize(width: 160.0, height: 150.0)
    var lastContentOffset: CGFloat = 0.0
    
    // ViewModel
    private var viewModel : CategoriesViewModel!
    
    // MARK: - Lifecycle
    
    public convenience init() {
        self.init(viewModel: CategoriesViewModel(), nibName: "CategoriesViewController")
    }
    
    public convenience init(viewModel: CategoriesViewModel) {
        self.init(viewModel: viewModel, nibName: "CategoriesViewController")
    }
    
    public required init(viewModel: CategoriesViewModel, nibName nibNameOrNil: String?) {
        super.init(viewModel: viewModel, nibName: nibNameOrNil)
        self.viewModel = viewModel
        self.viewModel.delegate = self
        
        hidesBottomBarWhenPushed = false
        floatingSellButtonHidden = false
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        
        // UX/UI & Appearance
        setLetGoNavigationBarStyle(NSLocalizedString("categories_title", comment: ""))
        
        // CollectionView
        let cellNib = UINib(nibName: "CategoryCell", bundle: nil)
        self.collectionView.registerNib(cellNib, forCellWithReuseIdentifier: "CategoryCell")
        
        // cell size
        let cellWidth = UIScreen.mainScreen().bounds.size.width * 0.50
        let cellHeight = cellWidth * Constants.categoriesCellFactor
        cellSize = CGSizeMake(cellWidth, cellHeight)
        
        viewModel.retrieveCategories()
        
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - CategoriesViewModelDelegate
    
    public func viewModelDidUpdate(viewModel: CategoriesViewModel) {
        self.collectionView.reloadData()
    }
    
    
    // MARK: - UICollectionViewDelegate & DataSource methods
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return cellSize
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numOfCategories
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CategoryCell", forIndexPath: indexPath) as! CategoryCell
        
        // configure cell
        guard let category = viewModel.categoryAtIndex(indexPath.row) else {
            return cell
        }
        
        cell.titleLabel.text = category.name()
        cell.imageView.image = category.image()
        
        return cell
    }
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        guard let productsViewModel = viewModel.productsViewModelForCategoryAtIndex(indexPath.row) else {
            return
        }
        
        let categoriesVC = MainProductsViewController(viewModel: productsViewModel)
        self.navigationController?.pushViewController(categoriesVC, animated: true)
    }
    
}
