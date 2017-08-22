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
    private static let cellSide: CGFloat = 110
    var categoryIcon: UIImageView = UIImageView()
    var categoryTitle: UILabel = UILabel()
    var selectedIcon: UIImageView = UIImageView()
    var gradientView: UIImageView = UIImageView()
    var selectedBackground: UIImageView = UIImageView()
    
    static func cellSize() -> CGSize {
        return CGSize(width: TourCategoriesCollectionViewCell.cellSide, height: TourCategoriesCollectionViewCell.cellSide)
    }
    
    override var isSelected: Bool {
        didSet {
            selectedIcon.isHidden = !isSelected
            selectedBackground.isHidden = !isSelected
        }
    }

    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        categoryIcon.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        categoryIcon.contentMode = .scaleAspectFit
        contentView.addSubviews([categoryIcon, gradientView, selectedBackground, categoryTitle, selectedIcon])
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
        
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: [categoryTitle, gradientView, selectedBackground, categoryIcon, selectedIcon])
        
        categoryTitle.font = UIFont.boldSystemFont(ofSize: 15)
        categoryTitle.textColor = UIColor.white
        
        categoryIcon.layout().height(TourCategoriesCollectionViewCell.cellSize().height).width(TourCategoriesCollectionViewCell.cellSize().width)
        categoryIcon.layout(with: contentView).fill()
        layoutIfNeeded()
        contentView.setRoundedCorners([.allCorners], cornerRadius: 10)
        categoryTitle.layout(with: contentView).bottom(by: -Metrics.shortMargin).left(by: Metrics.shortMargin).right()
        categoryTitle.numberOfLines = 0
        
        selectedIcon.layout(with: contentView).left(by: Metrics.shortMargin).top(by: Metrics.shortMargin)
        selectedIcon.layout().height(20).width(20)
        
        gradientView.layout(with: contentView).fill()
        gradientView.image = #imageLiteral(resourceName: "gradient_onboarding_categories")
        
        selectedBackground.layout(with: contentView).fill()
        selectedBackground.image = #imageLiteral(resourceName: "onboarding_category_selected")
    }
    
    private func resetUI() {
        categoryTitle.text = ""
        categoryIcon.image = nil
        selectedIcon.image = #imageLiteral(resourceName: "category_selected")
        selectedIcon.isHidden = true
        selectedBackground.isHidden = true
    }
    
    
    private func setAccessibilityIds() {
        self.accessibilityId = .tourCategoriesCollectionViewCell
        categoryIcon.accessibilityId = .tourCategoriesCollectionViewCellSelectedIcon
        categoryTitle.accessibilityId = .tourCategoriesCollectionViewCellTitle
        selectedIcon.accessibilityId = .tourCategoriesCollectionViewCellSelectedIcon
    }
}

