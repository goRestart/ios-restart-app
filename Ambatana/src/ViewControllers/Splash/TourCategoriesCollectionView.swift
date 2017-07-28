//
//  TourCategoriesCollectionView.swift
//  LetGo
//
//  Created by Juan Iglesias on 28/07/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import RxSwift
import LGCoreKit

class TourCategoriesCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private var categories: [TaxonomyChild]
    var categoriesSelected = Variable<[TaxonomyChild]>([])
    
    static let viewHeight: CGFloat = TourCategoriesCollectionViewCell.cellSize().height
    
    init(categories: [TaxonomyChild], frame: CGRect) {
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
        return TourCategoriesCollectionViewCell.cellSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TourCategoriesCollectionViewCell.reuseIdentifier, for: indexPath) as? TourCategoriesCollectionViewCell else { return UICollectionViewCell() }
        cell.categoryTitle.text = categories[indexPath.row].name
        if let url = categories[indexPath.row].image {
            cell.categoryIcon.lg_setImageWithURL(url)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let categorySelected = categories[indexPath.row]
        categoriesSelected.value.append(categorySelected)
    }
    
    
    // MARK: - Private methods
    
    private func setup() {
        dataSource = self
        delegate = self
        scrollsToTop = false
        showsHorizontalScrollIndicator = false
        
        backgroundColor = UIColor.clear
        
        // CollectionView cells
        register(TourCategoriesCollectionViewCell.self, forCellWithReuseIdentifier: TourCategoriesCollectionViewCell.reuseIdentifier)
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        }
    }
    
    private func setAccessibilityIds() {
        accessibilityId = .filterTagsCollectionView
    }
}
