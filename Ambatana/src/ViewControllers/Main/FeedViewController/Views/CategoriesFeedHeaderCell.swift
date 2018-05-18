//
//  CategoriesFeedHeaderCell.swift
//  LetGo
//
//  Created by Haiyan Ma on 25/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import UIKit

final class CategoriesFeedHeaderCell: UICollectionReusableView, ReusableCell {
    
    private let categoryView = CategoriesHeaderCollectionView()

    static let viewHeight: CGFloat = CategoriesHeaderCollectionView.viewHeight

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubviewForAutoLayout(categoryView)
        categoryView.layout(with: self).fill()
    }
    
    func configure(with feedPresenter: CategoriesHeaderCellPresentable) {
        categoryView.configure(with: feedPresenter.categories,
                               categoryHighlighted: feedPresenter.categoryHighlighted,
                               isMostSearchedItemsEnabled: feedPresenter.isMostSearchedItemsEnabled)
    }
}

