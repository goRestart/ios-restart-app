//
//  CategoryHeaderCollectionViewController.swift
//  LetGo
//
//  Created by Juan Iglesias on 28/04/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import RxSwift
import LGCoreKit

struct CategoryHeaderInfo {
    let listingCategory: ListingCategory
    let position: Int
    let name: String
}

class CategoriesHeaderCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private var categories: [ListingCategory]
    var categorySelected = Variable<CategoryHeaderInfo?>(nil)
    
    static let viewHeight: CGFloat = CategoryHeaderCell.cellSize().height
    
    init(categories: [ListingCategory], frame: CGRect) {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.itemSize = CategoryHeaderCell.cellSize()
        self.categories = categories
        super.init(frame: frame, collectionViewLayout: layout)
        //Setup
        setup()
        setAccessibilityIds()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - UICollectionViewDelegate & DataSource methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CategoryHeaderCell.cellSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryHeaderCell.reuseIdentifier, for: indexPath) as? CategoryHeaderCell else { return UICollectionViewCell() }
        cell.categoryTitle.text = categories[indexPath.row].nameInFeed.uppercase
        cell.categoryIcon.image = categories[indexPath.row].imageInFeed
        if categories[indexPath.row].isCar {
            cell.addNewTagToCategory()
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let listingCategory = categories[indexPath.row]
        categorySelected.value = CategoryHeaderInfo(listingCategory: listingCategory,
                                                    position: indexPath.row + 1,
                                                    name: listingCategory.nameInFeed)
    }

    
    // MARK: - Private methods
    
    private func setup() {
        dataSource = self
        delegate = self
        scrollsToTop = false
        showsHorizontalScrollIndicator = false
        
        backgroundColor = UIColor.clear
        
        // CollectionView cells
        register(CategoryHeaderCell.self, forCellWithReuseIdentifier: CategoryHeaderCell.reuseIdentifier)
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        }
    }
    
    private func setAccessibilityIds() {
        accessibilityId = .filterTagsCollectionView
    }
}
