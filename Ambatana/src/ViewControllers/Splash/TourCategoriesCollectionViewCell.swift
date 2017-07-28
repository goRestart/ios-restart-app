//
//  TourCategoriesCollectionViewCell.swift
//  LetGo
//
//  Created by Juan Iglesias on 28/07/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//



import UIKit
import LGCoreKit


class TourCategoriesCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "TourCategoriesCollectionViewCell"
    
    var categoryIcon: UIImageView = UIImageView()
    var categoryTitle: UILabel = UILabel()
    var selectedIcon: UIImageView = UIImageView()
    
    static func cellSize() -> CGSize {
        return CGSize(width: 110, height: 110)
    }
    
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        categoryIcon.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        categoryIcon.contentMode = .scaleAspectFit
        contentView.addSubview(categoryIcon)
        contentView.addSubview(categoryTitle)
        contentView.addSubview(selectedIcon)
        contentView.addSubviews([categoryIcon, categoryTitle, selectedIcon])
        self.setupUI()
        self.resetUI()
        self.setAccessibilityIds()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetUI()
    }
    
    // MARK: UI
    private func setupUI() {
        
        backgroundColor = UIColor.clear
        
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: [categoryTitle, categoryIcon, selectedIcon])
        
        categoryTitle.font = UIFont.boldSystemFont(ofSize: 15)
        
        categoryTitle.textColor = UIColor.grayDark
        
        categoryIcon.layout().height(110).width(110)
        categoryIcon.layout(with: contentView).fill()
        categoryTitle.layout(with: contentView).bottom(by: Metrics.margin).left().right()
        categoryTitle.numberOfLines = 0
        
        selectedIcon.layout(with: contentView).right().top()
        selectedIcon.layout().height(20).width(20)
    }
    
    private func resetUI() {
        categoryTitle.text = ""
        categoryIcon.image = nil
        selectedIcon.image = nil
    }
    
    private func setAccessibilityIds() {
        self.accessibilityId = .tourCategoriesCollectionViewCell
        categoryIcon.accessibilityId = .tourCategoriesCollectionViewCellSelectedIcon
        categoryTitle.accessibilityId = .tourCategoriesCollectionViewCellTitle
        selectedIcon.accessibilityId = .tourCategoriesCollectionViewCellSelectedIcon
    }
}

