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
        layout.sectionInset = UIEdgeInsets(top: Metrics.shortMargin,
                                           left: Metrics.shortMargin,
                                           bottom: Metrics.shortMargin,
                                           right: Metrics.shortMargin)
        layout.minimumInteritemSpacing = Metrics.collectionItemSpacing
        layout.minimumLineSpacing = Metrics.collectionItemSpacing
        layout.itemSize = TourCategoriesCollectionViewCell.cellSize()
        
        self.categories = categories
        super.init(frame: frame, collectionViewLayout: layout)
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
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let categorySelected = categories[indexPath.row]
        guard let index = categoriesSelected.value.index(where: { $0 == categorySelected }) else { return }
        categoriesSelected.value.remove(at: index)
    }
    
    
    // MARK: - Private methods
    
    private func setup() {
        dataSource = self
        delegate = self
        scrollsToTop = false
        showsHorizontalScrollIndicator = false
        allowsMultipleSelection = true
        
        backgroundColor = UIColor.clear
        
        register(TourCategoriesCollectionViewCell.self, forCellWithReuseIdentifier: TourCategoriesCollectionViewCell.reuseIdentifier)
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = UICollectionViewScrollDirection.vertical
        }
    }
    
    private func setAccessibilityIds() {
        accessibilityId = .filterTagsCollectionView
    }
}
