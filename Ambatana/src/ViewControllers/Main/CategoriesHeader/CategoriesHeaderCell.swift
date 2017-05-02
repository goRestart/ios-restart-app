//
//  CategoryHeaderCell.swift
//  LetGo
//
//  Created by Juan Iglesias on 28/04/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit
import LGCoreKit

protocol CategoriesHeaderCellDelegate : class {
    func categoryCellClicked(_ categoriesHeaderCell: CategoriesHeaderCell)
}

class CategoriesHeaderCell: UICollectionViewCell {
    
    static let reuseIdentifier = "CategoriesHeaderCell"
    
    var categoryIcon: UIImageView = UIImageView()
    var categoryTitle: UILabel = UILabel()
    var categoryNewLabel: UILabel = UILabel()
    var shouldShowCategoryNewBadge: Bool = false
    
    weak var delegate : CategoriesHeaderCellDelegate?
    
    
    // MARK: - Static methods
    
    static func cellSize() -> CGSize {
        return CGSize(width: 90, height: 120)
    }

    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        categoryIcon.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        categoryIcon.contentMode = .scaleAspectFit
        contentView.addSubview(categoryIcon)
        contentView.addSubview(categoryTitle)
        contentView.addSubview(categoryNewLabel)
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
    
    
    // MARK: - Private methods
    
    private func setupUI() {
        categoryTitle.translatesAutoresizingMaskIntoConstraints = false
        categoryNewLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryIcon.translatesAutoresizingMaskIntoConstraints = false
        contentView.layer.borderColor = UIColor.lineGray.cgColor
        contentView.layer.borderWidth = LGUIKitConstants.onePixelSize
        contentView.layer.cornerRadius = 4.0
        contentView.layer.backgroundColor = UIColor.white.cgColor
        
        categoryIcon.layout(with: contentView).top(by: 20).left(by: 10).right(by: 10)
        
        categoryTitle.layout(with: categoryIcon).centerX().below(by: 10)
        categoryTitle.layout().height(30)
        
        categoryNewLabel.layout().height(30)
        categoryNewLabel.layout(with: categoryIcon).top()
        
        categoryNewLabel.text = shouldShowCategoryNewBadge ? LGLocalizedString.commonNew : ""
        
    }
    
    private func resetUI() {
        self.categoryTitle.text = ""
        self.categoryNewLabel.text = ""
        self.categoryIcon.image = nil
        self.shouldShowCategoryNewBadge = false
    }
    
    private func setAccessibilityIds() {
        self.accessibilityId = .filterTagCell
        categoryIcon.accessibilityId = .categoriesHeaderCellCategoryIcon
        categoryTitle.accessibilityId = .categoriesHeaderCellCategoryTitle
    }
}
