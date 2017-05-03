//
//  CategoryHeaderCollectionViewController.swift
//  LetGo
//
//  Created by Juan Iglesias on 28/04/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit


class CategoriesHeaderCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, CategoriesHeaderCellDelegate {
    
    var categories: [ListingCategory]
    
     static let viewHeight: CGFloat = 110
    
    init(categories: [ListingCategory], frame: CGRect) {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.itemSize = CategoriesHeaderCell.cellSize()
        self.categories = categories
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
        cell.categoryTitle.text = categories[indexPath.row].nameInFeed.uppercase
        cell.categoryIcon.image = categories[indexPath.row].imageInFeed
        if  categories[indexPath.row].isCar {
            cell.addNewTagToCategory()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        print("category has been pressed")
        return true
    }

    
    // MARK: - Private methods
    
    private func setup() {
        dataSource = self
        delegate = self
        scrollsToTop = false
        showsHorizontalScrollIndicator = false
        
        backgroundColor = UIColor.clear
        
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
