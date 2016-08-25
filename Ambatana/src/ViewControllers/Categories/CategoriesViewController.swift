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

class CategoriesViewController: BaseViewController, CategoriesViewModelDelegate, UICollectionViewDataSource, UICollectionViewDelegate, ScrollableToTop {

    // outlets & buttons
    @IBOutlet weak var collectionView: UICollectionView!

    // data
    private var cellSize: CGSize = CGSize(width: 160.0, height: 150.0)
    private var lastContentOffset: CGFloat = 0.0
    
    // ViewModel
    private var viewModel : CategoriesViewModel!
    
    // MARK: - Lifecycle
    
    convenience init() {
        self.init(viewModel: CategoriesViewModel(), nibName: "CategoriesViewController")
    }
    
    convenience init(viewModel: CategoriesViewModel) {
        self.init(viewModel: viewModel, nibName: "CategoriesViewController")
    }
    
    required init(viewModel: CategoriesViewModel, nibName nibNameOrNil: String?) {
        super.init(viewModel: viewModel, nibName: nibNameOrNil)
        self.viewModel = viewModel
        self.viewModel.delegate = self
        
        hidesBottomBarWhenPushed = false
        floatingSellButtonHidden = false
        hasTabBar = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // UX/UI & Appearance
        setNavBarTitle(LGLocalizedString.categoriesTitle)

        // CollectionView
        let cellNib = UINib(nibName: "CategoryCell", bundle: nil)
        self.collectionView.registerNib(cellNib, forCellWithReuseIdentifier: "CategoryCell")
        
        // cell size
        let cellWidth = UIScreen.mainScreen().bounds.size.width * 0.50
        let cellHeight = cellWidth * Constants.categoriesCellFactor
        cellSize = CGSizeMake(cellWidth, cellHeight)
        
        viewModel.retrieveCategories()
        setupAccessibilityIds()
    }


    // MARK: - ScrollableToTop

    func scrollToTop() {
        guard let collectionView = collectionView else { return }
        let point = CGPoint(x: -collectionView.contentInset.left, y: -collectionView.contentInset.top)
        collectionView.setContentOffset(point, animated: true)
    }


    // MARK: - CategoriesViewModelDelegate
    
    func vmDidUpdate() {
        self.collectionView.reloadData()
    }
    
    
    // MARK: - UICollectionViewDelegate & DataSource methods
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return cellSize
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numOfCategories
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CategoryCell", forIndexPath: indexPath) as? CategoryCell else { return UICollectionViewCell() }
        
        // configure cell
        guard let category = viewModel.categoryAtIndex(indexPath.row) else {
            return cell
        }
        
        cell.titleLabel.text = category.name
        cell.imageView.image = category.image
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        guard let productsViewModel = viewModel.productsViewModelForCategoryAtIndex(indexPath.row) else {
            return
        }
        
        let categoriesVC = MainProductsViewController(viewModel: productsViewModel)
        self.navigationController?.pushViewController(categoriesVC, animated: true)
    }

    private func setupAccessibilityIds() {
        collectionView.accessibilityId = .CategoriesCollectionView
    }
}
