//
//  CategoryHeaderCollectionViewController.swift
//  LetGo
//
//  Created by Juan Iglesias on 28/04/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit


class CategoriesHeaderCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, CategoriesHeaderCellDelegate {
    
    let collectionView: UICollectionView?
    var categories: [ListingCategory]
    
    init(categories: [ListingCategory], frame: CGRect) {
        self.collectionView = UICollectionView()
        self.categories = categories
        //Setup collectionView layout here and pass with init
        let layout = UICollectionViewLayout()
        super.init(frame: frame, collectionViewLayout: layout)
        
        //Setup
        setup()
        setAccessibilityIds()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    // MARK: - Public methods
    func updateCategories(_ newCategories: [ListingCategory]) {
        categories = newCategories
        reloadData()
    }
    
    // MARK: - UICollectionViewDelegate & DataSource methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CategoriesHeaderCell.cellSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoriesHeaderCell", for: indexPath) as? CategoriesHeaderCell else { return UICollectionViewCell() }
        cell.delegate = self
        cell.categoryNewLabel.text = categories[indexPath.row].nameInFeed
        cell.categoryIcon.image = categories[indexPath.row].imageInFeed
        cell.shouldShowCategoryNewBadge = categories[indexPath.row].isCar
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    // MARK: CategoriesHeaderCellDelegate - 
    func categoryCellClicked(_ categoriesHeaderCell: CategoriesHeaderCell) {
        print("category has been pressed")
        // TODO: forward the category pressed.
    }
    
    
    // MARK: - Private methods
    
    private func setup() {
        dataSource = self
        delegate = self
        scrollsToTop = false
        
        // CollectionView cells
        register(CategoriesHeaderCell.self, forCellWithReuseIdentifier: CategoriesHeaderCell.reuseIdentifier)
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        }
    }
    
    private func setAccessibilityIds() {
        accessibilityId = .filterTagsCollectionView
    }
}
