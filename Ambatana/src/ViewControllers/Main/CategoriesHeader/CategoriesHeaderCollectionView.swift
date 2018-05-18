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
    let categoryHeaderElement: CategoryHeaderElement
    let position: Int
    let name: String
}

protocol CategoriesHeaderCollectionViewDelegate: class {
    func openTaxonomyList()
    func openMostSearchedItems()
}

final class CategoriesHeaderCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    fileprivate var categoryHeaderElements: [CategoryHeaderElement] = []
    fileprivate var categoryHighlighted: CategoryHeaderElement?
    
    weak var delegateCategoryHeader: CategoriesHeaderCollectionViewDelegate?
    
    fileprivate var isShowingSuperKeywords: Bool {
        return categoryHeaderElements.first?.isSuperKeyword ?? false
    }
    
    var categorySelected = Variable<CategoryHeaderInfo?>(nil)
    
    static let viewHeight: CGFloat = CategoryHeaderCell.cellSize().height
    
    init() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.itemSize = CategoryHeaderCell.cellSize()
        super.init(frame: .zero, collectionViewLayout: layout)
        setup()
        setAccessibilityIds()
    }
    
    func configure(with categories: [CategoryHeaderElement], categoryHighlighted: CategoryHeaderElement, isMostSearchedItemsEnabled: Bool) {
        self.categoryHeaderElements = categories
        self.categoryHighlighted = categoryHighlighted
        if isShowingSuperKeywords {
            categoryHeaderElements.append(CategoryHeaderElement.showMore)
        }
        if isMostSearchedItemsEnabled {
            categoryHeaderElements.insert(CategoryHeaderElement.mostSearchedItems, at: 0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - UICollectionViewDelegate & DataSource methods
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CategoryHeaderCell.cellSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryHeaderElements.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryHeaderCell.reuseIdentifier, for: indexPath) as? CategoryHeaderCell else { return UICollectionViewCell() }
            let categoryHeaderElement = categoryHeaderElements[indexPath.row]
            cell.categoryTitle.text = categoryHeaderElement.name.localizedUppercase
            cell.categoryTitle.addKern(value: -0.30)
            switch categoryHeaderElement {
            case .listingCategory, .showMore, .mostSearchedItems:
                cell.categoryIcon.image = categoryHeaderElement.imageIcon
            case .superKeyword, .superKeywordGroup:
                if let url = categoryHeaderElement.imageIconURL {
                    cell.categoryIcon.lg_setImageWithURL(url)
                }
            }
            if let categoryHighlighted = self.categoryHighlighted, categoryHeaderElement == categoryHighlighted {
                cell.addNewTagToCategory()
            }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
        let categoryHeaderElement = categoryHeaderElements[indexPath.row]
        switch categoryHeaderElement {
        case .showMore:
            delegateCategoryHeader?.openTaxonomyList()
        case .mostSearchedItems:
            delegateCategoryHeader?.openMostSearchedItems()
        case .listingCategory, .superKeyword, .superKeywordGroup:
            categorySelected.value = CategoryHeaderInfo(categoryHeaderElement: categoryHeaderElement,
                                                        position: indexPath.row + 1,
                                                        name: categoryHeaderElement.name)
        }
    }

    
    // MARK: - Private methods
    
    private func setup() {
        dataSource = self
        delegate = self
        scrollsToTop = false
        showsHorizontalScrollIndicator = false
        
        backgroundColor = .clear
        
        // CollectionView cells
        register(CategoryHeaderCell.self, forCellWithReuseIdentifier: CategoryHeaderCell.reuseIdentifier)
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        }
    }
    
    private func setAccessibilityIds() {
        set(accessibilityId: .filterTagsCollectionView)
    }
}
