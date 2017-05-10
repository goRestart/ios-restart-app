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
    private var viewModel : CategoriesViewModel
    
    // MARK: - Lifecycle
    
    convenience init() {
        self.init(viewModel: CategoriesViewModel(), nibName: "CategoriesViewController")
    }
    
    convenience init(viewModel: CategoriesViewModel) {
        self.init(viewModel: viewModel, nibName: "CategoriesViewController")
    }
    
    required init(viewModel: CategoriesViewModel, nibName nibNameOrNil: String?) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nibNameOrNil)
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
        self.collectionView.register(cellNib, forCellWithReuseIdentifier: "CategoryCell")
        
        // cell size
        let cellWidth = UIScreen.main.bounds.size.width * 0.50
        let cellHeight = cellWidth * Constants.categoriesCellFactor
        cellSize = CGSize(width: cellWidth, height: cellHeight)
        
        viewModel.retrieveCategories()
        setAccessibilityIds()
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
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numOfCategories
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as? CategoryCell else { return UICollectionViewCell() }
        
        // configure cell
        guard let category = viewModel.categoryAtIndex(indexPath.row) else {
            return cell
        }
        
        cell.titleLabel.text = category.name
        // This code is not used anymore. We should remove this whole class.
        cell.imageView.image = category.icon
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectItemAtIndex(indexPath.row)
    }

    private func setAccessibilityIds() {
        collectionView.accessibilityId = .categoriesCollectionView
    }
}
